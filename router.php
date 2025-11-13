<?php
// Router script for PHP built-in server on DigitalOcean App Platform
// This script handles routing for the PHP built-in server since .htaccess doesn't work

// Get the request URI
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Check if it's a static file that exists
if ($uri !== '/' && file_exists(__DIR__ . $uri)) {
    // Serve static files directly
    return false;
}

// Route all API requests to api.php
if (preg_match('/^\/(login|signup|logout|dashboard|profile|gigs|applications|conversations|messages|notifications)/', $uri)) {
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