# BUMA Wallet - Flutter Clean Architecture Implementation

A production-ready Flutter application demonstrating **Clean Architecture** with **offline-first capabilities** for wallet management and fund transfers.

## 📋 Prerequisites

- **Flutter**: >= 3.0.0
- **Dart**: >= 3.0.0
- **Docker**: Latest version (for backend services)
- **Docker Compose**: Latest version
- **Android SDK** or **iOS SDK** (for native development)
- **Node.js**: >= 14 (for backend API)
- **PostgreSQL**: 15+ (or use Docker)

## 🚀 Quick Start

### Step 1: Clone Repository

```bash
git clone <your-fork-url>
cd buma_wallet
```

### Step 2: Set Up Environment Variables

Create a `.env` file in the project root:

```env
# API Configuration
API_BASE_URL=http://10.0.2.2:8080
API_TIMEOUT_SECONDS=30

# Database (PostgreSQL)
DATABASE_URL=postgresql://buma_user:buma_password@localhost:5432/buma_wallet

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRY_MINUTES=60
JWT_REFRESH_EXPIRY_DAYS=7

# Backend Server
BACKEND_PORT=8080
NODE_ENV=development

# Flutter Runtime (optional)
FLUTTER_ENV=development
```

### Step 3: Start Backend Services with Docker Compose

```bash
cd buma_wallet/backend
docker-compose up -d
```

This starts:
- **PostgreSQL Database** on `localhost:5432`
- **Node.js API Server** on `localhost:8080`

Verify services are running:

```bash
docker-compose ps
```

Expected output:

```
NAME                    STATUS
buma-wallet-api         Up
buma-wallet-postgres    Up
```

### Step 4: Install Flutter Dependencies

```bash
flutter pub get
```

### Step 5: Generate Code

Several packages require code generation (Freezed, Retrofit, Drift, Injectable):

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Note**: First run may take 1-2 minutes.

### Step 6: Run the Application

```bash
# For Android Emulator or Device
flutter run

# For iOS Simulator
flutter run -d macos

# For Web Browser
flutter run -d chrome

# Specific device
flutter run -d <device-id>
```

List available devices:

```bash
flutter devices
```

## 🐳 Docker Compose Setup

The `docker-compose.yml` in the `backend/` directory sets up the complete backend infrastructure:

### Start Services

```bash
cd backend
docker-compose up -d
```

### Stop Services

```bash
docker-compose down
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f api
docker-compose logs -f postgres
```

### Reset Database

```bash
docker-compose down -v  # Removes volume data
docker-compose up -d    # Restarts fresh
```

### `docker-compose.yml` Structure

```yaml
version: '3.8'

services:
  api:
    image: buma-wallet-api:latest
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=postgresql://buma_user:buma_password@postgres:5432/buma_wallet
      - JWT_SECRET=${JWT_SECRET}
      - NODE_ENV=${NODE_ENV}
    depends_on:
      - postgres

  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=buma_user
      - POSTGRES_PASSWORD=buma_password
      - POSTGRES_DB=buma_wallet
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  postgres_data:
```

## 🔧 Environment Variables Reference

### API Configuration

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `API_BASE_URL` | ✅ | - | Backend API base URL (e.g., `http://10.0.2.2:8080`) |
| `API_TIMEOUT_SECONDS` | ❌ | 30 | HTTP request timeout |

### Database Configuration

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DATABASE_URL` | ✅ | - | PostgreSQL connection string |
| `DB_ENCRYPTION_KEY` | ❌ | - | Local database encryption key |

### Authentication

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `JWT_SECRET` | ✅ | - | Secret key for signing JWTs |
| `JWT_EXPIRY_MINUTES` | ❌ | 60 | Access token expiration time |
| `JWT_REFRESH_EXPIRY_DAYS` | ❌ | 7 | Refresh token expiration time |

### Server Configuration

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `BACKEND_PORT` | ❌ | 8080 | Backend API port |
| `NODE_ENV` | ❌ | development | Environment (development/production) |

### Feature Flags

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `ENABLE_LOGGING` | ❌ | true | Enable network request logging |
| `SYNC_INTERVAL_SECONDS` | ❌ | 300 | Background sync interval |

## 🌐 API Endpoints

Once backend is running, the following endpoints are available:

### Authentication

```
POST   /api/auth/register          # Register new user
POST   /api/auth/login             # Login, returns JWT
GET    /api/auth/me                # Get current user profile
POST   /api/auth/logout            # Logout
POST   /api/auth/refresh           # Refresh JWT token
```

### Wallet Operations

```
GET    /api/wallet/balance         # Get wallet balance
POST   /api/wallet/transfer        # Transfer funds
GET    /api/wallet/transactions    # Get transaction history
```

## 🔌 Network Configuration

### Android Emulator

For Android emulator, use `10.0.2.2` instead of `localhost`:

```env
API_BASE_URL=http://10.0.2.2:8080
```

### iOS Simulator

For iOS simulator, use `localhost`:

```env
API_BASE_URL=http://localhost:8080
```

### Physical Device

For physical device on same network:

```env
API_BASE_URL=http://<YOUR_MACHINE_IP>:8080
```

## 📱 Testing the Application

### 1. Register New Account

```bash
POST http://10.0.2.2:8080/api/auth/register
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123",
  "confirmPassword": "password123"
}
```

### 2. Login

```bash
POST http://10.0.2.2:8080/api/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123"
}
```

### 3. Check Wallet Balance

```bash
GET http://10.0.2.2:8080/api/wallet/balance
Authorization: Bearer <your_jwt_token>
```

### 4. Transfer Funds

```bash
POST http://10.0.2.2:8080/api/wallet/transfer
Authorization: Bearer <your_jwt_token>
Content-Type: application/json

{
  "recipientEmail": "recipient@example.com",
  "amount": 100.00,
  "note": "Payment for services"
}
```

## 🛠️ Troubleshooting

### Issue: Docker containers fail to start

```bash
# Check Docker daemon
docker ps

# Check compose file syntax
docker-compose config

# View service logs
docker-compose logs
```

### Issue: Flutter can't connect to API

1. Verify Docker services are running:
   ```bash
   docker-compose ps
   ```

2. Check API URL in `.env` matches your platform:
   - Android Emulator: `http://10.0.2.2:8080`
   - iOS Simulator: `http://localhost:8080`
   - Device: `http://<YOUR_IP>:8080`

3. Test API connectivity:
   ```bash
   curl http://10.0.2.2:8080/api/auth/login
   ```

### Issue: Database connection error

1. Verify PostgreSQL is running:
   ```bash
   docker-compose logs postgres
   ```

2. Check DATABASE_URL in `.env`

3. Reset database:
   ```bash
   docker-compose down -v
   docker-compose up -d
   ```

### Issue: Code generation fails

```bash
# Clean build artifacts
flutter clean
flutter pub get

# Rebuild code generation
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📦 Project Structure

```
buma_wallet/
├── lib/
│   ├── core/                      # Infrastructure & utilities
│   │   ├── database/              # Drift local database
│   │   ├── di/                    # Dependency injection
│   │   ├── network/               # Dio, Retrofit, interceptors
│   │   └── storage/               # Secure token storage
│   ├── data/                      # External dependencies
│   │   ├── datasources/           # Local/Remote API calls
│   │   ├── models/                # DTOs
│   │   ├── mappers/               # Entity conversions
│   │   └── repositories/          # Repository implementations
│   ├── domain/                    # Business logic
│   │   ├── entities/              # Domain models
│   │   ├── repositories/          # Repository interfaces
│   │   └── failures/              # Error types
│   └── presentation/              # UI Layer (Flutter)
│       ├── bloc/                  # BLoC state management
│       ├── screens/               # UI Screens
│       └── theme/                 # Theming
├── backend/
│   ├── src/
│   │   ├── routes/                # API endpoints
│   │   ├── controllers/           # Request handlers
│   │   ├── models/                # Database models
│   │   └── middleware/            # Auth, logging
│   ├── docker-compose.yml         # Docker services
│   ├── package.json
│   └── server.js
├── test/                          # Unit & integration tests
├── pubspec.yaml
└── README.md
```

## 🔐 Security Notes

1. **Environment Variables**: Never commit `.env` to version control
2. **JWT Secret**: Change `JWT_SECRET` in production
3. **Token Storage**: Uses platform-specific secure storage (Keychain/Keystore)
4. **HTTPS**: Use HTTPS in production (`https://` instead of `http://`)

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [PostgreSQL Docker Image](https://hub.docker.com/_/postgres)

## 📝 License

MIT License - See LICENSE file for details
