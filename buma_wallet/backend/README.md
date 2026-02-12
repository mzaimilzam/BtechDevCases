# BUMA Wallet Backend API

Production-ready Node.js Express backend for the BUMA Wallet application with **offline-first** transaction support.

## Prerequisites

- Node.js 16+
- PostgreSQL 15+
- Docker & Docker Compose (for containerized deployment)

## Installation

```bash
npm install
```

## Environment Variables

Create a `.env` file based on `.env.example`:

```
NODE_ENV=development
DATABASE_URL=postgresql://buma_user:buma_password@localhost:5432/buma_wallet
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRY=3600
REFRESH_TOKEN_EXPIRY=604800
API_PORT=8080
```

## Running the Server

### Development

```bash
npm run dev
```

### Production

```bash
npm start
```

## API Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user
- `GET /auth/current-user` - Get current authenticated user
- `POST /auth/refresh` - Refresh JWT token

### Wallet
- `GET /wallet/balance` - Get wallet balance

### Transactions (Offline-First Pattern)
- `POST /wallet/transfer` - Create pending transaction (offline-first)
- `PUT /wallet/transaction/:id/sync` - Sync pending transaction (execute transfer)
- `POST /wallet/transaction/:id/cancel` - Cancel pending transaction
- `GET /wallet/transactions` - Get transaction history with sync details

### Health Check
- `GET /health` - Service health status

For detailed API documentation, see [API_DOCUMENTATION.md](API_DOCUMENTATION.md).

## Offline-First Architecture

The backend supports a 3-step offline-first transaction flow:

### 1. Create Pending Transaction
```bash
POST /wallet/transfer
```
- Creates transaction with "pending" status immediately
- No balance deduction yet
- Mobile app displays transaction immediately

### 2. Sync Transaction (Execute)
```bash
PUT /wallet/transaction/:id/sync
```
- Validates sender has sufficient balance
- Deducts from sender, adds to recipient
- Updates transaction status to "success" or "failed"
- Can be retried if it fails

### 3. Cancel Transaction (Optional)
```bash
POST /wallet/transaction/:id/cancel
```
- Only works for pending transactions
- No funds are transferred
- Transaction preserved in history

See [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for detailed examples.

## Database

PostgreSQL 15 with the following tables:
- `users` - User accounts
- `wallets` - User wallets  
- `transactions` - Transaction history with status and sync tracking

See `init.sql` for complete schema with all fields.

### Key Transaction Fields
- `status` - pending | success | failed | cancelled
- `synced_at` - Timestamp when synced with server
- `sync_error_message` - Error message if sync failed

## Docker Deployment

### Build Image
```bash
docker build -t buma-wallet-api:latest .
```

### Run with Docker Compose
```bash
docker-compose up -d
```

### View Logs
```bash
docker-compose logs -f api
```

### Stop Services
```bash
docker-compose down
```

## Testing

### Manual Testing with cURL

**1. Register:**
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

**2. Login:**
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

**3. Get Balance:**
```bash
curl -X GET http://localhost:8080/wallet/balance \
  -H "Authorization: Bearer <token>"
```

**4. Create Transfer (Pending):**
```bash
curl -X POST http://localhost:8080/wallet/transfer \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"recipientEmail":"recipient@example.com","amount":100.00,"note":"Test"}'
```

**5. Sync Transaction:**
```bash
curl -X PUT http://localhost:8080/wallet/transaction/{id}/sync \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{}'
```

### Automated Testing

```bash
npm test
```

## Security

✅ **Implemented:**
- JWT-based authentication with configurable expiry
- Password hashing with bcryptjs
- CORS support
- SQL injection prevention (parameterized queries)
- Transaction atomicity (ACID properties)
- Database connection pooling

⚠️ **TODO for Production:**
- Rate limiting per user/IP
- Request validation (Joi/Yup)
- HTTPS enforcement
- Audit logging
- Database encryption
- Secrets management (AWS Secrets Manager)
- DDoS protection

## Troubleshooting

### Cannot Connect to Database
```bash
# Check connection string in .env
# Verify PostgreSQL is running
docker-compose ps
```

### JWT Token Errors
- Check `JWT_SECRET` is set correctly
- Verify token hasn't expired
- Use format: `Authorization: Bearer <token>`

### Transaction Sync Fails
- Verify sender has sufficient balance
- Check recipient email exists
- Check both users have wallets created

## Performance Tips

### Optimize Queries
- Database indices are already created
- Consider query caching for frequent operations
- Use pagination for large result sets

### Scale Backend
- Implement request rate limiting
- Add caching layer (Redis)
- Use load balancer (Nginx)
- Add monitoring and alerting

## Deployment Checklist

- [ ] Set JWT_SECRET to strong random value
- [ ] Set NODE_ENV to production
- [ ] Enable HTTPS
- [ ] Configure database backups
- [ ] Set up monitoring and alerting
- [ ] Implement rate limiting
- [ ] Add request validation
- [ ] Configure CORS whitelist
- [ ] Test all endpoints
- [ ] Verify database indices

## Resources

- [Express.js Documentation](https://expressjs.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [JWT Introduction](https://jwt.io/introduction)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
