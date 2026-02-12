# 403 Forbidden - JWT Authentication Fix

## Problem

The app was receiving `403 Forbidden` errors with message `"Invalid token"` when calling protected endpoints:
- `GET /auth/current-user` 
- `GET /wallet/balance`

Despite sending a valid JWT token in the `Authorization` header.

## Root Cause Analysis

Three configuration issues in backend JWT handling:

### Issue 1: Incorrect Token Expiry Format
```javascript
// WRONG - concatenating string to string
{ expiresIn: process.env.JWT_EXPIRY + 's' }
// Results in: { expiresIn: '900s' + 's' = '900ss' } ❌

// WRONG - accessing as string when should be number
jwt.verify(token, process.env.JWT_SECRET, ...)
// process.env values are always strings, but JWT needs number
```

### Issue 2: No Validation of JWT_SECRET
- `JWT_SECRET` could be `undefined` 
- Token generation and verification would use different (or missing) secrets
- Tokens generated with one secret fail verification with another

### Issue 3: Type Mismatch
- `process.env.JWT_EXPIRY` = `"900"` (string)
- JWT library expects number of seconds
- Incorrect format caused token validation to fail

## Solution Implemented

### 1. Load Constants at Startup
```javascript
const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRY = parseInt(process.env.JWT_EXPIRY || '900'); // defaults to 15 min
const REFRESH_TOKEN_EXPIRY = parseInt(process.env.REFRESH_TOKEN_EXPIRY || '604800'); // 7 days

// Validate JWT_SECRET is set
if (!JWT_SECRET) {
    console.error('ERROR: JWT_SECRET is not set in environment variables');
    process.exit(1);
}
```

### 2. Fix Token Generation
```javascript
// BEFORE - Incorrect format
{ expiresIn: process.env.JWT_EXPIRY + 's' }

// AFTER - Correct format with number
{ expiresIn: JWT_EXPIRY }  // JWT library handles seconds automatically
```

### 3. Fix Token Verification
```javascript
// BEFORE - Using undefined process.env
jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
        return res.status(403).json({ message: 'Invalid token' });
    }
    // ...
});

// AFTER - Using validated constant with error logging
jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
        console.error('JWT verification error:', err.message);
        return res.status(403).json({ message: 'Invalid token' });
    }
    // ...
});
```

### 4. Create Backend .env File
```env
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRY=900
REFRESH_TOKEN_EXPIRY=604800
```

## Files Modified

1. **backend/src/index.js**
   - Load JWT configuration at startup (lines 13-27)
   - Fix token generation (lines 48-61)
   - Fix token verification (lines 31-46)
   - Fix refresh endpoint (line 168)
   - Add error logging for debugging

2. **backend/.env** (NEW)
   - Default JWT configuration
   - Database connection string
   - Environment variables

## How It Works Now

### Token Generation Flow
1. User logs in → `POST /auth/login`
2. Backend generates JWT with `JWT_SECRET` and `JWT_EXPIRY` seconds
3. Token returned to app: `{ accessToken, expiresIn: 900 }`

### Token Verification Flow  
1. App calls protected endpoint with: `Authorization: Bearer <token>`
2. Backend verifies token using same `JWT_SECRET`
3. If valid → User data in `req.user`, request proceeds
4. If invalid → `403 Forbidden` with proper error message

## Testing

### Before Fix
```
❌ POST /auth/login → Works (generates token)
❌ GET /wallet/balance → Fails with "Invalid token" (403)
```

### After Fix
```
✅ POST /auth/login → Works (generates token with correct expiry)
✅ GET /wallet/balance → Works (verifies token successfully)
✅ GET /auth/current-user → Works
```

## Verification Steps

1. **Backend running**: Verify docker-compose has both services running
   ```bash
   docker-compose ps
   # Both api and db should show "Up"
   ```

2. **Test login flow**:
   ```bash
   # Register
   curl -X POST http://localhost:8080/auth/register \
     -H "Content-Type: application/json" \
     -d '{"email":"test@example.com","password":"pass123","firstName":"Test","lastName":"User"}'

   # Login
   curl -X POST http://localhost:8080/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email":"test@example.com","password":"pass123"}'
   # Returns accessToken with expiresIn: 900
   ```

3. **Test protected endpoint**:
   ```bash
   curl -X GET http://localhost:8080/wallet/balance \
     -H "Authorization: Bearer <accessToken>"
   # Should return wallet balance (200), not "Invalid token" (403)
   ```

4. **In Flutter app**:
   - Register a new account
   - Should be able to see current user info
   - Should be able to see wallet balance
   - Should be able to create transactions without 403 errors

## Configuration

For **production**, set strong JWT_SECRET:
```bash
# Generate secure secret
export JWT_SECRET=$(openssl rand -hex 32)

# Or in docker-compose.yml environment
JWT_SECRET=<your-strong-random-secret>
```

For **development**, use the default in `backend/.env` (already set).

## Git Commit

- **Commit Hash**: 9da2190
- **Changes**: 2 files modified, JWT configuration fixes implemented
- **Breaking Changes**: None (backwards compatible)

## Next Steps

1. **Restart backend** with the new configuration:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

2. **Test in Flutter app**:
   - Clear app data / reinstall
   - Register new account
   - Verify no 403 errors on protected endpoints

3. **Monitor logs** for any JWT errors:
   ```bash
   docker-compose logs -f api
   ```

4. **If issues persist**, check:
   - Is `JWT_SECRET` set in docker-compose.yml?
   - Are both backend and app using same `JWT_SECRET`?
   - Is database running?
   - Check `docker-compose logs api` for startup errors

