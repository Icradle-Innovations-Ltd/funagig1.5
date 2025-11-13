<?php

// Main API router for FunaGig - Production Ready
// Handles all API endpoints for gigs, applicants, messages, etc.

// Handle CORS immediately before any other processing
$allowedOrigins = [
    'http://localhost:3000',
    'http://localhost:3001',
    'http://127.0.0.1:3000',
    'http://127.0.0.1:3001',
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

// Handle preflight requests immediately
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once 'config.php';

// Set security headers immediately
setSecurityHeaders();

// Session is started in config.php

// Check session timeout
checkSessionTimeout();

// Get request method and path
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$script = $_SERVER['SCRIPT_NAME'] ?? '';
if ($script && strpos($path, $script) === 0) {
    $path = substr($path, strlen($script));
}

// Route the request
switch ($path) {
    case '/login':
        handleLogin();
        break;
    case '/signup':
        handleSignup();
        break;
    case '/logout':
        handleLogout();
        break;
    case '/dashboard':
        handleDashboard();
        break;
    case '/profile':
        handleProfile();
        break;
    case '/gigs':
        handleGigs();
        break;
    case '/gigs/active':
        handleActiveGigs();
        break;
    case '/applications':
        handleApplications();
        break;
    case '/conversations':
        handleConversations();
        break;
    case '/messages':
        handleMessages();
        break;
    case '/notifications':
        handleNotifications();
        break;
    case '/notifications/unread':
        handleUnreadNotifications();
        break;
    case '/notifications/mark-read':
        handleMarkAsRead();
        break;
    case '/notifications/clear':
        handleClearNotifications();
        break;
    case '/notifications/real-time':
        handleRealTimeNotifications();
        break;
    case '/password/request':
        handlePasswordRequest();
        break;
    case '/password/reset':
        handlePasswordReset();
        break;
    default:
        if (strpos($path, '/messages/') === 0) {
            $conversationId = substr($path, 10);
            handleMessagesByConversation($conversationId);
        } else {
            sendError('Endpoint not found', 404);
        }
        break;
}

// Authentication handlers
function handleLogin() {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        sendError('Method not allowed', 405);
    }
    
    try {
        $input = json_decode(file_get_contents('php://input'), true);
        
        // Rate limiting (toggle via RATE_LIMIT_ENABLED)
        if (defined('RATE_LIMIT_ENABLED') && RATE_LIMIT_ENABLED) {
            $clientIP = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
            if (!checkRateLimit('login_' . $clientIP, 5, 300)) {
                sendError('Too many login attempts. Please try again later.', 429);
            }
        }
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            sendError('Invalid JSON data');
        }
        
        $email = sanitizeInput($input['email'] ?? '');
        $password = $input['password'] ?? '';
        
        if (empty($email) || empty($password)) {
            sendError('Email and password are required');
        }
        
        if (!validateEmail($email)) {
            sendError('Invalid email format');
        }
        
        $db = Database::getInstance();
        $user = $db->fetchOne(
            "SELECT id, name, email, password, type, university, major, industry FROM users WHERE email = ?",
            [$email]
        );
        
        if (!$user || !verifyPassword($password, $user['password'])) {
            sendError('Invalid credentials');
        }
        
        // Create user session
        createUserSession($user);
        unset($user['password']);
        
        sendResponse([
            'success' => true,
            'user' => $user,
            'userType' => $user['type'],
            'session_id' => session_id()
        ]);
        
    } catch (Exception $e) {
        error_log("Login error: " . $e->getMessage());
        sendError('An error occurred during login. Please try again.');
    }
}

function handleSignup() {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        sendError('Method not allowed', 405);
    }
    
    try {
        $input = json_decode(file_get_contents('php://input'), true);
        
        // Rate limiting
        $clientIP = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        if (!checkRateLimit('signup_' . $clientIP, 3, 300)) {
            sendError('Too many signup attempts. Please try again later.', 429);
        }
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            sendError('Invalid JSON data');
        }
        
        $role = sanitizeInput($input['role'] ?? '');
        $name = sanitizeInput($input['name'] ?? '');
        $email = sanitizeInput($input['email'] ?? '');
        $password = $input['password'] ?? '';
        $confirmPassword = $input['confirmPassword'] ?? '';
        $tosAccepted = !empty($input['terms']);
        $privacyAccepted = !empty($input['privacy']);
        $dpaAccepted = !empty($input['dpa']);
        
        // Validation
        if (empty($role) || empty($name) || empty($email) || empty($password)) {
            sendError('All fields are required');
        }
        
        if (!in_array($role, ['student', 'business'])) {
            sendError('Invalid role');
        }
        
        if (!validateEmail($email)) {
            sendError('Invalid email format');
        }
        
        if ($password !== $confirmPassword) {
            sendError('Passwords do not match');
        }
        
        if (strlen($password) < 6) {
            sendError('Password must be at least 6 characters');
        }
        
        if (!$tosAccepted || !$privacyAccepted || !$dpaAccepted) {
            sendError('You must accept Terms, Privacy Policy, and DPA');
        }
        
        // Additional validation for role-specific fields
        if ($role === 'student') {
            if (empty($input['university']) || empty($input['major'])) {
                sendError('University and major are required for students');
            }
        } else if ($role === 'business') {
            if (empty($input['industry'])) {
                sendError('Industry is required for businesses');
            }
        }
        
        // Check if email already exists
        $db = Database::getInstance();
        $existingUser = $db->fetchOne("SELECT id FROM users WHERE email = ?", [$email]);
        
        if ($existingUser) {
            sendError('Email already registered');
        }
        
        // Create user
        $hashedPassword = hashPassword($password);
        $userId = $db->insert(
            "INSERT INTO users (name, email, password, type, university, major, industry, tos_accepted, privacy_accepted, dpa_accepted, policies_accepted_at, terms_version, privacy_version, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), '1.0', '1.0', NOW())",
            [
                $name,
                $email,
                $hashedPassword,
                $role,
                $input['university'] ?? null,
                $input['major'] ?? null,
                $input['industry'] ?? null,
                $tosAccepted ? 1 : 0,
                $privacyAccepted ? 1 : 0,
                $dpaAccepted ? 1 : 0
            ]
        );
        
        if (!$userId) {
            sendError('Failed to create account');
        }
        
        sendResponse([
            'success' => true,
            'message' => 'Account created successfully'
        ]);
        
    } catch (Exception $e) {
        error_log("Signup error: " . $e->getMessage());
        sendError('An error occurred during signup. Please try again.');
    }
}

function handleLogout() {
    destroyUserSession();
    sendResponse(['success' => true, 'message' => 'Logged out successfully']);
}

// Password reset: request
function handlePasswordRequest() {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        sendError('Method not allowed', 405);
    }
    try {
        $input = json_decode(file_get_contents('php://input'), true);
        $email = sanitizeInput($input['email'] ?? '');
        if (empty($email) || !validateEmail($email)) {
            sendError('Valid email is required');
        }
        $db = Database::getInstance();
        $user = $db->fetchOne("SELECT id FROM users WHERE email = ?", [$email]);
        if (!$user) {
            // Don't reveal whether email exists
            sendResponse(['success' => true, 'message' => 'If the email exists, a reset link has been sent.']);
        }
        $token = bin2hex(random_bytes(32));
        $db->insert("INSERT INTO password_resets (email, token, requested_at) VALUES (?, ?, NOW())", [$email, $token]);
        // TODO: send email. For dev, return token.
        sendResponse(['success' => true, 'message' => 'Reset link generated', 'token' => $token]);
    } catch (Exception $e) {
        error_log('Password request error: '.$e->getMessage());
        sendError('Failed to request password reset');
    }
}

// Password reset: confirm
function handlePasswordReset() {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        sendError('Method not allowed', 405);
    }
    try {
        $input = json_decode(file_get_contents('php://input'), true);
        $token = $input['token'] ?? '';
        $newPassword = $input['newPassword'] ?? '';
        $confirm = $input['confirmPassword'] ?? '';
        if (strlen($newPassword) < 6 || $newPassword !== $confirm) {
            sendError('Password must be at least 6 characters and match confirmation');
        }
        $db = Database::getInstance();
        $row = $db->fetchOne("SELECT email FROM password_resets WHERE token = ? AND used_at IS NULL", [$token]);
        if (!$row) {
            sendError('Invalid or used reset token', 400);
        }
        $hashed = hashPassword($newPassword);
        $db->update("UPDATE users SET password = ? WHERE email = ?", [$hashed, $row['email']]);
        $db->update("UPDATE password_resets SET used_at = NOW() WHERE token = ?", [$token]);
        sendResponse(['success' => true, 'message' => 'Password has been reset']);
    } catch (Exception $e) {
        error_log('Password reset error: '.$e->getMessage());
        sendError('Failed to reset password');
    }
}

// Dashboard handler
function handleDashboard() {
    requireAuth();
    
    $user = getCurrentUser();
    $db = Database::getInstance();
    
    if ($user['type'] === 'student') {
        $stats = getStudentStats($db, $user['id']);
    } else {
        $stats = getBusinessStats($db, $user['id']);
    }
    
    sendResponse([
        'success' => true,
        'stats' => $stats
    ]);
}

function getStudentStats($db, $userId) {
    $stats = [];
    
    // Active applications
    $stats['active_tasks'] = $db->fetchOne(
        "SELECT COUNT(*) as count FROM applications WHERE user_id = ? AND status = 'accepted'",
        [$userId]
    )['count'];
    
    // Pending applications
    $stats['pending_tasks'] = $db->fetchOne(
        "SELECT COUNT(*) as count FROM applications WHERE user_id = ? AND status = 'pending'",
        [$userId]
    )['count'];
    
    // Completed tasks
    $stats['completed_tasks'] = $db->fetchOne(
        "SELECT COUNT(*) as count FROM applications WHERE user_id = ? AND status = 'completed'",
        [$userId]
    )['count'];
    
    // Total earned
    $stats['total_earned'] = $db->fetchOne(
        "SELECT COALESCE(SUM(g.budget), 0) as total FROM applications a 
         JOIN gigs g ON a.gig_id = g.id 
         WHERE a.user_id = ? AND a.status = 'completed'",
        [$userId]
    )['total'];
    
    return $stats;
}

function getBusinessStats($db, $userId) {
    $stats = [];
    
    // Active gigs
    $stats['active_gigs'] = $db->fetchOne(
        "SELECT COUNT(*) as count FROM gigs WHERE user_id = ? AND status = 'active'",
        [$userId]
    )['count'];
    
    // Total applicants
    $stats['total_applicants'] = $db->fetchOne(
        "SELECT COUNT(*) as count FROM applications a 
         JOIN gigs g ON a.gig_id = g.id 
         WHERE g.user_id = ?",
        [$userId]
    )['count'];
    
    // Hired students (accepted applications)
    $stats['hired_students'] = $db->fetchOne(
        "SELECT COUNT(*) as count FROM applications a 
         JOIN gigs g ON a.gig_id = g.id 
         WHERE g.user_id = ? AND a.status = 'accepted'",
        [$userId]
    )['count'];
    
    // Average rating
    $stats['average_rating'] = $db->fetchOne(
        "SELECT AVG(rating) as avg_rating FROM reviews WHERE reviewee_id = ?",
        [$userId]
    )['avg_rating'];
    $stats['average_rating'] = $stats['average_rating'] ? round($stats['average_rating'], 1) : 4.6;
    
    // Total revenue (completed projects)
    $stats['total_revenue'] = $db->fetchOne(
        "SELECT SUM(budget) as total FROM gigs WHERE user_id = ? AND status = 'completed'",
        [$userId]
    )['total'];
    $stats['total_revenue'] = $stats['total_revenue'] ? (int)$stats['total_revenue'] : 0;
    
    // Completed projects
    $stats['completed_projects'] = $db->fetchOne(
        "SELECT COUNT(*) as count FROM gigs WHERE user_id = ? AND status = 'completed'",
        [$userId]
    )['count'];
    
    // Active students (students with accepted or completed applications)
    $stats['active_students'] = $db->fetchOne(
        "SELECT COUNT(DISTINCT a.user_id) as count FROM applications a 
         JOIN gigs g ON a.gig_id = g.id 
         WHERE g.user_id = ? AND a.status IN ('accepted', 'completed')",
        [$userId]
    )['count'];
    
    return $stats;
}

// Profile handler
function handleProfile() {
    requireAuth();
    
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $user = getCurrentUser();
        sendResponse(['success' => true, 'user' => $user]);
    } elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $input = json_decode(file_get_contents('php://input'), true);
        $userId = $_SESSION['user_id'];
        
        $db = Database::getInstance();
        $db->update(
            "UPDATE users SET name = ?, university = ?, major = ?, industry = ?, phone = ?, website = ?, bio = ?, location = ?, skills = ? WHERE id = ?",
            [
                sanitizeInput($input['name'] ?? ''),
                sanitizeInput($input['university'] ?? ''),
                sanitizeInput($input['major'] ?? ''),
                sanitizeInput($input['industry'] ?? ''),
                sanitizeInput($input['phone'] ?? ''),
                sanitizeInput($input['website'] ?? ''),
                sanitizeInput($input['bio'] ?? ''),
                sanitizeInput($input['location'] ?? ''),
                sanitizeInput($input['skills'] ?? ''),
                $userId
            ]
        );
        
        sendResponse(['success' => true, 'message' => 'Profile updated']);
    }
}

// Gigs handlers
function handleGigs() {
    requireAuth();
    
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $db = Database::getInstance();
        $gigs = $db->fetchAll(
            "SELECT g.*, u.name as business_name FROM gigs g 
             JOIN users u ON g.user_id = u.id 
             WHERE g.status = 'active' 
             ORDER BY g.created_at DESC"
        );
        
        sendResponse(['success' => true, 'gigs' => $gigs]);
    } elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
        try {
            $input = json_decode(file_get_contents('php://input'), true);
            
            if (json_last_error() !== JSON_ERROR_NONE) {
                sendError('Invalid JSON data');
            }
            
            $userId = $_SESSION['user_id'];
            
            // Validate required fields
            $requiredFields = ['title', 'description', 'budget', 'deadline'];
            foreach ($requiredFields as $field) {
                if (empty($input[$field])) {
                    sendError("Field '$field' is required");
                }
            }
            
            // Validate budget is numeric and positive
            if (!is_numeric($input['budget']) || $input['budget'] <= 0) {
                sendError('Budget must be a positive number');
            }
            
            // Validate deadline is in the future
            if (strtotime($input['deadline']) <= time()) {
                sendError('Deadline must be in the future');
            }
            
            $db = Database::getInstance();
            $gigId = $db->insert(
                "INSERT INTO gigs (user_id, title, description, budget, deadline, skills, location, type, category, duration, hours_per_week, required_skills, preferred_skills, education_level, experience_level, work_location, specific_location, company_name, contact_person, contact_email, additional_notes, status, created_at) 
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'active', NOW())",
                [
                    $userId,
                    sanitizeInput($input['title'] ?? ''),
                    sanitizeInput($input['description'] ?? ''),
                    $input['budget'] ?? 0,
                    $input['deadline'] ?? '',
                    sanitizeInput($input['requiredSkills'] ?? ''),
                    sanitizeInput($input['specificLocation'] ?? ''),
                    sanitizeInput($input['type'] ?? ''),
                    sanitizeInput($input['category'] ?? ''),
                    sanitizeInput($input['duration'] ?? ''),
                    sanitizeInput($input['hoursPerWeek'] ?? ''),
                    sanitizeInput($input['preferredSkills'] ?? ''),
                    sanitizeInput($input['educationLevel'] ?? ''),
                    sanitizeInput($input['experienceLevel'] ?? ''),
                    sanitizeInput($input['workLocation'] ?? ''),
                    sanitizeInput($input['specificLocation'] ?? ''),
                    sanitizeInput($input['companyName'] ?? ''),
                    sanitizeInput($input['contactPerson'] ?? ''),
                    sanitizeInput($input['contactEmail'] ?? ''),
                    sanitizeInput($input['additionalNotes'] ?? '')
                ]
            );
            
            if (!$gigId) {
                sendError('Failed to create gig');
            }
            
            sendResponse(['success' => true, 'gig_id' => $gigId]);
            
        } catch (Exception $e) {
            error_log("Gig creation error: " . $e->getMessage());
            sendError('An error occurred while creating the gig. Please try again.');
        }
    }
}

function handleActiveGigs() {
    requireAuth();
    
    $user = getCurrentUser();
    $db = Database::getInstance();
    
    if ($user['type'] === 'business') {
        $gigs = $db->fetchAll(
            "SELECT g.*, 
             (SELECT COUNT(*) FROM applications WHERE gig_id = g.id) as applicant_count,
             (SELECT COUNT(*) FROM applications WHERE gig_id = g.id AND status = 'accepted') as hired_count
             FROM gigs g 
             WHERE g.user_id = ? AND g.status = 'active' 
             ORDER BY g.created_at DESC",
            [$user['id']]
        );
    } else {
        $gigs = $db->fetchAll(
            "SELECT g.*, u.name as business_name FROM gigs g 
             JOIN users u ON g.user_id = u.id 
             WHERE g.status = 'active' 
             ORDER BY g.created_at DESC"
        );
    }
    
    sendResponse(['success' => true, 'gigs' => $gigs]);
}

// Applications handler
function handleApplications() {
    requireAuth();
    
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $input = json_decode(file_get_contents('php://input'), true);
        $userId = $_SESSION['user_id'];
        
        $db = Database::getInstance();
        
        // Check if already applied
        $existing = $db->fetchOne(
            "SELECT id FROM applications WHERE user_id = ? AND gig_id = ?",
            [$userId, $input['gig_id']]
        );
        
        if ($existing) {
            sendError('Already applied to this gig');
        }
        
        $applicationId = $db->insert(
            "INSERT INTO applications (user_id, gig_id, message, status, created_at) 
             VALUES (?, ?, ?, 'pending', NOW())",
            [
                $userId,
                $input['gig_id'],
                sanitizeInput($input['message'] ?? '')
            ]
        );
        
        sendResponse(['success' => true, 'application_id' => $applicationId]);
    }
}

// Messaging handlers
function handleConversations() {
    requireAuth();
    
    $userId = $_SESSION['user_id'];
    $db = Database::getInstance();
    
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $conversations = $db->fetchAll(
            "SELECT c.*, 
             CASE 
                 WHEN c.user1_id = ? THEN u2.name 
                 ELSE u1.name 
             END as other_user_name,
             (SELECT content FROM messages WHERE conversation_id = c.id ORDER BY created_at DESC LIMIT 1) as last_message,
             (SELECT created_at FROM messages WHERE conversation_id = c.id ORDER BY created_at DESC LIMIT 1) as last_message_time
             FROM conversations c
             JOIN users u1 ON c.user1_id = u1.id
             JOIN users u2 ON c.user2_id = u2.id
             WHERE c.user1_id = ? OR c.user2_id = ?
             ORDER BY last_message_time DESC",
            [$userId, $userId, $userId]
        );
        
        sendResponse(['success' => true, 'conversations' => $conversations]);
    } elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $input = json_decode(file_get_contents('php://input'), true);
        
        $conversationId = $db->insert(
            "INSERT INTO conversations (user1_id, user2_id, created_at) VALUES (?, ?, NOW())",
            [$userId, $input['user_id']]
        );
        
        sendResponse(['success' => true, 'conversation_id' => $conversationId]);
    }
}

function handleMessages() {
    requireAuth();
    
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $input = json_decode(file_get_contents('php://input'), true);
        $userId = $_SESSION['user_id'];
        
        $db = Database::getInstance();
        $messageId = $db->insert(
            "INSERT INTO messages (conversation_id, sender_id, content, created_at) VALUES (?, ?, ?, NOW())",
            [
                $input['conversation_id'],
                $userId,
                sanitizeInput($input['message'])
            ]
        );
        
        sendResponse(['success' => true, 'message_id' => $messageId]);
    }
}

function handleMessagesByConversation($conversationId) {
    requireAuth();
    
    $db = Database::getInstance();
    $messages = $db->fetchAll(
        "SELECT m.*, u.name as sender_name FROM messages m
         JOIN users u ON m.sender_id = u.id
         WHERE m.conversation_id = ?
         ORDER BY m.created_at ASC",
        [$conversationId]
    );
    
    sendResponse(['success' => true, 'messages' => $messages]);
}

// Notification handlers
function handleNotifications() {
    requireAuth();
    
    try {
        $db = Database::getInstance();
        $userId = $_SESSION['user_id'];
        
        $page = $_GET['page'] ?? 1;
        $limit = $_GET['limit'] ?? 20;
        $offset = ($page - 1) * $limit;
        
        $notifications = $db->fetchAll(
            "SELECT n.*, u.name as user_name, u.type as user_type 
             FROM notifications n
             LEFT JOIN users u ON n.user_id = u.id
             WHERE n.user_id = ?
             ORDER BY n.created_at DESC
             LIMIT ? OFFSET ?",
            [$userId, $limit, $offset]
        );
        
        $totalCount = $db->fetchOne(
            "SELECT COUNT(*) as count FROM notifications WHERE user_id = ?",
            [$userId]
        )['count'];
        
        sendResponse([
            'success' => true,
            'notifications' => $notifications,
            'pagination' => [
                'page' => (int)$page,
                'limit' => (int)$limit,
                'total' => (int)$totalCount,
                'pages' => ceil($totalCount / $limit)
            ]
        ]);
        
    } catch (Exception $e) {
        error_log("Notifications error: " . $e->getMessage());
        sendError('Failed to fetch notifications');
    }
}

function handleUnreadNotifications() {
    requireAuth();
    
    try {
        $db = Database::getInstance();
        $userId = $_SESSION['user_id'];
        
        $unreadCount = $db->fetchOne(
            "SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = FALSE",
            [$userId]
        )['count'];
        
        sendResponse([
            'success' => true,
            'unread_count' => (int)$unreadCount
        ]);
        
    } catch (Exception $e) {
        error_log("Unread notifications error: " . $e->getMessage());
        sendError('Failed to fetch unread count');
    }
}

function handleMarkAsRead() {
    requireAuth();
    
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        sendError('Method not allowed', 405);
    }
    
    try {
        $input = json_decode(file_get_contents('php://input'), true);
        $notificationId = $input['notification_id'] ?? null;
        
        if (!$notificationId) {
            sendError('Notification ID is required');
        }
        
        $db = Database::getInstance();
        $userId = $_SESSION['user_id'];
        
        // Verify notification belongs to user
        $notification = $db->fetchOne(
            "SELECT id FROM notifications WHERE id = ? AND user_id = ?",
            [$notificationId, $userId]
        );
        
        if (!$notification) {
            sendError('Notification not found', 404);
        }
        
        // Mark as read
        $db->query(
            "UPDATE notifications SET is_read = TRUE WHERE id = ? AND user_id = ?",
            [$notificationId, $userId]
        );
        
        sendResponse([
            'success' => true,
            'message' => 'Notification marked as read'
        ]);
        
    } catch (Exception $e) {
        error_log("Mark as read error: " . $e->getMessage());
        sendError('Failed to mark notification as read');
    }
}

function handleClearNotifications() {
    requireAuth();
    
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        sendError('Method not allowed', 405);
    }
    
    try {
        $db = Database::getInstance();
        $userId = $_SESSION['user_id'];
        
        $db->query(
            "DELETE FROM notifications WHERE user_id = ?",
            [$userId]
        );
        
        sendResponse([
            'success' => true,
            'message' => 'All notifications cleared'
        ]);
        
    } catch (Exception $e) {
        error_log("Clear notifications error: " . $e->getMessage());
        sendError('Failed to clear notifications');
    }
}

function handleRealTimeNotifications() {
    requireAuth();
    
    // Set headers for Server-Sent Events
    header('Content-Type: text/event-stream');
    header('Cache-Control: no-cache');
    header('Connection: keep-alive');
    // CORS headers are already set in config.php. Ensure credentials allowed for SSE.
    header('Access-Control-Allow-Credentials: true');
    
    $userId = $_SESSION['user_id'];
    $lastCheck = $_GET['last_check'] ?? time();
    
    try {
        $db = Database::getInstance();
        
        // Send initial connection message
        echo "data: " . json_encode([
            'type' => 'connected',
            'message' => 'Real-time notifications connected',
            'timestamp' => time()
        ]) . "\n\n";
        
        // Keep connection alive and check for new notifications
        $timeout = 300; // extend to 5 minutes to reduce reconnect churn
        $startTime = time();
        
        while ((time() - $startTime) < $timeout) {
            // Check for new notifications
            $newNotifications = $db->fetchAll(
                "SELECT n.*, u.name as user_name, u.type as user_type 
                 FROM notifications n
                 LEFT JOIN users u ON n.user_id = u.id
                 WHERE n.user_id = ? AND n.created_at > FROM_UNIXTIME(?)
                 ORDER BY n.created_at DESC",
                [$userId, $lastCheck]
            );
            
            if (!empty($newNotifications)) {
                foreach ($newNotifications as $notification) {
                    echo "data: " . json_encode([
                        'type' => 'notification',
                        'notification' => $notification,
                        'timestamp' => time()
                    ]) . "\n\n";
                }
                
                $lastCheck = time();
            }
            
            // Send heartbeat every 5 seconds
            if ((time() - $startTime) % 5 === 0) {
                echo "data: " . json_encode([
                    'type' => 'heartbeat',
                    'timestamp' => time()
                ]) . "\n\n";
            }
            
            flush();
            sleep(1);
        }
        
        // Send disconnect message
        echo "data: " . json_encode([
            'type' => 'disconnected',
            'message' => 'Connection timeout',
            'timestamp' => time()
        ]) . "\n\n";
        
    } catch (Exception $e) {
        error_log("Real-time notifications error: " . $e->getMessage());
        echo "data: " . json_encode([
            'type' => 'error',
            'message' => 'Connection error',
            'timestamp' => time()
        ]) . "\n\n";
    }
}
?>

