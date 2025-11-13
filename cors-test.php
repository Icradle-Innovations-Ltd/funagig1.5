<?php
// Simple CORS test endpoint
header('Access-Control-Allow-Origin: http://localhost:3000');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Allow-Credentials: true');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    echo json_encode(['message' => 'CORS preflight handled']);
    exit;
}

echo json_encode([
    'message' => 'CORS test endpoint working',
    'method' => $_SERVER['REQUEST_METHOD'],
    'origin' => $_SERVER['HTTP_ORIGIN'] ?? 'none'
]);
?>