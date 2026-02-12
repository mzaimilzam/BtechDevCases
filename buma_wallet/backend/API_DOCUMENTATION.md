# BUMA Wallet Backend - Offline-First API

This document describes the backend API endpoints that support the offline-first transaction architecture.

## API Overview

The BUMA Wallet API is built with **Express.js** and **PostgreSQL**, providing JWT-based authentication and support for offline-first wallet operations.

### Base URL
```
http://localhost:8080
```

## Authentication

All wallet-related endpoints require a valid JWT token in the `Authorization` header:

```
Authorization: Bearer <access_token>
```

### Authentication Endpoints

#### Register User
```http
POST /auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "firstName": "John",
  "lastName": "Doe"
}

Response (201):
{
  "message": "User registered successfully",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe"
  },
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "expiresIn": 3600
}
```

#### Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}

Response (200):
{
  "message": "Login successful",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe"
  },
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "expiresIn": 3600
}
```

#### Refresh Token
```http
POST /auth/refresh
Content-Type: application/json

{
  "refreshToken": "eyJhbGc..."
}

Response (200):
{
  "message": "Token refreshed successfully",
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "expiresIn": 3600
}
```

#### Get Current User
```http
GET /auth/current-user
Authorization: Bearer <access_token>

Response (200):
{
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe"
  }
}
```

## Wallet Endpoints

### Get Wallet Balance
```http
GET /wallet/balance
Authorization: Bearer <access_token>

Response (200):
{
  "wallet": {
    "id": "660e8400-e29b-41d4-a716-446655440000",
    "balance": 1000.00,
    "currency": "USD"
  }
}
```

## Transaction Endpoints (Offline-First Pattern)

### 1. Create Transfer (Step 1: Local Save)

Creates a transaction with **pending** status. This is called immediately when the user initiates a transfer, regardless of network connectivity.

```http
POST /wallet/transfer
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "recipientEmail": "recipient@example.com",
  "amount": 100.00,
  "note": "Payment for services"
}

Response (201):
{
  "message": "Transaction created with pending status",
  "transaction": {
    "id": "770e8400-e29b-41d4-a716-446655440000",
    "amount": 100.00,
    "recipientEmail": "recipient@example.com",
    "note": "Payment for services",
    "status": "pending",
    "timestamp": "2026-02-12T10:30:00.000Z"
  }
}
```

**Status Codes:**
- `201 Created`: Transaction created with pending status
- `400 Bad Request`: Invalid recipient or amount
- `404 Not Found`: Wallet not found or recipient doesn't exist
- `500 Internal Server Error`: Server error

**Important Notes:**
- Transaction is saved to the database immediately with "pending" status
- Mobile app displays the transaction in history right away
- Mobile app attempts to sync in background or on demand
- Recipient email is validated (user must exist)
- No balance deduction occurs until sync succeeds

### 2. Sync Transaction (Step 2: Execute Transfer)

Called when:
1. Mobile app has connectivity and attempts automatic sync
2. User manually clicks "Sync" button on pending transaction
3. App syncs all pending transactions when coming back online

```http
PUT /wallet/transaction/:id/sync
Authorization: Bearer <access_token>
Content-Type: application/json

{}

Response (200):
{
  "message": "Transaction synced successfully",
  "transaction": {
    "id": "770e8400-e29b-41d4-a716-446655440000",
    "amount": 100.00,
    "recipientEmail": "recipient@example.com",
    "note": "Payment for services",
    "status": "success",
    "timestamp": "2026-02-12T10:30:00.000Z"
  }
}
```

**Status Codes:**
- `200 OK`: Transaction synced successfully
- `400 Bad Request`: Transaction is not pending (already synced/failed/cancelled)
- `400 Bad Request`: Insufficient balance
- `404 Not Found`: Transaction not found or user doesn't own it
- `404 Not Found`: Recipient not found
- `404 Not Found`: Recipient wallet not found
- `500 Internal Server Error`: Server error

**Transaction Status After Sync:**

Success (balance updated):
```json
{
  "status": "success",
  "timestamp": "2026-02-12T10:30:00.000Z"
}
```

Failure (with error message, no balance change):
```json
{
  "message": "Insufficient balance",
  "transaction": {
    "id": "770e8400-e29b-41d4-a716-446655440000",
    "status": "failed",
    "syncErrorMessage": "Insufficient balance"
  }
}
```

**Process Flow:**
1. Validate transaction exists and belongs to user
2. Validate transaction status is "pending"
3. Check sender has sufficient balance
4. Check recipient exists and has wallet
5. Deduct from sender's wallet
6. Add to recipient's wallet
7. Update transaction status to "success" with synced_at timestamp
8. All operations in single transaction (atomicity guaranteed)

### 3. Cancel Transaction

Called when user clicks "Cancel" button on pending transaction.

```http
POST /wallet/transaction/:id/cancel
Authorization: Bearer <access_token>
Content-Type: application/json

{}

Response (200):
{
  "message": "Transaction cancelled successfully",
  "transaction": {
    "id": "770e8400-e29b-41d4-a716-446655440000",
    "amount": 100.00,
    "recipientEmail": "recipient@example.com",
    "note": "Payment for services",
    "status": "cancelled",
    "timestamp": "2026-02-12T10:30:00.000Z"
  }
}
```

**Status Codes:**
- `200 OK`: Transaction cancelled successfully
- `400 Bad Request`: Transaction is not pending (already synced/failed/cancelled)
- `404 Not Found`: Transaction not found or user doesn't own it
- `500 Internal Server Error`: Server error

**Important Notes:**
- Only pending transactions can be cancelled
- Cancelled transactions are preserved in history
- No balance changes occur
- Cancellation is immediate (no sync required)

### 4. Get Transaction History

Retrieves all transactions (pending, success, failed, cancelled) with sync details.

```http
GET /wallet/transactions?limit=20&offset=0
Authorization: Bearer <access_token>

Response (200):
[
  {
    "id": "770e8400-e29b-41d4-a716-446655440000",
    "amount": 100.00,
    "recipientEmail": "recipient@example.com",
    "note": "Payment for services",
    "status": "pending",
    "syncErrorMessage": null,
    "syncedAt": null,
    "timestamp": "2026-02-12T10:30:00.000Z"
  },
  {
    "id": "880e8400-e29b-41d4-a716-446655440000",
    "amount": 50.00,
    "recipientEmail": "other@example.com",
    "note": "Loan repayment",
    "status": "success",
    "syncErrorMessage": null,
    "syncedAt": "2026-02-12T10:35:00.000Z",
    "timestamp": "2026-02-12T10:35:00.000Z"
  },
  {
    "id": "990e8400-e29b-41d4-a716-446655440000",
    "amount": 25.00,
    "recipientEmail": "failed@example.com",
    "note": "Test transfer",
    "status": "failed",
    "syncErrorMessage": "Insufficient balance",
    "syncedAt": null,
    "timestamp": "2026-02-12T10:40:00.000Z"
  },
  {
    "id": "aa0e8400-e29b-41d4-a716-446655440000",
    "amount": 15.00,
    "recipientEmail": "cancelled@example.com",
    "note": "Cancelled transfer",
    "status": "cancelled",
    "syncErrorMessage": null,
    "syncedAt": null,
    "timestamp": "2026-02-12T10:45:00.000Z"
  }
]
```

**Query Parameters:**
- `limit`: Number of transactions to return (default: 20, max: 100)
- `offset`: Number of transactions to skip for pagination (default: 0)

**Response Fields:**
- `id`: Transaction ID (UUID)
- `amount`: Transfer amount
- `recipientEmail`: Recipient's email
- `note`: Optional transfer notes
- `status`: Transaction status (pending|success|failed|cancelled)
- `syncErrorMessage`: Error message if sync failed (null if success)
- `syncedAt`: ISO timestamp when synced with server (null if pending)
- `timestamp`: ISO timestamp when transaction was created

**Status Codes:**
- `200 OK`: Transaction list retrieved
- `401 Unauthorized`: Invalid or missing token
- `500 Internal Server Error`: Server error

## Transaction Status Lifecycle

```
pending → success (after sync succeeds)
       ↘ failed (after sync fails)
       ↘ cancelled (user manually cancels)
```

### Status Descriptions

| Status | Meaning | Can Sync? | Can Cancel? | Funds Deducted? |
|--------|---------|-----------|------------|-----------------|
| pending | Waiting to sync with server | ✅ Yes | ✅ Yes | ❌ No |
| success | Successfully synced and completed | ❌ No | ❌ No | ✅ Yes |
| failed | Sync failed, user can retry | ✅ Yes | ✅ Yes | ❌ No |
| cancelled | User cancelled the transaction | ❌ No | ❌ No | ❌ No |

## Data Model: Transaction

### Database Schema
```sql
CREATE TABLE transactions (
  id UUID PRIMARY KEY,
  wallet_id UUID NOT NULL (FOREIGN KEY: wallets),
  user_id UUID NOT NULL (FOREIGN KEY: users),
  recipient_email VARCHAR(255) NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  note TEXT,
  transaction_type VARCHAR(50) NOT NULL DEFAULT 'transfer',
  status VARCHAR(50) NOT NULL DEFAULT 'pending',
  synced_at TIMESTAMP,
  sync_error_message TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_status ON transactions(status);
```

### API Response Schema
```javascript
{
  "id": string (UUID),
  "amount": number (decimal),
  "recipientEmail": string (email format),
  "note": string,
  "status": enum ("pending" | "success" | "failed" | "cancelled"),
  "syncErrorMessage": string | null,
  "syncedAt": string (ISO 8601 timestamp) | null,
  "timestamp": string (ISO 8601 timestamp)
}
```

## Error Responses

### Common Error Formats

**Validation Error:**
```json
{
  "message": "Invalid recipient or amount"
}
```

**Authentication Error:**
```json
{
  "message": "Invalid token"
}
```

**Business Logic Error:**
```json
{
  "message": "Cannot sync pending transaction",
  "currentStatus": "success"
}
```

**Sync Failure (with transaction details):**
```json
{
  "message": "Insufficient balance",
  "transaction": {
    "id": "770e8400-e29b-41d4-a716-446655440000",
    "status": "failed",
    "syncErrorMessage": "Insufficient balance"
  }
}
```

## Rate Limiting

Currently no rate limiting is implemented. In production:
- Implement rate limiting per user (e.g., 100 transfers/hour)
- Implement per-endpoint rate limits
- Add DDoS protection

## Testing the API

### Test User Account
```
Email: test@example.com
Password: test123
Initial Balance: $1000.00
```

### Example Workflow

**1. Login:**
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123"
  }'
```

**2. Create Transfer (pending):**
```bash
curl -X POST http://localhost:8080/wallet/transfer \
  -H "Authorization: Bearer <access_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "recipientEmail": "recipient@example.com",
    "amount": 100.00,
    "note": "Test transfer"
  }'
```

**3. Sync Transaction:**
```bash
curl -X PUT http://localhost:8080/wallet/transaction/<transaction_id>/sync \
  -H "Authorization: Bearer <access_token>" \
  -H "Content-Type: application/json" \
  -d '{}'
```

**4. View Transactions:**
```bash
curl -X GET http://localhost:8080/wallet/transactions \
  -H "Authorization: Bearer <access_token>"
```

**5. Cancel Transaction (if still pending):**
```bash
curl -X POST http://localhost:8080/wallet/transaction/<transaction_id>/cancel \
  -H "Authorization: Bearer <access_token>" \
  -H "Content-Type: application/json" \
  -d '{}'
```

## Deployment Checklist

- [ ] Set `JWT_SECRET` to a strong random value
- [ ] Set `NODE_ENV` to "production"
- [ ] Enable HTTPS (redirect HTTP to HTTPS)
- [ ] Implement rate limiting
- [ ] Add request logging and monitoring
- [ ] Set up database backups
- [ ] Enable transaction query indices
- [ ] Add CORS whitelist (not wildcard)
- [ ] Implement API versioning (`/api/v1/wallet/...`)
- [ ] Add API documentation (Swagger/OpenAPI)
- [ ] Set up monitoring and alerting
- [ ] Implement transaction retry logic
- [ ] Add webhook support for transaction status changes

## Security Considerations

1. **Token Management:**
   - Tokens expire after configured period
   - Refresh tokens have longer expiry
   - Implement token blacklist on logout

2. **Database:**
   - Use parameterized queries (prevent SQL injection)
   - Encrypt sensitive data at rest
   - Use SSL for database connections

3. **API:**
   - HTTPS required in production
   - Input validation on all endpoints
   - Rate limiting per IP and user
   - CORS properly configured

4. **Transaction Safety:**
   - All balance updates use database transactions
   - Atomicity guaranteed at database level
   - Idempotent sync operations (safe to retry)

## Future Enhancements

1. **Batch Operations:** Sync multiple pending transactions in one request
2. **Webhooks:** Notify external systems when transactions complete
3. **Analytics:** Transaction statistics and trends
4. **Dispute Resolution:** Handle transaction disputes
5. **Multi-Currency:** Support multiple currencies and exchange rates
6. **Transaction Limits:** Daily/monthly transfer limits
7. **Merchant Payments:** Support payments to businesses
8. **Scheduled Transfers:** Allow scheduling transfers for future dates
9. **API Versioning:** Maintain backward compatibility
10. **Transaction Receipts:** Generate and email transaction receipts
