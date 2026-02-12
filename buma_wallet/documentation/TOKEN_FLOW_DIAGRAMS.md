# Token Management System - Complete Flow Diagrams

## 1. App Startup Flow

```
┌─────────────────────────────────┐
│      App Starts                 │
│   main() function called        │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│  WidgetsFlutterBinding          │
│  ensureInitialized()            │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│  configureDependencies()        │
│  (DI Setup)                     │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│  runApp(MyApp())                │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│  MyApp build()                  │
│  Shows AuthWrapper              │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│  AuthWrapper initState()        │
│  Calls isAuthenticated()        │
└──────────────┬──────────────────┘
               │
               ▼
        ┌──────────────────┐
        │ Is token valid?  │
        └────┬────────┬────┘
             │        │
        YES  │        │  NO
             ▼        ▼
    ┌─────────────┐  ┌──────────────┐
    │ HomeScreen  │  │ LoginScreen  │
    └─────────────┘  └──────────────┘
```

## 2. Login Flow

```
┌──────────────────────────────────┐
│  User enters credentials         │
│  - Email: test@example.com       │
│  - Password: test123             │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  LoginScreen.login() called      │
│  authRepo.login(email, password) │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  AuthRepositoryImpl.login()       │
│  - Validates input               │
│  - Calls remoteDataSource.login()│
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  POST /auth/login                │
│  {                               │
│    "email": "...",               │
│    "password": "..."             │
│  }                               │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  Backend validates credentials   │
│  Generates JWT tokens            │
│  Returns:                        │
│  {                               │
│    accessToken: "jwt...",        │
│    refreshToken: "jwt...",       │
│    expiresIn: 900                │
│  }                               │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  RemoteAuthDataSourceImpl.login() │
│  - Saves token via               │
│    tokenStorage.saveAuthToken()  │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  SecureTokenStorage.save()       │
│  - Encrypts tokens               │
│  - Stores in platform storage:   │
│    - iOS: Keychain               │
│    - Android: Encrypted Prefs    │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  Return User object to UI        │
│  Show HomeScreen                 │
└──────────────────────────────────┘
```

## 3. Normal API Request Flow

```
┌──────────────────────────────────┐
│  User makes API call             │
│  GET /wallet/balance             │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  AuthInterceptor.onRequest()     │
│  - Retrieves token from storage  │
│  - Adds Authorization header     │
│    "Authorization: Bearer ..."   │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  Dio HTTP Client                 │
│  GET http://10.0.2.2:8080/...    │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  Server validates token          │
│  Token is VALID                  │
│  Returns 200 OK                  │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  Dio HTTP Client                 │
│  Response received               │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  Process response                │
│  Return data to caller           │
│  Show wallet balance             │
└──────────────────────────────────┘
```

## 4. Expired Token Refresh Flow

```
┌──────────────────────────────────┐
│  User makes API call             │
│  GET /wallet/balance             │
│  (Token has expired)             │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  AuthInterceptor.onRequest()     │
│  - Adds old Authorization header │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  Server receives request         │
│  Token is EXPIRED                │
│  Returns 401 Unauthorized        │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  AuthInterceptor.onError()       │
│  Detects 401 status              │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  Check if refresh token exists   │
│  in SecureTokenStorage           │
└────────┬─────────────────────┬───┘
         │                     │
    YES  │                     │ NO
         ▼                     ▼
    ┌─────────┐        ┌─────────────┐
    │ Proceed │        │ Clear token │
    │ with    │        │ Logout user │
    │ refresh │        └─────────────┘
    └────┬────┘
         │
         ▼
┌──────────────────────────────────┐
│  POST /auth/refresh              │
│  {                               │
│    "refreshToken": "jwt..."      │
│  }                               │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  Backend validates refresh token │
│  Generates NEW access token      │
│  Returns:                        │
│  {                               │
│    accessToken: "new_jwt...",    │
│    refreshToken: "new_jwt...",   │
│    expiresIn: 900                │
│  }                               │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  Save new tokens to              │
│  SecureTokenStorage              │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  Automatic Retry                 │
│  GET /wallet/balance             │
│  Authorization: Bearer NEW_TOKEN │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  Server validates NEW token      │
│  Token is VALID                  │
│  Returns 200 OK with data        │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  Return response to UI           │
│  User sees wallet balance        │
│  NO re-login needed              │
└──────────────────────────────────┘
```

## 5. Logout Flow

```
┌──────────────────────────────────┐
│  User taps Logout button         │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  authRepo.logout()               │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  LocalAuthDataSource.clearUser() │
│  - Remove cached user data       │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  SecureTokenStorage.clearToken() │
│  - Delete encrypted tokens       │
│    from platform storage:        │
│    - iOS: Keychain               │
│    - Android: Encrypted Prefs    │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  Navigate to LoginScreen         │
│  User must login again           │
└──────────────────────────────────┘
```

## 6. Token Validation on App Open

```
┌──────────────────────────────────┐
│  App launched                    │
│  AuthWrapper created             │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  authRepo.isAuthenticated()      │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  SecureTokenStorage.getToken()   │
│  - Retrieve encrypted token      │
└────────────┬─────────────────────┘
             │
             ▼
        ┌──────────────────┐
        │ Token exists?    │
        └────┬────────┬────┘
             │        │
        YES  │        │ NO
             ▼        ▼
    ┌─────────────┐  ┌──────────┐
    │ Check if    │  │ Show     │
    │ expired     │  │ Login    │
    └──┬──────┬───┘  │ Screen   │
       │      │      └──────────┘
   YES │      │ NO
       ▼      ▼
    ┌───┐  ┌──────────┐
    │   │  │ Show     │
    │ L │  │ Home     │
    │ O │  │ Screen   │
    │ G │  └──────────┘
    │ O │
    │ U │
    │ T │
    └───┘
       │
       ▼
   ┌─────────┐
   │ Login   │
   │ Screen  │
   └─────────┘
```

## 7. Complete Request Lifecycle

```
Start: User Makes API Call
       │
       ▼
Add Auth Header (Token)
       │
       ▼
Send HTTP Request
       │
       ▼
    ┌──────────────┐
    │ Response?    │
    └────┬─────┬───┘
         │     │
    200  │     │ 401 (Token Expired)
         ▼     ▼
      SUCCESS  REFRESH TOKEN
         │        │
         │        ├─→ POST /auth/refresh
         │        │
         │        ├─→ Get new tokens
         │        │
         │        ├─→ Save to storage
         │        │
         │        └─→ RETRY request
         │             │
         │             └─→ SUCCESS
         │
         ▼
    Return Data to UI
```

## 8. Interceptor Chain

```
Dio HTTP Client
    │
    ▼
RetryInterceptor (3 retries on network error)
    │
    ▼
AuthInterceptor (add token + handle 401)
    ├─ onRequest()
    │  └─ Add Authorization header
    │
    ├─ onResponse()
    │  └─ Pass through (200, 201, 204...)
    │
    └─ onError()
       ├─ Check if 401
       ├─ Refresh token if available
       ├─ Retry request with new token
       └─ Or logout if refresh fails
    │
    ▼
Request sent to server
```

## 9. Token Storage Hierarchy

```
App Memory
    │
    ├─ AuthToken (current session)
    │   ├─ accessToken (string)
    │   ├─ refreshToken (string)
    │   └─ expiry (DateTime)
    │
    ▼
SecureTokenStorage Interface
    │
    ├─ saveAuthToken(token)
    ├─ getAuthToken()
    ├─ getAccessToken()
    └─ clearAuthToken()
    │
    ▼
Platform-Specific Implementation
    │
    ├─ iOS: Keychain
    │  └─ Encrypted storage
    │
    └─ Android: EncryptedSharedPreferences
       └─ Encrypted storage
```

## 10. Error Handling Tree

```
API Response
    │
    ├─ 200 OK
    │  └─ Return data
    │
    ├─ 201 Created
    │  └─ Return data
    │
    ├─ 401 Unauthorized
    │  │
    │  ├─ Has refresh token?
    │  │  │
    │  │  ├─ YES
    │  │  │  ├─ Refresh token
    │  │  │  │
    │  │  │  ├─ Success?
    │  │  │  │  ├─ YES → Retry request
    │  │  │  │  └─ NO → Logout
    │  │  │  │
    │  │  │  └─ (Logout if refresh fails)
    │  │  │
    │  │  └─ NO
    │  │     └─ Logout immediately
    │  │
    │  └─ (User sent to LoginScreen)
    │
    ├─ 4xx Client Error
    │  └─ Show error message to user
    │
    └─ 5xx Server Error
       └─ Show error message & retry option
```

## Timeline Example

```
Time    Event
────────────────────────────────────────────────────────────

00:00   User opens app
00:05   AuthWrapper checks: Token valid? YES
00:06   Show HomeScreen
00:15   User navigates wallet
00:20   API request with token (token has 50 min left)
00:21   ← Response 200 OK
00:25   Close app
01:00   Reopen app
01:01   AuthWrapper checks: Token still valid? YES (expires in 43 min)
01:02   Show HomeScreen directly (no re-login!)
01:10   API request (token has 33 min left)
01:11   ← Response 200 OK
02:30   API request (token has 3 sec left - about to expire)
02:31   ← Response 401 (token expired)
02:32   AuthInterceptor: Refresh token!
02:33   ← New tokens received (15 min validity)
02:34   Automatic retry of API request
02:35   ← Response 200 OK (user didn't notice!)
```

## State Transitions

```
┌─────────────────────────────────────────────────────────┐
│                    AUTH STATES                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  NOT_AUTHENTICATED                                      │
│  ├─ No token in storage                                 │
│  ├─ LoginScreen visible                                 │
│  └─ Can only access /auth/register, /auth/login         │
│     │                                                   │
│     │ (User logs in)                                    │
│     ▼                                                   │
│  AUTHENTICATED                                          │
│  ├─ Valid token in storage                              │
│  ├─ HomeScreen visible                                  │
│  ├─ Can access wallet endpoints                         │
│  │                                                      │
│  ├─ Token expires                                       │
│  │  └─ Try refresh                                      │
│  │     ├─ Refresh succeeds → AUTHENTICATED              │
│  │     └─ Refresh fails → NOT_AUTHENTICATED             │
│  │                                                      │
│  └─ User logs out → NOT_AUTHENTICATED                   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

This comprehensive flow shows how the token management system works at every stage of the app lifecycle!
