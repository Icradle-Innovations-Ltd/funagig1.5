<?php
// Setup Demo Accounts Script
// Run this file in your browser to create demo accounts

require_once 'php/config.php';

try {
    $db = Database::getInstance();
    
    echo "<h1>Setting up FunaGig Demo Accounts...</h1>";
    
    // Check if demo accounts already exist
    $existingUsers = $db->query("SELECT COUNT(*) as count FROM users WHERE email LIKE '%@demo.com' OR email LIKE '%@techflow.com' OR email LIKE '%@creativeminds.com' OR email LIKE '%@pixelperfect.com' OR email LIKE '%@datainsights.com' OR email LIKE '%@wordcraft.com'");
    $count = $existingUsers[0]['count'] ?? 0;
    
    if ($count > 0) {
        echo "<p>Demo accounts already exist ($count accounts found). Skipping creation.</p>";
        echo "<p><a href='auth.html'>Go to Login Page</a></p>";
        exit;
    }
    
    // Create demo student accounts
    $students = [
        [
            'name' => 'Alice Johnson',
            'email' => 'alice@demo.com',
            'password' => password_hash('password', PASSWORD_DEFAULT),
            'type' => 'student',
            'university' => 'Makerere University',
            'major' => 'Computer Science',
            'bio' => 'Passionate computer science student with strong programming skills. Love working on web development projects and mobile apps.',
            'skills' => 'JavaScript,Python,React,Node.js,HTML/CSS',
            'location' => 'Kampala, Uganda',
            'phone' => '+256 700 123 001',
            'rating' => 4.8,
            'total_ratings' => 12,
            'is_verified' => 1,
            'is_active' => 1
        ],
        [
            'name' => 'David Kimani',
            'email' => 'david@demo.com',
            'password' => password_hash('password', PASSWORD_DEFAULT),
            'type' => 'student',
            'university' => 'University of Nairobi',
            'major' => 'Business Administration',
            'bio' => 'Business student with marketing expertise and social media management skills. Creative and detail-oriented.',
            'skills' => 'Marketing,Social Media Management,Content Writing,Graphic Design',
            'location' => 'Nairobi, Kenya',
            'phone' => '+254 700 123 002',
            'rating' => 4.5,
            'total_ratings' => 8,
            'is_verified' => 1,
            'is_active' => 1
        ],
        [
            'name' => 'Grace Akello',
            'email' => 'grace@demo.com',
            'password' => password_hash('password', PASSWORD_DEFAULT),
            'type' => 'student',
            'university' => 'Kampala International University',
            'major' => 'Software Engineering',
            'bio' => 'Software engineering student with focus on mobile app development and UI/UX design. Always eager to learn new technologies.',
            'skills' => 'React Native,Flutter,UI/UX Design,JavaScript,Java',
            'location' => 'Kampala, Uganda',
            'phone' => '+256 700 123 003',
            'rating' => 4.7,
            'total_ratings' => 15,
            'is_verified' => 1,
            'is_active' => 1
        ],
        [
            'name' => 'Michael Ochieng',
            'email' => 'michael@demo.com',
            'password' => password_hash('password', PASSWORD_DEFAULT),
            'type' => 'student',
            'university' => 'Strathmore University',
            'major' => 'Graphic Design',
            'bio' => 'Creative graphic designer with expertise in branding, logo design, and digital marketing materials. Portfolio includes work for local businesses.',
            'skills' => 'Graphic Design,Logo Design,Branding,Adobe Creative Suite,Social Media Design',
            'location' => 'Nairobi, Kenya',
            'phone' => '+254 700 123 004',
            'rating' => 4.9,
            'total_ratings' => 20,
            'is_verified' => 1,
            'is_active' => 1
        ],
        [
            'name' => 'Sarah Nalwanga',
            'email' => 'sarah@demo.com',
            'password' => password_hash('password', PASSWORD_DEFAULT),
            'type' => 'student',
            'university' => 'Makerere University',
            'major' => 'Statistics',
            'bio' => 'Statistics student with strong analytical skills and experience in data visualization. Passionate about turning data into actionable insights.',
            'skills' => 'Data Analysis,Python,R,Excel,SQL,Tableau',
            'location' => 'Kampala, Uganda',
            'phone' => '+256 700 123 005',
            'rating' => 4.6,
            'total_ratings' => 10,
            'is_verified' => 1,
            'is_active' => 1
        ],
        [
            'name' => 'Peter Mwangi',
            'email' => 'peter@demo.com',
            'password' => password_hash('password', PASSWORD_DEFAULT),
            'type' => 'student',
            'university' => 'University of Nairobi',
            'major' => 'Journalism',
            'bio' => 'Journalism student with excellent writing skills and experience in content creation. Specializes in blog writing and social media content.',
            'skills' => 'Content Writing,Blog Writing,Social Media Content,SEO Writing,Technical Writing',
            'location' => 'Nairobi, Kenya',
            'phone' => '+254 700 123 006',
            'rating' => 4.4,
            'total_ratings' => 7,
            'is_verified' => 1,
            'is_active' => 1
        ]
    ];
    
    // Create demo business accounts
    $businesses = [
        [
            'name' => 'TechFlow Solutions',
            'email' => 'info@techflow.com',
            'password' => password_hash('password', PASSWORD_DEFAULT),
            'type' => 'business',
            'industry' => 'Technology',
            'bio' => 'Innovative tech startup focused on developing cutting-edge web and mobile applications. We believe in empowering young talent and providing real-world experience.',
            'skills' => 'Software Development,Web Development,Mobile Development,Project Management',
            'location' => 'Kampala, Uganda',
            'phone' => '+256 700 456 001',
            'website' => 'https://techflow.com',
            'rating' => 4.8,
            'total_ratings' => 25,
            'is_verified' => 1,
            'is_active' => 1
        ],
        [
            'name' => 'Creative Minds Agency',
            'email' => 'hello@creativeminds.com',
            'password' => password_hash('password', PASSWORD_DEFAULT),
            'type' => 'business',
            'industry' => 'Marketing',
            'bio' => 'Full-service marketing agency specializing in digital marketing, brand development, and creative campaigns. We work with startups and established businesses.',
            'skills' => 'Digital Marketing,Social Media Marketing,Brand Development,Content Strategy',
            'location' => 'Nairobi, Kenya',
            'phone' => '+254 700 456 002',
            'website' => 'https://creativeminds.com',
            'rating' => 4.7,
            'total_ratings' => 18,
            'is_verified' => 1,
            'is_active' => 1
        ],
        [
            'name' => 'ShopSmart Uganda',
            'email' => 'contact@shopsmart.ug',
            'password' => password_hash('password', PASSWORD_DEFAULT),
            'type' => 'business',
            'industry' => 'E-commerce',
            'bio' => 'Leading e-commerce platform in Uganda, connecting local businesses with customers nationwide. We focus on user experience and innovative solutions.',
            'skills' => 'E-commerce Development,User Experience,Digital Strategy,Business Analysis',
            'location' => 'Kampala, Uganda',
            'phone' => '+256 700 456 003',
            'website' => 'https://shopsmart.ug',
            'rating' => 4.6,
            'total_ratings' => 22,
            'is_verified' => 1,
            'is_active' => 1
        ],
        [
            'name' => 'Pixel Perfect Studio',
            'email' => 'studio@pixelperfect.com',
            'password' => password_hash('password', PASSWORD_DEFAULT),
            'type' => 'business',
            'industry' => 'Design',
            'bio' => 'Creative design studio specializing in branding, web design, and digital marketing materials. We help businesses create compelling visual identities.',
            'skills' => 'Graphic Design,Web Design,Branding,UI/UX Design,Digital Marketing',
            'location' => 'Nairobi, Kenya',
            'phone' => '+254 700 456 004',
            'website' => 'https://pixelperfect.com',
            'rating' => 4.9,
            'total_ratings' => 30,
            'is_verified' => 1,
            'is_active' => 1
        ],
        [
            'name' => 'Data Insights Ltd',
            'email' => 'info@datainsights.com',
            'password' => password_hash('password', PASSWORD_DEFAULT),
            'type' => 'business',
            'industry' => 'Consulting',
            'bio' => 'Data analytics and business intelligence consulting firm. We help businesses make data-driven decisions and optimize their operations.',
            'skills' => 'Data Analytics,Business Intelligence,Consulting,Data Visualization,Machine Learning',
            'location' => 'Kampala, Uganda',
            'phone' => '+256 700 456 005',
            'website' => 'https://datainsights.com',
            'rating' => 4.5,
            'total_ratings' => 16,
            'is_verified' => 1,
            'is_active' => 1
        ],
        [
            'name' => 'WordCraft Media',
            'email' => 'team@wordcraft.com',
            'password' => password_hash('password', PASSWORD_DEFAULT),
            'type' => 'business',
            'industry' => 'Content',
            'bio' => 'Content creation agency specializing in blog writing, social media content, and digital marketing copy. We help brands tell their stories effectively.',
            'skills' => 'Content Writing,Social Media Management,Digital Marketing,SEO,Content Strategy',
            'location' => 'Nairobi, Kenya',
            'phone' => '+254 700 456 006',
            'website' => 'https://wordcraft.com',
            'rating' => 4.7,
            'total_ratings' => 20,
            'is_verified' => 1,
            'is_active' => 1
        ]
    ];
    
    // Insert student accounts
    echo "<h2>Creating Student Accounts...</h2>";
    foreach ($students as $student) {
        $userId = $db->insert(
            "INSERT INTO users (name, email, password, type, university, major, bio, skills, location, phone, rating, total_ratings, is_verified, is_active, created_at) 
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())",
            [
                $student['name'],
                $student['email'],
                $student['password'],
                $student['type'],
                $student['university'],
                $student['major'],
                $student['bio'],
                $student['skills'],
                $student['location'],
                $student['phone'],
                $student['rating'],
                $student['total_ratings'],
                $student['is_verified'],
                $student['is_active']
            ]
        );
        echo "<p>✅ Created student: {$student['name']} ({$student['email']})</p>";
    }
    
    // Insert business accounts
    echo "<h2>Creating Business Accounts...</h2>";
    foreach ($businesses as $business) {
        $userId = $db->insert(
            "INSERT INTO users (name, email, password, type, industry, bio, skills, location, phone, website, rating, total_ratings, is_verified, is_active, created_at) 
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())",
            [
                $business['name'],
                $business['email'],
                $business['password'],
                $business['type'],
                $business['industry'],
                $business['bio'],
                $business['skills'],
                $business['location'],
                $business['phone'],
                $business['website'],
                $business['rating'],
                $business['total_ratings'],
                $business['is_verified'],
                $business['is_active']
            ]
        );
        echo "<p>✅ Created business: {$business['name']} ({$business['email']})</p>";
    }
    
    // Create some demo gigs
    echo "<h2>Creating Demo Gigs...</h2>";
    
    // Get business user IDs
    $techflowId = $db->query("SELECT id FROM users WHERE email = 'info@techflow.com'")[0]['id'];
    $creativemindsId = $db->query("SELECT id FROM users WHERE email = 'hello@creativeminds.com'")[0]['id'];
    $pixelperfectId = $db->query("SELECT id FROM users WHERE email = 'studio@pixelperfect.com'")[0]['id'];
    $datainsightsId = $db->query("SELECT id FROM users WHERE email = 'info@datainsights.com'")[0]['id'];
    $wordcraftId = $db->query("SELECT id FROM users WHERE email = 'team@wordcraft.com'")[0]['id'];
    
    $gigs = [
        [
            'user_id' => $techflowId,
            'title' => 'E-commerce Website Development',
            'description' => 'We need a modern, responsive e-commerce website for our online store. The site should include product catalog, shopping cart, payment integration, and admin dashboard. Must be mobile-friendly and SEO optimized.',
            'budget' => 800000.00,
            'deadline' => '2025-02-15',
            'skills' => 'Web Development,E-commerce,Payment Integration',
            'location' => 'Remote',
            'type' => 'one-time',
            'category' => 'Web Development',
            'duration' => '2-3 months',
            'hours_per_week' => '20-30 hours/week',
            'required_skills' => 'HTML/CSS,JavaScript,React,Node.js,Payment Gateway Integration',
            'preferred_skills' => 'E-commerce Experience,SEO Knowledge,UI/UX Design',
            'education_level' => 'Undergraduate',
            'experience_level' => 'Intermediate',
            'work_location' => 'Remote',
            'specific_location' => 'Anywhere in Uganda',
            'company_name' => 'TechFlow Solutions',
            'contact_person' => 'John Mwangi',
            'contact_email' => 'john@techflow.com',
            'additional_notes' => 'This is a great opportunity for students to work on a real-world project and gain valuable experience.'
        ],
        [
            'user_id' => $creativemindsId,
            'title' => 'Social Media Management',
            'description' => 'Manage our social media accounts across Facebook, Instagram, Twitter, and LinkedIn. Create engaging content, schedule posts, respond to comments, and analyze performance metrics.',
            'budget' => 300000.00,
            'deadline' => '2025-01-31',
            'skills' => 'Social Media Management,Content Creation,Analytics',
            'location' => 'Remote',
            'type' => 'ongoing',
            'category' => 'Marketing',
            'duration' => '6 months',
            'hours_per_week' => '15-20 hours/week',
            'required_skills' => 'Social Media Management,Content Creation,Graphic Design',
            'preferred_skills' => 'Social Media Analytics,Video Editing,Photography',
            'education_level' => 'Any',
            'experience_level' => 'Beginner',
            'work_location' => 'Remote',
            'specific_location' => 'Anywhere in Kenya',
            'company_name' => 'Creative Minds Agency',
            'contact_person' => 'Grace Wanjiku',
            'contact_email' => 'grace@creativeminds.com',
            'additional_notes' => 'Great opportunity for students to gain hands-on experience in digital marketing.'
        ],
        [
            'user_id' => $pixelperfectId,
            'title' => 'Brand Logo Design',
            'description' => 'Design a modern, professional logo for our new tech startup. The logo should be versatile, work well in both digital and print formats, and reflect innovation and technology.',
            'budget' => 150000.00,
            'deadline' => '2025-01-20',
            'skills' => 'Logo Design,Branding,Graphic Design',
            'location' => 'Remote',
            'type' => 'one-time',
            'category' => 'Design',
            'duration' => '2-3 weeks',
            'hours_per_week' => '10-15 hours/week',
            'required_skills' => 'Adobe Illustrator,Logo Design,Branding',
            'preferred_skills' => 'Creative Thinking,Color Theory,Typography',
            'education_level' => 'Any',
            'experience_level' => 'Beginner',
            'work_location' => 'Remote',
            'specific_location' => 'Anywhere in East Africa',
            'company_name' => 'Pixel Perfect Studio',
            'contact_person' => 'Michael Ochieng',
            'contact_email' => 'michael@pixelperfect.com',
            'additional_notes' => 'This project will help students build their design portfolio and gain real client experience.'
        ]
    ];
    
    foreach ($gigs as $gig) {
        $gigId = $db->insert(
            "INSERT INTO gigs (user_id, title, description, budget, deadline, skills, location, type, category, duration, hours_per_week, required_skills, preferred_skills, education_level, experience_level, work_location, specific_location, company_name, contact_person, contact_email, additional_notes, status, created_at) 
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'active', NOW())",
            [
                $gig['user_id'],
                $gig['title'],
                $gig['description'],
                $gig['budget'],
                $gig['deadline'],
                $gig['skills'],
                $gig['location'],
                $gig['type'],
                $gig['category'],
                $gig['duration'],
                $gig['hours_per_week'],
                $gig['required_skills'],
                $gig['preferred_skills'],
                $gig['education_level'],
                $gig['experience_level'],
                $gig['work_location'],
                $gig['specific_location'],
                $gig['company_name'],
                $gig['contact_person'],
                $gig['contact_email'],
                $gig['additional_notes']
            ]
        );
        echo "<p>✅ Created gig: {$gig['title']}</p>";
    }
    
    echo "<h2>Demo Setup Complete!</h2>";
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
    
} catch (Exception $e) {
    echo "<h2>Error:</h2>";
    echo "<p style='color: red;'>" . $e->getMessage() . "</p>";
    echo "<p>Make sure XAMPP is running and the database is set up correctly.</p>";
}
?>
