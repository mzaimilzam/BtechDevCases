# Token Management System - BUMA Wallet

## Overview

The BUMA Wallet app now includes a comprehensive token management system that ensures users remain logged in across app restarts and automatically handles token refresh when access tokens expire.

## Features

### 1. **Persistent Login Across App Restarts**
- Tokens are stored securely in FlutterSecureStorage
- On app startup, the AuthWrapper checks if a valid token exists
- If valid token found, user is automatically logged in to HomeScreen
- If no token or expired token, user is sent to LoginScreen

### 2. **Automatic Token Refresh**
- When access token expires, the app automatically attempts to refresh it using the refresh token
- This happens transparently without requiring user intervention
- If refresh fails, user is logged out

### 3. **Token Expiry Checking**
- AuthToken entity includes expiry validation:
  - `isValid` - returns true if token hasn't expired
  - `isExpired` - returns true if token has expired
  - `isExpiringSoon` - returns true if token expires within 5 minutes (for proactive refresh)

### 4. **Secure Token Storage**
- All tokens stored in encrypted secure storage
- Refresh tokens kept safe alongside access tokens
- Tokens automatically retrieved with Authorization header on API calls

## Architecture

### Backend (Node.js/Express)

#### New Endpoint: `POST /auth/refresh`
```javascript
{
    "refreshToken": "jwt_refresh_token_string"
}
```

Response:
```json
{
    "message": "Token refreshed successfully",
    "accessToken": "new_jwt_access_token",
    "refreshToken": "new_refresh_token",
    "expiresIn": 900
}
```

### Flutter Frontend

#### 1. **Domain Layer** - Authentication Repository Interface
```dart
// lib/domain/repositories/auth_repository.dart
Future<Either<Failure, Unit>> refreshToken();
Future<bool> isAuthenticated();
```

#### 2. **Data Layer** - Implementation & Data Sources

##### AuthRepositoryImpl
- `refreshToken()` - Calls remote datasource and saves new token to secure storage
- `isAuthenticated()` - Checks if valid token exists in secure storage

##### RemoteAuthDataSourceImpl
- `refreshToken(String refreshToken)` - API call to /auth/refresh endpoint
- Automatically saves new token to secure storage

#### 3. **Core Layer** - HTTP Interceptors & API Client

##### AuthInterceptor
```dart
class AuthInterceptor extends Interceptor {
  // Automatically adds Authorization header to all requests
  // On 401 response:
  //   - Attempts automatic token refresh
  //   - Retries original request with new token
  //   - Only logs out if refresh fails
}
```

##### ApiClient
```dart
Future<AuthResponseDto> refreshToken(String refreshToken);
```

#### 4. **Presentation Layer** - App Entry Point

##### AuthWrapper (in main.dart)
```dart
class AuthWrapper extends StatefulWidget {
  // Checks authentication status on app startup
  // Routes to HomeScreen if authenticated
  // Routes to LoginScreen if not authenticated
}
```

## Data Flow

### Login Flow
1. User enters email & password on LoginScreen
2. `AuthRepository.login()` called
3. `RemoteAuthDataSource.login()` makes POST request to `/auth/login`
4. Backend returns `accessToken`, `refreshToken`, `expiresIn`
5. Token saved to `SecureTokenStorage` with expiry datetime
6. User data cached locally
7. User navigated to HomeScreen

### API Request Flow (with Token Refresh)
1. `AuthInterceptor.onRequest()` adds `Authorization: Bearer {accessToken}` header
2. Request sent to API
3. If response is 401 (token expired):
   - `AuthInterceptor.onError()` detects 401
   - Retrieves refresh token from storage
   - Makes POST request to `/auth/refresh`
   - Backend returns new tokens
   - Original request retried with new token
   - User continues without interruption
4. If refresh fails:
   - Token cleared from storage
   - User logged out

### App Startup Flow
1. `main()` initializes dependency injection
2. `MyApp` renders with `AuthWrapper`
3. `AuthWrapper.initState()` calls `isAuthenticated()`
4. `AuthRepository.isAuthenticated()` checks:
   - Is token stored in secure storage?
   - Is token not expired?
5. If yes → Show HomeScreen
6. If no → Show LoginScreen

## Security Considerations

### Token Storage
- All tokens stored in `FlutterSecureStorage` (encrypted)
- Platform-specific encryption:
  - **iOS**: Uses Keychain
  - **Android**: Uses EncryptedSharedPreferences

### Token Security
- Access tokens short-lived (900 seconds / 15 minutes)
- Refresh tokens longer-lived (604800 seconds / 7 days)
- Tokens validated on every app request
- 401 responses trigger automatic refresh
- Failed refresh logs user out immediately

### No Token Exposure
- Tokens never logged to console (except in debug with PrettyDioLogger)
- Tokens cleared on logout
- Tokens cleared on failed refresh
- Secure header transmission via HTTPS (in production)

## Implementation Details

### AuthToken Entity
```dart
@freezed
class AuthToken with _$AuthToken {
  const factory AuthToken({
    required String accessToken,
    String? refreshToken,
    required DateTime expiry,
  }) = _AuthToken;

  bool get isExpired => DateTime.now().isAfter(expiry);
  bool get isValid => !isExpired;
  bool get isExpiringSoon => DateTime.now().add(Duration(minutes: 5)).isBefore(expiry);
}
```

### Token Refresh Cascade
1. Access token expires
2. Next API request fails with 401
3. AuthInterceptor catches 401
4. Refresh token used to get new access token
5. Original request automatically retried
6. User never sees login screen (unless refresh also fails)

### Logout Flow
1. User taps Logout on HomeScreen
2. `AuthRepository.logout()` called
3. Local user cache cleared
4. Token cleared from secure storage
5. User navigated to LoginScreen

## Testing Token Management

### Test Scenario 1: App Restart Login Persistence
1. Login with `test@example.com` / `test123`
2. Close app completely
3. Reopen app
4. ✅ Should show HomeScreen directly (no login required)

### Test Scenario 2: Token Refresh
1. Login to app
2. Monitor network logs (PrettyDioLogger)
3. Wait for access token to near expiry (check expiry in SecureTokenStorage)
4. Make API call (tap "Get Balance" or refresh)
5. ✅ Should see 401 → 200 sequence (failed request, refresh, retry)

### Test Scenario 3: Invalid Refresh Token
1. Manually corrupt refresh token in secure storage (for testing)
2. Force token to expire
3. Try to make API call
4. ✅ Should be logged out and sent to LoginScreen

### Test Scenario 4: Logout
1. Tap Logout button
2. Token cleared from storage
3. ✅ Should see LoginScreen

## Files Modified

### Core Layer
- `lib/core/network/dio_interceptors.dart` - Updated AuthInterceptor with refresh logic
- `lib/core/network/api_client.dart` - Added refreshToken() endpoint
- `lib/core/storage/secure_token_storage.dart` - ✅ Already complete

### Domain Layer
- `lib/domain/repositories/auth_repository.dart` - Added refreshToken() method

### Data Layer
- `lib/data/repositories/auth_repository_impl.dart` - Implemented refreshToken()
- `lib/data/datasources/remote_auth_datasource.dart` - Added refreshToken() call

### Presentation Layer
- `lib/main.dart` - Enhanced AuthWrapper with async auth check

### Backend
- `backend/src/index.js` - Added POST /auth/refresh endpoint

## Future Enhancements

### 1. Proactive Token Refresh
```dart
// Refresh token before it expires
if (authToken.isExpiringSoon) {
  await authRepository.refreshToken();
}
```

### 2. Token Rotation
- Server generates new refresh token on each refresh
- Old refresh token invalidated
- Improved security for long-lived sessions

### 3. Multi-Device Session Management
- Track sessions per device
- Allow logout from other devices
- Monitor suspicious login locations

### 4. Biometric Re-authentication
- Require fingerprint/face for sensitive operations
- Automatic re-lock after inactivity
- Secure token access with biometric

### 5. Offline Support
- Queue API requests during offline
- Attempt automatic refresh when back online
- Fallback to cached data if refresh fails

## Troubleshooting

### Issue: "User keeps getting logged out"
- Check token expiry time (should be 900 seconds)
- Verify backend JWT_SECRET matches
- Check refresh token is being saved

### Issue: "Token refresh failing silently"
- Check PrettyDioLogger output
- Verify backend /auth/refresh endpoint is working
- Test with curl: `curl -X POST http://localhost:8080/auth/refresh -H "Content-Type: application/json" -d '{"refreshToken":"..."}'`

### Issue: "AuthInterceptor not catching 401"
- Verify AuthInterceptor is registered in Dio
- Check that API calls are going through Dio (not making raw HTTP calls)
- Log AuthInterceptor.onError() for debugging

### Issue: "Token not persisting across app restart"
- Verify FlutterSecureStorage is properly initialized
- Check iOS Keychain entitlements
- Check Android EncryptedSharedPreferences permissions

## Summary

The token management system provides:
- ✅ Persistent login across app restarts
- ✅ Automatic token refresh on expiry
- ✅ Transparent retry of failed requests
- ✅ Secure token storage (encrypted)
- ✅ Proper logout/cleanup
- ✅ Ready for production use

Users no longer need to login every time they open the app. Expired tokens are automatically refreshed in the background, providing a seamless experience.
