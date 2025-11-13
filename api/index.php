<?php
// Vercel PHP Runtime Entry Point for FunaGig API
// This file routes all API requests through the main API handler

// Set up proper CORS headers for Vercel deployment
header('Access-Control-Allow-Origin: https://funagig1-5.vercel.app');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Allow-Credentials: true');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Adjust paths for Vercel environment
$_SERVER['DOCUMENT_ROOT'] = dirname(__DIR__);
$_SERVER['SCRIPT_NAME'] = '/api/index.php';

// Include the main API file
require_once dirname(__DIR__) . '/php/api.php';
?>