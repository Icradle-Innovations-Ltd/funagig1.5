<?php
// Simple database setup script
// Run this in your browser to set up the database and demo accounts

echo "<h1>FunaGig Database Setup</h1>";

// Database configuration
$host = 'localhost';
$username = 'root';
$password = '97swain'; // MySQL password
$database = 'funagig';

try {
    // Connect to MySQL
    $pdo = new PDO("mysql:host=$host", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "<p>✅ Connected to MySQL</p>";
    
    // Create database if it doesn't exist
    $pdo->exec("CREATE DATABASE IF NOT EXISTS $database");
    echo "<p>✅ Database '$database' created/verified</p>";
    
    // Use the database
    $pdo->exec("USE $database");
    
    // Create users table
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            email VARCHAR(255) UNIQUE NOT NULL,
            password VARCHAR(255) NOT NULL,
            type ENUM('student', 'business') NOT NULL,
            university VARCHAR(255) NULL,
            major VARCHAR(255) NULL,
            industry VARCHAR(255) NULL,
            tos_accepted TINYINT(1) DEFAULT 0,
            privacy_accepted TINYINT(1) DEFAULT 0,
            dpa_accepted TINYINT(1) DEFAULT 0,
            policies_accepted_at TIMESTAMP NULL,
            terms_version VARCHAR(10) DEFAULT '1.0',
            privacy_version VARCHAR(10) DEFAULT '1.0',
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
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ");
    echo "<p>✅ Users table created</p>";

    // Ensure policy columns exist (for upgrades)
    $alterSql = [
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS tos_accepted TINYINT(1) DEFAULT 0",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS privacy_accepted TINYINT(1) DEFAULT 0",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS dpa_accepted TINYINT(1) DEFAULT 0",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS policies_accepted_at TIMESTAMP NULL",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS terms_version VARCHAR(10) DEFAULT '1.0'",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS privacy_version VARCHAR(10) DEFAULT '1.0'"
    ];
    foreach ($alterSql as $sql) {
        try { $pdo->exec($sql); } catch (Exception $e) {}
    }
    echo "<p>✅ Users table policy columns verified</p>";
    
    // Create gigs table
    $pdo->exec("
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
        )
    ");
    echo "<p>✅ Gigs table created</p>";
    
    // Create applications table
    $pdo->exec("
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
        )
    ");
    echo "<p>✅ Applications table created</p>";
    
    // Create conversations table
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS conversations (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user1_id INT NOT NULL,
            user2_id INT NOT NULL,
            last_message_at TIMESTAMP NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user1_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (user2_id) REFERENCES users(id) ON DELETE CASCADE,
            UNIQUE KEY unique_conversation (user1_id, user2_id)
        )
    ");
    echo "<p>✅ Conversations table created</p>";
    
    // Create messages table
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS messages (
            id INT AUTO_INCREMENT PRIMARY KEY,
            conversation_id INT NOT NULL,
            sender_id INT NOT NULL,
            content TEXT NOT NULL,
            is_read BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
            FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
        )
    ");
    echo "<p>✅ Messages table created</p>";
    
    // Create notifications table
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS notifications (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            title VARCHAR(255) NOT NULL,
            message TEXT NOT NULL,
            type ENUM('info', 'success', 'warning', 'error') DEFAULT 'info',
            is_read BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
    ");
    echo "<p>✅ Notifications table created</p>";

    // Create password_resets table (minimal)
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS password_resets (
            id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
            email VARCHAR(190) NOT NULL,
            token CHAR(64) NOT NULL,
            requested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            used_at TIMESTAMP NULL DEFAULT NULL,
            PRIMARY KEY (id),
            UNIQUE KEY uq_password_resets_token (token),
            KEY idx_password_resets_email (email)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ");
    echo "<p>✅ Password resets table created</p>";
    
    // Check if demo accounts already exist
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM users WHERE email LIKE '%@demo.com' OR email LIKE '%@techflow.com' OR email LIKE '%@creativeminds.com' OR email LIKE '%@pixelperfect.com' OR email LIKE '%@datainsights.com' OR email LIKE '%@wordcraft.com'");
    $count = $stmt->fetch()['count'];
    
    if ($count > 0) {
        echo "<p>Demo accounts already exist ($count accounts found). Skipping creation.</p>";
    } else {
        echo "<h2>Creating Demo Accounts...</h2>";
        
        // Demo student accounts
        $students = [
            ['Alice Johnson', 'alice@demo.com', 'Makerere University', 'Computer Science', 'JavaScript,Python,React,Node.js', 'Kampala, Uganda', '+256 700 123 001', 4.8, 12],
            ['David Kimani', 'david@demo.com', 'University of Nairobi', 'Business Administration', 'Marketing,Social Media Management,Content Writing', 'Nairobi, Kenya', '+254 700 123 002', 4.5, 8],
            ['Grace Akello', 'grace@demo.com', 'Kampala International University', 'Software Engineering', 'React Native,Flutter,UI/UX Design,JavaScript', 'Kampala, Uganda', '+256 700 123 003', 4.7, 15],
            ['Michael Ochieng', 'michael@demo.com', 'Strathmore University', 'Graphic Design', 'Graphic Design,Logo Design,Branding,Adobe Creative Suite', 'Nairobi, Kenya', '+254 700 123 004', 4.9, 20],
            ['Sarah Nalwanga', 'sarah@demo.com', 'Makerere University', 'Statistics', 'Data Analysis,Python,R,Excel,SQL', 'Kampala, Uganda', '+256 700 123 005', 4.6, 10],
            ['Peter Mwangi', 'peter@demo.com', 'University of Nairobi', 'Journalism', 'Content Writing,Blog Writing,Social Media Content,SEO', 'Nairobi, Kenya', '+254 700 123 006', 4.4, 7]
        ];
        
        foreach ($students as $student) {
            $stmt = $pdo->prepare("INSERT INTO users (name, email, password, type, university, major, skills, location, phone, rating, total_ratings, is_verified, is_active) VALUES (?, ?, ?, 'student', ?, ?, ?, ?, ?, ?, ?, 1, 1)");
            $stmt->execute([
                $student[0], // name
                $student[1], // email
                password_hash('password', PASSWORD_DEFAULT), // password
                $student[2], // university
                $student[3], // major
                $student[4], // skills
                $student[5], // location
                $student[6], // phone
                $student[7], // rating
                $student[8]  // total_ratings
            ]);
            echo "<p>✅ Created student: {$student[0]} ({$student[1]})</p>";
        }
        
        // Demo business accounts
        $businesses = [
            ['TechFlow Solutions', 'info@techflow.com', 'Technology', 'Software Development,Web Development,Mobile Development', 'Kampala, Uganda', '+256 700 456 001', 'https://techflow.com', 4.8, 25],
            ['Creative Minds Agency', 'hello@creativeminds.com', 'Marketing', 'Digital Marketing,Social Media Marketing,Brand Development', 'Nairobi, Kenya', '+254 700 456 002', 'https://creativeminds.com', 4.7, 18],
            ['ShopSmart Uganda', 'contact@shopsmart.ug', 'E-commerce', 'E-commerce Development,User Experience,Digital Strategy', 'Kampala, Uganda', '+256 700 456 003', 'https://shopsmart.ug', 4.6, 22],
            ['Pixel Perfect Studio', 'studio@pixelperfect.com', 'Design', 'Graphic Design,Web Design,Branding,UI/UX Design', 'Nairobi, Kenya', '+254 700 456 004', 'https://pixelperfect.com', 4.9, 30],
            ['Data Insights Ltd', 'info@datainsights.com', 'Consulting', 'Data Analytics,Business Intelligence,Consulting,Data Visualization', 'Kampala, Uganda', '+256 700 456 005', 'https://datainsights.com', 4.5, 16],
            ['WordCraft Media', 'team@wordcraft.com', 'Content', 'Content Writing,Social Media Management,Digital Marketing,SEO', 'Nairobi, Kenya', '+254 700 456 006', 'https://wordcraft.com', 4.7, 20]
        ];
        
        foreach ($businesses as $business) {
            $stmt = $pdo->prepare("INSERT INTO users (name, email, password, type, industry, skills, location, phone, website, rating, total_ratings, is_verified, is_active) VALUES (?, ?, ?, 'business', ?, ?, ?, ?, ?, ?, ?, 1, 1)");
            $stmt->execute([
                $business[0], // name
                $business[1], // email
                password_hash('password', PASSWORD_DEFAULT), // password
                $business[2], // industry
                $business[3], // skills
                $business[4], // location
                $business[5], // phone
                $business[6], // website
                $business[7], // rating
                $business[8]  // total_ratings
            ]);
            echo "<p>✅ Created business: {$business[0]} ({$business[1]})</p>";
        }
        
        // Create some demo gigs
        echo "<h2>Creating Demo Gigs...</h2>";
        
        // Get business user IDs
        $techflowId = $pdo->query("SELECT id FROM users WHERE email = 'info@techflow.com'")->fetch()['id'];
        $creativemindsId = $pdo->query("SELECT id FROM users WHERE email = 'hello@creativeminds.com'")->fetch()['id'];
        $pixelperfectId = $pdo->query("SELECT id FROM users WHERE email = 'studio@pixelperfect.com'")->fetch()['id'];
        
        $gigs = [
            [$techflowId, 'E-commerce Website Development', 'We need a modern, responsive e-commerce website for our online store. The site should include product catalog, shopping cart, payment integration, and admin dashboard.', 800000.00, '2025-02-15', 'Web Development,E-commerce,Payment Integration', 'Remote', 'one-time'],
            [$creativemindsId, 'Social Media Management', 'Manage our social media accounts across Facebook, Instagram, Twitter, and LinkedIn. Create engaging content, schedule posts, respond to comments, and analyze performance metrics.', 300000.00, '2025-01-31', 'Social Media Management,Content Creation,Analytics', 'Remote', 'ongoing'],
            [$pixelperfectId, 'Brand Logo Design', 'Design a modern, professional logo for our new tech startup. The logo should be versatile, work well in both digital and print formats, and reflect innovation and technology.', 150000.00, '2025-01-20', 'Logo Design,Branding,Graphic Design', 'Remote', 'one-time']
        ];
        
        foreach ($gigs as $gig) {
            $stmt = $pdo->prepare("INSERT INTO gigs (user_id, title, description, budget, deadline, skills, location, type, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'active')");
            $stmt->execute($gig);
            echo "<p>✅ Created gig: {$gig[1]}</p>";
        }
    }
    
    echo "<h2>Setup Complete!</h2>";
    echo "<h3>Demo Login Credentials:</h3>";
    echo "<h4>Student Accounts:</h4>";
    echo "<ul>";
    echo "<li>alice@demo.com / password</li>";
    echo "<li>david@demo.com / password</li>";
    echo "<li>grace@demo.com / password</li>";
    echo "<li>michael@demo.com / password</li>";
    echo "<li>sarah@demo.com / password</li>";
    echo "<li>peter@demo.com / password</li>";
    echo "</ul>";
    
    echo "<h4>Business Accounts:</h4>";
    echo "<ul>";
    echo "<li>info@techflow.com / password</li>";
    echo "<li>hello@creativeminds.com / password</li>";
    echo "<li>contact@shopsmart.ug / password</li>";
    echo "<li>studio@pixelperfect.com / password</li>";
    echo "<li>info@datainsights.com / password</li>";
    echo "<li>team@wordcraft.com / password</li>";
    echo "</ul>";
    
    echo "<p><a href='auth.html' style='background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;'>Go to Login Page</a></p>";
    
} catch (PDOException $e) {
    echo "<h2>Database Error:</h2>";
    echo "<p style='color: red;'>" . $e->getMessage() . "</p>";
    echo "<p>Make sure XAMPP is running and MySQL is accessible.</p>";
} catch (Exception $e) {
    echo "<h2>Error:</h2>";
    echo "<p style='color: red;'>" . $e->getMessage() . "</p>";
}
?>
