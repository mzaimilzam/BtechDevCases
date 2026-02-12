# Quick Reference - Offline-First Transaction Architecture

## 🚀 Start Here

1. **Frontend** (Flutter) - See [OFFLINE_FIRST_ARCHITECTURE.md](OFFLINE_FIRST_ARCHITECTURE.md)
2. **Backend** (Node.js) - See [backend/API_DOCUMENTATION.md](backend/API_DOCUMENTATION.md)
3. **Full Summary** - See [IMPLEMENTATION_COMPLETE.md](IMPLEMENTATION_COMPLETE.md)

---

## 📱 Frontend Quick Commands

```bash
# Get dependencies
flutter pub get

# Generate code (Freezed, Drift, Injectable, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Check for errors
flutter analyze

# Run app
flutter run

# Run on specific device
flutter run -d <device-id>
```

---

## 🚀 Backend Quick Commands

```bash
# Install dependencies
cd backend && npm install

# Development
npm run dev

# Production
npm start

# Syntax check
node -c src/index.js

# Docker
docker-compose up -d     # Start
docker-compose logs -f   # View logs
docker-compose down      # Stop
```

---

## 🌐 API Quick Reference

### Authentication
```bash
# Register
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"pass123","firstName":"John","lastName":"Doe"}'

# Login
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"pass123"}'
```

### Transactions (3-Step Flow)
```bash
# Step 1: Create Pending (User can see immediately)
curl -X POST http://localhost:8080/wallet/transfer \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"recipientEmail":"recipient@example.com","amount":100.00,"note":"Payment"}'

# Step 2: Sync (Execute transfer when ready)
curl -X PUT http://localhost:8080/wallet/transaction/{id}/sync \
  -H "Authorization: Bearer <token>" \
  -d '{}'

# Step 3 (Optional): Cancel
curl -X POST http://localhost:8080/wallet/transaction/{id}/cancel \
  -H "Authorization: Bearer <token>" \
  -d '{}'

# View all transactions
curl -X GET http://localhost:8080/wallet/transactions \
  -H "Authorization: Bearer <token>"
```

---

## 📊 Transaction Status Flow

```
pending ─(sync)→ success
    ↓            (final)
    ├─(cancel)→ cancelled
    │            (final)
    └─(sync fails)→ failed
                    ↓
                 (can retry)
```

**Status Meanings:**
- `pending` - Created locally, not synced yet
- `success` - Synced successfully, funds transferred
- `failed` - Sync failed, can retry or cancel
- `cancelled` - User cancelled, funds not transferred

---

## 🗂️ Key Files

### Frontend
- `lib/domain/entities/transaction.dart` - Transaction model
- `lib/core/database/app_database_schema.dart` - Database schema
- `lib/data/datasources/local_wallet_datasource.dart` - Local DB operations
- `lib/data/repositories/wallet_repository_impl.dart` - Business logic
- `lib/presentation/bloc/wallet/wallet_bloc.dart` - State management
- `lib/presentation/screens/home/history_tab_screen.dart` - UI with buttons

### Backend
- `backend/src/index.js` - All API routes and logic
- `backend/init.sql` - Database schema
- `backend/package.json` - Dependencies
- `backend/docker-compose.yml` - Container setup

---

## 🧪 Quick Test Workflow

### Test Pending Transaction
```bash
# 1. Create transfer
curl -X POST http://localhost:8080/wallet/transfer \
  -H "Authorization: Bearer <token>" \
  -d '{"recipientEmail":"test2@example.com","amount":50}'
# Response includes transaction ID

# 2. Verify it's pending
curl -X GET http://localhost:8080/wallet/transactions \
  -H "Authorization: Bearer <token>"
# Should see status: "pending"

# 3. Sync it
curl -X PUT http://localhost:8080/wallet/transaction/{id}/sync \
  -H "Authorization: Bearer <token>" \
  -d '{}'
# Should see status: "success"

# 4. Verify synced
curl -X GET http://localhost:8080/wallet/transactions \
  -H "Authorization: Bearer <token}"
# Should show status: "success" with syncedAt timestamp
```

### Test Cancel
```bash
# 1. Create transfer
curl -X POST http://localhost:8080/wallet/transfer \
  -d '...'

# 2. Cancel immediately
curl -X POST http://localhost:8080/wallet/transaction/{id}/cancel \
  -H "Authorization: Bearer <token>" \
  -d '{}'
# Should see status: "cancelled"
```

### Test Failure (Insufficient Balance)
```bash
# Create transfer for more than balance
curl -X POST http://localhost:8080/wallet/transfer \
  -d '{"recipientEmail":"...","amount":999999}'

# Try to sync - will fail
curl -X PUT http://localhost:8080/wallet/transaction/{id}/sync \
  -d '{}'
# Response: status "failed", syncErrorMessage "Insufficient balance"

# Try sync again - same error
# Or cancel the transaction
```

---

## 🔍 Common Issues & Fixes

### Issue: "Cannot connect to database"
**Fix**: Check .env DATABASE_URL and verify PostgreSQL is running
```bash
docker-compose ps  # Check if postgres running
docker-compose logs postgres  # View errors
```

### Issue: "Invalid token" on API calls
**Fix**: 
- Verify token from login response
- Use format: `Authorization: Bearer <token>`
- Token may have expired (3600 seconds)
- Get new token with refresh endpoint

### Issue: "Recipient not found"
**Fix**: Recipient email must be registered in system
- Register recipient first
- Both users need wallets (created automatically)

### Issue: "Cannot sync non-pending transaction"
**Fix**: Transaction already synced (status: success/failed)
- You can only sync transactions with status: pending
- Check transaction status first

### Issue: Insufficient balance
**Fix**: Sender doesn't have enough funds
- Create transfer for more than balance
- It will sync with status: failed
- Add more balance to account
- Retry sync on the same transaction ID

---

## 📦 Environment Variables

### Backend (.env)
```env
NODE_ENV=development              # development or production
API_PORT=8080
DATABASE_URL=postgresql://user:pass@localhost:5432/buma_wallet
JWT_SECRET=your-super-secret      # Change in production!
JWT_EXPIRY=3600                   # 1 hour
REFRESH_TOKEN_EXPIRY=604800       # 7 days
```

### Frontend (Android Emulator)
```
API_BASE_URL=http://10.0.2.2:8080
```

### Frontend (iOS Simulator)
```
API_BASE_URL=http://localhost:8080
```

---

## 🏗️ Architecture Overview

```
Flutter App (Dart)
    ↓ (BLoC manages state)
    ↓ (Repository pattern)
    ↓ (LocalWalletDataSource + RemoteWalletDataSource)
    ↓ (HTTP requests)
    ↓
Express.js API (Node.js)
    ↓ (Routes)
    ↓ (JWT Authentication)
    ↓ (Atomic transactions)
    ↓ (Database queries)
    ↓
PostgreSQL Database
    ↓ (Tables: users, wallets, transactions)
    ↓
Persistent Storage
```

---

## 📚 Documentation Map

| Document | Purpose |
|----------|---------|
| [README.md](README.md) | Project overview and setup |
| [OFFLINE_FIRST_ARCHITECTURE.md](OFFLINE_FIRST_ARCHITECTURE.md) | Frontend architecture details |
| [IMPLEMENTATION_COMPLETE.md](IMPLEMENTATION_COMPLETE.md) | Complete implementation summary |
| [backend/README.md](backend/README.md) | Backend setup and architecture |
| [backend/API_DOCUMENTATION.md](backend/API_DOCUMENTATION.md) | Detailed API reference |

---

## ✅ Checklist: Before Deploying

### Frontend
- [ ] `flutter analyze` shows no errors
- [ ] `flutter pub run build_runner build` succeeds
- [ ] `flutter run` works on device
- [ ] Status badges display correctly
- [ ] Sync button works
- [ ] Cancel button works
- [ ] Error messages show correctly

### Backend
- [ ] `node -c src/index.js` passes
- [ ] `.env` configured correctly
- [ ] PostgreSQL accessible
- [ ] `npm start` runs without errors
- [ ] Health endpoint responds: `curl http://localhost:8080/health`
- [ ] Can register user
- [ ] Can login
- [ ] Can create transfer
- [ ] Can sync transfer
- [ ] Can cancel transfer

### Integration
- [ ] Frontend connects to backend
- [ ] Create transfer shows pending
- [ ] Sync updates status to success
- [ ] Cancel works before sync
- [ ] Notifications display
- [ ] Error messages clear

---

## 🚀 Deploy Steps

### Backend (Docker)
```bash
cd backend
docker build -t buma-wallet-api:latest .
docker run -d --name buma-api -p 8080:8080 \
  -e DATABASE_URL="postgresql://..." \
  -e JWT_SECRET="..." \
  buma-wallet-api:latest
```

### Frontend (Flutter)
```bash
flutter build apk           # Android
flutter build ios           # iOS
flutter build web           # Web
```

---

## 💡 Tips & Tricks

1. **Test offline**: Disable network → create transfer → enable network → sync
2. **Batch test**: Create 5 transfers, sync one-by-one
3. **Error testing**: Try transferring more than balance
4. **Concurrent transfers**: Create multiple simultaneously, verify ordering
5. **Database queries**: Check transactions in pgAdmin or DBeaver

---

## 🆘 Support

1. Check the main README
2. Check architecture docs
3. Review API documentation
4. Look at error messages in logs
5. Use curl to test API endpoints directly
6. Check database with SQL tools

---

**Version**: 1.0  
**Last Updated**: Feb 12, 2026  
**Status**: ✅ Complete & Ready for Testing
