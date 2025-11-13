-- FunaGig Database Schema Export
-- Complete database structure for MySQL/MariaDB
-- Generated for XAMPP deployment
-- Date: 2025-01-16

-- =====================================================
-- DATABASE CREATION
-- =====================================================

CREATE DATABASE IF NOT EXISTS funagig;
USE funagig;

-- =====================================================
-- TABLES
-- =====================================================

-- Users table (unified for students and businesses)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    type ENUM('student', 'business') NOT NULL,
    university VARCHAR(255) NULL,
    major VARCHAR(255) NULL,
    industry VARCHAR(255) NULL,
    profile_image VARCHAR(500) NULL,
    bio TEXT NULL,
    skills TEXT NULL,
    location VARCHAR(255) NULL,
    phone VARCHAR(20) NULL,
    website VARCHAR(255) NULL,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_ratings INT DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    tos_accepted TINYINT(1) DEFAULT 0,
    privacy_accepted TINYINT(1) DEFAULT 0,
    dpa_accepted TINYINT(1) DEFAULT 0,
    policies_accepted_at TIMESTAMP NULL,
    terms_version VARCHAR(10) DEFAULT '1.0',
    privacy_version VARCHAR(10) DEFAULT '1.0',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Gigs table (jobs/projects posted by businesses)
CREATE TABLE IF NOT EXISTS gigs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    budget DECIMAL(10,2) NOT NULL,
    deadline DATE NOT NULL,
    skills TEXT NULL,
    location VARCHAR(255) NULL,
    type ENUM('one-time', 'ongoing', 'contract') DEFAULT 'one-time',
    status ENUM('active', 'paused', 'completed', 'cancelled') DEFAULT 'active',
    view_count INT DEFAULT 0,
    application_count INT DEFAULT 0,
    category VARCHAR(100) NULL,
    duration VARCHAR(50) NULL,
    hours_per_week VARCHAR(20) NULL,
    required_skills TEXT NULL,
    preferred_skills TEXT NULL,
    education_level VARCHAR(50) NULL,
    experience_level VARCHAR(50) NULL,
    work_location VARCHAR(50) NULL,
    specific_location VARCHAR(255) NULL,
    company_name VARCHAR(255) NULL,
    contact_person VARCHAR(255) NULL,
    contact_email VARCHAR(255) NULL,
    additional_notes TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Applications table (student applications to gigs)
CREATE TABLE IF NOT EXISTS applications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    gig_id INT NOT NULL,
    message TEXT NULL,
    status ENUM('pending', 'accepted', 'rejected', 'completed') DEFAULT 'pending',
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    rating INT NULL,
    review TEXT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (gig_id) REFERENCES gigs(id) ON DELETE CASCADE,
    UNIQUE KEY unique_application (user_id, gig_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Conversations table (messaging between users)
CREATE TABLE IF NOT EXISTS conversations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user1_id INT NOT NULL,
    user2_id INT NOT NULL,
    last_message_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user1_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (user2_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_conversation (user1_id, user2_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Messages table (individual messages in conversations)
CREATE TABLE IF NOT EXISTS messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    conversation_id INT NOT NULL,
    sender_id INT NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Notifications table (system notifications)
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('info', 'success', 'warning', 'error') DEFAULT 'info',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Password resets table
CREATE TABLE IF NOT EXISTS password_resets (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    email VARCHAR(190) NOT NULL,
    token CHAR(64) NOT NULL,
    requested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    used_at TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_password_resets_token (token),
    KEY idx_password_resets_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Saved gigs table (students can save gigs for later)
CREATE TABLE IF NOT EXISTS saved_gigs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    gig_id INT NOT NULL,
    saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (gig_id) REFERENCES gigs(id) ON DELETE CASCADE,
    UNIQUE KEY unique_saved_gig (user_id, gig_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Skills table (for skill management)
CREATE TABLE IF NOT EXISTS skills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(50) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User skills table (many-to-many relationship)
CREATE TABLE IF NOT EXISTS user_skills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    skill_id INT NOT NULL,
    proficiency ENUM('beginner', 'intermediate', 'advanced', 'expert') DEFAULT 'intermediate',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_skill (user_id, skill_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Reviews table (ratings and reviews)
CREATE TABLE IF NOT EXISTS reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reviewer_id INT NOT NULL,
    reviewee_id INT NOT NULL,
    application_id INT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewee_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE SET NULL,
    UNIQUE KEY unique_review (reviewer_id, reviewee_id, application_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Categories table (for gig categorization)
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT NULL,
    parent_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Gig categories table (many-to-many relationship)
CREATE TABLE IF NOT EXISTS gig_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    gig_id INT NOT NULL,
    category_id INT NOT NULL,
    FOREIGN KEY (gig_id) REFERENCES gigs(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    UNIQUE KEY unique_gig_category (gig_id, category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- INDEXES
-- =====================================================

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_type ON users(type);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);

-- Gigs indexes
CREATE INDEX IF NOT EXISTS idx_gigs_user_id ON gigs(user_id);
CREATE INDEX IF NOT EXISTS idx_gigs_status ON gigs(status);
CREATE INDEX IF NOT EXISTS idx_gigs_deadline ON gigs(deadline);

-- Applications indexes
CREATE INDEX IF NOT EXISTS idx_applications_user_id ON applications(user_id);
CREATE INDEX IF NOT EXISTS idx_applications_gig_id ON applications(gig_id);
CREATE INDEX IF NOT EXISTS idx_applications_status ON applications(status);
CREATE INDEX IF NOT EXISTS idx_applications_gig_id_status ON applications(gig_id, status);

-- Messages indexes
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);

-- Notifications indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id_read ON notifications(user_id, is_read);

-- Reviews indexes
CREATE INDEX IF NOT EXISTS idx_reviews_reviewee_id ON reviews(reviewee_id);
CREATE INDEX IF NOT EXISTS idx_reviews_reviewer_id ON reviews(reviewer_id);

-- Conversations indexes
CREATE INDEX IF NOT EXISTS idx_conversations_user1_id ON conversations(user1_id);
CREATE INDEX IF NOT EXISTS idx_conversations_user2_id ON conversations(user2_id);
CREATE INDEX IF NOT EXISTS idx_conversations_last_message_at ON conversations(last_message_at);

-- =====================================================
-- VIEWS
-- =====================================================

-- Active gigs view
CREATE OR REPLACE VIEW active_gigs AS
SELECT 
    g.*, 
    u.name as business_name, 
    u.industry, 
    u.location as business_location
FROM gigs g
JOIN users u ON g.user_id = u.id
WHERE g.status = 'active';

-- Application details view
CREATE OR REPLACE VIEW application_details AS
SELECT 
    a.*, 
    g.title as gig_title, 
    g.budget, 
    u1.name as student_name, 
    u2.name as business_name
FROM applications a
JOIN gigs g ON a.gig_id = g.id
JOIN users u1 ON a.user_id = u1.id
JOIN users u2 ON g.user_id = u2.id;

-- Conversation summary view
CREATE OR REPLACE VIEW conversation_summary AS
SELECT 
    c.*, 
    u1.name as user1_name, 
    u2.name as user2_name,
    (SELECT content FROM messages WHERE conversation_id = c.id ORDER BY created_at DESC LIMIT 1) as last_message,
    (SELECT created_at FROM messages WHERE conversation_id = c.id ORDER BY created_at DESC LIMIT 1) as last_message_time
FROM conversations c
JOIN users u1 ON c.user1_id = u1.id
JOIN users u2 ON c.user2_id = u2.id;

-- Notification summary view
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

-- Application statistics view
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

-- User statistics view
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

-- =====================================================
-- TRIGGERS
-- =====================================================

-- Drop existing triggers if they exist
DROP TRIGGER IF EXISTS update_gig_application_count;
DROP TRIGGER IF EXISTS update_gig_application_count_update;
DROP TRIGGER IF EXISTS update_gig_application_count_delete;
DROP TRIGGER IF EXISTS update_user_rating_insert;
DROP TRIGGER IF EXISTS update_user_rating_update;
DROP TRIGGER IF EXISTS update_user_rating_delete;
DROP TRIGGER IF EXISTS create_notification_on_application;
DROP TRIGGER IF EXISTS create_notification_on_application_status;
DROP TRIGGER IF EXISTS create_notification_on_message;
DROP TRIGGER IF EXISTS update_conversation_last_message;
DROP TRIGGER IF EXISTS create_welcome_notification;
DROP TRIGGER IF EXISTS create_gig_notification;

-- Trigger 1: Update gig application count when application is created
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

-- Trigger 2: Update gig application count when application is updated
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

-- Trigger 3: Update gig application count when application is deleted
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

-- Trigger 4: Update user rating when review is created
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

-- Trigger 5: Update user rating when review is updated
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

-- Trigger 6: Update user rating when review is deleted
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

-- Trigger 7: Create notification when application is submitted
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
END$$

-- Trigger 8: Create notification when application status changes
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

-- Trigger 9: Create notification when new message is sent
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
END$$

-- Trigger 10: Update conversation last_message_at when new message is added
CREATE TRIGGER update_conversation_last_message
    AFTER INSERT ON messages
    FOR EACH ROW
BEGIN
    UPDATE conversations 
    SET last_message_at = NOW()
    WHERE id = NEW.conversation_id;
END$$

-- Trigger 11: Create welcome notification for new users
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

-- Trigger 12: Create notification when new gig is posted
CREATE TRIGGER create_gig_notification
    AFTER INSERT ON gigs
    FOR EACH ROW
BEGIN
    DECLARE business_name VARCHAR(255);
    
    SELECT name INTO business_name
    FROM users
    WHERE id = NEW.user_id;
    
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
    LIMIT 10;
END$$
DELIMITER ;

-- =====================================================
-- EXPORT COMPLETE
-- =====================================================

SELECT 'FunaGig Database Schema Export Complete!' as Status;
SELECT 'Tables: users, gigs, applications, conversations, messages, notifications, password_resets, saved_gigs, skills, user_skills, reviews, categories, gig_categories' as Tables;
SELECT 'Views: active_gigs, application_details, conversation_summary, notification_summary, application_stats, user_stats' as Views;
SELECT 'Triggers: 12 triggers installed for automatic data management' as Triggers;

