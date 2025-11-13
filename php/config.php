<?php
// Database configuration for FunaGig
// Simple mysqli connection setup for XAMPP deployment

// Database configuration - Update for production
define('DB_HOST', getenv('DB_HOST') ?: 'localhost');
define('DB_NAME', getenv('DB_NAME') ?: 'funagig');
define('DB_USER', getenv('DB_USER') ?: 'root');
define('DB_PASS', getenv('DB_PASS') ?: '97swain'); // Use environment variables in production
define('DB_PORT', (int)(getenv('DB_PORT') ?: 3306));
define('DB_SSL', getenv('DB_SSL') === 'true');
define('DB_SSL_MODE', getenv('DB_SSL_MODE') ?: 'PREFERRED');

// Application configuration
define('APP_NAME', 'FunaGig');
define('APP_VERSION', '1.5'); // Updated to production version
define('APP_URL', getenv('APP_URL') ?: 'http://localhost/funagig1.5'); // Use environment variable in production
define('HTTPS_REQUIRED', getenv('HTTPS_REQUIRED') === 'true'); // Force HTTPS in production

// Security settings
define('JWT_SECRET', 'your-secret-key-here-change-in-production'); // Use secure random in production
define('PASSWORD_HASH_ALGO', PASSWORD_DEFAULT); // Revert to default for compatibility
// Feature flags
define('RATE_LIMIT_ENABLED', false); // Disable for development
define('PRODUCTION_MODE', false); // Set to true for production deployment
define('DEBUG_MODE', true); // Set to false for production deployment

// Production security configuration
if (PRODUCTION_MODE) {
    // Disable error display in production
    ini_set('display_errors', '0');
    ini_set('display_startup_errors', '0');
    error_reporting(0);
    
    // Log errors instead of displaying them
    ini_set('log_errors', '1');
    ini_set('error_log', __DIR__ . '/../logs/php_errors.log');
} else {
    // Development mode error handling
    ini_set('display_errors', '1');
    ini_set('display_startup_errors', '1');
    error_reporting(E_ALL);
}

// Security headers
function setSecurityHeaders() {
    // Prevent clickjacking (DENY is most secure)
    header('X-Frame-Options: SAMEORIGIN'); // Changed from DENY for flexibility
    
    // Prevent MIME type sniffing
    header('X-Content-Type-Options: nosniff');
    
    // XSS Protection
    header('X-XSS-Protection: 1; mode=block');
    
    // Referrer Policy
    header('Referrer-Policy: strict-origin-when-cross-origin');
    
    // Content Security Policy
    header("Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:;");
    
    // Force HTTPS if required
    if (HTTPS_REQUIRED && !isset($_SERVER['HTTPS'])) {
        $host = filter_var($_SERVER['HTTP_HOST'], FILTER_SANITIZE_URL);
        $uri = filter_var($_SERVER['REQUEST_URI'], FILTER_SANITIZE_URL);
        if ($host && $uri) {
            header('Location: https://' . $host . $uri, true, 301);
            exit();
        }
    }
}

// File upload settings
define('MAX_FILE_SIZE', 5 * 1024 * 1024); // 5MB
define('UPLOAD_PATH', 'uploads/');
define('ALLOWED_EXTENSIONS', ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx']);

// Email settings (for notifications)
define('SMTP_HOST', 'smtp.gmail.com');
define('SMTP_PORT', 587);
define('SMTP_USERNAME', 'your-email@gmail.com');
define('SMTP_PASSWORD', 'your-app-password');
define('FROM_EMAIL', 'noreply@funagig.com');
define('FROM_NAME', 'FunaGig');

// Database connection class
class Database {
    private static $instance = null;
    private $connection;
    
    private function __construct() {
        try {
            // Create new mysqli instance
            $this->connection = new mysqli();
            
            // Configure SSL if required (for DigitalOcean managed database)
            if (DB_SSL) {
                $ssl_ca = __DIR__ . '/ca-certificate.crt';
                
                // Set SSL options with certificate
                if (file_exists($ssl_ca)) {
                    $this->connection->ssl_set(null, null, $ssl_ca, null, null);
                } else {
                    // Fallback without specific CA file
                    $this->connection->ssl_set(null, null, null, null, null);
                }
                
                // Enable SSL certificate verification
                $this->connection->options(MYSQLI_OPT_SSL_VERIFY_SERVER_CERT, true);
            }
            
            // Connect with SSL support
            $flags = DB_SSL ? MYSQLI_CLIENT_SSL : 0;
            $result = $this->connection->real_connect(
                DB_HOST,
                DB_USER,
                DB_PASS,
                DB_NAME,
                DB_PORT,
                null,
                $flags
            );
            
            if (!$result) {
                throw new Exception("Connection failed: " . $this->connection->connect_error);
            }
            
            // Set charset to utf8mb4 for full Unicode support
            $this->connection->set_charset("utf8mb4");
            
            // Set timezone for consistency
            $this->connection->query("SET time_zone = '+00:00'");
            
            // Log successful connection for monitoring
            if (PRODUCTION_MODE) {
                error_log("DigitalOcean database connection established successfully");
            }
            
        } catch (Exception $e) {
            error_log("Database connection error: " . $e->getMessage());
            throw $e;
        }
    }
    
    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }
    
    public function getConnection() {
        return $this->connection;
    }
    
    public function query($sql, $params = []) {
        $stmt = $this->connection->prepare($sql);
        
        if (!$stmt) {
            throw new Exception("Prepare failed: " . $this->connection->error);
        }
        
        if (!empty($params)) {
            $types = str_repeat('s', count($params));
            $stmt->bind_param($types, ...$params);
        }
        
        $stmt->execute();
        
        if ($stmt->error) {
            throw new Exception("Execute failed: " . $stmt->error);
        }
        
        return $stmt;
    }
    
    public function fetchAll($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        $result = $stmt->get_result();
        return $result->fetch_all(MYSQLI_ASSOC);
    }
    
    public function fetchOne($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        $result = $stmt->get_result();
        return $result->fetch_assoc();
    }
    
    public function insert($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $this->connection->insert_id;
    }
    
    public function update($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $stmt->affected_rows;
    }
    
    public function delete($sql, $params = []) {
        $stmt = $this->query($sql, $params);
        return $stmt->affected_rows;
    }
    
    public function beginTransaction() {
        $this->connection->begin_transaction();
    }
    
    public function commit() {
        $this->connection->commit();
    }
    
    public function rollback() {
        $this->connection->rollback();
    }
    
    public function close() {
        if ($this->connection) {
            $this->connection->close();
        }
    }
}

// Enhanced utility functions for production security
function sanitizeInput($data) {
    if (is_array($data)) {
        return array_map('sanitizeInput', $data);
    }
    return htmlspecialchars(strip_tags(trim($data)), ENT_QUOTES, 'UTF-8');
}

function validateInput($data, $type = 'string', $maxLength = null) {
    $data = sanitizeInput($data);
    
    switch ($type) {
        case 'email':
            return filter_var($data, FILTER_VALIDATE_EMAIL);
        case 'int':
            return filter_var($data, FILTER_VALIDATE_INT);
        case 'float':
            return filter_var($data, FILTER_VALIDATE_FLOAT);
        case 'url':
            return filter_var($data, FILTER_VALIDATE_URL);
        case 'string':
        default:
            if ($maxLength && strlen($data) > $maxLength) {
                return false;
            }
            return $data;
    }
}

function validateEmail($email) {
    return filter_var($email, FILTER_VALIDATE_EMAIL);
}

// Enhanced security functions
function generateToken($length = 32) {
    return bin2hex(random_bytes($length));
}

function hashPassword($password) {
    return password_hash($password, PASSWORD_HASH_ALGO);
}

function verifyPassword($password, $hash) {
    return password_verify($password, $hash);
}

// Secure response functions
function sendResponse($data, $status = 200) {
    // Set security headers before sending response
    setSecurityHeaders();
    
    http_response_code($status);
    header('Content-Type: application/json; charset=UTF-8');
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function sendError($message, $status = 400) {
    // Log security-related errors
    if ($status >= 400) {
        error_log("Security Error [{$status}]: {$message} - IP: " . ($_SERVER['REMOTE_ADDR'] ?? 'unknown'));
    }
    
    // Don't expose internal error details in production
    if (PRODUCTION_MODE && $status >= 500) {
        $message = 'Internal server error';
    }
    
    sendResponse(['success' => false, 'error' => $message], $status);
}

// Rate limiting function
function checkRateLimit($identifier, $maxAttempts = 10, $timeWindow = 300) {
    $key = 'rate_limit_' . md5($identifier);
    $attempts = $_SESSION[$key] ?? [];
    
    // Clean old attempts
    $currentTime = time();
    $attempts = array_filter($attempts, function($timestamp) use ($currentTime, $timeWindow) {
        return ($currentTime - $timestamp) < $timeWindow;
    });
    
    if (count($attempts) >= $maxAttempts) {
        return false;
    }
    
    $attempts[] = $currentTime;
    $_SESSION[$key] = $attempts;
    return true;
}

// CSRF token functions
function generateCSRFToken() {
    if (!isset($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

function validateCSRFToken($token) {
    return isset($_SESSION['csrf_token']) && hash_equals($_SESSION['csrf_token'], $token);
}

function requireAuth() {
    if (!isset($_SESSION['user_id'])) {
        sendError('Authentication required', 401);
    }
}

// Enhanced session management functions
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

function isUserLoggedIn() {
    return isset($_SESSION['user_id']) && !empty($_SESSION['user_id']);
}

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

function updateLastActivity() {
    if (isUserLoggedIn()) {
        $_SESSION['last_activity'] = time();
    }
}

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


// CORS headers for API - Configure for distributed deployment
$allowedOrigins = [
    'http://localhost:3000',
    'http://localhost:3001',
    'http://localhost:3002',
    'http://127.0.0.1:3000',
    'http://127.0.0.1:3001',
    'http://127.0.0.1:3002',
    'http://192.168.1.100:3000',
    'http://192.168.1.101:3000',
    'http://192.168.1.138:3000',
    'http://localhost',
    'http://192.168.1.138:8080',
    'https://funagig1-5.vercel.app',  // Production frontend
    'https://vercel.app',  // Vercel preview deployments
    // Add more IPs as needed
];

$requestOrigin = $_SERVER['HTTP_ORIGIN'] ?? '';
if ($requestOrigin && in_array($requestOrigin, $allowedOrigins, true)) {
    header('Access-Control-Allow-Origin: ' . $requestOrigin);
    header('Vary: Origin');
    header('Access-Control-Allow-Credentials: true');
} else {
    // Fallback for non-CORS or same-origin requests
    header('Access-Control-Allow-Origin: http://localhost:3000');
    header('Vary: Origin');
}

header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Max-Age: 86400');

// Handle preflight requests
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Session and Cookie Configuration (must be before session_start)
ini_set('session.cookie_httponly', 1);
ini_set('session.cookie_secure', 0); // Set to 1 for HTTPS
ini_set('session.use_only_cookies', 1);
ini_set('session.cookie_samesite', 'Lax');
ini_set('session.cookie_lifetime', 86400); // 24 hours

// Set session cookie parameters before starting session
session_set_cookie_params([
    'lifetime' => 86400, // 24 hours
    'path' => '/',
    'domain' => '',
    'secure' => false, // Set to true for HTTPS
    'httponly' => true,
    'samesite' => 'Lax'
]);

// Start session
session_start();

// Error reporting (disable in production)
error_reporting(E_ALL);
ini_set('display_errors', 1);
?>

