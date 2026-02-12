const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
require('dotenv').config();

const app = express();
const port = process.env.API_PORT || 8080;

// Validate required environment variables
const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRY = parseInt(process.env.JWT_EXPIRY || '900'); // 15 minutes default
const REFRESH_TOKEN_EXPIRY = parseInt(process.env.REFRESH_TOKEN_EXPIRY || '604800'); // 7 days default

if (!JWT_SECRET) {
    console.error('ERROR: JWT_SECRET is not set in environment variables');
    process.exit(1);
}

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

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) {
            console.error('JWT verification error:', err.message);
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
        JWT_SECRET,
        { expiresIn: JWT_EXPIRY }
    );

    const refreshToken = jwt.sign(
        { userId, email },
        JWT_SECRET,
        { expiresIn: REFRESH_TOKEN_EXPIRY }
    );

    return { accessToken, refreshToken, expiresIn: JWT_EXPIRY };
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

        jwt.verify(refreshToken, JWT_SECRET, (err, user) => {
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

// Transfer funds (Offline-First Pattern)
// Step 1: Create transaction with pending status (from mobile)
// Step 2: Sync transaction (from mobile or auto)
app.post('/wallet/transfer', verifyToken, async (req, res) => {
    try {
        const { recipientEmail, amount, note } = req.body;

        if (!recipientEmail || !amount || amount <= 0) {
            return res.status(400).json({ message: 'Invalid recipient or amount' });
        }

        // Get sender's wallet
        const senderWallet = await pool.query('SELECT id, balance FROM wallets WHERE user_id = $1', [req.user.userId]);

        if (senderWallet.rows.length === 0) {
            return res.status(404).json({ message: 'Wallet not found' });
        }

        // Get recipient user to verify they exist
        const recipientUser = await pool.query('SELECT id FROM users WHERE email = $1', [recipientEmail]);

        if (recipientUser.rows.length === 0) {
            return res.status(404).json({ message: 'Recipient not found' });
        }

        // Create transaction record with pending status
        // This represents the offline-first pattern: save locally first
        const transactionId = uuidv4();
        const now = new Date();

        const result = await pool.query(
            `INSERT INTO transactions 
             (id, wallet_id, user_id, recipient_email, amount, note, transaction_type, status, created_at, updated_at) 
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
             RETURNING id, amount, recipient_email, note, status, created_at`,
            [transactionId, senderWallet.rows[0].id, req.user.userId, recipientEmail, amount, note || '', 'transfer', 'pending', now, now]
        );

        const transaction = result.rows[0];

        res.status(201).json({
            message: 'Transaction created with pending status',
            transaction: {
                id: transaction.id,
                amount: parseFloat(transaction.amount),
                recipientEmail: transaction.recipient_email,
                note: transaction.note || '',
                status: transaction.status,
                timestamp: transaction.created_at.toISOString()
            }
        });
    } catch (error) {
        console.error('Transfer error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// Sync transaction with server (Execute the actual transfer)
app.put('/wallet/transaction/:id/sync', verifyToken, async (req, res) => {
    const client = await pool.connect();
    try {
        const transactionId = req.params.id;

        // Get transaction
        const transactionResult = await client.query(
            'SELECT * FROM transactions WHERE id = $1 AND user_id = $2',
            [transactionId, req.user.userId]
        );

        if (transactionResult.rows.length === 0) {
            return res.status(404).json({ message: 'Transaction not found' });
        }

        const transaction = transactionResult.rows[0];

        // Only sync pending transactions
        if (transaction.status !== 'pending') {
            return res.status(400).json({
                message: `Cannot sync ${transaction.status} transaction`
            });
        }

        await client.query('BEGIN');

        // Get sender's current wallet balance
        const senderWallet = await client.query(
            'SELECT id, balance FROM wallets WHERE user_id = $1',
            [req.user.userId]
        );

        if (senderWallet.rows.length === 0) {
            await client.query('ROLLBACK');
            return res.status(404).json({ message: 'Wallet not found' });
        }

        // Check if sender has sufficient balance
        if (parseFloat(senderWallet.rows[0].balance) < parseFloat(transaction.amount)) {
            // Update transaction status to failed
            await client.query(
                'UPDATE transactions SET status = $1, sync_error_message = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $3',
                ['failed', 'Insufficient balance', transactionId]
            );
            await client.query('COMMIT');

            return res.status(400).json({
                message: 'Insufficient balance',
                transaction: {
                    id: transaction.id,
                    status: 'failed',
                    syncErrorMessage: 'Insufficient balance'
                }
            });
        }

        // Get recipient user
        const recipientUser = await client.query(
            'SELECT id FROM users WHERE email = $1',
            [transaction.recipient_email]
        );

        if (recipientUser.rows.length === 0) {
            // Update transaction status to failed
            await client.query(
                'UPDATE transactions SET status = $1, sync_error_message = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $3',
                ['failed', 'Recipient not found', transactionId]
            );
            await client.query('COMMIT');

            return res.status(404).json({
                message: 'Recipient not found',
                transaction: {
                    id: transaction.id,
                    status: 'failed',
                    syncErrorMessage: 'Recipient not found'
                }
            });
        }

        const recipientId = recipientUser.rows[0].id;

        // Get recipient's wallet
        const recipientWallet = await client.query(
            'SELECT id FROM wallets WHERE user_id = $1',
            [recipientId]
        );

        if (recipientWallet.rows.length === 0) {
            // Update transaction status to failed
            await client.query(
                'UPDATE transactions SET status = $1, sync_error_message = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $3',
                ['failed', 'Recipient wallet not found', transactionId]
            );
            await client.query('COMMIT');

            return res.status(404).json({
                message: 'Recipient wallet not found',
                transaction: {
                    id: transaction.id,
                    status: 'failed',
                    syncErrorMessage: 'Recipient wallet not found'
                }
            });
        }

        // Update sender balance
        await client.query(
            'UPDATE wallets SET balance = balance - $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2',
            [transaction.amount, senderWallet.rows[0].id]
        );

        // Update recipient balance
        await client.query(
            'UPDATE wallets SET balance = balance + $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2',
            [transaction.amount, recipientWallet.rows[0].id]
        );

        // Update transaction status to success
        const updateResult = await client.query(
            `UPDATE transactions 
             SET status = $1, synced_at = CURRENT_TIMESTAMP, sync_error_message = NULL, updated_at = CURRENT_TIMESTAMP 
             WHERE id = $2
             RETURNING id, amount, recipient_email, note, status, created_at`,
            ['success', transactionId]
        );

        await client.query('COMMIT');

        const updatedTransaction = updateResult.rows[0];

        res.status(200).json({
            message: 'Transaction synced successfully',
            transaction: {
                id: updatedTransaction.id,
                amount: parseFloat(updatedTransaction.amount),
                recipientEmail: updatedTransaction.recipient_email,
                note: updatedTransaction.note || '',
                status: updatedTransaction.status,
                timestamp: updatedTransaction.created_at.toISOString()
            }
        });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Sync transaction error:', error);
        res.status(500).json({ message: 'Internal server error' });
    } finally {
        client.release();
    }
});

// Cancel pending transaction
app.post('/wallet/transaction/:id/cancel', verifyToken, async (req, res) => {
    try {
        const transactionId = req.params.id;

        // Get transaction
        const transactionResult = await pool.query(
            'SELECT * FROM transactions WHERE id = $1 AND user_id = $2',
            [transactionId, req.user.userId]
        );

        if (transactionResult.rows.length === 0) {
            return res.status(404).json({ message: 'Transaction not found' });
        }

        const transaction = transactionResult.rows[0];

        // Only cancel pending transactions
        if (transaction.status !== 'pending') {
            return res.status(400).json({
                message: `Cannot cancel ${transaction.status} transaction`,
                currentStatus: transaction.status
            });
        }

        // Update transaction status to cancelled
        const result = await pool.query(
            `UPDATE transactions 
             SET status = $1, updated_at = CURRENT_TIMESTAMP 
             WHERE id = $2
             RETURNING id, amount, recipient_email, note, status, created_at`,
            ['cancelled', transactionId]
        );

        const cancelledTransaction = result.rows[0];

        res.status(200).json({
            message: 'Transaction cancelled successfully',
            transaction: {
                id: cancelledTransaction.id,
                amount: parseFloat(cancelledTransaction.amount),
                recipientEmail: cancelledTransaction.recipient_email,
                note: cancelledTransaction.note || '',
                status: cancelledTransaction.status,
                timestamp: cancelledTransaction.created_at.toISOString()
            }
        });
    } catch (error) {
        console.error('Cancel transaction error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// Get transaction history
app.get('/wallet/transactions', verifyToken, async (req, res) => {
    try {
        const limit = parseInt(req.query.limit) || 20;
        const offset = parseInt(req.query.offset) || 0;

        const result = await pool.query(
            `SELECT t.id, t.amount, t.recipient_email, t.note, t.status, t.sync_error_message, t.synced_at, t.created_at 
             FROM transactions t 
             WHERE t.user_id = $1 
             ORDER BY t.created_at DESC 
             LIMIT $2 OFFSET $3`,
            [req.user.userId, limit, offset]
        );

        const transactions = result.rows.map(t => ({
            id: t.id,
            amount: parseFloat(t.amount),
            recipientEmail: t.recipient_email,
            note: t.note || '',
            status: t.status,
            syncErrorMessage: t.sync_error_message || null,
            syncedAt: t.synced_at ? t.synced_at.toISOString() : null,
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
