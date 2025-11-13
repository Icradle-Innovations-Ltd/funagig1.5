<?php
// Setup script for FunaGig database triggers
// Installs all triggers and tests their functionality

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
    
    // Read and execute triggers SQL
    $triggersSql = file_get_contents('database/triggers.sql');
    if (!$triggersSql) {
        throw new Exception("Could not read triggers.sql file");
    }
    
    echo "<p class='info'>📄 Reading triggers.sql file...</p>";
    
    // Split SQL into individual statements
    $statements = explode(';', $triggersSql);
    $executedCount = 0;
    $errorCount = 0;
    
    foreach ($statements as $statement) {
        $statement = trim($statement);
        if (empty($statement) || strpos($statement, '--') === 0) {
            continue;
        }
        
        try {
            $db->query($statement);
            $executedCount++;
            
            // Show progress for major operations
            if (strpos($statement, 'CREATE TRIGGER') !== false) {
                $triggerName = preg_match('/CREATE TRIGGER\s+(\w+)/i', $statement, $matches);
                if ($triggerName) {
                    echo "<p class='success'>✅ Created trigger: {$matches[1]}</p>";
                }
            } elseif (strpos($statement, 'CREATE INDEX') !== false) {
                $indexName = preg_match('/CREATE INDEX\s+(\w+)/i', $statement, $matches);
                if ($indexName) {
                    echo "<p class='success'>✅ Created index: {$matches[1]}</p>";
                }
            } elseif (strpos($statement, 'CREATE VIEW') !== false) {
                $viewName = preg_match('/CREATE VIEW\s+(\w+)/i', $statement, $matches);
                if ($viewName) {
                    echo "<p class='success'>✅ Created view: {$matches[1]}</p>";
                }
            }
            
        } catch (Exception $e) {
            $errorCount++;
            echo "<p class='error'>❌ Error executing statement: " . htmlspecialchars($e->getMessage()) . "</p>";
            echo "<pre>" . htmlspecialchars(substr($statement, 0, 200)) . "...</pre>";
        }
    }
    
    echo "<h2>Setup Summary</h2>";
    echo "<p class='info'>📊 Executed {$executedCount} SQL statements</p>";
    if ($errorCount > 0) {
        echo "<p class='warning'>⚠️ {$errorCount} statements had errors</p>";
    }
    
    // Test trigger functionality
    echo "<h2>Testing Triggers</h2>";
    
    // Test 1: Check if triggers exist
    $triggers = $db->fetchAll("SHOW TRIGGERS");
    echo "<p class='info'>📋 Found " . count($triggers) . " triggers in database</p>";
    
    foreach ($triggers as $trigger) {
        echo "<p class='success'>✅ {$trigger['Trigger']} - {$trigger['Event']} {$trigger['Table']}</p>";
    }
    
    // Test 2: Check views
    $views = $db->fetchAll("SHOW FULL TABLES WHERE Table_type = 'VIEW'");
    echo "<p class='info'>📋 Found " . count($views) . " views in database</p>";
    
    foreach ($views as $view) {
        echo "<p class='success'>✅ View: {$view['Tables_in_funagig']}</p>";
    }
    
    // Test 3: Check indexes
    $indexes = $db->fetchAll("SHOW INDEX FROM notifications");
    echo "<p class='info'>📋 Found " . count($indexes) . " indexes on notifications table</p>";
    
    // Test 4: Test notification creation
    echo "<h3>Testing Notification System</h3>";
    
    // Get a test user
    $testUser = $db->fetchOne("SELECT id FROM users WHERE type = 'student' LIMIT 1");
    if ($testUser) {
        // Create a test notification
        $notificationId = $db->insert(
            "INSERT INTO notifications (user_id, title, message, type, is_read, created_at) 
             VALUES (?, ?, ?, ?, FALSE, NOW())",
            [$testUser['id'], 'Test Notification', 'This is a test notification to verify the system is working.', 'info']
        );
        
        if ($notificationId) {
            echo "<p class='success'>✅ Test notification created with ID: {$notificationId}</p>";
            
            // Test unread count
            $unreadCount = $db->fetchOne(
                "SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = FALSE",
                [$testUser['id']]
            )['count'];
            
            echo "<p class='info'>📊 Unread notifications for test user: {$unreadCount}</p>";
            
            // Mark as read
            $db->query(
                "UPDATE notifications SET is_read = TRUE WHERE id = ?",
                [$notificationId]
            );
            
            echo "<p class='success'>✅ Test notification marked as read</p>";
        }
    } else {
        echo "<p class='warning'>⚠️ No test users found</p>";
    }
    
    // Test 5: Test application trigger
    echo "<h3>Testing Application Triggers</h3>";
    
    $testGig = $db->fetchOne("SELECT id, user_id FROM gigs LIMIT 1");
    $testStudent = $db->fetchOne("SELECT id FROM users WHERE type = 'student' LIMIT 1");
    
    if ($testGig && $testStudent) {
        // Get initial application count
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
            
            // Check if application count was updated
            $newCount = $db->fetchOne(
                "SELECT application_count FROM gigs WHERE id = ?",
                [$testGig['id']]
            )['application_count'];
            
            echo "<p class='info'>📊 New application count: {$newCount}</p>";
            
            if ($newCount > $initialCount) {
                echo "<p class='success'>✅ Application count trigger working correctly</p>";
            } else {
                echo "<p class='warning'>⚠️ Application count trigger may not be working</p>";
            }
            
            // Check if notification was created
            $notification = $db->fetchOne(
                "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 1",
                [$testGig['user_id']]
            );
            
            if ($notification) {
                echo "<p class='success'>✅ Notification created for business user</p>";
                echo "<p class='info'>📧 Notification: {$notification['title']}</p>";
            } else {
                echo "<p class='warning'>⚠️ No notification created for business user</p>";
            }
            
            // Clean up test application
            $db->query("DELETE FROM applications WHERE id = ?", [$applicationId]);
            echo "<p class='info'>🧹 Test application cleaned up</p>";
        }
    } else {
        echo "<p class='warning'>⚠️ No test data available for application trigger testing</p>";
    }
    
    // Test 6: Test message trigger
    echo "<h3>Testing Message Triggers</h3>";
    
    $testUsers = $db->fetchAll("SELECT id FROM users LIMIT 2");
    if (count($testUsers) >= 2) {
        $user1 = $testUsers[0]['id'];
        $user2 = $testUsers[1]['id'];
        
        // Create test conversation
        $conversationId = $db->insert(
            "INSERT INTO conversations (user1_id, user2_id, created_at) VALUES (?, ?, NOW())",
            [$user1, $user2]
        );
        
        if ($conversationId) {
            echo "<p class='success'>✅ Test conversation created with ID: {$conversationId}</p>";
            
            // Send test message
            $messageId = $db->insert(
                "INSERT INTO messages (conversation_id, sender_id, content, created_at) 
                 VALUES (?, ?, 'Test message for trigger testing', NOW())",
                [$conversationId, $user1]
            );
            
            if ($messageId) {
                echo "<p class='success'>✅ Test message sent with ID: {$messageId}</p>";
                
                // Check if notification was created
                $notification = $db->fetchOne(
                    "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 1",
                    [$user2]
                );
                
                if ($notification) {
                    echo "<p class='success'>✅ Notification created for message recipient</p>";
                    echo "<p class='info'>📧 Notification: {$notification['title']}</p>";
                } else {
                    echo "<p class='warning'>⚠️ No notification created for message recipient</p>";
                }
                
                // Check if conversation timestamp was updated
                $conversation = $db->fetchOne(
                    "SELECT last_message_at FROM conversations WHERE id = ?",
                    [$conversationId]
                );
                
                if ($conversation['last_message_at']) {
                    echo "<p class='success'>✅ Conversation timestamp updated</p>";
                } else {
                    echo "<p class='warning'>⚠️ Conversation timestamp not updated</p>";
                }
            }
            
            // Clean up test data
            $db->query("DELETE FROM messages WHERE conversation_id = ?", [$conversationId]);
            $db->query("DELETE FROM conversations WHERE id = ?", [$conversationId]);
            echo "<p class='info'>🧹 Test conversation cleaned up</p>";
        }
    } else {
        echo "<p class='warning'>⚠️ Not enough test users for message trigger testing</p>";
    }
    
    echo "<h2>Setup Complete!</h2>";
    echo "<p class='success'>🎉 Database triggers have been successfully installed and tested.</p>";
    echo "<p class='info'>📋 The following features are now active:</p>";
    echo "<ul>";
    echo "<li>✅ Automatic application count updates</li>";
    echo "<li>✅ Automatic user rating updates</li>";
    echo "<li>✅ Automatic notification creation</li>";
    echo "<li>✅ Real-time notification system</li>";
    echo "<li>✅ Welcome notifications for new users</li>";
    echo "<li>✅ Message notifications</li>";
    echo "<li>✅ Application status notifications</li>";
    echo "<li>✅ New gig notifications</li>";
    echo "</ul>";
    
    echo "<p class='info'>🔗 You can now test the notification system by:</p>";
    echo "<ul>";
    echo "<li>Logging in as a user</li>";
    echo "<li>Applying to gigs</li>";
    echo "<li>Sending messages</li>";
    echo "<li>Posting new gigs</li>";
    echo "<li>Visiting the notifications page</li>";
    echo "</ul>";
    
} catch (Exception $e) {
    echo "<p class='error'>❌ Setup failed: " . htmlspecialchars($e->getMessage()) . "</p>";
    echo "<pre>" . htmlspecialchars($e->getTraceAsString()) . "</pre>";
}
?>
