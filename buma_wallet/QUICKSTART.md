# Quick Start Guide

## 5-Minute Setup

### 1. Clone & Setup
```bash
git clone <your-fork-url>
cd buma_wallet
flutter pub get
```

### 2. Generate Code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run Docker Compose (if backend not available)
```bash
docker-compose up -d
```

### 4. Configure Environment
```bash
cp .env.example .env
# Edit .env with your API_BASE_URL and other settings
```

### 5. Run App
```bash
flutter run
```

---

## Project Structure at a Glance

```
lib/
├── domain/              ← Business logic (entities, interfaces, failures)
│   ├── entities/        ← User, Wallet, Transaction, AuthToken
│   ├── repositories/    ← AuthRepository, WalletRepository (interfaces)
│   └── failures/        ← Error types (NetworkFailure, etc.)
│
├── data/                ← Data access layer
│   ├── datasources/     ← RemoteAuthDataSource, RemoteWalletDataSource, Local*
│   ├── models/          ← DTOs with JSON serialization
│   ├── mappers/         ← DTO ↔ Entity conversions
│   └── repositories/    ← Repository implementations
│
└── core/                ← Infrastructure
    ├── database/        ← Drift database, schema
    ├── network/         ← Dio, Retrofit, interceptors
    ├── storage/         ← Secure JWT storage
    └── di/              ← Dependency injection (GetIt, Injectable)
```

---

## Code Generation

Required after any model/DTO/database/DI changes:

```bash
# Full rebuild
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on file save)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean and rebuild
flutter pub run build_runner clean
flutter pub run build_runner build
```

---

## Key Concepts

### 1. Offline-First
- **Write**: If offline, save to `TransactionQueueTable` with `pending_sync` status
- **Read**: Try remote, fallback to cached data
- **Sync**: `syncPendingTransactions()` uploads queued items when online

### 2. Error Handling (Either<Failure, Success>)
```dart
// All repository methods return Either<Failure, T>
final result = await authRepository.login(email, password);

result.fold(
  (failure) => showError(failure.message),  // Error case
  (user) => goToHome(user),                 // Success case
);
```

### 3. Dependency Injection
```dart
// Get dependencies (not new AuthRepositoryImpl())
final authRepo = getIt<AuthRepository>();
final walletRepo = getIt<WalletRepository>();
```

### 4. Immutability
```dart
// All models are immutable (Freezed)
final user = User(id: '1', email: 'test@example.com', name: 'Test');
final updated = user.copyWith(name: 'Updated');  // Creates new instance
```

---

## Testing

Example test structure:

```dart
test('login returns User on success', () async {
  // Arrange
  when(() => mockRemote.login(...)).thenAnswer((_) async => user);

  // Act
  final result = await repo.login(email, password);

  // Assert
  expect(result, Right(expectedUser));
});
```

Run tests:
```bash
flutter test
```

---

## Common Tasks

### Add a New Feature
1. Create entity in `domain/entities/`
2. Add to database schema in `core/database/`
3. Create DTOs in `data/models/`
4. Implement data sources (local + remote)
5. Implement repository interface
6. Register in DI (`service_locator.dart`)
7. Add tests in `test/`

### Handle a New API Endpoint
1. Add method to `ApiClient` (Retrofit)
2. Create DTOs for request/response
3. Implement data source method
4. Update repository to call data source
5. Test with mocks

### Debug Network Issues
- Enable logging: `ENABLE_API_LOGGING=true` in `.env`
- Logs appear in Flutter console (PrettyDioLogger)
- Check network tab in DevTools

### Test Offline Mode
- Disable WiFi/cellular on device
- App should still work (cached data, transaction queuing)
- Re-enable network and call `syncPendingTransactions()`

---

## Environment Variables

Copy `.env.example` → `.env` and customize:

```env
API_BASE_URL=http://localhost:8080        # Backend API
API_TIMEOUT_SECONDS=30                    # Request timeout
JWT_EXPIRY_SECONDS=900                    # 15 minutes
ENABLE_LOGGING=true                       # Network logging
SYNC_INTERVAL_SECONDS=300                 # Auto-sync pending txns
```

---

## Troubleshooting

### "Type not found" errors after adding new code
→ Run code generator: `flutter pub run build_runner build --delete-conflicting-outputs`

### App crashes on startup
→ Check if database initialization worked
→ Check secure storage permissions (iOS/Android)

### Network requests timeout
→ Increase `API_TIMEOUT_SECONDS` in `.env`
→ Check if backend is running

### Offline transactions not syncing
→ Call `getIt<WalletRepository>().syncPendingTransactions()`
→ Check transaction status in database

---

## Architecture Highlights

✅ **Clean Architecture**: Domain, Data, Presentation separated  
✅ **Offline-First**: Works in jungle/cave scenarios  
✅ **Type-Safe**: Freezed, fpdart, Retrofit all generate code  
✅ **Error Handling**: No exceptions; use Either<Failure, Success>  
✅ **Testable**: All dependencies injectable, mockable  
✅ **Retry Logic**: Automatic exponential backoff on network errors  

---

## Next Steps (Not in This Spec)

1. **Presentation Layer**: Create UI with BLoC/Riverpod
2. **Login Screen**: User registration and authentication UI
3. **Wallet Screen**: Display balance, transaction history
4. **Transfer Screen**: Send money with confirmation dialog
5. **Background Sync**: Use WorkManager for periodic syncing
6. **Connectivity Detection**: Monitor online/offline status
7. **Tests**: Unit and integration tests
8. **Release**: Build APK/IPA for production

---

## Resources

- [Clean Architecture Article](https://resocoder.com/flutter-clean-architecture)
- [Drift Documentation](https://drift.simonbinder.eu/)
- [fpdart (Functional Programming)](https://pub.dev/packages/fpdart)
- [Flutter Security Best Practices](https://flutter.dev/docs/development/data-and-backend/json)

---

## Support

For questions or issues:
1. Check `ARCHITECTURE.md` for design decisions
2. Review example tests in `test/`
3. Search code comments (marked with `//`)
4. Check Flutter/Dart official docs
