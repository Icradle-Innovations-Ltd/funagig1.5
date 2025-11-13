# FunaGig Database Triggers & Frontend Integration

## 🎯 **Overview**

This document provides comprehensive documentation for the database triggers and frontend integration implemented in the FunaGig platform. The system provides real-time notifications, automatic data updates, and seamless user experience.

## 🗄️ **Database Triggers**

### **Trigger Architecture**

The FunaGig platform uses MySQL triggers to automatically handle data consistency, notifications, and real-time updates. All triggers are designed to be efficient and non-blocking.

### **Installed Triggers**

#### **1. Application Count Triggers**
```sql
-- Updates gig application count when applications are created
CREATE TRIGGER update_gig_application_count
    AFTER INSERT ON applications
    FOR EACH ROW
BEGIN
    UPDATE gigs 
    SET application_count = (
        SELECT COUNT(*) 
        FROM applications 
        WHERE gig_id = NEW.gig_id AND status != 'rejected'
    )
    WHERE id = NEW.gig_id;
END;

-- Updates gig application count when applications are updated
CREATE TRIGGER update_gig_application_count_update
    AFTER UPDATE ON applications
    FOR EACH ROW
BEGIN
    UPDATE gigs 
    SET application_count = (
        SELECT COUNT(*) 
        FROM applications 
        WHERE gig_id = NEW.gig_id AND status != 'rejected'
    )
    WHERE id = NEW.gig_id;
END;

-- Updates gig application count when applications are deleted
CREATE TRIGGER update_gig_application_count_delete
    AFTER DELETE ON applications
    FOR EACH ROW
BEGIN
    UPDATE gigs 
    SET application_count = (
        SELECT COUNT(*) 
        FROM applications 
        WHERE gig_id = OLD.gig_id AND status != 'rejected'
    )
    WHERE id = OLD.gig_id;
END;
```

**Purpose**: Automatically maintains accurate application counts for gigs without manual updates.

#### **2. Notification Triggers**
```sql
-- Creates notification when application is submitted
CREATE TRIGGER create_notification_on_application
    AFTER INSERT ON applications
    FOR EACH ROW
BEGIN
    DECLARE business_user_id INT;
    DECLARE gig_title VARCHAR(255);
    DECLARE student_name VARCHAR(255);
    
    SELECT g.user_id, g.title INTO business_user_id, gig_title
    FROM gigs g WHERE g.id = NEW.gig_id;
    
    SELECT name INTO student_name
    FROM users WHERE id = NEW.user_id;
    
    INSERT INTO notifications (user_id, title, message, type, is_read, created_at)
    VALUES (
        business_user_id,
        'New Application Received',
        CONCAT(student_name, ' has applied to your gig: ', gig_title),
        'info',
        FALSE,
        NOW()
    );
END;
```

**Purpose**: Automatically notifies business users when students apply to their gigs.

#### **3. Application Status Notification Trigger**
```sql
-- Creates notification when application status changes
CREATE TRIGGER create_notification_on_application_status
    AFTER UPDATE ON applications
    FOR EACH ROW
BEGIN
    DECLARE business_user_id INT;
    DECLARE gig_title VARCHAR(255);
    DECLARE student_name VARCHAR(255);
    
    IF OLD.status != NEW.status THEN
        SELECT g.user_id, g.title INTO business_user_id, gig_title
        FROM gigs g WHERE g.id = NEW.gig_id;
        
        SELECT name INTO student_name
        FROM users WHERE id = NEW.user_id;
        
        INSERT INTO notifications (user_id, title, message, type, is_read, created_at)
        VALUES (
            NEW.user_id,
            CASE 
                WHEN NEW.status = 'accepted' THEN 'Application Accepted!'
                WHEN NEW.status = 'rejected' THEN 'Application Status Update'
                WHEN NEW.status = 'completed' THEN 'Project Completed'
                ELSE 'Application Status Update'
            END,
            CASE 
                WHEN NEW.status = 'accepted' THEN CONCAT('Congratulations! Your application for "', gig_title, '" has been accepted.')
                WHEN NEW.status = 'rejected' THEN CONCAT('Your application for "', gig_title, '" was not selected this time.')
                WHEN NEW.status = 'completed' THEN CONCAT('Your project "', gig_title, '" has been marked as completed.')
                ELSE CONCAT('Your application for "', gig_title, '" status has been updated.')
            END,
            CASE 
                WHEN NEW.status = 'accepted' THEN 'success'
                WHEN NEW.status = 'rejected' THEN 'warning'
                WHEN NEW.status = 'completed' THEN 'success'
                ELSE 'info'
            END,
            FALSE,
            NOW()
        );
    END IF;
END;
```

**Purpose**: Notifies students when their application status changes (accepted, rejected, completed).

#### **4. Message Notification Trigger**
```sql
-- Creates notification when new message is sent
CREATE TRIGGER create_notification_on_message
    AFTER INSERT ON messages
    FOR EACH ROW
BEGIN
    DECLARE recipient_id INT;
    DECLARE sender_name VARCHAR(255);
    
    SELECT 
        CASE 
            WHEN c.user1_id = NEW.sender_id THEN c.user2_id
            ELSE c.user1_id
        END INTO recipient_id
    FROM conversations c
    WHERE c.id = NEW.conversation_id;
    
    SELECT name INTO sender_name
    FROM users WHERE id = NEW.sender_id;
    
    INSERT INTO notifications (user_id, title, message, type, is_read, created_at)
    VALUES (
        recipient_id,
        'New Message',
        CONCAT(sender_name, ' sent you a message'),
        'info',
        FALSE,
        NOW()
    );
END;
```

**Purpose**: Notifies users when they receive new messages.

#### **5. Welcome Notification Trigger**
```sql
-- Creates welcome notification for new users
CREATE TRIGGER create_welcome_notification
    AFTER INSERT ON users
    FOR EACH ROW
BEGIN
    INSERT INTO notifications (user_id, title, message, type, is_read, created_at)
    VALUES (
        NEW.id,
        'Welcome to FunaGig!',
        CASE 
            WHEN NEW.type = 'student' THEN 'Welcome! Start exploring gigs and building your portfolio.'
            WHEN NEW.type = 'business' THEN 'Welcome! Start posting gigs and finding talented students.'
            ELSE 'Welcome to FunaGig!'
        END,
        'success',
        TRUE,
        NOW()
    );
END;
```

**Purpose**: Welcomes new users with personalized messages.

#### **6. Conversation Timestamp Trigger**
```sql
-- Updates conversation last message timestamp
CREATE TRIGGER update_conversation_last_message
    AFTER INSERT ON messages
    FOR EACH ROW
BEGIN
    UPDATE conversations 
    SET last_message_at = NOW()
    WHERE id = NEW.conversation_id;
END;
```

**Purpose**: Maintains accurate conversation timestamps for sorting and display.

### **Database Indexes**

For optimal performance, the following indexes were created:

```sql
-- Application count optimization
CREATE INDEX idx_applications_gig_id_status ON applications(gig_id, status);

-- Message notification optimization  
CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);

-- Notification query optimization
CREATE INDEX idx_notifications_user_id_read ON notifications(user_id, is_read);
```

## 🎨 **Frontend Integration**

### **Real-Time Notification System**

#### **JavaScript Notification Manager**

The frontend uses a comprehensive `NotificationManager` class to handle real-time notifications:

```javascript
class NotificationManager {
    constructor() {
        this.eventSource = null;
        this.isConnected = false;
        this.unreadCount = 0;
        this.notifications = [];
        this.callbacks = {
            onNotification: [],
            onUnreadCountChange: [],
            onConnectionChange: []
        };
        
        this.init();
    }
    
    // Load notifications from server
    async loadNotifications(page = 1, limit = 20) {
        try {
            const response = await apiFetch(`/notifications?page=${page}&limit=${limit}`);
            if (response.success) {
                this.notifications = response.notifications;
                this.updateNotificationDisplay();
                return response;
            }
        } catch (error) {
            console.error('Failed to load notifications:', error);
            this.showNotification('Failed to load notifications', 'error');
        }
    }
    
    // Get unread count
    async getUnreadCount() {
        try {
            const response = await apiFetch('/notifications/unread');
            if (response.success) {
                const newCount = response.unread_count;
                if (newCount !== this.unreadCount) {
                    this.unreadCount = newCount;
                    this.updateUnreadCountDisplay();
                    this.triggerCallbacks('onUnreadCountChange', newCount);
                }
                return newCount;
            }
        } catch (error) {
            console.error('Failed to get unread count:', error);
        }
        return 0;
    }
    
    // Connect to real-time notifications
    connectRealTime() {
        if (this.isConnected) {
            return;
        }
        
        try {
            const lastCheck = localStorage.getItem('lastNotificationCheck') || Math.floor(Date.now() / 1000);
            
            this.eventSource = new EventSource(`/notifications/real-time?last_check=${lastCheck}`);
            
            this.eventSource.onopen = () => {
                this.isConnected = true;
                this.triggerCallbacks('onConnectionChange', true);
                console.log('Real-time notifications connected');
            };
            
            this.eventSource.onmessage = (event) => {
                try {
                    const data = JSON.parse(event.data);
                    this.handleRealTimeMessage(data);
                } catch (error) {
                    console.error('Failed to parse real-time message:', error);
                }
            };
            
            this.eventSource.onerror = (error) => {
                console.error('Real-time notifications error:', error);
                this.isConnected = false;
                this.triggerCallbacks('onConnectionChange', false);
                
                // Attempt to reconnect after 5 seconds
                setTimeout(() => {
                    if (Auth.isLoggedIn()) {
                        this.connectRealTime();
                    }
                }, 5000);
            };
            
        } catch (error) {
            console.error('Failed to connect to real-time notifications:', error);
        }
    }
}
```

#### **Server-Sent Events (SSE)**

The backend provides real-time notifications using Server-Sent Events:

```php
function handleRealTimeNotifications() {
    requireAuth();
    
    // Set headers for Server-Sent Events
    header('Content-Type: text/event-stream');
    header('Cache-Control: no-cache');
    header('Connection: keep-alive');
    header('Access-Control-Allow-Origin: *');
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
```

### **API Endpoints**

#### **Notification Endpoints**

**GET /notifications**
- Retrieves paginated notifications for the current user
- Parameters: `page`, `limit`
- Returns: notifications array with pagination info

**GET /notifications/unread**
- Returns unread notification count
- Returns: `unread_count` integer

**POST /notifications/mark-read**
- Marks a specific notification as read
- Body: `{ "notification_id": 123 }`
- Returns: success message

**POST /notifications/clear**
- Clears all notifications for the current user
- Returns: success message

**GET /notifications/real-time**
- Server-Sent Events endpoint for real-time notifications
- Parameters: `last_check` (timestamp)
- Returns: SSE stream with notification events

### **Frontend Components**

#### **Notification Page**

The `notifications.html` page provides a comprehensive notification interface:

- **Real-time connection status**
- **Paginated notification list**
- **Mark as read functionality**
- **Clear all notifications**
- **Browser notification support**
- **Responsive design**

#### **Notification Badge Integration**

The system automatically updates notification badges across the platform:

```javascript
// Update unread count display
function updateUnreadCount(count) {
    // Update page title
    if (count > 0) {
        document.title = `(${count}) Notifications - FunaGig`;
    } else {
        document.title = 'Notifications - FunaGig';
    }
    
    // Update notification badges
    const badges = document.querySelectorAll('.notification-badge');
    badges.forEach(badge => {
        if (count > 0) {
            badge.textContent = count;
            badge.style.display = 'inline-block';
        } else {
            badge.style.display = 'none';
        }
    });
}
```

## 🔄 **Trigger Workflow**

### **Application Workflow**

1. **Student applies to gig**
   - `applications` table INSERT
   - `update_gig_application_count` trigger fires
   - `create_notification_on_application` trigger fires
   - Business user receives notification

2. **Business updates application status**
   - `applications` table UPDATE
   - `update_gig_application_count_update` trigger fires
   - `create_notification_on_application_status` trigger fires
   - Student receives status notification

3. **Application is deleted**
   - `applications` table DELETE
   - `update_gig_application_count_delete` trigger fires
   - Application count is updated

### **Message Workflow**

1. **User sends message**
   - `messages` table INSERT
   - `create_notification_on_message` trigger fires
   - `update_conversation_last_message` trigger fires
   - Recipient receives notification
   - Conversation timestamp is updated

### **User Registration Workflow**

1. **New user registers**
   - `users` table INSERT
   - `create_welcome_notification` trigger fires
   - User receives welcome notification

## 🧪 **Testing**

### **Manual Testing Steps**

1. **Test Application Notifications**
   - Login as student
   - Apply to a gig
   - Login as business owner
   - Check notifications page
   - Verify notification was created

2. **Test Status Notifications**
   - Login as business owner
   - Accept/reject an application
   - Login as student
   - Check notifications page
   - Verify status notification

3. **Test Message Notifications**
   - Start conversation between users
   - Send message
   - Check recipient's notifications
   - Verify message notification

4. **Test Real-Time Updates**
   - Open notifications page
   - Perform actions that trigger notifications
   - Verify real-time updates appear

### **Automated Testing**

The system includes comprehensive test scripts:

- **Trigger installation verification**
- **Notification creation testing**
- **Application count testing**
- **Message notification testing**
- **Real-time connection testing**

## 📊 **Performance Considerations**

### **Database Optimization**

- **Indexes**: Created on frequently queried columns
- **Trigger Efficiency**: Triggers use efficient queries
- **Batch Operations**: Notifications are created in batches when possible

### **Frontend Optimization**

- **Connection Management**: Automatic reconnection on failure
- **Pagination**: Large notification lists are paginated
- **Caching**: Local storage for notification state
- **Debouncing**: Prevents excessive API calls

### **Real-Time Optimization**

- **Heartbeat**: 5-second heartbeat to maintain connection
- **Timeout**: 30-second connection timeout
- **Reconnection**: Automatic reconnection on failure
- **Error Handling**: Graceful error handling and recovery

## 🚀 **Production Deployment**

### **Requirements**

- **MySQL 5.7+** with trigger support
- **PHP 7.4+** with session support
- **Modern browsers** with EventSource support
- **HTTPS** for production (recommended)

### **Configuration**

1. **Database Setup**
   ```bash
   php setup_triggers_simple.php
   ```

2. **Frontend Integration**
   ```html
   <script src="js/notifications.js"></script>
   ```

3. **API Configuration**
   - Ensure notification endpoints are accessible
   - Configure CORS for real-time connections
   - Set up proper session handling

### **Monitoring**

- **Trigger Performance**: Monitor trigger execution times
- **Notification Volume**: Track notification creation rates
- **Real-Time Connections**: Monitor SSE connection counts
- **Error Rates**: Track notification delivery failures

## 🔧 **Troubleshooting**

### **Common Issues**

1. **Triggers Not Firing**
   - Check MySQL trigger support
   - Verify trigger syntax
   - Check database permissions

2. **Real-Time Not Working**
   - Check browser EventSource support
   - Verify CORS configuration
   - Check network connectivity

3. **Notifications Not Appearing**
   - Check user authentication
   - Verify notification creation
   - Check frontend JavaScript errors

### **Debug Tools**

```php
// Check trigger status
SHOW TRIGGERS;

// Check notification count
SELECT COUNT(*) FROM notifications WHERE user_id = ?;

// Check real-time connection
// Monitor browser network tab for SSE connections
```

## 📚 **API Reference**

### **Notification Object Structure**

```json
{
    "id": 123,
    "user_id": 456,
    "title": "New Application Received",
    "message": "Alex Johnson has applied to your gig: Website Design",
    "type": "info",
    "is_read": false,
    "created_at": "2024-12-20 10:30:00",
    "user_name": "Business Owner",
    "user_type": "business"
}
```

### **Real-Time Event Types**

- **connected**: Initial connection established
- **notification**: New notification received
- **heartbeat**: Connection alive signal
- **disconnected**: Connection lost
- **error**: Connection error

---

**Last Updated:** December 2024  
**Version:** 1.0  
**Author:** FunaGig Development Team
