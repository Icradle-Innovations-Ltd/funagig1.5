-- FunaGig Database Triggers
-- Triggers for automatic data management and notifications

USE funagig;

-- Drop existing triggers if they exist
DROP TRIGGER IF EXISTS update_gig_application_count;
DROP TRIGGER IF EXISTS update_user_rating;
DROP TRIGGER IF EXISTS create_notification_on_application;
DROP TRIGGER IF EXISTS create_notification_on_message;
DROP TRIGGER IF EXISTS update_gig_view_count;
DROP TRIGGER IF EXISTS create_welcome_notification;
DROP TRIGGER IF EXISTS update_user_last_activity;
DROP TRIGGER IF EXISTS create_gig_notification;

-- Trigger 1: Update gig application count when application is created/updated/deleted
DELIMITER $$
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
END$$

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
END$$

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
END$$
DELIMITER ;

-- Trigger 2: Update user rating when review is created/updated/deleted
DELIMITER $$
CREATE TRIGGER update_user_rating_insert
    AFTER INSERT ON reviews
    FOR EACH ROW
BEGIN
    UPDATE users 
    SET 
        rating = (
            SELECT AVG(rating) 
            FROM reviews 
            WHERE reviewee_id = NEW.reviewee_id
        ),
        total_ratings = (
            SELECT COUNT(*) 
            FROM reviews 
            WHERE reviewee_id = NEW.reviewee_id
        )
    WHERE id = NEW.reviewee_id;
END$$

CREATE TRIGGER update_user_rating_update
    AFTER UPDATE ON reviews
    FOR EACH ROW
BEGIN
    UPDATE users 
    SET 
        rating = (
            SELECT AVG(rating) 
            FROM reviews 
            WHERE reviewee_id = NEW.reviewee_id
        ),
        total_ratings = (
            SELECT COUNT(*) 
            FROM reviews 
            WHERE reviewee_id = NEW.reviewee_id
        )
    WHERE id = NEW.reviewee_id;
END$$

CREATE TRIGGER update_user_rating_delete
    AFTER DELETE ON reviews
    FOR EACH ROW
BEGIN
    UPDATE users 
    SET 
        rating = (
            SELECT COALESCE(AVG(rating), 0) 
            FROM reviews 
            WHERE reviewee_id = OLD.reviewee_id
        ),
        total_ratings = (
            SELECT COUNT(*) 
            FROM reviews 
            WHERE reviewee_id = OLD.reviewee_id
        )
    WHERE id = OLD.reviewee_id;
END$$
DELIMITER ;

-- Trigger 3: Create notification when application is submitted
DELIMITER $$
CREATE TRIGGER create_notification_on_application
    AFTER INSERT ON applications
    FOR EACH ROW
BEGIN
    DECLARE business_user_id INT;
    DECLARE gig_title VARCHAR(255);
    DECLARE student_name VARCHAR(255);
    
    -- Get business user ID and gig title
    SELECT g.user_id, g.title INTO business_user_id, gig_title
    FROM gigs g
    WHERE g.id = NEW.gig_id;
    
    -- Get student name
    SELECT name INTO student_name
    FROM users
    WHERE id = NEW.user_id;
    
    -- Create notification for business
    INSERT INTO notifications (user_id, title, message, type, is_read, created_at)
    VALUES (
        business_user_id,
        'New Application Received',
        CONCAT(student_name, ' has applied to your gig: ', gig_title),
        'info',
        FALSE,
        NOW()
    );
END$$
DELIMITER ;

-- Trigger 4: Create notification when application status changes
DELIMITER $$
CREATE TRIGGER create_notification_on_application_status
    AFTER UPDATE ON applications
    FOR EACH ROW
BEGIN
    DECLARE business_user_id INT;
    DECLARE gig_title VARCHAR(255);
    DECLARE student_name VARCHAR(255);
    
    -- Only trigger if status changed
    IF OLD.status != NEW.status THEN
        -- Get business user ID and gig title
        SELECT g.user_id, g.title INTO business_user_id, gig_title
        FROM gigs g
        WHERE g.id = NEW.gig_id;
        
        -- Get student name
        SELECT name INTO student_name
        FROM users
        WHERE id = NEW.user_id;
        
        -- Create notification for student
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
END$$
DELIMITER ;

-- Trigger 5: Create notification when new message is sent
DELIMITER $$
CREATE TRIGGER create_notification_on_message
    AFTER INSERT ON messages
    FOR EACH ROW
BEGIN
    DECLARE recipient_id INT;
    DECLARE sender_name VARCHAR(255);
    DECLARE conversation_title VARCHAR(255);
    
    -- Get recipient ID (the other user in the conversation)
    SELECT 
        CASE 
            WHEN c.user1_id = NEW.sender_id THEN c.user2_id
            ELSE c.user1_id
        END INTO recipient_id
    FROM conversations c
    WHERE c.id = NEW.conversation_id;
    
    -- Get sender name
    SELECT name INTO sender_name
    FROM users
    WHERE id = NEW.sender_id;
    
    -- Create notification for recipient
    INSERT INTO notifications (user_id, title, message, type, is_read, created_at)
    VALUES (
        recipient_id,
        'New Message',
        CONCAT(sender_name, ' sent you a message'),
        'info',
        FALSE,
        NOW()
    );
END$$
DELIMITER ;

-- Trigger 6: Update gig view count (simulated - would be triggered by frontend)
DELIMITER $$
CREATE TRIGGER update_gig_view_count
    AFTER UPDATE ON gigs
    FOR EACH ROW
BEGIN
    -- This trigger can be used to update view counts
    -- The actual view count update would be handled by the frontend
    -- This is a placeholder for future view tracking
END$$
DELIMITER ;

-- Trigger 7: Create welcome notification for new users
DELIMITER $$
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
END$$
DELIMITER ;

-- Trigger 8: Create notification when new gig is posted
DELIMITER $$
CREATE TRIGGER create_gig_notification
    AFTER INSERT ON gigs
    FOR EACH ROW
BEGIN
    DECLARE business_name VARCHAR(255);
    
    -- Get business name
    SELECT name INTO business_name
    FROM users
    WHERE id = NEW.user_id;
    
    -- Create notifications for students who might be interested
    -- This would be based on skills matching (simplified here)
    INSERT INTO notifications (user_id, title, message, type, is_read, created_at)
    SELECT 
        u.id,
        'New Gig Available',
        CONCAT(business_name, ' posted a new gig: ', NEW.title),
        'info',
        FALSE,
        NOW()
    FROM users u
    WHERE u.type = 'student' 
    AND u.is_active = TRUE
    AND (
        NEW.skills IS NULL 
        OR NEW.skills = '' 
        OR u.skills LIKE CONCAT('%', SUBSTRING_INDEX(NEW.skills, ',', 1), '%')
    )
    LIMIT 10; -- Limit to avoid spam
END$$
DELIMITER ;

-- Trigger 9: Update conversation last_message_at when new message is added
DELIMITER $$
CREATE TRIGGER update_conversation_last_message
    AFTER INSERT ON messages
    FOR EACH ROW
BEGIN
    UPDATE conversations 
    SET last_message_at = NOW()
    WHERE id = NEW.conversation_id;
END$$
DELIMITER ;

-- Trigger 10: Update user last activity (for session management)
DELIMITER $$
CREATE TRIGGER update_user_last_activity
    AFTER UPDATE ON users
    FOR EACH ROW
BEGIN
    -- This trigger can be used to track user activity
    -- The actual activity tracking is handled by the session system
    -- This is a placeholder for future activity tracking
END$$
DELIMITER ;

-- Create indexes for better trigger performance
CREATE INDEX IF NOT EXISTS idx_applications_gig_id_status ON applications(gig_id, status);
CREATE INDEX IF NOT EXISTS idx_reviews_reviewee_id ON reviews(reviewee_id);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id_read ON notifications(user_id, is_read);

-- Create a view for notification summary
CREATE OR REPLACE VIEW notification_summary AS
SELECT 
    n.id,
    n.user_id,
    n.title,
    n.message,
    n.type,
    n.is_read,
    n.created_at,
    u.name as user_name,
    u.type as user_type
FROM notifications n
JOIN users u ON n.user_id = u.id
ORDER BY n.created_at DESC;

-- Create a view for application statistics
CREATE OR REPLACE VIEW application_stats AS
SELECT 
    g.id as gig_id,
    g.title as gig_title,
    g.user_id as business_id,
    u.name as business_name,
    COUNT(a.id) as total_applications,
    COUNT(CASE WHEN a.status = 'pending' THEN 1 END) as pending_applications,
    COUNT(CASE WHEN a.status = 'accepted' THEN 1 END) as accepted_applications,
    COUNT(CASE WHEN a.status = 'rejected' THEN 1 END) as rejected_applications,
    COUNT(CASE WHEN a.status = 'completed' THEN 1 END) as completed_applications
FROM gigs g
LEFT JOIN applications a ON g.id = a.gig_id
LEFT JOIN users u ON g.user_id = u.id
GROUP BY g.id, g.title, g.user_id, u.name;

-- Create a view for user statistics
CREATE OR REPLACE VIEW user_stats AS
SELECT 
    u.id,
    u.name,
    u.email,
    u.type,
    u.rating,
    u.total_ratings,
    u.created_at,
    COUNT(DISTINCT g.id) as total_gigs_posted,
    COUNT(DISTINCT a.id) as total_applications,
    COUNT(DISTINCT r.id) as total_reviews_given,
    COUNT(DISTINCT CASE WHEN r.rating >= 4 THEN r.id END) as positive_reviews
FROM users u
LEFT JOIN gigs g ON u.id = g.user_id
LEFT JOIN applications a ON u.id = a.user_id
LEFT JOIN reviews r ON u.id = r.reviewer_id
GROUP BY u.id, u.name, u.email, u.type, u.rating, u.total_ratings, u.created_at;

-- Test the triggers by inserting some sample data
INSERT INTO notifications (user_id, title, message, type, is_read, created_at)
SELECT 
    u.id,
    'System Ready',
    'Database triggers have been successfully installed and are ready to use.',
    'success',
    TRUE,
    NOW()
FROM users u
WHERE u.email LIKE '%@demo.com' OR u.email LIKE '%@techflow.com' OR u.email LIKE '%@creativeminds.com' OR u.email LIKE '%@pixelperfect.com' OR u.email LIKE '%@datainsights.com' OR u.email LIKE '%@wordcraft.com'
LIMIT 5;

-- Display trigger information
SELECT 'Database triggers installed successfully!' as status;
SELECT 'Triggers created:' as info;
SELECT '1. update_gig_application_count - Updates application count on gigs' as trigger_1;
SELECT '2. update_user_rating - Updates user ratings when reviews change' as trigger_2;
SELECT '3. create_notification_on_application - Notifies business of new applications' as trigger_3;
SELECT '4. create_notification_on_application_status - Notifies students of status changes' as trigger_4;
SELECT '5. create_notification_on_message - Notifies users of new messages' as trigger_5;
SELECT '6. create_welcome_notification - Welcomes new users' as trigger_6;
SELECT '7. create_gig_notification - Notifies students of new gigs' as trigger_7;
SELECT '8. update_conversation_last_message - Updates conversation timestamps' as trigger_8;
SELECT 'Views created: notification_summary, application_stats, user_stats' as views;
