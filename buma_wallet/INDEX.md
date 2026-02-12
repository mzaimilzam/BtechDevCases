# BUMA Wallet - Documentation Index

Welcome! This document helps you navigate the complete BUMA Wallet implementation.

---

## 🗺️ Quick Navigation

### For First-Time Setup
1. **Start here**: [QUICKSTART.md](QUICKSTART.md) - 5-minute setup guide
2. **Then read**: [README.md](README.md) - Complete overview
3. **Setup issues?**: See "Troubleshooting" section in QUICKSTART.md

### To Understand the Architecture
1. **Architecture Overview**: [README.md#architecture-overview](README.md#architecture-overview)
2. **Design Decisions**: [ARCHITECTURE.md](ARCHITECTURE.md) - 10 ADRs with rationale
3. **Visual Diagram**: [README.md#-offline-first-pattern-critical](README.md#-offline-first-pattern-critical)

### To Extend with New Features
1. **Code Examples**: [EXAMPLES.md](EXAMPLES.md) - 6 realistic examples
2. **Project Structure**: [README.md#-project-structure](README.md#-project-structure)
3. **Testing Pattern**: [EXAMPLES.md#example-6-unit-testing-a-repository](EXAMPLES.md#example-6-unit-testing-a-repository)

### To Understand Offline-First Pattern
1. **Core Concept**: [README.md#offline-first-pattern](README.md#-offline-first-pattern-critical)
2. **Implementation Details**: [ARCHITECTURE.md#adr-002](ARCHITECTURE.md#adr-002-offline-first-pattern-with-transaction-queuing)
3. **Example Flow**: [IMPLEMENTATION_SUMMARY.md#offline-transaction-flow-detailed](IMPLEMENTATION_SUMMARY.md#-offline-transaction-flow-detailed)

---

## 📚 Documentation Files

### Main Guides

| File | Purpose | Best For |
|------|---------|----------|
| **[QUICKSTART.md](QUICKSTART.md)** | 5-minute setup + key concepts | Getting started quickly |
| **[README.md](README.md)** | Complete reference (architecture, setup, Docker, dependencies) | Comprehensive overview |
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | 10 Architecture Decision Records with rationale | Understanding why decisions were made |
| **[EXAMPLES.md](EXAMPLES.md)** | 6 code examples + implementation patterns | Extending the application |
| **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** | What was built + complete file listing | Project completion checklist |

---

## 🏗️ Implementation Structure

### Domain Layer (`lib/domain/`)
Pure business logic, framework-independent:
- **Entities**: User, Wallet, Transaction, AuthToken (immutable)
- **Repositories**: AuthRepository, WalletRepository (interfaces)
- **Failures**: NetworkFailure, ServerFailure, CacheFailure, AuthFailure (union types)

**Read**: [README.md#domain-layer](README.md#1-domain-layer)

### Data Layer (`lib/data/`)
External dependencies and implementations:
- **DataSources**: Local (Drift) + Remote (Retrofit)
- **Models**: DTOs with JSON serialization
- **Mappers**: DTO ↔ Entity conversions
- **Repositories**: Implementation with offline-first logic

**Read**: [README.md#data-layer](README.md#2-data-layer)

### Core Layer (`lib/core/`)
Infrastructure and utilities:
- **Database**: Drift schema + CRUD operations
- **Network**: Dio + Retrofit with retry interceptor
- **Storage**: Secure JWT token storage
- **DI**: GetIt + Injectable configuration

**Read**: [README.md#core-infrastructure](README.md#-core-infrastructure)

---

## 🔑 Key Features

### Offline-First Pattern ✅
Handles poor connectivity (jungles, caves):
- **Reads**: Try remote → fallback to cache
- **Writes**: Queue locally → sync when online
- **Sync**: `syncPendingTransactions()` uploads queued items

**Learn More**: 
- [README.md#offline-first-pattern](README.md#-offline-first-pattern-critical)
- [ARCHITECTURE.md#adr-002](ARCHITECTURE.md#adr-002-offline-first-pattern-with-transaction-queuing)

### Automatic Retry Logic ✅
Network resilience:
- Up to 3 retries on network errors
- Exponential backoff: 1s → 2s → 4s
- Transparent to callers

**Learn More**: [ARCHITECTURE.md#adr-006](ARCHITECTURE.md#adr-006-retry-logic-with-exponential-backoff)

### Type-Safe Error Handling ✅
No exceptions in business logic:
- Uses `Either<Failure, Success>` from fpdart
- Pattern matching with `.fold()` or `.when()`
- Forces handling of error cases

**Learn More**: [ARCHITECTURE.md#adr-003](ARCHITECTURE.md#adr-003-functional-programming-with-fpdart-either-type)

### Immutable Models ✅
Prevents mutation bugs:
- All entities use Freezed
- Value equality works correctly
- Safe for concurrency

**Learn More**: [ARCHITECTURE.md#adr-004](ARCHITECTURE.md#adr-004-immutability-with-freezed)

---

## 🚀 Getting Started

### Step 1: Initial Setup (5 minutes)
```bash
git clone <url>
cd buma_wallet
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
docker-compose up -d
cp .env.example .env
flutter run
```

**Detailed Guide**: [QUICKSTART.md#5-minute-setup](QUICKSTART.md#5-minute-setup)

### Step 2: Understand Architecture
Read in this order:
1. [README.md#architecture-overview](README.md#architecture-overview) - Big picture
2. [ARCHITECTURE.md](#architecture-decision-records-adr) - Why decisions were made
3. [EXAMPLES.md](EXAMPLES.md) - How to extend

### Step 3: Explore Code
- **Domain**: [lib/domain/](lib/domain/)
  - [lib/domain/entities/](lib/domain/entities/) - User, Wallet, Transaction, AuthToken
  - [lib/domain/repositories/](lib/domain/repositories/) - Interfaces
  - [lib/domain/failures/](lib/domain/failures/) - Error types

- **Data**: [lib/data/](lib/data/)
  - [lib/data/datasources/](lib/data/datasources/) - Local + Remote
  - [lib/data/models/](lib/data/models/) - DTOs
  - [lib/data/repositories/](lib/data/repositories/) - Implementations

- **Core**: [lib/core/](lib/core/)
  - [lib/core/database/](lib/core/database/) - Drift DB
  - [lib/core/network/](lib/core/network/) - API client + interceptors
  - [lib/core/storage/](lib/core/storage/) - JWT storage
  - [lib/core/di/](lib/core/di/) - Dependency injection

---

## 🧪 Testing

### Unit Test Example
See [test/domain_and_data_test.dart](test/domain_and_data_test.dart)

**Learn More**: [EXAMPLES.md#example-6-unit-testing-a-repository](EXAMPLES.md#example-6-unit-testing-a-repository)

### Run Tests
```bash
flutter test
```

---

## 🔧 Common Tasks

### Add a New Endpoint
1. Add method to [lib/core/network/api_client.dart](lib/core/network/api_client.dart)
2. Create DTOs in [lib/data/models/](lib/data/models/)
3. Create mappers in [lib/data/mappers/](lib/data/mappers/)
4. Update data sources
5. Update repository interface + implementation
6. Run code generation

**Example**: [EXAMPLES.md#example-1-extending-with-a-new-feature](EXAMPLES.md#example-1-extending-with-a-new-feature-transaction-filtering)

### Debug Network Issues
- Enable logging: `ENABLE_API_LOGGING=true` in `.env`
- Check Flutter console (PrettyDioLogger output)
- View network tab in DevTools

**More**: [QUICKSTART.md#troubleshooting](QUICKSTART.md#troubleshooting)

### Test Offline Mode
1. Disable WiFi/cellular on device
2. App continues working (cached data, transaction queuing)
3. Re-enable network
4. Transactions sync automatically

**How It Works**: [IMPLEMENTATION_SUMMARY.md#-offline-transaction-flow-detailed](IMPLEMENTATION_SUMMARY.md#-offline-transaction-flow-detailed)

### Generate Code
```bash
# Full rebuild
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate)
flutter pub run build_runner watch --delete-conflicting-outputs
```

**Learn More**: [QUICKSTART.md#code-generation](QUICKSTART.md#code-generation)

---

## 📚 Architecture Decision Records (ADRs)

[ARCHITECTURE.md](ARCHITECTURE.md) contains 10 detailed ADRs:

1. **ADR-001**: Clean Architecture Pattern
2. **ADR-002**: Offline-First Pattern with Transaction Queuing
3. **ADR-003**: Functional Programming with fpdart (Either)
4. **ADR-004**: Immutability with Freezed
5. **ADR-005**: Service Locator Pattern (GetIt + Injectable)
6. **ADR-006**: Retry Logic with Exponential Backoff
7. **ADR-007**: Secure Storage for JWT Tokens
8. **ADR-008**: Drift (SQLite) over Hive
9. **ADR-009**: Validation in Repository Layer
10. **ADR-010**: Current User ID Storage

Each ADR includes:
- Decision made
- Rationale
- Implementation details
- Trade-offs
- Alternatives considered

---

## 📋 Checklist for New Developers

- [ ] Read [QUICKSTART.md](QUICKSTART.md) (5 min)
- [ ] Complete setup steps (5 min)
- [ ] Run `flutter run` successfully
- [ ] Read [README.md#architecture-overview](README.md#architecture-overview) (10 min)
- [ ] Read [ARCHITECTURE.md](ARCHITECTURE.md) (20 min)
- [ ] Explore [lib/domain/](lib/domain/) folder structure
- [ ] Explore [lib/data/](lib/data/) folder structure
- [ ] Review [EXAMPLES.md](EXAMPLES.md) for extension patterns (15 min)
- [ ] Run `flutter test` to see example tests
- [ ] Ask questions about ADR decisions in [ARCHITECTURE.md](ARCHITECTURE.md)

**Total Time**: ~60 minutes for complete understanding

---

## 🎯 File Quick Reference

| Path | Purpose |
|------|---------|
| [pubspec.yaml](pubspec.yaml) | All dependencies |
| [build.yaml](build.yaml) | Code generation config |
| [docker-compose.yml](docker-compose.yml) | Backend stack (PostgreSQL, API, Redis) |
| [.env.example](.env.example) | Environment variables template |
| [lib/domain/](lib/domain/) | Business logic (framework-independent) |
| [lib/data/](lib/data/) | Data access layer (Drift, Retrofit, mappers) |
| [lib/core/](lib/core/) | Infrastructure (database, network, DI, storage) |
| [test/](test/) | Example unit tests |

---

## 💡 Pro Tips

1. **Code Generation Issues?** Always run: `flutter pub run build_runner clean && flutter pub run build_runner build`

2. **Want to Understand Offline Logic?** Read [IMPLEMENTATION_SUMMARY.md#-offline-transaction-flow-detailed](IMPLEMENTATION_SUMMARY.md#-offline-transaction-flow-detailed)

3. **Extending the App?** Use [EXAMPLES.md](EXAMPLES.md) as template for new features

4. **Network Debugging?** Set `ENABLE_API_LOGGING=true` in `.env`

5. **Testing Offline?** Disable WiFi/cellular → use app → re-enable → syncs automatically

6. **Confused about Design?** Each ADR in [ARCHITECTURE.md](ARCHITECTURE.md) explains the "why"

---

## 🚨 Troubleshooting Links

| Issue | Solution |
|-------|----------|
| "Type not found" after code change | Run code generation: [QUICKSTART.md#code-generation](QUICKSTART.md#code-generation) |
| App crashes on startup | Check database init + storage permissions in README |
| Network timeout | Increase `API_TIMEOUT_SECONDS` in `.env` |
| Offline transactions not syncing | Call `syncPendingTransactions()` when online |

**Full Troubleshooting**: [QUICKSTART.md#troubleshooting](QUICKSTART.md#troubleshooting)

---

## 📞 Documentation Summary

| Document | Read Time | For |
|----------|-----------|-----|
| [QUICKSTART.md](QUICKSTART.md) | 10 min | Getting started |
| [README.md](README.md) | 20 min | Complete overview |
| [ARCHITECTURE.md](ARCHITECTURE.md) | 30 min | Understanding design |
| [EXAMPLES.md](EXAMPLES.md) | 20 min | Extending the app |
| [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) | 15 min | What was built |
| **Total** | **~90 min** | **Full mastery** |

---

## ✨ Key Takeaways

This is a **production-ready, offline-first Flutter Clean Architecture** with:

✅ Strict separation of concerns (Domain, Data, Core layers)
✅ Offline-first pattern (transactions queue locally, sync when online)
✅ Automatic network retry with exponential backoff
✅ Type-safe error handling (Either<Failure, Success>)
✅ Immutable models (Freezed)
✅ Secure token storage (Keychain/Keystore)
✅ Dependency injection (testable)
✅ Complete documentation (5 guides)
✅ Code examples (6 patterns)
✅ Architecture decisions documented (10 ADRs)

**Ready for:** Presentation layer development or direct use!

---

## 🎓 Next Steps

1. **Begin with**: [QUICKSTART.md](QUICKSTART.md)
2. **Understand**: [ARCHITECTURE.md](ARCHITECTURE.md)
3. **Extend using**: [EXAMPLES.md](EXAMPLES.md)
4. **Reference**: [README.md](README.md)

Happy coding! 🚀
