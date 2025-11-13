-- =============================================
-- FUNAGIG UNIFIED DATABASE SCHEMA
-- Complete MySQL Database for FunaGig Platform
-- Version: 2.0 - Enhanced with all features
-- =============================================

-- Create database
CREATE DATABASE IF NOT EXISTS funagig CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE funagig;

-- =============================================
-- CORE TABLES
-- =============================================

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  email VARCHAR(190) NOT NULL,
  password_hash VARCHAR(255) NULL,
  role ENUM('student','business','admin') NOT NULL DEFAULT 'student',
  display_name VARCHAR(190) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Student Profile
CREATE TABLE IF NOT EXISTS student_profiles (
  user_id BIGINT UNSIGNED NOT NULL,
  university VARCHAR(190) NULL,
  major VARCHAR(190) NULL,
  year_of_study VARCHAR(50) NULL,
  phone VARCHAR(50) NULL,
  skills JSON NULL,
  payment_info VARCHAR(190) NULL,
  avatar_initials VARCHAR(4) NULL,
  PRIMARY KEY (user_id),
  CONSTRAINT fk_student_profiles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Business Profile
CREATE TABLE IF NOT EXISTS business_profiles (
  user_id BIGINT UNSIGNED NOT NULL,
  company_name VARCHAR(190) NOT NULL,
  contact_person VARCHAR(190) NULL,
  industry VARCHAR(120) NULL,
  website VARCHAR(190) NULL,
  location VARCHAR(190) NULL,
  contact_email VARCHAR(190) NULL,
  PRIMARY KEY (user_id),
  CONSTRAINT fk_business_profiles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Gig Categories
CREATE TABLE IF NOT EXISTS gig_categories (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  description TEXT NULL,
  icon VARCHAR(50) NULL,
  color VARCHAR(7) NULL,
  is_active BOOLEAN DEFAULT TRUE,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_categories_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Skills
CREATE TABLE IF NOT EXISTS skills (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  category VARCHAR(50) NULL,
  description TEXT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  usage_count INT DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_skills_name (name),
  KEY idx_skills_category (category),
  KEY idx_skills_usage (usage_count)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Gigs (enhanced with all fields)
CREATE TABLE IF NOT EXISTS gigs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  business_user_id BIGINT UNSIGNED NOT NULL,
  category_id BIGINT UNSIGNED NULL,
  title VARCHAR(190) NOT NULL,
  description TEXT NULL,
  type ENUM('one_time','part_time','full_time') NULL,
  gig_type ENUM('one_time','part_time','full_time','contract') NULL,
  skills TEXT NULL,
  required_skills TEXT NULL,
  preferred_skills TEXT NULL,
  compensation VARCHAR(120) NULL,
  location ENUM('on_campus','remote','hybrid') NULL,
  work_location ENUM('on_campus','remote','hybrid','flexible') NULL,
  specific_location VARCHAR(255) NULL,
  application_deadline DATE NULL,
  project_duration VARCHAR(50) NULL,
  hours_per_week VARCHAR(50) NULL,
  education_level ENUM('high_school','diploma','bachelor','master','phd') NULL,
  experience_level ENUM('entry','junior','mid','senior') NULL,
  company_name VARCHAR(190) NULL,
  contact_person VARCHAR(190) NULL,
  contact_email VARCHAR(190) NULL,
  additional_notes TEXT NULL,
  status ENUM('open','in_progress','closed') NOT NULL DEFAULT 'open',
  views_count INT DEFAULT 0,
  applications_count INT DEFAULT 0,
  hired_count INT DEFAULT 0,
  is_draft BOOLEAN DEFAULT FALSE,
  published_at TIMESTAMP NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_gigs_business (business_user_id),
  KEY idx_gigs_category (category_id),
  KEY idx_gigs_deadline (application_deadline),
  KEY idx_gigs_type (gig_type),
  KEY idx_gigs_status_draft (status, is_draft),
  KEY idx_gigs_views_count (views_count),
  KEY idx_gigs_applications_count (applications_count),
  KEY idx_gigs_hired_count (hired_count),
  KEY idx_gigs_published_at (published_at),
  FULLTEXT KEY ft_gigs_title_desc (title, description),
  CONSTRAINT fk_gigs_business FOREIGN KEY (business_user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_gigs_category FOREIGN KEY (category_id) REFERENCES gig_categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Applications
CREATE TABLE IF NOT EXISTS applications (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  gig_id BIGINT UNSIGNED NOT NULL,
  student_user_id BIGINT UNSIGNED NOT NULL,
  status ENUM('pending','viewed','accepted','rejected') NOT NULL DEFAULT 'pending',
  cover_letter TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_applications_unique (gig_id, student_user_id),
  KEY idx_applications_student (student_user_id),
  KEY idx_applications_status (status),
  CONSTRAINT fk_applications_gig FOREIGN KEY (gig_id) REFERENCES gigs(id) ON DELETE CASCADE,
  CONSTRAINT fk_applications_student FOREIGN KEY (student_user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Saved gigs
CREATE TABLE IF NOT EXISTS saved_gigs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  student_user_id BIGINT UNSIGNED NOT NULL,
  gig_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_saved_gigs_unique (student_user_id, gig_id),
  KEY idx_saved_gigs_student (student_user_id),
  CONSTRAINT fk_saved_gigs_student FOREIGN KEY (student_user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_saved_gigs_gig FOREIGN KEY (gig_id) REFERENCES gigs(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Interested gigs
CREATE TABLE IF NOT EXISTS interested_gigs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  student_user_id BIGINT UNSIGNED NOT NULL,
  gig_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_interested_gigs_unique (student_user_id, gig_id),
  KEY idx_interested_gigs_student (student_user_id),
  CONSTRAINT fk_interested_gigs_student FOREIGN KEY (student_user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_interested_gigs_gig FOREIGN KEY (gig_id) REFERENCES gigs(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- ENHANCED FEATURES TABLES
-- =============================================

-- User Notifications System
CREATE TABLE IF NOT EXISTS user_notifications (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  notification_type ENUM('application_received','application_accepted','application_rejected','gig_posted','gig_updated','gig_expiring','payment_received','message_received','system_announcement','gig_deadline_reminder','new_gig_matching_skills','profile_viewed','review_received') NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP NULL,
  action_url VARCHAR(500) NULL,
  related_gig_id BIGINT UNSIGNED NULL,
  related_application_id BIGINT UNSIGNED NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_user_notifications_user (user_id),
  KEY idx_user_notifications_unread (user_id, is_read),
  KEY idx_user_notifications_type (notification_type),
  KEY idx_user_notifications_created (created_at),
  KEY idx_user_notifications_created_desc (created_at DESC),
  KEY idx_user_notifications_unread_created (user_id, is_read, created_at DESC),
  CONSTRAINT fk_user_notifications_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_user_notifications_gig FOREIGN KEY (related_gig_id) REFERENCES gigs(id) ON DELETE SET NULL,
  CONSTRAINT fk_user_notifications_application FOREIGN KEY (related_application_id) REFERENCES applications(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Messaging System
CREATE TABLE IF NOT EXISTS conversations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  gig_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  business_id BIGINT UNSIGNED NOT NULL,
  last_message_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_conversations_unique (gig_id, student_id, business_id),
  KEY idx_conversations_student (student_id),
  KEY idx_conversations_business (business_id),
  KEY idx_conversations_last_message (last_message_at),
  CONSTRAINT fk_conversations_gig FOREIGN KEY (gig_id) REFERENCES gigs(id) ON DELETE CASCADE,
  CONSTRAINT fk_conversations_student FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_conversations_business FOREIGN KEY (business_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  conversation_id BIGINT UNSIGNED NOT NULL,
  sender_id BIGINT UNSIGNED NOT NULL,
  message_text TEXT NOT NULL,
  message_type ENUM('text','file','image','system','gig_update','application_update') DEFAULT 'text',
  file_url VARCHAR(500) NULL,
  file_name VARCHAR(255) NULL,
  file_size BIGINT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_messages_conversation (conversation_id),
  KEY idx_messages_sender (sender_id),
  KEY idx_messages_created (created_at),
  KEY idx_messages_conversation_created (conversation_id, created_at DESC),
  KEY idx_messages_unread (conversation_id, is_read, created_at),
  CONSTRAINT fk_messages_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
  CONSTRAINT fk_messages_sender FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- File Attachments System
CREATE TABLE IF NOT EXISTS file_attachments (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  gig_id BIGINT UNSIGNED NULL,
  application_id BIGINT UNSIGNED NULL,
  conversation_id BIGINT UNSIGNED NULL,
  file_name VARCHAR(255) NOT NULL,
  file_path VARCHAR(500) NOT NULL,
  file_size BIGINT NOT NULL,
  file_type VARCHAR(100) NOT NULL,
  file_category ENUM('resume','portfolio','cover_letter','gig_attachment','profile_photo','message_attachment','other') NOT NULL,
  is_public BOOLEAN DEFAULT FALSE,
  download_count INT DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_file_attachments_user (user_id),
  KEY idx_file_attachments_gig (gig_id),
  KEY idx_file_attachments_application (application_id),
  KEY idx_file_attachments_conversation (conversation_id),
  KEY idx_file_attachments_category (file_category),
  KEY idx_file_attachments_public (is_public, created_at DESC),
  CONSTRAINT fk_file_attachments_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_file_attachments_gig FOREIGN KEY (gig_id) REFERENCES gigs(id) ON DELETE CASCADE,
  CONSTRAINT fk_file_attachments_application FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE,
  CONSTRAINT fk_file_attachments_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- User Activity Tracking
CREATE TABLE IF NOT EXISTS user_activity_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NULL,
  action VARCHAR(100) NOT NULL,
  resource_type VARCHAR(50) NULL,
  resource_id BIGINT UNSIGNED NULL,
  details JSON NULL,
  ip_address VARCHAR(45) NULL,
  user_agent TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_activity_user (user_id),
  KEY idx_activity_action (action),
  KEY idx_activity_created (created_at),
  CONSTRAINT fk_activity_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Platform Analytics
CREATE TABLE IF NOT EXISTS platform_analytics (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  metric_name VARCHAR(100) NOT NULL,
  metric_value DECIMAL(15,2) NOT NULL,
  metric_date DATE NOT NULL,
  additional_data JSON NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_platform_analytics (metric_name, metric_date),
  KEY idx_platform_analytics_date (metric_date),
  KEY idx_platform_analytics_name (metric_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Audit Trail
CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NULL,
  action VARCHAR(100) NOT NULL,
  table_name VARCHAR(100) NOT NULL,
  record_id BIGINT UNSIGNED NULL,
  old_values JSON NULL,
  new_values JSON NULL,
  ip_address VARCHAR(45) NULL,
  user_agent TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_audit_logs_user (user_id),
  KEY idx_audit_logs_action (action),
  KEY idx_audit_logs_table (table_name),
  KEY idx_audit_logs_created (created_at),
  CONSTRAINT fk_audit_logs_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Security Events
CREATE TABLE IF NOT EXISTS security_events (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NULL,
  event_type ENUM('login_success','login_failed','password_change','email_change','suspicious_activity','account_locked','account_unlocked','password_reset_requested','password_reset_completed','two_factor_enabled','two_factor_disabled','api_key_created','api_key_revoked') NOT NULL,
  ip_address VARCHAR(45) NULL,
  user_agent TEXT NULL,
  event_details JSON NULL,
  severity ENUM('low','medium','high','critical') DEFAULT 'medium',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_security_events_user (user_id),
  KEY idx_security_events_type (event_type),
  KEY idx_security_events_severity (severity),
  KEY idx_security_events_created (created_at),
  KEY idx_security_events_ip (ip_address, created_at DESC),
  KEY idx_security_events_severity_created (severity, created_at DESC),
  CONSTRAINT fk_security_events_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Wallet System
CREATE TABLE IF NOT EXISTS user_wallets (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  balance DECIMAL(10,2) DEFAULT 0.00,
  currency VARCHAR(3) DEFAULT 'UGX',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_user_wallets_user (user_id),
  CONSTRAINT fk_user_wallets_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS wallet_transactions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  wallet_id BIGINT UNSIGNED NOT NULL,
  transaction_type ENUM('credit','debit','refund','withdrawal','fee','bonus','penalty') NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  description TEXT NULL,
  reference_id VARCHAR(100) NULL,
  reference_type ENUM('gig_payment','platform_fee','withdrawal','refund','bonus','penalty') NULL,
  status ENUM('pending','completed','failed','cancelled') DEFAULT 'pending',
  processed_at TIMESTAMP NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_wallet_transactions_wallet (wallet_id),
  KEY idx_wallet_transactions_type (transaction_type),
  KEY idx_wallet_transactions_status (status),
  KEY idx_wallet_transactions_created (created_at),
  KEY idx_wallet_transactions_reference (reference_id, reference_type),
  KEY idx_wallet_transactions_amount (amount, created_at DESC),
  CONSTRAINT fk_wallet_transactions_wallet FOREIGN KEY (wallet_id) REFERENCES user_wallets(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- User Preferences
CREATE TABLE IF NOT EXISTS user_preferences (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  preference_key VARCHAR(100) NOT NULL,
  preference_value TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_user_preferences (user_id, preference_key),
  CONSTRAINT fk_user_preferences_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Saved Searches
CREATE TABLE IF NOT EXISTS saved_searches (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  search_name VARCHAR(255) NOT NULL,
  search_criteria JSON NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  last_searched_at TIMESTAMP NULL,
  search_count INT DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_saved_searches_user (user_id),
  KEY idx_saved_searches_active (is_active),
  KEY idx_saved_searches_last_searched (last_searched_at DESC),
  KEY idx_saved_searches_search_count (search_count DESC),
  CONSTRAINT fk_saved_searches_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- A/B Testing
CREATE TABLE IF NOT EXISTS ab_tests (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  test_name VARCHAR(100) NOT NULL,
  test_description TEXT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  start_date TIMESTAMP NOT NULL,
  end_date TIMESTAMP NULL,
  target_audience JSON NULL,
  success_metric VARCHAR(100) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_ab_tests_active (is_active),
  KEY idx_ab_tests_dates (start_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ab_test_assignments (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  test_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  variant VARCHAR(50) NOT NULL,
  assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_ab_assignments (test_id, user_id),
  CONSTRAINT fk_ab_assignments_test FOREIGN KEY (test_id) REFERENCES ab_tests(id) ON DELETE CASCADE,
  CONSTRAINT fk_ab_assignments_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Gig Recommendations
CREATE TABLE IF NOT EXISTS gig_recommendations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  gig_id BIGINT UNSIGNED NOT NULL,
  recommendation_score DECIMAL(5,4) NOT NULL,
  recommendation_reason VARCHAR(255) NULL,
  is_viewed BOOLEAN DEFAULT FALSE,
  is_applied BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_gig_recommendations (user_id, gig_id),
  KEY idx_gig_recommendations_user (user_id),
  KEY idx_gig_recommendations_score (recommendation_score),
  KEY idx_gig_recommendations_score_desc (recommendation_score DESC),
  KEY idx_gig_recommendations_not_viewed (user_id, is_viewed, recommendation_score DESC),
  CONSTRAINT fk_gig_recommendations_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_gig_recommendations_gig FOREIGN KEY (gig_id) REFERENCES gigs(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Enhanced User Sessions
CREATE TABLE IF NOT EXISTS user_sessions_enhanced (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  session_token VARCHAR(255) NOT NULL,
  device_info VARCHAR(500) NULL,
  ip_address VARCHAR(45) NULL,
  user_agent TEXT NULL,
  location_country VARCHAR(100) NULL,
  location_city VARCHAR(100) NULL,
  is_active BOOLEAN DEFAULT TRUE,
  expires_at TIMESTAMP NOT NULL,
  last_activity TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_sessions_token (session_token),
  KEY idx_sessions_user (user_id),
  KEY idx_sessions_active (is_active),
  KEY idx_sessions_expires (expires_at),
  CONSTRAINT fk_sessions_enhanced_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Feedback System
CREATE TABLE IF NOT EXISTS feedback (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  feedback_type ENUM('bug_report','feature_request','general_feedback','complaint','compliment') NOT NULL,
  subject VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  priority ENUM('low','medium','high','urgent') DEFAULT 'medium',
  status ENUM('open','in_progress','resolved','closed') DEFAULT 'open',
  admin_notes TEXT NULL,
  resolved_by BIGINT UNSIGNED NULL,
  resolved_at TIMESTAMP NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_feedback_user (user_id),
  KEY idx_feedback_type (feedback_type),
  KEY idx_feedback_status (status),
  KEY idx_feedback_priority (priority),
  KEY idx_feedback_created_desc (created_at DESC),
  KEY idx_feedback_status_priority (status, priority, created_at DESC),
  CONSTRAINT fk_feedback_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_feedback_resolved_by FOREIGN KEY (resolved_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- API Rate Limiting
CREATE TABLE IF NOT EXISTS api_rate_limits (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NULL,
  ip_address VARCHAR(45) NOT NULL,
  endpoint VARCHAR(255) NOT NULL,
  request_count INT DEFAULT 1,
  window_start TIMESTAMP NOT NULL,
  window_end TIMESTAMP NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_api_rate_limits (user_id, ip_address, endpoint, window_start),
  KEY idx_api_rate_limits_user (user_id),
  KEY idx_api_rate_limits_ip (ip_address),
  KEY idx_api_rate_limits_window (window_start, window_end),
  KEY idx_api_rate_limits_cleanup (window_end),
  KEY idx_api_rate_limits_user_endpoint (user_id, endpoint, window_start),
  CONSTRAINT fk_api_rate_limits_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- ADDITIONAL SUPPORT TABLES
-- =============================================

-- Contact messages (enhanced)
CREATE TABLE IF NOT EXISTS contact_messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NULL,
  name VARCHAR(190) NULL,
  email VARCHAR(190) NULL,
  subject VARCHAR(100) NULL,
  message TEXT NOT NULL,
  newsletter_subscription BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_contact_user (user_id),
  CONSTRAINT fk_contact_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Password reset requests
CREATE TABLE IF NOT EXISTS password_resets (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  email VARCHAR(190) NOT NULL,
  token CHAR(64) NOT NULL,
  requested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  used_at TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_password_resets_token (token),
  KEY idx_password_resets_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Reviews and Ratings
CREATE TABLE IF NOT EXISTS reviews (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  reviewer_id BIGINT UNSIGNED NOT NULL,
  reviewee_id BIGINT UNSIGNED NOT NULL,
  gig_id BIGINT UNSIGNED NULL,
  rating TINYINT UNSIGNED NOT NULL CHECK (rating >= 1 AND rating <= 5),
  title VARCHAR(200) NULL,
  comment TEXT NULL,
  is_public BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_reviews_unique (reviewer_id, reviewee_id, gig_id),
  KEY idx_reviews_reviewer (reviewer_id),
  KEY idx_reviews_reviewee (reviewee_id),
  KEY idx_reviews_gig (gig_id),
  KEY idx_reviews_rating (rating),
  CONSTRAINT fk_reviews_reviewer FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_reviews_reviewee FOREIGN KEY (reviewee_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_reviews_gig FOREIGN KEY (gig_id) REFERENCES gigs(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- User Skills Junction
CREATE TABLE IF NOT EXISTS user_skills (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  skill_id BIGINT UNSIGNED NOT NULL,
  proficiency_level ENUM('beginner','intermediate','advanced','expert') DEFAULT 'intermediate',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_user_skills (user_id, skill_id),
  KEY idx_user_skills_user (user_id),
  KEY idx_user_skills_skill (skill_id),
  CONSTRAINT fk_user_skills_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_user_skills_skill FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Application Status History
CREATE TABLE IF NOT EXISTS application_status_history (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  application_id BIGINT UNSIGNED NOT NULL,
  old_status ENUM('pending','viewed','accepted','rejected') NULL,
  new_status ENUM('pending','viewed','accepted','rejected') NOT NULL,
  changed_by BIGINT UNSIGNED NOT NULL,
  reason TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_status_history_application (application_id),
  KEY idx_status_history_changed_by (changed_by),
  CONSTRAINT fk_status_history_application FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE,
  CONSTRAINT fk_status_history_changed_by FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- System Settings
CREATE TABLE IF NOT EXISTS system_settings (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  setting_key VARCHAR(100) NOT NULL,
  setting_value TEXT NULL,
  setting_type ENUM('string','number','boolean','json') DEFAULT 'string',
  description TEXT NULL,
  is_public BOOLEAN DEFAULT FALSE,
  updated_by BIGINT UNSIGNED NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_settings_key (setting_key),
  KEY idx_settings_public (is_public),
  CONSTRAINT fk_settings_updated_by FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- INSERT DEFAULT DATA
-- =============================================

-- Insert gig categories
INSERT INTO gig_categories (name, description, icon, color, sort_order) VALUES
('Web Development', 'Website and web application development', '💻', '#3B82F6', 1),
('Graphic Design', 'Visual design and creative work', '🎨', '#8B5CF6', 2),
('Content Writing', 'Written content creation', '✍️', '#10B981', 3),
('Marketing', 'Digital marketing and promotion', '📈', '#F59E0B', 4),
('Tutoring', 'Educational and training services', '📚', '#EF4444', 5),
('Data Entry', 'Administrative and data tasks', '📊', '#6B7280', 6),
('Photography', 'Photo and video services', '📸', '#EC4899', 7),
('Translation', 'Language translation services', '🌐', '#14B8A6', 8),
('Research', 'Research and analysis work', '🔍', '#6366F1', 9),
('Other', 'Other types of work', '🔧', '#64748B', 10);

-- Insert skills
INSERT INTO skills (name, category, description) VALUES
('HTML/CSS', 'Web Development', 'Frontend web development'),
('JavaScript', 'Web Development', 'Programming language for web'),
('React', 'Web Development', 'JavaScript library for UI'),
('Node.js', 'Web Development', 'Backend JavaScript runtime'),
('Python', 'Programming', 'General purpose programming'),
('PHP', 'Programming', 'Server-side scripting'),
('MySQL', 'Database', 'Relational database management'),
('Adobe Photoshop', 'Design', 'Image editing software'),
('Adobe Illustrator', 'Design', 'Vector graphics software'),
('Figma', 'Design', 'UI/UX design tool'),
('Content Writing', 'Writing', 'Creating written content'),
('Copywriting', 'Writing', 'Marketing copy creation'),
('Social Media Marketing', 'Marketing', 'Social platform promotion'),
('SEO', 'Marketing', 'Search engine optimization'),
('Google Analytics', 'Marketing', 'Web analytics tool'),
('Mathematics', 'Education', 'Mathematical concepts'),
('English', 'Education', 'English language teaching'),
('Data Analysis', 'Research', 'Statistical data analysis'),
('Microsoft Excel', 'Office', 'Spreadsheet software'),
('PowerPoint', 'Office', 'Presentation software');

-- Insert system settings
INSERT INTO system_settings (setting_key, setting_value, setting_type, description, is_public) VALUES
('platform_fee_percentage', '5.0', 'number', 'Platform fee percentage for businesses', TRUE),
('min_gig_amount', '50000', 'number', 'Minimum gig amount in UGX', TRUE),
('max_gig_amount', '5000000', 'number', 'Maximum gig amount in UGX', TRUE),
('default_currency', 'UGX', 'string', 'Default currency for the platform', TRUE),
('contact_email', 'support@funagig.com', 'string', 'Main contact email', TRUE),
('emergency_phone', '+256 700 123 456', 'string', 'Emergency contact phone', TRUE),
('terms_version', '1.0', 'string', 'Current terms and conditions version', FALSE),
('privacy_version', '1.0', 'string', 'Current privacy policy version', FALSE);

-- Insert default platform analytics
INSERT INTO platform_analytics (metric_name, metric_value, metric_date) VALUES
('total_users', 0, CURDATE()),
('total_gigs', 0, CURDATE()),
('total_applications', 0, CURDATE()),
('platform_revenue', 0.00, CURDATE()),
('active_users_today', 0, CURDATE()),
('gigs_posted_today', 0, CURDATE()),
('applications_submitted_today', 0, CURDATE())
ON DUPLICATE KEY UPDATE metric_value = VALUES(metric_value);

-- =============================================
-- CREATE VIEWS FOR COMMON QUERIES
-- =============================================

-- User notification summary view
CREATE OR REPLACE VIEW v_user_notification_summary AS
SELECT 
  u.id as user_id,
  u.email,
  COUNT(un.id) as total_notifications,
  COUNT(CASE WHEN un.is_read = FALSE THEN 1 END) as unread_notifications,
  MAX(un.created_at) as last_notification_at
FROM users u
LEFT JOIN user_notifications un ON u.id = un.user_id
GROUP BY u.id, u.email;

-- User activity summary view
CREATE OR REPLACE VIEW v_user_activity_summary AS
SELECT 
  u.id as user_id,
  u.email,
  ual.action as activity_type,
  COUNT(*) as activity_count,
  MAX(ual.created_at) as last_activity_at
FROM users u
JOIN user_activity_logs ual ON u.id = ual.user_id
GROUP BY u.id, u.email, ual.action;

-- Wallet balance summary view
CREATE OR REPLACE VIEW v_wallet_summary AS
SELECT 
  u.id as user_id,
  u.email,
  uw.balance,
  uw.currency,
  COUNT(wt.id) as total_transactions,
  SUM(CASE WHEN wt.transaction_type = 'credit' THEN wt.amount ELSE 0 END) as total_credits,
  SUM(CASE WHEN wt.transaction_type = 'debit' THEN wt.amount ELSE 0 END) as total_debits
FROM users u
JOIN user_wallets uw ON u.id = uw.user_id
LEFT JOIN wallet_transactions wt ON uw.id = wt.wallet_id
GROUP BY u.id, u.email, uw.balance, uw.currency;

-- Gig performance summary view
CREATE OR REPLACE VIEW v_gig_performance_summary AS
SELECT 
  g.id as gig_id,
  g.title,
  g.status,
  g.type,
  g.compensation,
  g.application_deadline,
  u.email as business_email,
  COUNT(a.id) as total_applications,
  COUNT(CASE WHEN a.status = 'accepted' THEN 1 END) as accepted_applications,
  COUNT(CASE WHEN a.status = 'pending' THEN 1 END) as pending_applications,
  COUNT(CASE WHEN a.status = 'rejected' THEN 1 END) as rejected_applications,
  g.created_at
FROM gigs g
LEFT JOIN users u ON g.business_user_id = u.id
LEFT JOIN applications a ON g.id = a.gig_id
GROUP BY g.id, g.title, g.status, g.type, g.compensation, g.application_deadline, u.email, g.created_at;

-- User engagement summary view
CREATE OR REPLACE VIEW v_user_engagement_summary AS
SELECT 
  u.id as user_id,
  u.email,
  u.role,
  COUNT(DISTINCT g.id) as gigs_posted,
  COUNT(DISTINCT a.id) as applications_made,
  COUNT(DISTINCT sg.id) as gigs_saved,
  COUNT(DISTINCT ig.id) as gigs_interested,
  COUNT(DISTINCT un.id) as notifications_received,
  COUNT(DISTINCT un.id) - COUNT(CASE WHEN un.is_read = TRUE THEN 1 END) as unread_notifications
FROM users u
LEFT JOIN gigs g ON u.id = g.business_user_id
LEFT JOIN applications a ON u.id = a.student_user_id
LEFT JOIN saved_gigs sg ON u.id = sg.student_user_id
LEFT JOIN interested_gigs ig ON u.id = ig.student_user_id
LEFT JOIN user_notifications un ON u.id = un.user_id
GROUP BY u.id, u.email, u.role;

-- Recent gigs view
CREATE OR REPLACE VIEW v_recent_gigs AS
SELECT 
  g.id,
  g.title,
  g.description,
  g.type,
  g.compensation,
  g.status,
  g.application_deadline,
  u.email as business_email,
  u.display_name as business_name,
  g.created_at
FROM gigs g
JOIN users u ON g.business_user_id = u.id
WHERE g.status = 'open'
ORDER BY g.created_at DESC;

-- User applications with gig details
CREATE OR REPLACE VIEW v_user_applications_detailed AS
SELECT 
  a.id as application_id,
  a.status as application_status,
  a.created_at as applied_at,
  g.id as gig_id,
  g.title as gig_title,
  g.description as gig_description,
  g.compensation,
  g.application_deadline,
  u_student.id as student_id,
  u_student.email as student_email,
  u_business.id as business_id,
  u_business.email as business_email,
  u_business.display_name as business_name
FROM applications a
JOIN gigs g ON a.gig_id = g.id
JOIN users u_student ON a.student_user_id = u_student.id
JOIN users u_business ON g.business_user_id = u_business.id;

-- Business gigs with application counts
CREATE OR REPLACE VIEW v_business_gigs_with_applications AS
SELECT 
  g.id as gig_id,
  g.title,
  g.status,
  g.type,
  g.compensation,
  g.application_deadline,
  u.email as business_email,
  u.display_name as business_name,
  COUNT(a.id) as total_applications,
  COUNT(CASE WHEN a.status = 'pending' THEN 1 END) as pending_applications,
  COUNT(CASE WHEN a.status = 'accepted' THEN 1 END) as accepted_applications,
  COUNT(CASE WHEN a.status = 'rejected' THEN 1 END) as rejected_applications,
  g.created_at
FROM gigs g
JOIN users u ON g.business_user_id = u.id
LEFT JOIN applications a ON g.id = a.gig_id
GROUP BY g.id, g.title, g.status, g.type, g.compensation, g.application_deadline, u.email, u.display_name, g.created_at;

-- Student saved gigs with details
CREATE OR REPLACE VIEW v_student_saved_gigs_detailed AS
SELECT 
  sg.id as saved_id,
  sg.created_at as saved_at,
  g.id as gig_id,
  g.title,
  g.description,
  g.type,
  g.compensation,
  g.status,
  g.application_deadline,
  u.email as business_email,
  u.display_name as business_name,
  u_student.id as student_id,
  u_student.email as student_email
FROM saved_gigs sg
JOIN gigs g ON sg.gig_id = g.id
JOIN users u ON g.business_user_id = u.id
JOIN users u_student ON sg.student_user_id = u_student.id;

-- =============================================
-- CREATE ADDITIONAL PERFORMANCE INDEXES
-- =============================================

-- Gigs table indexes
CREATE INDEX idx_gigs_status_deadline ON gigs(status, application_deadline);
CREATE INDEX idx_gigs_views_applications ON gigs(views_count, applications_count);

-- Applications table indexes
CREATE INDEX idx_applications_status ON applications(status);

-- Reviews table indexes
CREATE INDEX idx_reviews_rating_public ON reviews(rating, is_public);

-- Activity logs indexes
CREATE INDEX idx_activity_logs_user_action ON user_activity_logs(user_id, action);

-- =============================================
-- SUCCESS MESSAGE
-- =============================================

SELECT 'FunaGig Unified Database Schema Created Successfully!' as status,
       'Version 2.0 - Enhanced with all features' as version,
       'Ready for production use' as status_message;
