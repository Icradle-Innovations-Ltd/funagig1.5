<?php
// Real-time notifications API for FunaGig
// Handles trigger-based notifications and real-time updates

require_once 'config.php';

// Get request method and path
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$path = str_replace('/funagig/php/notifications.php', '', $path);

// Route the request
switch ($path) {
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
    default:
        sendError('Endpoint not found', 404);
        break;
}

// Get user notifications
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

// Get unread notifications count
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

// Mark notification as read
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

// Clear all notifications
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

// Real-time notifications (Server-Sent Events)
function handleRealTimeNotifications() {
    requireAuth();
    
    // Set headers for Server-Sent Events
    header('Content-Type: text/event-stream');
    header('Cache-Control: no-cache');
    header('Connection: keep-alive');
    // CORS headers - use specific origins for security
    $allowedOrigins = ['http://localhost:3000', 'http://127.0.0.1:3000'];
    $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
    if (in_array($origin, $allowedOrigins)) {
        header('Access-Control-Allow-Origin: ' . $origin);
    }
    header('Access-Control-Allow-Headers: Cache-Control');
    
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
        $timeout = 30; // 30 seconds timeout
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

// Create notification manually (for testing triggers)
function createNotification($userId, $title, $message, $type = 'info') {
    try {
        $db = Database::getInstance();
        
        $notificationId = $db->insert(
            "INSERT INTO notifications (user_id, title, message, type, is_read, created_at) 
             VALUES (?, ?, ?, ?, FALSE, NOW())",
            [$userId, $title, $message, $type]
        );
        
        return $notificationId;
        
    } catch (Exception $e) {
        error_log("Create notification error: " . $e->getMessage());
        return false;
    }
}

// Test trigger functionality
function testTriggers() {
    try {
        $db = Database::getInstance();
        
        // Test application trigger
        $testGig = $db->fetchOne("SELECT id FROM gigs LIMIT 1");
        $testUser = $db->fetchOne("SELECT id FROM users WHERE type = 'student' LIMIT 1");
        
        if ($testGig && $testUser) {
            // Create test application
            $applicationId = $db->insert(
                "INSERT INTO applications (user_id, gig_id, message, status, applied_at) 
                 VALUES (?, ?, 'Test application for trigger', 'pending', NOW())",
                [$testUser['id'], $testGig['id']]
            );
            
            // Check if notification was created
            $notification = $db->fetchOne(
                "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 1",
                [$testGig['user_id']]
            );
            
            return [
                'application_created' => $applicationId,
                'notification_created' => $notification ? true : false,
                'notification_data' => $notification
            ];
        }
        
        return ['error' => 'No test data available'];
        
    } catch (Exception $e) {
        error_log("Test triggers error: " . $e->getMessage());
        return ['error' => $e->getMessage()];
    }
}
?>
