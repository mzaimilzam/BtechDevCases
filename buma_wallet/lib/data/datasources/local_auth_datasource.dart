import 'package:injectable/injectable.dart';

import '../../core/database/app_database.dart';
import '../../domain/entities/user.dart';

/// Local data source for user-related cached data.
/// Implements offline-first pattern by caching user profile.
abstract interface class LocalAuthDataSource {
  /// Cache user profile locally
  Future<void> cacheUser(User user);

  /// Retrieve cached user by ID
  Future<User?> getUserById(String userId);

  /// Clear cached user
  Future<void> clearUser();
}

/// Implementation of LocalAuthDataSource using Drift
@Injectable(as: LocalAuthDataSource)
class LocalAuthDataSourceImpl implements LocalAuthDataSource {
  final AppDatabase _database;

  LocalAuthDataSourceImpl(this._database);

  @override
  Future<void> cacheUser(User user) async {
    await _database.cacheUser(
      UserCacheData(
        id: user.id,
        email: user.email,
        name: user.name,
        cachedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<User?> getUserById(String userId) async {
    final cachedUser = await _database.getUserById(userId);
    if (cachedUser != null) {
      return User(
        id: cachedUser.id,
        email: cachedUser.email,
        name: cachedUser.name,
      );
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await _database.clearUserCache();
  }
}
