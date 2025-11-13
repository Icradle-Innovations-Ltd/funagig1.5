<?php
// Vercel PHP Runtime Entry Point for FunaGig API
// This file routes all API requests through the main API handler

// Adjust paths for Vercel environment
$_SERVER['DOCUMENT_ROOT'] = dirname(__DIR__);
$_SERVER['SCRIPT_NAME'] = '/api/index.php';

// Include the main API file which handles CORS dynamically
require_once dirname(__DIR__) . '/php/api.php';
?>