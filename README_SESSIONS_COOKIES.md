# FunaGig Sessions & Cookies Documentation

## 🍪 **Overview**

This document provides comprehensive documentation for the session and cookie management system implemented in the FunaGig platform. The system ensures secure user authentication, session persistence, and proper security measures.

## 🔐 **Security Features**

### **Session Security**
- **HttpOnly Cookies** - Prevents XSS attacks by making cookies inaccessible to JavaScript
- **SameSite Lax** - Provides CSRF protection while maintaining usability
- **Session Timeout** - Automatic logout after 24 hours of inactivity
- **Activity Tracking** - Monitors user activity and updates last activity timestamp
- **Secure Session Destruction** - Proper cleanup of session data and cookies

### **Cookie Configuration**
- **Lifetime**: 24 hours (86400 seconds)
- **Path**: `/` (accessible across the entire domain)
- **Domain**: Empty (restricted to current domain)
- **Secure**: `false` (set to `true` for HTTPS in production)
- **HttpOnly**: `true` (prevents JavaScript access)
- **SameSite**: `Lax` (CSRF protection)

## 🏗️ **Architecture**

### **Server-Side Implementation**

#### **Session Configuration (php/config.php)**
```php
// Session and Cookie Configuration
ini_set('session.cookie_httponly', 1);
ini_set('session.cookie_secure', 0); // Set to 1 for HTTPS
ini_set('session.use_only_cookies', 1);
ini_set('session.cookie_samesite', 'Lax');
ini_set('session.cookie_lifetime', 86400); // 24 hours

// Set session cookie parameters
session_set_cookie_params([
    'lifetime' => 86400, // 24 hours
    'path' => '/',
    'domain' => '',
    'secure' => false, // Set to true for HTTPS
    'httponly' => true,
    'samesite' => 'Lax'
]);

session_start();
```

#### **Session Management Functions**

**1. createUserSession($user)**
- Creates a secure user session
- Stores user data in session variables
- Sets session cookie
- Tracks login time and activity

```php
function createUserSession($user) {
    $_SESSION['user_id'] = $user['id'];
    $_SESSION['user_name'] = $user['name'];
    $_SESSION['user_email'] = $user['email'];
    $_SESSION['user_type'] = $user['type'];
    $_SESSION['login_time'] = time();
    $_SESSION['last_activity'] = time();
    
    // Set session cookie
    setcookie('funagig_session', session_id(), time() + 86400, '/', '', false, true);
    
    return true;
}
```

**2. destroyUserSession()**
- Clears all session data
- Destroys session cookies
- Properly terminates the session

```php
function destroyUserSession() {
    // Clear session data
    $_SESSION = array();
    
    // Destroy session cookie
    if (isset($_COOKIE[session_name()])) {
        setcookie(session_name(), '', time() - 42000, '/');
    }
    
    // Destroy session
    session_destroy();
    
    return true;
}
```

**3. isUserLoggedIn()**
- Checks if user has an active session
- Validates session data integrity

```php
function isUserLoggedIn() {
    return isset($_SESSION['user_id']) && !empty($_SESSION['user_id']);
}
```

**4. getCurrentUser()**
- Retrieves current user data from session
- Returns user information array

```php
function getCurrentUser() {
    if (!isUserLoggedIn()) {
        return null;
    }
    
    return [
        'id' => $_SESSION['user_id'],
        'name' => $_SESSION['user_name'] ?? '',
        'email' => $_SESSION['user_email'] ?? '',
        'type' => $_SESSION['user_type'] ?? '',
        'login_time' => $_SESSION['login_time'] ?? time(),
        'last_activity' => $_SESSION['last_activity'] ?? time()
    ];
}
```

**5. checkSessionTimeout()**
- Validates session timeout
- Automatically destroys expired sessions
- Updates activity timestamp

```php
function checkSessionTimeout() {
    if (isUserLoggedIn()) {
        $timeout = 86400; // 24 hours
        $lastActivity = $_SESSION['last_activity'] ?? time();
        
        if (time() - $lastActivity > $timeout) {
            destroyUserSession();
            return false;
        }
        
        updateLastActivity();
        return true;
    }
    
    return false;
}
```

### **Client-Side Implementation**

#### **JavaScript Session Management (js/app.js)**

**1. Enhanced Auth Object**
```javascript
const Auth = {
    isLoggedIn() {
        try {
            // Check both localStorage and session cookie
            const user = Storage.get('user');
            const sessionCookie = this.getCookie('funagig_session');
            
            return user !== null && typeof user === 'object' && sessionCookie !== null;
        } catch (error) {
            console.error('Auth check error:', error);
            return false;
        }
    },
    
    setUser(user) {
        try {
            if (!user || typeof user !== 'object') {
                throw new Error('Invalid user data');
            }
            Storage.set('user', user);
            
            // Set session cookie
            this.setCookie('funagig_session', user.session_id || 'active', 1);
            
            return true;
        } catch (error) {
            console.error('Set user error:', error);
            showNotification('Failed to save user data', 'error');
            return false;
        }
    },
    
    logout() {
        try {
            // Call server logout
            apiFetch('/logout', {
                method: 'POST'
            }).catch(error => {
                console.error('Server logout error:', error);
            });
            
            // Clear local storage
            Storage.remove('user');
            Storage.remove('userType');
            Storage.remove('isLoggedIn');
            Storage.clear();
            
            // Clear session cookie
            this.deleteCookie('funagig_session');
            
            window.location.href = 'index.html';
        } catch (error) {
            console.error('Logout error:', error);
            window.location.href = 'index.html';
        }
    }
};
```

**2. Cookie Management Functions**
```javascript
// Cookie management functions
setCookie(name, value, days) {
    const expires = new Date();
    expires.setTime(expires.getTime() + (days * 24 * 60 * 60 * 1000));
    document.cookie = `${name}=${value};expires=${expires.toUTCString()};path=/;SameSite=Lax`;
},

getCookie(name) {
    const nameEQ = name + "=";
    const ca = document.cookie.split(';');
    for (let i = 0; i < ca.length; i++) {
        let c = ca[i];
        while (c.charAt(0) === ' ') c = c.substring(1, c.length);
        if (c.indexOf(nameEQ) === 0) return c.substring(nameEQ.length, c.length);
    }
    return null;
},

deleteCookie(name) {
    document.cookie = `${name}=;expires=Thu, 01 Jan 1970 00:00:00 UTC;path=/;`;
},

// Session validation
async validateSession() {
    try {
        const response = await apiFetch('/profile');
        if (response.success) {
            return true;
        }
        return false;
    } catch (error) {
        console.error('Session validation error:', error);
        return false;
    }
}
```

## 🔄 **Session Lifecycle**

### **1. Login Process**
1. User submits login credentials
2. Server validates credentials against database
3. `createUserSession()` is called
4. Session variables are set
5. Session cookie is created
6. User data is returned to client
7. Client stores user data in localStorage
8. Client sets additional session cookie

### **2. Session Validation**
1. Every protected page checks `isUserLoggedIn()`
2. Server validates session exists and is not expired
3. `checkSessionTimeout()` validates activity timestamp
4. `updateLastActivity()` updates timestamp on valid requests
5. Session is destroyed if timeout exceeded

### **3. Logout Process**
1. User clicks logout or session expires
2. `destroyUserSession()` is called
3. All session variables are cleared
4. Session cookies are destroyed
5. Client clears localStorage
6. User is redirected to login page

## 🧪 **Testing**

### **Test Scripts Available**

**1. test_session.php**
- Tests session configuration
- Validates cookie settings
- Checks database connection
- Displays session variables

**2. test_login.php**
- Tests login functionality
- Creates user session
- Validates session data
- Tests session timeout

**3. test_logout.php**
- Tests logout functionality
- Validates session destruction
- Checks cookie cleanup

### **Manual Testing Steps**

**1. Session Creation Test**
```bash
# Run session test
php test_session.php

# Expected output:
# - Session ID generated
# - Session Status: Active
# - Cookie configuration correct
# - Database connection successful
```

**2. Login Test**
```bash
# Run login test
php test_login.php

# Expected output:
# - User found and password verified
# - Session created successfully
# - User logged in: Yes
# - Session variables populated
```

**3. Web Interface Test**
1. Open browser: `http://localhost/funagig1.5/auth.html`
2. Login with: `alice@demo.com` / `password`
3. Verify session persists across page refreshes
4. Test logout functionality
5. Verify session destruction

## 📊 **Session Data Structure**

### **Session Variables**
```php
$_SESSION = [
    'user_id' => 6,                    // User ID from database
    'user_name' => 'Alice Johnson',    // User's full name
    'user_email' => 'alice@demo.com',  // User's email address
    'user_type' => 'student',          // User type (student/business)
    'login_time' => 1761283317,        // Unix timestamp of login
    'last_activity' => 1761283317       // Unix timestamp of last activity
];
```

### **Cookie Data**
```javascript
// Session cookie
document.cookie = "PHPSESSID=66cfa5818d8444a0f71fd6049b820729; path=/; HttpOnly; SameSite=Lax"

// Custom session cookie
document.cookie = "funagig_session=active; path=/; SameSite=Lax"
```

## 🚀 **Production Considerations**

### **Security Checklist**
- [ ] Set `session.cookie_secure = 1` for HTTPS
- [ ] Use strong session IDs
- [ ] Implement CSRF tokens
- [ ] Add rate limiting for login attempts
- [ ] Log security events
- [ ] Regular session cleanup

### **Performance Optimization**
- [ ] Use Redis for session storage (high traffic)
- [ ] Implement session garbage collection
- [ ] Monitor session timeout rates
- [ ] Optimize database queries

### **Monitoring**
- [ ] Track session creation/destruction rates
- [ ] Monitor failed login attempts
- [ ] Alert on suspicious activity
- [ ] Regular security audits

## 🔧 **Configuration Options**

### **Session Timeout**
```php
// Default: 24 hours
ini_set('session.cookie_lifetime', 86400);

// For testing: 1 hour
ini_set('session.cookie_lifetime', 3600);

// For production: 8 hours
ini_set('session.cookie_lifetime', 28800);
```

### **Cookie Security**
```php
// Development (localhost)
ini_set('session.cookie_secure', 0);
ini_set('session.cookie_httponly', 1);
ini_set('session.cookie_samesite', 'Lax');

// Production (HTTPS)
ini_set('session.cookie_secure', 1);
ini_set('session.cookie_httponly', 1);
ini_set('session.cookie_samesite', 'Strict');
```

## 📝 **API Endpoints**

### **Authentication Endpoints**

**POST /login**
- Creates user session
- Returns user data and session ID
- Sets session cookies

**POST /logout**
- Destroys user session
- Clears session cookies
- Returns success message

**GET /profile**
- Validates current session
- Returns user profile data
- Updates activity timestamp

## 🎯 **Demo Accounts**

### **Student Accounts**
- alice@demo.com / password
- david@demo.com / password
- grace@demo.com / password
- michael@demo.com / password
- sarah@demo.com / password
- peter@demo.com / password

### **Business Accounts**
- info@techflow.com / password
- hello@creativeminds.com / password
- contact@shopsmart.ug / password
- studio@pixelperfect.com / password
- info@datainsights.com / password
- team@wordcraft.com / password

## 🚨 **Troubleshooting**

### **Common Issues**

**1. Session not persisting**
- Check cookie settings
- Verify session configuration
- Check browser cookie settings

**2. Login fails**
- Verify database connection
- Check password hashing
- Validate user credentials

**3. Session timeout issues**
- Check session lifetime settings
- Verify activity tracking
- Monitor session variables

### **Debug Tools**
```php
// Enable session debugging
ini_set('session.cookie_lifetime', 0);
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Check session status
echo "Session ID: " . session_id();
echo "Session Status: " . session_status();
echo "Session Data: " . print_r($_SESSION, true);
```

## 📚 **References**

- [PHP Session Management](https://www.php.net/manual/en/book.session.php)
- [HTTP Cookies Security](https://owasp.org/www-community/controls/SecureCookieAttribute)
- [Session Security Best Practices](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html)

---

**Last Updated:** December 2024  
**Version:** 1.0  
**Author:** FunaGig Development Team
