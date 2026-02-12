# Architecture Decision Record (ADR)

## Overview
This document outlines the key architectural decisions made for the BUMA Wallet Flutter application and the reasoning behind them.

---

## ADR-001: Clean Architecture Pattern

### Decision
Implement a strict three-layer Clean Architecture: Domain, Data, and Presentation layers.

### Rationale
1. **Separation of Concerns**: Business logic is isolated from framework dependencies
2. **Testability**: Domain layer can be tested without Flutter/Dio/Drift dependencies
3. **Maintainability**: Clear boundaries between layers make refactoring easier
4. **Flexibility**: Easy to swap implementations (e.g., different databases or APIs)

### Implementation
- **Domain Layer**: Framework-agnostic entities, repositories (interfaces), and failures
- **Data Layer**: Repository implementations, data sources, DTOs, mappers
- **Core Layer**: Infrastructure (database, network, storage, DI)
- **Presentation Layer**: UI code (not included in this spec)

### Trade-offs
- More boilerplate code initially
- Steeper learning curve for new developers
- Worth it for projects lasting >6 months or with >2 developers

---

## ADR-002: Offline-First Pattern with Transaction Queuing

### Decision
Implement offline-first architecture where:
- **Reads**: Try remote → fallback to local cache
- **Writes**: Queue locally when offline, sync when online

### Rationale
The application operates in jungles/caves with extremely poor connectivity. We must:
1. Never lose user data (transactions, settings)
2. Provide immediate feedback (not wait for network)
3. Sync reliably when connectivity returns

### Implementation
- **Local Database (Drift)**: 
  - `TransactionQueueTable`: Stores pending transfers with `pending_sync` status
  - `WalletCacheTable`: Caches last known balance
  - `UserCacheTable`: Caches user profile
  - `TransactionHistoryTable`: Synced transaction records

- **Repository Layer**:
  - Write operations: Queue + mark as `pending_sync`
  - Read operations: Try remote, fallback to cache
  - Sync method: Attempts to upload queued transactions

### Example: Transfer in Offline Mode
```
User taps "Send" → transferFund() → No internet? → Save to queue → 
Return "pending_sync" to UI → User sees "Syncing..." badge → 
Connectivity returns → syncPendingTransactions() → Upload all → 
UI updates to "success/failed"
```

### Trade-offs
- More database operations (cache management)
- Duplicate transactions possible if sync fails midway (mitigated by unique IDs)
- Users must understand "pending" state

---

## ADR-003: Functional Programming with fpdart (Either Type)

### Decision
Use `fpdart` library's `Either<Failure, Success>` type for error handling instead of exceptions.

### Rationale
1. **Railway-Oriented Programming**: Errors flow through the program without exceptions
2. **Type Safety**: Compiler forces handling of failure cases
3. **Composability**: Easy to chain operations with `.fold()`, `.map()`, `.flatMap()`
4. **Testability**: No try-catch needed; failures are values

### Implementation
```dart
// Instead of:
try {
  final user = await login(email, password);
  await cache(user);
  return user;
} catch (e) {
  // Hard to handle specific errors
}

// We use:
return await login(email, password).then((userOrFailure) {
  return userOrFailure.fold(
    (failure) => Left(failure),  // Error path
    (user) => cache(user).then((_) => Right(user)),  // Success path
  );
});
```

### Example in Repository:
```dart
@override
Future<Either<Failure, User>> login(...) async {
  try {
    final user = await _remoteDataSource.login(...);
    await _localDataSource.cacheUser(user);
    return Right(user);  // Success
  } on NetworkFailure catch (e) {
    return Left(e);  // Failure
  }
}
```

### Trade-offs
- New developers unfamiliar with `Either` pattern need learning curve
- Slightly more verbose than exceptions
- Powerful for complex error handling in presentation layer

---

## ADR-004: Immutability with Freezed

### Decision
All entities, DTOs, and state classes use `@freezed` annotation from Freezed package.

### Rationale
1. **Predictability**: Objects can't be mutated after creation
2. **Concurrency Safety**: No race conditions from shared mutable state
3. **Value Equality**: `==` comparison works correctly (generated)
4. **Copy With**: Easy immutable updates via `.copyWith()`
5. **Pattern Matching**: Sealed classes allow exhaustive `when()` matching

### Implementation
```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
  }) = _User;
}

// Usage
final user = User(id: '1', email: 'test@example.com', name: 'Test');
final updated = user.copyWith(name: 'New Name');  // Immutable
```

### Trade-offs
- Code generation adds build time
- Slightly more generated code
- Worth it for reduced bugs from mutation

---

## ADR-005: Service Locator Pattern (GetIt + Injectable)

### Decision
Use GetIt for service locator with Injectable for compile-time code generation.

### Rationale
1. **Dependency Injection**: Decouples objects from their dependencies
2. **Testability**: Easy to inject mocks in tests
3. **Compile-Time Safety**: Injectable generates DI code (vs runtime reflection)
4. **Single Responsibility**: Each class focuses on its job, not construction

### Implementation
```dart
// In service_locator.dart
@Injectable()
class AuthRepositoryImpl implements AuthRepository {
  final RemoteAuthDataSource _remote;
  AuthRepositoryImpl(this._remote);  // Dependencies injected
}

// Usage
final authRepo = getIt<AuthRepository>();  // Retrieved, not constructed
```

### Alternatives Considered
- **Provider**: More for UI state, less for business logic
- **Riverpod**: Good alternative, but selected GetIt for simplicity
- **Manual DI**: Scales poorly, hard to maintain

---

## ADR-006: Retry Logic with Exponential Backoff

### Decision
Implement automatic retry on network errors with exponential backoff: 1s → 2s → 4s (3 attempts).

### Rationale
In poor connectivity environments, transient failures are common. Automatic retry:
1. Increases success rate without user intervention
2. Exponential backoff prevents overwhelming the server
3. User doesn't see errors unless truly offline

### Implementation
```dart
class RetryInterceptor extends Interceptor {
  static const int _maxRetries = 3;
  static const Duration _initialDelay = Duration(seconds: 1);

  // Retries on: SocketException, timeouts
  // Waits: 1s, 2s, 4s
}
```

### Limitations
- Won't retry POST requests on some error types (idempotent only)
- Should verify backend is idempotent before retrying
- Can be adjusted for critical operations

---

## ADR-007: Secure Storage for JWT Tokens

### Decision
Use `flutter_secure_storage` for platform-native token storage.

### Rationale
1. **Security**: Stored in Keychain (iOS) / Keystore (Android), not shared preferences
2. **Encryption**: Platform handles encryption automatically
3. **OS Level**: Not accessible to other apps
4. **Standard**: Recommended by Flutter team and security experts

### Implementation
```dart
// Securely stored
await _secureStorage.write(key: 'access_token', value: token);

// Retrieved only when needed
final token = await _secureStorage.read(key: 'access_token');
```

### Never Do
```dart
// ❌ WRONG: Shared preferences (plaintext)
sharedPreferences.setString('token', jwt);

// ❌ WRONG: Hard-coded in code
const token = 'eyJhbGciOiJIUzI1NiIs...';
```

---

## ADR-008: Drift (SQLite) over Hive for Local Database

### Decision
Use Drift for relational database operations instead of Hive (key-value store).

### Rationale
1. **Relational Integrity**: Can enforce foreign keys, constraints
2. **Complex Queries**: Easy to query transaction history with filters, sorting
3. **Type Safety**: Generated code for all queries (no string queries)
4. **Migration Support**: Version database schema safely
5. **Testability**: Can test with in-memory SQLite

### Schema
```
UserCacheTable: User profiles
WalletCacheTable: Cached balance
TransactionQueueTable: Pending transfers (CRITICAL)
TransactionHistoryTable: Synced transaction records
```

### Trade-offs
- More complex than Hive
- Larger app size
- Worth it for structured data and complex queries

---

## ADR-009: Validation in Repository Layer

### Decision
Perform input validation in repository layer, not data sources.

### Rationale
1. **Single Responsibility**: Repository orchestrates validation
2. **Reusability**: Validation same for all data sources
3. **Type Safety**: Return `Left<ValidationFailure>` for invalid input
4. **Early Exit**: Fail fast before hitting network

### Implementation
```dart
@override
Future<Either<Failure, Unit>> register({...}) async {
  if (email.isEmpty || !email.contains('@')) {
    return Left(ValidationFailure('Invalid email'));
  }
  if (password.length < 6) {
    return Left(ValidationFailure('Password too short'));
  }
  // Now safe to proceed
}
```

---

## ADR-010: Current User ID Storage

### Decision
Store current user ID separately from tokens for quick access.

### Rationale
1. Many operations need user ID (e.g., accessing local cache)
2. Avoids decoding JWT tokens repeatedly
3. Simple to retrieve without parsing

### Implementation
```dart
// On login
await _tokenStorage.saveCurrentUserId(user.id);

// Later
final userId = await _tokenStorage.getCurrentUserId();
if (userId != null) {
  // User is authenticated
}
```

---

## Summary Table

| Decision | Technology | Reason |
|----------|-----------|--------|
| Architecture | Clean + Offline-First | Testable, maintainable, works offline |
| Error Handling | fpdart (Either) | Type-safe, composable |
| Immutability | Freezed | Prevents bugs, enables pattern matching |
| DI Container | GetIt + Injectable | Compile-time safe, testable |
| Network Client | Dio + Retrofit | Interceptors, automatic retry |
| Local DB | Drift | Relational, type-safe, migrations |
| Token Storage | flutter_secure_storage | Platform-native security |
| HTTP Retry | Exponential backoff | Handles poor connectivity |
| Validation | Repository layer | Early fail, reusable |

---

## Future Improvements

1. **Connectivity Monitoring**: Use `connectivity_plus` for real-time online/offline detection
2. **Token Refresh**: Implement refresh token flow for better UX
3. **Background Sync**: Use `workmanager` to sync pending transactions periodically
4. **Error Recovery**: Add smart retry strategies per error type
5. **Analytics**: Track offline transactions, network errors
6. **Tests**: Unit tests for all repositories and data sources
