<?php
// Router script for PHP built-in server on DigitalOcean App Platform
// This script handles routing for the PHP built-in server since .htaccess doesn't work

// Get the request URI and method
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

// Handle CORS preflight requests for API endpoints first
if ($method === 'OPTIONS' && preg_match('/^\/(login|signup|logout|dashboard|profile|gigs|applications|conversations|messages|notifications|health)/', $uri)) {
    // Set CORS headers for API endpoints
    $allowedOrigins = [
        'http://localhost:3000',
        'http://localhost:3001', 
        'http://localhost:3002',
        'http://127.0.0.1:3000',
        'http://127.0.0.1:3001',
        'http://127.0.0.1:3002',
        'https://funagig1-5.vercel.app',
    ];
    
    $requestOrigin = $_SERVER['HTTP_ORIGIN'] ?? '';
    if ($requestOrigin && in_array($requestOrigin, $allowedOrigins, true)) {
        header('Access-Control-Allow-Origin: ' . $requestOrigin);
        header('Vary: Origin');
        header('Access-Control-Allow-Credentials: true');
    } else {
        header('Access-Control-Allow-Origin: http://localhost:3000');
        header('Vary: Origin');
    }
    
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
    header('Access-Control-Max-Age: 86400');
    http_response_code(200);
    exit;
}

// Check if it's a static file that exists
if ($uri !== '/' && file_exists(__DIR__ . $uri)) {
    // Serve static files directly
    return false;
}

// Route all API requests to api.php
if (preg_match('/^\/(login|signup|logout|dashboard|profile|gigs|applications|conversations|messages|notifications|health)/', $uri)) {
    // Route API endpoints to api.php
    require_once __DIR__ . '/php/api.php';
} else {
    // Serve the frontend index.html for all other requests
    if (file_exists(__DIR__ . '/index.html')) {
        $content = file_get_contents(__DIR__ . '/index.html');
        header('Content-Type: text/html');
        echo $content;
    } else {
        http_response_code(404);
        echo '404 Not Found';
    }
}
?>