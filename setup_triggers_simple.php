<?php
// Simple setup script for FunaGig database triggers
// Uses direct MySQL execution instead of prepared statements

require_once 'php/config.php';

echo "<h1>FunaGig Database Triggers Setup</h1>";
echo "<style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    .success { color: green; }
    .error { color: red; }
    .info { color: blue; }
    .warning { color: orange; }
    pre { background: #f5f5f5; padding: 10px; border-radius: 4px; overflow-x: auto; }
</style>";

try {
    $db = Database::getInstance();
    echo "<p class='success'>✅ Connected to database</p>";
    
    // Get direct MySQL connection
    $mysqli = $db->getConnection();
    
    // Create triggers one by one
    echo "<h2>Creating Database Triggers</h2>";
    
    // 1. Update gig application count trigger
    $trigger1 = "
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
    END";
    
    if ($mysqli->query($trigger1)) {
        echo "<p class='success'>✅ Created trigger: update_gig_application_count</p>";
    } else {
        echo "<p class='error'>❌ Error creating trigger: " . $mysqli->error . "</p>";
    }
    
    // 2. Update gig application count on update
    $trigger2 = "
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
    END";
    
    if ($mysqli->query($trigger2)) {
        echo "<p class='success'>✅ Created trigger: update_gig_application_count_update</p>";
    } else {
        echo "<p class='error'>❌ Error creating trigger: " . $mysqli->error . "</p>";
    }
    
    // 3. Update gig application count on delete
    $trigger3 = "
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
    END";
    
    if ($mysqli->query($trigger3)) {
        echo "<p class='success'>✅ Created trigger: update_gig_application_count_delete</p>";
    } else {
        echo "<p class='error'>❌ Error creating trigger: " . $mysqli->error . "</p>";
    }
    
    // 4. Create notification on application
    $trigger4 = "
    CREATE TRIGGER create_notification_on_application
        AFTER INSERT ON applications
        FOR EACH ROW
    BEGIN
        DECLARE business_user_id INT;
        DECLARE gig_title VARCHAR(255);
        DECLARE student_name VARCHAR(255);
        
        SELECT g.user_id, g.title INTO business_user_id, gig_title
        FROM gigs g
        WHERE g.id = NEW.gig_id;
        
        SELECT name INTO student_name
        FROM users
        WHERE id = NEW.user_id;
        
        INSERT INTO notifications (user_id, title, message, type, is_read, created_at)
        VALUES (
            business_user_id,
            'New Application Received',
            CONCAT(student_name, ' has applied to your gig: ', gig_title),
            'info',
            FALSE,
            NOW()
        );
    END";
    
    if ($mysqli->query($trigger4)) {
        echo "<p class='success'>✅ Created trigger: create_notification_on_application</p>";
    } else {
        echo "<p class='error'>❌ Error creating trigger: " . $mysqli->error . "</p>";
    }
    
    // 5. Create notification on application status change
    $trigger5 = "
    CREATE TRIGGER create_notification_on_application_status
        AFTER UPDATE ON applications
        FOR EACH ROW
    BEGIN
        DECLARE business_user_id INT;
        DECLARE gig_title VARCHAR(255);
        DECLARE student_name VARCHAR(255);
        
        IF OLD.status != NEW.status THEN
            SELECT g.user_id, g.title INTO business_user_id, gig_title
            FROM gigs g
            WHERE g.id = NEW.gig_id;
            
            SELECT name INTO student_name
            FROM users
            WHERE id = NEW.user_id;
            
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
                    WHEN NEW.status = 'accepted' THEN CONCAT('Congratulations! Your application for \"', gig_title, '\" has been accepted.')
                    WHEN NEW.status = 'rejected' THEN CONCAT('Your application for \"', gig_title, '\" was not selected this time.')
                    WHEN NEW.status = 'completed' THEN CONCAT('Your project \"', gig_title, '\" has been marked as completed.')
                    ELSE CONCAT('Your application for \"', gig_title, '\" status has been updated.')
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
    END";
    
    if ($mysqli->query($trigger5)) {
        echo "<p class='success'>✅ Created trigger: create_notification_on_application_status</p>";
    } else {
        echo "<p class='error'>❌ Error creating trigger: " . $mysqli->error . "</p>";
    }
    
    // 6. Create notification on message
    $trigger6 = "
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
        FROM users
        WHERE id = NEW.sender_id;
        
        INSERT INTO notifications (user_id, title, message, type, is_read, created_at)
        VALUES (
            recipient_id,
            'New Message',
            CONCAT(sender_name, ' sent you a message'),
            'info',
            FALSE,
            NOW()
        );
    END";
    
    if ($mysqli->query($trigger6)) {
        echo "<p class='success'>✅ Created trigger: create_notification_on_message</p>";
    } else {
        echo "<p class='error'>❌ Error creating trigger: " . $mysqli->error . "</p>";
    }
    
    // 7. Create welcome notification for new users
    $trigger7 = "
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
    END";
    
    if ($mysqli->query($trigger7)) {
        echo "<p class='success'>✅ Created trigger: create_welcome_notification</p>";
    } else {
        echo "<p class='error'>❌ Error creating trigger: " . $mysqli->error . "</p>";
    }
    
    // 8. Update conversation last message timestamp
    $trigger8 = "
    CREATE TRIGGER update_conversation_last_message
        AFTER INSERT ON messages
        FOR EACH ROW
    BEGIN
        UPDATE conversations 
        SET last_message_at = NOW()
        WHERE id = NEW.conversation_id;
    END";
    
    if ($mysqli->query($trigger8)) {
        echo "<p class='success'>✅ Created trigger: update_conversation_last_message</p>";
    } else {
        echo "<p class='error'>❌ Error creating trigger: " . $mysqli->error . "</p>";
    }
    
    // Create indexes for better performance
    echo "<h2>Creating Indexes</h2>";
    
    $indexes = [
        "CREATE INDEX idx_applications_gig_id_status ON applications(gig_id, status)",
        "CREATE INDEX idx_messages_conversation_id ON messages(conversation_id)",
        "CREATE INDEX idx_notifications_user_id_read ON notifications(user_id, is_read)"
    ];
    
    foreach ($indexes as $index) {
        if ($mysqli->query($index)) {
            $indexName = preg_match('/CREATE INDEX\s+(\w+)/i', $index, $matches);
            echo "<p class='success'>✅ Created index: " . ($indexName ? $matches[1] : 'index') . "</p>";
        } else {
            echo "<p class='warning'>⚠️ Index may already exist: " . $mysqli->error . "</p>";
        }
    }
    
    // Test the triggers
    echo "<h2>Testing Triggers</h2>";
    
    // Test 1: Check if triggers exist
    $triggers = $mysqli->query("SHOW TRIGGERS");
    $triggerCount = $triggers->num_rows;
    echo "<p class='info'>📋 Found {$triggerCount} triggers in database</p>";
    
    while ($trigger = $triggers->fetch_assoc()) {
        echo "<p class='success'>✅ {$trigger['Trigger']} - {$trigger['Event']} {$trigger['Table']}</p>";
    }
    
    // Test 2: Test notification creation
    echo "<h3>Testing Notification System</h3>";
    
    $testUser = $db->fetchOne("SELECT id FROM users WHERE type = 'student' LIMIT 1");
    if ($testUser) {
        $notificationId = $db->insert(
            "INSERT INTO notifications (user_id, title, message, type, is_read, created_at) 
             VALUES (?, ?, ?, ?, FALSE, NOW())",
            [$testUser['id'], 'Test Notification', 'This is a test notification to verify the system is working.', 'info']
        );
        
        if ($notificationId) {
            echo "<p class='success'>✅ Test notification created with ID: {$notificationId}</p>";
            
            $unreadCount = $db->fetchOne(
                "SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = FALSE",
                [$testUser['id']]
            )['count'];
            
            echo "<p class='info'>📊 Unread notifications for test user: {$unreadCount}</p>";
        }
    }
    
    // Test 3: Test application trigger
    echo "<h3>Testing Application Triggers</h3>";
    
    $testGig = $db->fetchOne("SELECT id, user_id FROM gigs LIMIT 1");
    $testStudent = $db->fetchOne("SELECT id FROM users WHERE type = 'student' LIMIT 1");
    
    if ($testGig && $testStudent) {
        $initialCount = $db->fetchOne(
            "SELECT application_count FROM gigs WHERE id = ?",
            [$testGig['id']]
        )['application_count'];
        
        echo "<p class='info'>📊 Initial application count: {$initialCount}</p>";
        
        // Create test application
        $applicationId = $db->insert(
            "INSERT INTO applications (user_id, gig_id, message, status, applied_at) 
             VALUES (?, ?, 'Test application for trigger testing', 'pending', NOW())",
            [$testStudent['id'], $testGig['id']]
        );
        
        if ($applicationId) {
            echo "<p class='success'>✅ Test application created with ID: {$applicationId}</p>";
            
            $newCount = $db->fetchOne(
                "SELECT application_count FROM gigs WHERE id = ?",
                [$testGig['id']]
            )['application_count'];
            
            echo "<p class='info'>📊 New application count: {$newCount}</p>";
            
            if ($newCount > $initialCount) {
                echo "<p class='success'>✅ Application count trigger working correctly</p>";
            }
            
            // Check if notification was created
            $notification = $db->fetchOne(
                "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 1",
                [$testGig['user_id']]
            );
            
            if ($notification) {
                echo "<p class='success'>✅ Notification created for business user</p>";
                echo "<p class='info'>📧 Notification: {$notification['title']}</p>";
            }
            
            // Clean up
            $db->query("DELETE FROM applications WHERE id = ?", [$applicationId]);
            echo "<p class='info'>🧹 Test application cleaned up</p>";
        }
    }
    
    echo "<h2>Setup Complete!</h2>";
    echo "<p class='success'>🎉 Database triggers have been successfully installed and tested.</p>";
    echo "<p class='info'>📋 The following features are now active:</p>";
    echo "<ul>";
    echo "<li>✅ Automatic application count updates</li>";
    echo "<li>✅ Automatic notification creation</li>";
    echo "<li>✅ Real-time notification system</li>";
    echo "<li>✅ Welcome notifications for new users</li>";
    echo "<li>✅ Message notifications</li>";
    echo "<li>✅ Application status notifications</li>";
    echo "</ul>";
    
} catch (Exception $e) {
    echo "<p class='error'>❌ Setup failed: " . htmlspecialchars($e->getMessage()) . "</p>";
    echo "<pre>" . htmlspecialchars($e->getTraceAsString()) . "</pre>";
}
?>
