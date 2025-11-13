# FunaGig Test Accounts

This document contains all test accounts created for the FunaGig platform in production.

## Production URL
**Frontend**: https://vercel-frontend-url (to be updated)
**Backend API**: https://plankton-app-3beec.ondigitalocean.app/

## Test Account Credentials

### Student Accounts

#### 1. Alice Johnson (Primary Student)
- **Email**: alice@demo.com
- **Password**: demo123
- **University**: MIT
- **Major**: Computer Science
- **Graduation Year**: 2025
- **Profile**: Tech-focused student, ideal for technical gig testing

#### 2. Bob Smith (Secondary Student)
- **Email**: bob@demo.com
- **Password**: demo123
- **University**: Stanford University
- **Major**: Data Science
- **Graduation Year**: 2024
- **Profile**: Data science student, good for analytics and research gigs

#### 3. Carol Davis (Third Student)
- **Email**: carol@demo.com
- **Password**: demo123
- **University**: UC Berkeley
- **Major**: Business Administration
- **Graduation Year**: 2026
- **Profile**: Business-oriented student, perfect for marketing and business gigs

#### 4. Previously Created Student
- **Email**: test@funagig.com
- **Password**: password123
- **Profile**: Basic test account for general testing

### Business Accounts

#### 1. Tech Solutions Inc (Primary Business)
- **Email**: techsolutions@demo.com
- **Password**: demo123
- **Industry**: Technology
- **Company Size**: 50-100 employees
- **Profile**: Mid-size tech company, posts development and IT gigs

#### 2. Creative Media Corp (Secondary Business)
- **Email**: creativemedia@demo.com
- **Password**: demo123
- **Industry**: Marketing
- **Company Size**: 10-50 employees
- **Profile**: Marketing agency, posts creative and digital marketing gigs

#### 3. Healthcare Innovations Ltd (Third Business)
- **Email**: healthcare@demo.com
- **Password**: demo123
- **Industry**: Healthcare
- **Company Size**: 100+ employees
- **Profile**: Large healthcare company, posts research and healthcare gigs

#### 4. StartupHub Ventures (Startup Business)
- **Email**: startup@demo.com
- **Password**: demo123
- **Industry**: Consulting
- **Company Size**: 1-10 employees
- **Profile**: Small startup, posts diverse small-scale gigs

#### 5. Previously Created Business
- **Email**: business@funagig.com
- **Password**: password123
- **Profile**: Basic test business account for general testing

## Testing Scenarios

### Authentication Testing
- Use any account to test login/logout functionality
- Test session management and security

### Gig Management Testing
- **Business accounts** can create, edit, and manage gigs
- **Student accounts** can browse, apply to, and manage applications

### Messaging Testing
- Create conversations between business and student accounts
- Test real-time messaging features

### Profile Management
- Test profile updates for both account types
- Verify data persistence and validation

### Cross-Account Testing
- Business posts gig → Student applies → Communication flow
- Multiple students applying to same gig
- Business managing multiple active gigs

## API Endpoints to Test

### Authentication
- `POST /login` - Test with any account above
- `POST /logout` - Test session termination
- `GET /profile` - Test authenticated user data

### Dashboard
- `GET /dashboard` - Different views for student vs business

### Gigs
- `GET /gigs` - Public gig listings
- `POST /gigs` - Business account creating gigs
- `POST /applications` - Student account applying to gigs

### Messaging
- `GET /conversations` - User's message threads
- `POST /messages` - Sending messages
- `GET /messages/{conversation_id}` - Message history

## Notes
- All accounts use the password pattern: `demo123` or `password123`
- Accounts are created in production database
- Use these accounts for comprehensive testing of all platform features
- Remember to test cross-user interactions (business-student workflows)

## Security Note
These are test accounts for development and demonstration purposes only. Do not use these credentials in any production scenario outside of testing.