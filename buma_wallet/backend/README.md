# BUMA Wallet Backend API

Node.js Express backend for the BUMA Wallet Flutter application.

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
JWT_EXPIRY=900
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

### Wallet
- `GET /wallet/balance` - Get wallet balance
- `POST /wallet/transfer` - Transfer funds to another user
- `GET /wallet/transactions` - Get transaction history

### Health Check
- `GET /health` - Service health status

## Docker Deployment

```bash
docker-compose up -d
```

## Database

PostgreSQL 15 with the following tables:
- `users` - User accounts
- `wallets` - User wallets
- `transactions` - Transaction history

See `init.sql` for schema details.

## Testing

```bash
npm test
```
