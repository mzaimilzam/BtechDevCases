const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
require('dotenv').config();

const app = express();
const port = process.env.API_PORT || 8080;

// Middleware
app.use(cors());
app.use(express.json());

// Database connection pool
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'healthy' });
});

// JWT verification middleware
const verifyToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return res.status(401).json({ message: 'No token provided' });
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ message: 'Invalid token' });
        }
        req.user = user;
        next();
    });
};

// Generate tokens
const generateTokens = (userId, email) => {
    const accessToken = jwt.sign(
        { userId, email },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRY + 's' }
    );

    const refreshToken = jwt.sign(
        { userId, email },
        process.env.JWT_SECRET,
        { expiresIn: process.env.REFRESH_TOKEN_EXPIRY + 's' }
    );

    return { accessToken, refreshToken, expiresIn: parseInt(process.env.JWT_EXPIRY) };
};

// ============ AUTH ENDPOINTS ============

// Register endpoint
app.post('/auth/register', async (req, res) => {
    try {
        const { email, password, firstName, lastName } = req.body;

        if (!email || !password) {
            return res.status(400).json({ message: 'Email and password are required' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const userId = uuidv4();

        const result = await pool.query(
            'INSERT INTO users (id, email, password_hash, first_name, last_name) VALUES ($1, $2, $3, $4, $5) RETURNING id, email, first_name, last_name',
            [userId, email, hashedPassword, firstName || '', lastName || '']
        );

        // Create wallet for new user
        await pool.query(
            'INSERT INTO wallets (user_id, balance, currency) VALUES ($1, $2, $3)',
            [userId, 0.00, 'USD']
        );

        const user = result.rows[0];
        const tokens = generateTokens(user.id, user.email);

        res.status(201).json({
            message: 'User registered successfully',
            user,
            ...tokens
        });
    } catch (error) {
        console.error('Registration error:', error);
        if (error.code === '23505') {
            return res.status(409).json({ message: 'Email already exists' });
        }
        res.status(500).json({ message: 'Internal server error' });
    }
});

// Login endpoint
app.post('/auth/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ message: 'Email and password are required' });
        }

        const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);

        if (result.rows.length === 0) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        const user = result.rows[0];
        const isPasswordValid = await bcrypt.compare(password, user.password_hash);

        if (!isPasswordValid) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        const tokens = generateTokens(user.id, user.email);

        res.json({
            message: 'Login successful',
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
            expiresIn: tokens.expiresIn,
            user: {
                id: user.id,
                email: user.email,
                firstName: user.first_name,
                lastName: user.last_name
            }
        });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// Refresh token endpoint
app.post('/auth/refresh', async (req, res) => {
    try {
        const { refreshToken } = req.body;

        if (!refreshToken) {
            return res.status(400).json({ message: 'Refresh token is required' });
        }

        jwt.verify(refreshToken, process.env.JWT_SECRET, (err, user) => {
            if (err) {
                return res.status(401).json({ message: 'Invalid or expired refresh token' });
            }

            // Generate new tokens
            const tokens = generateTokens(user.userId, user.email);

            res.json({
                message: 'Token refreshed successfully',
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken,
                expiresIn: tokens.expiresIn
            });
        });
    } catch (error) {
        console.error('Refresh token error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// Get current user endpoint
app.get('/auth/current-user', verifyToken, async (req, res) => {
    try {
        const result = await pool.query('SELECT id, email, first_name, last_name FROM users WHERE id = $1', [req.user.userId]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        const user = result.rows[0];
        res.json({
            user: {
                id: user.id,
                email: user.email,
                firstName: user.first_name,
                lastName: user.last_name
            }
        });
    } catch (error) {
        console.error('Get current user error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ============ WALLET ENDPOINTS ============

// Get wallet balance
app.get('/wallet/balance', verifyToken, async (req, res) => {
    try {
        const result = await pool.query('SELECT id, balance, currency FROM wallets WHERE user_id = $1', [req.user.userId]);

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Wallet not found' });
        }

        const wallet = result.rows[0];
        res.json({
            wallet: {
                id: wallet.id,
                balance: parseFloat(wallet.balance),
                currency: wallet.currency
            }
        });
    } catch (error) {
        console.error('Get balance error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// Transfer funds
app.post('/wallet/transfer', verifyToken, async (req, res) => {
    const client = await pool.connect();
    try {
        const { recipientEmail, amount } = req.body;

        if (!recipientEmail || !amount || amount <= 0) {
            return res.status(400).json({ message: 'Invalid recipient or amount' });
        }

        await client.query('BEGIN');

        // Get sender's wallet
        const senderWallet = await client.query('SELECT id, balance FROM wallets WHERE user_id = $1', [req.user.userId]);

        if (senderWallet.rows.length === 0) {
            await client.query('ROLLBACK');
            return res.status(404).json({ message: 'Wallet not found' });
        }

        if (parseFloat(senderWallet.rows[0].balance) < amount) {
            await client.query('ROLLBACK');
            return res.status(400).json({ message: 'Insufficient balance' });
        }

        // Get recipient user
        const recipientUser = await client.query('SELECT id FROM users WHERE email = $1', [recipientEmail]);

        if (recipientUser.rows.length === 0) {
            await client.query('ROLLBACK');
            return res.status(404).json({ message: 'Recipient not found' });
        }

        const recipientId = recipientUser.rows[0].id;

        // Get recipient's wallet
        const recipientWallet = await client.query('SELECT id FROM wallets WHERE user_id = $1', [recipientId]);

        if (recipientWallet.rows.length === 0) {
            await client.query('ROLLBACK');
            return res.status(404).json({ message: 'Recipient wallet not found' });
        }

        // Update sender balance
        await client.query('UPDATE wallets SET balance = balance - $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2', [amount, senderWallet.rows[0].id]);

        // Update recipient balance
        await client.query('UPDATE wallets SET balance = balance + $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2', [amount, recipientWallet.rows[0].id]);

        // Create transaction record
        const transactionId = uuidv4();
        await client.query(
            'INSERT INTO transactions (id, wallet_id, recipient_email, amount, transaction_type, status) VALUES ($1, $2, $3, $4, $5, $6)',
            [transactionId, senderWallet.rows[0].id, recipientEmail, amount, 'transfer', 'completed']
        );

        await client.query('COMMIT');

        res.status(200).json({
            message: 'Transfer successful',
            transaction: {
                id: transactionId,
                amount,
                recipientEmail,
                status: 'completed'
            }
        });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Transfer error:', error);
        res.status(500).json({ message: 'Internal server error' });
    } finally {
        client.release();
    }
});

// Get transaction history
app.get('/wallet/transactions', verifyToken, async (req, res) => {
    try {
        const limit = parseInt(req.query.limit) || 20;
        const offset = parseInt(req.query.offset) || 0;

        const result = await pool.query(
            'SELECT t.id, t.amount, t.recipient_email, t.note, t.status, t.created_at FROM transactions t INNER JOIN wallets w ON t.wallet_id = w.id WHERE w.user_id = $1 ORDER BY t.created_at DESC LIMIT $2 OFFSET $3',
            [req.user.userId, limit, offset]
        );

        const transactions = result.rows.map(t => ({
            id: t.id,
            amount: parseFloat(t.amount),
            recipient_email: t.recipient_email,
            note: t.note || '',
            status: t.status.toLowerCase(),
            timestamp: t.created_at.toISOString()
        }));

        res.json(transactions);
    } catch (error) {
        console.error('Get transactions error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Unhandled error:', err);
    res.status(500).json({ message: 'Internal server error' });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({ message: 'Endpoint not found' });
});

// Start server
app.listen(port, () => {
    console.log(`BUMA Wallet API running on http://localhost:${port}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM signal received: closing HTTP server');
    pool.end();
    process.exit(0);
});
