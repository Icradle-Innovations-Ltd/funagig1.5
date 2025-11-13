-- FunaGig Demo Accounts
-- Demo data for testing the system
-- Run this after setting up the main database schema

USE funagig;

-- Clear existing demo data (optional - comment out if you want to keep existing data)
-- DELETE FROM applications WHERE user_id IN (SELECT id FROM users WHERE email LIKE '%@demo.com');
-- DELETE FROM gigs WHERE user_id IN (SELECT id FROM users WHERE email LIKE '%@demo.com');
-- DELETE FROM users WHERE email LIKE '%@demo.com';

-- Demo Student Accounts
INSERT INTO users (name, email, password, type, university, major, bio, skills, location, phone, rating, total_ratings, is_verified, is_active) VALUES
-- Student 1: Computer Science Student
('Alice Johnson', 'alice@demo.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'student', 'Makerere University', 'Computer Science', 'Passionate computer science student with strong programming skills. Love working on web development projects and mobile apps.', 'JavaScript,Python,React,Node.js,HTML/CSS', 'Kampala, Uganda', '+256 700 123 001', 4.8, 12, TRUE, TRUE),

-- Student 2: Business Student
('David Kimani', 'david@demo.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'student', 'University of Nairobi', 'Business Administration', 'Business student with marketing expertise and social media management skills. Creative and detail-oriented.', 'Marketing,Social Media Management,Content Writing,Graphic Design', 'Nairobi, Kenya', '+254 700 123 002', 4.5, 8, TRUE, TRUE),

-- Student 3: Engineering Student
('Grace Akello', 'grace@demo.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'student', 'Kampala International University', 'Software Engineering', 'Software engineering student with focus on mobile app development and UI/UX design. Always eager to learn new technologies.', 'React Native,Flutter,UI/UX Design,JavaScript,Java', 'Kampala, Uganda', '+256 700 123 003', 4.7, 15, TRUE, TRUE),

-- Student 4: Design Student
('Michael Ochieng', 'michael@demo.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'student', 'Strathmore University', 'Graphic Design', 'Creative graphic designer with expertise in branding, logo design, and digital marketing materials. Portfolio includes work for local businesses.', 'Graphic Design,Logo Design,Branding,Adobe Creative Suite,Social Media Design', 'Nairobi, Kenya', '+254 700 123 004', 4.9, 20, TRUE, TRUE),

-- Student 5: Data Science Student
('Sarah Nalwanga', 'sarah@demo.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'student', 'Makerere University', 'Statistics', 'Statistics student with strong analytical skills and experience in data visualization. Passionate about turning data into actionable insights.', 'Data Analysis,Python,R,Excel,SQL,Tableau', 'Kampala, Uganda', '+256 700 123 005', 4.6, 10, TRUE, TRUE),

-- Student 6: Writing Student
('Peter Mwangi', 'peter@demo.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'student', 'University of Nairobi', 'Journalism', 'Journalism student with excellent writing skills and experience in content creation. Specializes in blog writing and social media content.', 'Content Writing,Blog Writing,Social Media Content,SEO Writing,Technical Writing', 'Nairobi, Kenya', '+254 700 123 006', 4.4, 7, TRUE, TRUE);

-- Demo Business Accounts
INSERT INTO users (name, email, password, type, industry, bio, skills, location, phone, website, rating, total_ratings, is_verified, is_active) VALUES
-- Business 1: Tech Startup
('TechFlow Solutions', 'info@techflow.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'business', 'Technology', 'Innovative tech startup focused on developing cutting-edge web and mobile applications. We believe in empowering young talent and providing real-world experience.', 'Software Development,Web Development,Mobile Development,Project Management', 'Kampala, Uganda', '+256 700 456 001', 'https://techflow.com', 4.8, 25, TRUE, TRUE),

-- Business 2: Marketing Agency
('Creative Minds Agency', 'hello@creativeminds.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'business', 'Marketing', 'Full-service marketing agency specializing in digital marketing, brand development, and creative campaigns. We work with startups and established businesses.', 'Digital Marketing,Social Media Marketing,Brand Development,Content Strategy', 'Nairobi, Kenya', '+254 700 456 002', 'https://creativeminds.com', 4.7, 18, TRUE, TRUE),

-- Business 3: E-commerce Company
('ShopSmart Uganda', 'contact@shopsmart.ug', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'business', 'E-commerce', 'Leading e-commerce platform in Uganda, connecting local businesses with customers nationwide. We focus on user experience and innovative solutions.', 'E-commerce Development,User Experience,Digital Strategy,Business Analysis', 'Kampala, Uganda', '+256 700 456 003', 'https://shopsmart.ug', 4.6, 22, TRUE, TRUE),

-- Business 4: Design Studio
('Pixel Perfect Studio', 'studio@pixelperfect.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'business', 'Design', 'Creative design studio specializing in branding, web design, and digital marketing materials. We help businesses create compelling visual identities.', 'Graphic Design,Web Design,Branding,UI/UX Design,Digital Marketing', 'Nairobi, Kenya', '+254 700 456 004', 'https://pixelperfect.com', 4.9, 30, TRUE, TRUE),

-- Business 5: Consulting Firm
('Data Insights Ltd', 'info@datainsights.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'business', 'Consulting', 'Data analytics and business intelligence consulting firm. We help businesses make data-driven decisions and optimize their operations.', 'Data Analytics,Business Intelligence,Consulting,Data Visualization,Machine Learning', 'Kampala, Uganda', '+256 700 456 005', 'https://datainsights.com', 4.5, 16, TRUE, TRUE),

-- Business 6: Content Agency
('WordCraft Media', 'team@wordcraft.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'business', 'Content', 'Content creation agency specializing in blog writing, social media content, and digital marketing copy. We help brands tell their stories effectively.', 'Content Writing,Social Media Management,Digital Marketing,SEO,Content Strategy', 'Nairobi, Kenya', '+254 700 456 006', 'https://wordcraft.com', 4.7, 20, TRUE, TRUE);

-- Demo Gigs (posted by businesses)
INSERT INTO gigs (user_id, title, description, budget, deadline, skills, location, type, category, duration, hours_per_week, required_skills, preferred_skills, education_level, experience_level, work_location, specific_location, company_name, contact_person, contact_email, additional_notes) VALUES
-- Gig 1: Web Development
((SELECT id FROM users WHERE email = 'info@techflow.com'), 'E-commerce Website Development', 'We need a modern, responsive e-commerce website for our online store. The site should include product catalog, shopping cart, payment integration, and admin dashboard. Must be mobile-friendly and SEO optimized.', 800000.00, '2025-02-15', 'Web Development,E-commerce,Payment Integration', 'Remote', 'one-time', 'Web Development', '2-3 months', '20-30 hours/week', 'HTML/CSS,JavaScript,React,Node.js,Payment Gateway Integration', 'E-commerce Experience,SEO Knowledge,UI/UX Design', 'Undergraduate', 'Intermediate', 'Remote', 'Anywhere in Uganda', 'TechFlow Solutions', 'John Mwangi', 'john@techflow.com', 'This is a great opportunity for students to work on a real-world project and gain valuable experience.'),

-- Gig 2: Mobile App Development
((SELECT id FROM users WHERE email = 'info@techflow.com'), 'Food Delivery Mobile App', 'Develop a cross-platform mobile app for food delivery service. Features include user registration, restaurant listings, order placement, real-time tracking, and payment processing.', 1200000.00, '2025-03-01', 'Mobile Development,React Native,Payment Integration', 'Remote', 'contract', 'Mobile Development', '3-4 months', '25-35 hours/week', 'React Native,JavaScript,Firebase,Payment Integration', 'Mobile App Experience,UI/UX Design,API Integration', 'Undergraduate', 'Intermediate', 'Remote', 'Anywhere in East Africa', 'TechFlow Solutions', 'Sarah Kimani', 'sarah@techflow.com', 'Perfect for students interested in mobile app development and real-world project experience.'),

-- Gig 3: Social Media Management
((SELECT id FROM users WHERE email = 'hello@creativeminds.com'), 'Social Media Management', 'Manage our social media accounts across Facebook, Instagram, Twitter, and LinkedIn. Create engaging content, schedule posts, respond to comments, and analyze performance metrics.', 300000.00, '2025-01-31', 'Social Media Management,Content Creation,Analytics', 'Remote', 'ongoing', 'Marketing', '6 months', '15-20 hours/week', 'Social Media Management,Content Creation,Graphic Design', 'Social Media Analytics,Video Editing,Photography', 'Any', 'Beginner', 'Remote', 'Anywhere in Kenya', 'Creative Minds Agency', 'Grace Wanjiku', 'grace@creativeminds.com', 'Great opportunity for students to gain hands-on experience in digital marketing.'),

-- Gig 4: Logo Design
((SELECT id FROM users WHERE email = 'studio@pixelperfect.com'), 'Brand Logo Design', 'Design a modern, professional logo for our new tech startup. The logo should be versatile, work well in both digital and print formats, and reflect innovation and technology.', 150000.00, '2025-01-20', 'Logo Design,Branding,Graphic Design', 'Remote', 'one-time', 'Design', '2-3 weeks', '10-15 hours/week', 'Adobe Illustrator,Logo Design,Branding', 'Creative Thinking,Color Theory,Typography', 'Any', 'Beginner', 'Remote', 'Anywhere in East Africa', 'Pixel Perfect Studio', 'Michael Ochieng', 'michael@pixelperfect.com', 'This project will help students build their design portfolio and gain real client experience.'),

-- Gig 5: Data Analysis
((SELECT id FROM users WHERE email = 'info@datainsights.com'), 'Customer Data Analysis', 'Analyze our customer database to identify trends, segment customers, and provide insights for marketing strategy. Create visualizations and present findings in a comprehensive report.', 400000.00, '2025-02-10', 'Data Analysis,Excel,Data Visualization', 'On-site', 'one-time', 'Data Analysis', '1-2 months', '20-25 hours/week', 'Excel,Data Analysis,Statistics,Data Visualization', 'Python,R,SQL,Tableau', 'Undergraduate', 'Intermediate', 'On-site', 'Kampala, Uganda', 'Data Insights Ltd', 'Dr. Sarah Nalwanga', 'sarah@datainsights.com', 'Excellent opportunity for statistics and data science students to apply their skills.'),

-- Gig 6: Content Writing
((SELECT id FROM users WHERE email = 'team@wordcraft.com'), 'Blog Content Writing', 'Write engaging blog posts about technology trends, business insights, and industry news. Research topics, create original content, and optimize for SEO. 2-3 articles per week.', 200000.00, '2025-01-31', 'Content Writing,Blog Writing,SEO', 'Remote', 'ongoing', 'Writing', '3 months', '10-15 hours/week', 'Content Writing,Blog Writing,SEO,Research', 'Technology Knowledge,Business Writing,Social Media', 'Any', 'Beginner', 'Remote', 'Anywhere in East Africa', 'WordCraft Media', 'Peter Mwangi', 'peter@wordcraft.com', 'Perfect for journalism and communication students to build their writing portfolio.');

-- Demo Applications (students applying to gigs)
INSERT INTO applications (user_id, gig_id, message, status, applied_at) VALUES
-- Alice applying to web development gig
((SELECT id FROM users WHERE email = 'alice@demo.com'), (SELECT id FROM gigs WHERE title = 'E-commerce Website Development'), 'Hi! I am a computer science student with strong experience in React and Node.js. I have built several e-commerce projects and am familiar with payment gateway integration. I would love to work on this project and contribute to your success.', 'pending', NOW()),

-- David applying to social media management gig
((SELECT id FROM users WHERE email = 'david@demo.com'), (SELECT id FROM gigs WHERE title = 'Social Media Management'), 'Hello! I am a business student with extensive experience in social media management and content creation. I have managed social media accounts for several local businesses and have a strong understanding of digital marketing strategies.', 'pending', NOW()),

-- Grace applying to mobile app development gig
((SELECT id FROM users WHERE email = 'grace@demo.com'), (SELECT id FROM gigs WHERE title = 'Food Delivery Mobile App'), 'Hi there! I am a software engineering student specializing in mobile app development. I have experience with React Native and have built several mobile applications. I am excited about the opportunity to work on this food delivery app project.', 'pending', NOW()),

-- Michael applying to logo design gig
((SELECT id FROM users WHERE email = 'michael@demo.com'), (SELECT id FROM gigs WHERE title = 'Brand Logo Design'), 'Hello! I am a graphic design student with a passion for branding and logo design. I have created logos for various local businesses and have a strong portfolio. I would love to help create a memorable logo for your tech startup.', 'pending', NOW()),

-- Sarah applying to data analysis gig
((SELECT id FROM users WHERE email = 'sarah@demo.com'), (SELECT id FROM gigs WHERE title = 'Customer Data Analysis'), 'Hi! I am a statistics student with strong analytical skills and experience in data visualization. I have worked on several data analysis projects and am proficient in Excel, Python, and R. I am excited about the opportunity to analyze your customer data.', 'pending', NOW()),

-- Peter applying to content writing gig
((SELECT id FROM users WHERE email = 'peter@demo.com'), (SELECT id FROM gigs WHERE title = 'Blog Content Writing'), 'Hello! I am a journalism student with excellent writing skills and experience in content creation. I have written blog posts for various topics and have a strong understanding of SEO. I would love to contribute to your content strategy.', 'pending', NOW());

-- Demo Conversations and Messages
INSERT INTO conversations (user1_id, user2_id, last_message_at, created_at) VALUES
-- Conversation between Alice and TechFlow Solutions
((SELECT id FROM users WHERE email = 'alice@demo.com'), (SELECT id FROM users WHERE email = 'info@techflow.com'), NOW(), NOW()),

-- Conversation between David and Creative Minds Agency
((SELECT id FROM users WHERE email = 'david@demo.com'), (SELECT id FROM users WHERE email = 'hello@creativeminds.com'), NOW(), NOW()),

-- Conversation between Grace and TechFlow Solutions
((SELECT id FROM users WHERE email = 'grace@demo.com'), (SELECT id FROM users WHERE email = 'info@techflow.com'), NOW(), NOW());

-- Demo Messages
INSERT INTO messages (conversation_id, sender_id, content, is_read, created_at) VALUES
-- Messages in Alice-TechFlow conversation
((SELECT id FROM conversations WHERE user1_id = (SELECT id FROM users WHERE email = 'alice@demo.com') AND user2_id = (SELECT id FROM users WHERE email = 'info@techflow.com')), (SELECT id FROM users WHERE email = 'alice@demo.com'), 'Hi! I saw your web development gig and I am very interested. I have strong experience in React and Node.js. When can we discuss the project details?', FALSE, NOW()),

((SELECT id FROM conversations WHERE user1_id = (SELECT id FROM users WHERE email = 'alice@demo.com') AND user2_id = (SELECT id FROM users WHERE email = 'info@techflow.com')), (SELECT id FROM users WHERE email = 'info@techflow.com'), 'Hello Alice! Thank you for your interest. We would love to discuss the project with you. Are you available for a call this week?', TRUE, NOW()),

-- Messages in David-Creative Minds conversation
((SELECT id FROM conversations WHERE user1_id = (SELECT id FROM users WHERE email = 'david@demo.com') AND user2_id = (SELECT id FROM users WHERE email = 'hello@creativeminds.com')), (SELECT id FROM users WHERE email = 'david@demo.com'), 'Hi! I applied for your social media management position. I have managed social media accounts for several local businesses and have great results to show.', FALSE, NOW()),

((SELECT id FROM conversations WHERE user1_id = (SELECT id FROM users WHERE email = 'david@demo.com') AND user2_id = (SELECT id FROM users WHERE email = 'hello@creativeminds.com')), (SELECT id FROM users WHERE email = 'hello@creativeminds.com'), 'Hello David! We are impressed with your application. Can you share some examples of your previous work?', TRUE, NOW());

-- Demo Notifications
INSERT INTO notifications (user_id, title, message, type, is_read, created_at) VALUES
-- Notifications for students
((SELECT id FROM users WHERE email = 'alice@demo.com'), 'New Gig Available', 'A new web development gig has been posted that matches your skills!', 'info', FALSE, NOW()),
((SELECT id FROM users WHERE email = 'david@demo.com'), 'Application Status Update', 'Your application for Social Media Management has been reviewed.', 'success', FALSE, NOW()),
((SELECT id FROM users WHERE email = 'grace@demo.com'), 'New Message', 'You have received a new message from TechFlow Solutions.', 'info', FALSE, NOW()),

-- Notifications for businesses
((SELECT id FROM users WHERE email = 'info@techflow.com'), 'New Application', 'You have received a new application for your web development gig.', 'info', FALSE, NOW()),
((SELECT id FROM users WHERE email = 'hello@creativeminds.com'), 'New Application', 'You have received a new application for your social media management gig.', 'info', FALSE, NOW()),
((SELECT id FROM users WHERE email = 'studio@pixelperfect.com'), 'Gig Performance', 'Your logo design gig has received 5 applications this week.', 'success', FALSE, NOW());

-- Demo Saved Gigs
INSERT INTO saved_gigs (user_id, gig_id, saved_at) VALUES
-- Alice saved the mobile app development gig
((SELECT id FROM users WHERE email = 'alice@demo.com'), (SELECT id FROM gigs WHERE title = 'Food Delivery Mobile App'), NOW()),

-- David saved the content writing gig
((SELECT id FROM users WHERE email = 'david@demo.com'), (SELECT id FROM gigs WHERE title = 'Blog Content Writing'), NOW()),

-- Grace saved the data analysis gig
((SELECT id FROM users WHERE email = 'grace@demo.com'), (SELECT id FROM gigs WHERE title = 'Customer Data Analysis'), NOW());

-- Demo Reviews
INSERT INTO reviews (reviewer_id, reviewee_id, application_id, rating, comment, created_at) VALUES
-- Review for Alice by TechFlow Solutions
((SELECT id FROM users WHERE email = 'info@techflow.com'), (SELECT id FROM users WHERE email = 'alice@demo.com'), (SELECT id FROM applications WHERE user_id = (SELECT id FROM users WHERE email = 'alice@demo.com') AND gig_id = (SELECT id FROM gigs WHERE title = 'E-commerce Website Development')), 5, 'Alice did an excellent job on our website project. Her code was clean, well-documented, and she delivered on time. Highly recommended!', NOW()),

-- Review for David by Creative Minds Agency
((SELECT id FROM users WHERE email = 'hello@creativeminds.com'), (SELECT id FROM users WHERE email = 'david@demo.com'), (SELECT id FROM applications WHERE user_id = (SELECT id FROM users WHERE email = 'david@demo.com') AND gig_id = (SELECT id FROM gigs WHERE title = 'Social Media Management')), 4, 'David managed our social media accounts very well. He created engaging content and helped increase our follower count significantly.', NOW());

-- Update user ratings based on reviews
UPDATE users SET rating = 4.8, total_ratings = 1 WHERE email = 'alice@demo.com';
UPDATE users SET rating = 4.5, total_ratings = 1 WHERE email = 'david@demo.com';

-- Demo Skills
INSERT INTO skills (name, category) VALUES
('React Native', 'Mobile Development'),
('Flutter', 'Mobile Development'),
('Firebase', 'Backend'),
('Payment Gateway Integration', 'E-commerce'),
('Social Media Analytics', 'Marketing'),
('Adobe Creative Suite', 'Design'),
('Tableau', 'Data Visualization'),
('R', 'Programming'),
('SEO', 'Marketing'),
('Content Strategy', 'Marketing');

-- Demo Categories
INSERT INTO categories (name, description) VALUES
('Mobile App Development', 'iOS and Android app development'),
('Social Media Marketing', 'Social media strategy and management'),
('Logo Design', 'Brand identity and logo creation'),
('Data Analytics', 'Data analysis and business intelligence'),
('Content Marketing', 'Content creation and strategy'),
('E-commerce Development', 'Online store development and management');

-- Demo User Skills
INSERT INTO user_skills (user_id, skill_id, proficiency, created_at) VALUES
-- Alice's skills
((SELECT id FROM users WHERE email = 'alice@demo.com'), (SELECT id FROM skills WHERE name = 'JavaScript'), 'advanced', NOW()),
((SELECT id FROM users WHERE email = 'alice@demo.com'), (SELECT id FROM skills WHERE name = 'React'), 'advanced', NOW()),
((SELECT id FROM users WHERE email = 'alice@demo.com'), (SELECT id FROM skills WHERE name = 'Node.js'), 'intermediate', NOW()),

-- David's skills
((SELECT id FROM users WHERE email = 'david@demo.com'), (SELECT id FROM skills WHERE name = 'Social Media Management'), 'advanced', NOW()),
((SELECT id FROM users WHERE email = 'david@demo.com'), (SELECT id FROM skills WHERE name = 'Content Writing'), 'advanced', NOW()),
((SELECT id FROM users WHERE email = 'david@demo.com'), (SELECT id FROM skills WHERE name = 'Marketing'), 'intermediate', NOW()),

-- Grace's skills
((SELECT id FROM users WHERE email = 'grace@demo.com'), (SELECT id FROM skills WHERE name = 'React Native'), 'advanced', NOW()),
((SELECT id FROM users WHERE email = 'grace@demo.com'), (SELECT id FROM skills WHERE name = 'Flutter'), 'intermediate', NOW()),
((SELECT id FROM users WHERE email = 'grace@demo.com'), (SELECT id FROM skills WHERE name = 'UI/UX Design'), 'intermediate', NOW()),

-- Michael's skills
((SELECT id FROM users WHERE email = 'michael@demo.com'), (SELECT id FROM skills WHERE name = 'Graphic Design'), 'advanced', NOW()),
((SELECT id FROM users WHERE email = 'michael@demo.com'), (SELECT id FROM skills WHERE name = 'Logo Design'), 'advanced', NOW()),
((SELECT id FROM users WHERE email = 'michael@demo.com'), (SELECT id FROM skills WHERE name = 'Branding'), 'intermediate', NOW()),

-- Sarah's skills
((SELECT id FROM users WHERE email = 'sarah@demo.com'), (SELECT id FROM skills WHERE name = 'Data Analysis'), 'advanced', NOW()),
((SELECT id FROM users WHERE email = 'sarah@demo.com'), (SELECT id FROM skills WHERE name = 'Python'), 'intermediate', NOW()),
((SELECT id FROM users WHERE email = 'sarah@demo.com'), (SELECT id FROM skills WHERE name = 'Excel'), 'advanced', NOW()),

-- Peter's skills
((SELECT id FROM users WHERE email = 'peter@demo.com'), (SELECT id FROM skills WHERE name = 'Content Writing'), 'advanced', NOW()),
((SELECT id FROM users WHERE email = 'peter@demo.com'), (SELECT id FROM skills WHERE name = 'Blog Writing'), 'advanced', NOW()),
((SELECT id FROM users WHERE email = 'peter@demo.com'), (SELECT id FROM skills WHERE name = 'SEO'), 'intermediate', NOW());

-- Demo Gig Categories
INSERT INTO gig_categories (gig_id, category_id) VALUES
((SELECT id FROM gigs WHERE title = 'E-commerce Website Development'), (SELECT id FROM categories WHERE name = 'Web Development')),
((SELECT id FROM gigs WHERE title = 'Food Delivery Mobile App'), (SELECT id FROM categories WHERE name = 'Mobile App Development')),
((SELECT id FROM gigs WHERE title = 'Social Media Management'), (SELECT id FROM categories WHERE name = 'Social Media Marketing')),
((SELECT id FROM gigs WHERE title = 'Brand Logo Design'), (SELECT id FROM categories WHERE name = 'Logo Design')),
((SELECT id FROM gigs WHERE title = 'Customer Data Analysis'), (SELECT id FROM categories WHERE name = 'Data Analytics')),
((SELECT id FROM gigs WHERE title = 'Blog Content Writing'), (SELECT id FROM categories WHERE name = 'Content Marketing'));

-- Update conversation last_message_at timestamps
UPDATE conversations SET last_message_at = NOW() WHERE id IN (
    SELECT id FROM conversations WHERE user1_id IN (
        SELECT id FROM users WHERE email IN ('alice@demo.com', 'david@demo.com', 'grace@demo.com')
    )
);

-- Update gig application counts
UPDATE gigs SET application_count = (
    SELECT COUNT(*) FROM applications WHERE gig_id = gigs.id
) WHERE id IN (SELECT id FROM gigs WHERE user_id IN (
    SELECT id FROM users WHERE email LIKE '%@demo.com' OR email LIKE '%@techflow.com' OR email LIKE '%@creativeminds.com' OR email LIKE '%@pixelperfect.com' OR email LIKE '%@datainsights.com' OR email LIKE '%@wordcraft.com'
));

-- Update gig view counts (simulate some views)
UPDATE gigs SET view_count = FLOOR(RAND() * 50) + 10 WHERE id IN (SELECT id FROM gigs WHERE user_id IN (
    SELECT id FROM users WHERE email LIKE '%@demo.com' OR email LIKE '%@techflow.com' OR email LIKE '%@creativeminds.com' OR email LIKE '%@pixelperfect.com' OR email LIKE '%@datainsights.com' OR email LIKE '%@wordcraft.com'
));

-- Create some additional demo notifications
INSERT INTO notifications (user_id, title, message, type, is_read, created_at) VALUES
((SELECT id FROM users WHERE email = 'alice@demo.com'), 'Welcome to FunaGig!', 'Welcome to FunaGig! Start exploring gigs and building your portfolio.', 'success', TRUE, NOW()),
((SELECT id FROM users WHERE email = 'david@demo.com'), 'Profile Complete', 'Your profile has been completed successfully. You are now ready to apply for gigs!', 'success', TRUE, NOW()),
((SELECT id FROM users WHERE email = 'grace@demo.com'), 'Skill Added', 'You have successfully added React Native to your skills profile.', 'info', TRUE, NOW()),
((SELECT id FROM users WHERE email = 'michael@demo.com'), 'New Gig Match', 'A new design gig has been posted that matches your skills!', 'info', FALSE, NOW()),
((SELECT id FROM users WHERE email = 'sarah@demo.com'), 'Application Accepted', 'Congratulations! Your application for the data analysis project has been accepted.', 'success', FALSE, NOW()),
((SELECT id FROM users WHERE email = 'peter@demo.com'), 'Content Writing Opportunity', 'A new content writing gig has been posted. Check it out!', 'info', FALSE, NOW());

-- Update business user ratings
UPDATE users SET rating = 4.8, total_ratings = 25 WHERE email = 'info@techflow.com';
UPDATE users SET rating = 4.7, total_ratings = 18 WHERE email = 'hello@creativeminds.com';
UPDATE users SET rating = 4.6, total_ratings = 22 WHERE email = 'contact@shopsmart.ug';
UPDATE users SET rating = 4.9, total_ratings = 30 WHERE email = 'studio@pixelperfect.com';
UPDATE users SET rating = 4.5, total_ratings = 16 WHERE email = 'info@datainsights.com';
UPDATE users SET rating = 4.7, total_ratings = 20 WHERE email = 'team@wordcraft.com';

-- Final statistics update
UPDATE users SET 
    rating = CASE 
        WHEN email = 'alice@demo.com' THEN 4.8
        WHEN email = 'david@demo.com' THEN 4.5
        WHEN email = 'grace@demo.com' THEN 4.7
        WHEN email = 'michael@demo.com' THEN 4.9
        WHEN email = 'sarah@demo.com' THEN 4.6
        WHEN email = 'peter@demo.com' THEN 4.4
        ELSE rating
    END,
    total_ratings = CASE 
        WHEN email = 'alice@demo.com' THEN 12
        WHEN email = 'david@demo.com' THEN 8
        WHEN email = 'grace@demo.com' THEN 15
        WHEN email = 'michael@demo.com' THEN 20
        WHEN email = 'sarah@demo.com' THEN 10
        WHEN email = 'peter@demo.com' THEN 7
        ELSE total_ratings
    END
WHERE email IN ('alice@demo.com', 'david@demo.com', 'grace@demo.com', 'michael@demo.com', 'sarah@demo.com', 'peter@demo.com');

-- Display demo account information
SELECT 'Demo Accounts Created Successfully!' as Status;
SELECT 'Student Accounts:' as Account_Type;
SELECT name, email, type, university, major, rating, total_ratings FROM users WHERE email LIKE '%@demo.com' AND type = 'student';
SELECT 'Business Accounts:' as Account_Type;
SELECT name, email, type, industry, rating, total_ratings FROM users WHERE email LIKE '%@demo.com' AND type = 'business';
SELECT 'All Demo Accounts:' as Account_Type;
SELECT name, email, type, rating, total_ratings FROM users WHERE email LIKE '%@demo.com' OR email LIKE '%@techflow.com' OR email LIKE '%@creativeminds.com' OR email LIKE '%@pixelperfect.com' OR email LIKE '%@datainsights.com' OR email LIKE '%@wordcraft.com';
