# FunaGig Demo Accounts

## 🚀 Quick Setup

### Prerequisites
- XAMPP running (Apache + MySQL)
- Database `funagig` created

### Setup Commands
```bash
# Method 1: Automated setup
setup_demo_accounts.bat

# Method 2: Manual setup
mysql -u root -p funagig < database/database_unified.sql
mysql -u root -p funagig < database/demo_accounts.sql
```

## 👨‍🎓 Student Demo Accounts

| Name | Email | Password | University | Major | Skills | Rating |
|------|-------|----------|------------|-------|--------|--------|
| **Alice Johnson** | alice@demo.com | password | Makerere University | Computer Science | JavaScript, Python, React, Node.js | 4.8/5 |
| **David Kimani** | david@demo.com | password | University of Nairobi | Business Administration | Marketing, Social Media, Content Writing | 4.5/5 |
| **Grace Akello** | grace@demo.com | password | Kampala International University | Software Engineering | React Native, Flutter, UI/UX Design | 4.7/5 |
| **Michael Ochieng** | michael@demo.com | password | Strathmore University | Graphic Design | Graphic Design, Logo Design, Branding | 4.9/5 |
| **Sarah Nalwanga** | sarah@demo.com | password | Makerere University | Statistics | Data Analysis, Python, R, Excel | 4.6/5 |
| **Peter Mwangi** | peter@demo.com | password | University of Nairobi | Journalism | Content Writing, Blog Writing, SEO | 4.4/5 |

## 🏢 Business Demo Accounts

| Company | Email | Password | Industry | Specialization | Rating |
|---------|-------|----------|----------|----------------|--------|
| **TechFlow Solutions** | info@techflow.com | password | Technology | Web & Mobile Development | 4.8/5 |
| **Creative Minds Agency** | hello@creativeminds.com | password | Marketing | Digital Marketing & Branding | 4.7/5 |
| **ShopSmart Uganda** | contact@shopsmart.ug | password | E-commerce | E-commerce Platform | 4.6/5 |
| **Pixel Perfect Studio** | studio@pixelperfect.com | password | Design | Graphic Design & Branding | 4.9/5 |
| **Data Insights Ltd** | info@datainsights.com | password | Consulting | Data Analytics & BI | 4.5/5 |
| **WordCraft Media** | team@wordcraft.com | password | Content | Content Creation & Marketing | 4.7/5 |

## 🎯 Demo Gigs Available

### Active Gigs
1. **E-commerce Website Development** - TechFlow Solutions
   - Budget: UGX 800,000
   - Skills: Web Development, E-commerce, Payment Integration
   - Type: One-time project

2. **Food Delivery Mobile App** - TechFlow Solutions
   - Budget: UGX 1,200,000
   - Skills: Mobile Development, React Native, Payment Integration
   - Type: Contract

3. **Social Media Management** - Creative Minds Agency
   - Budget: UGX 300,000
   - Skills: Social Media Management, Content Creation, Analytics
   - Type: Ongoing

4. **Brand Logo Design** - Pixel Perfect Studio
   - Budget: UGX 150,000
   - Skills: Logo Design, Branding, Graphic Design
   - Type: One-time project

5. **Customer Data Analysis** - Data Insights Ltd
   - Budget: UGX 400,000
   - Skills: Data Analysis, Excel, Data Visualization
   - Type: One-time project

6. **Blog Content Writing** - WordCraft Media
   - Budget: UGX 200,000
   - Skills: Content Writing, Blog Writing, SEO
   - Type: Ongoing

## 🧪 Testing Scenarios

### Student Testing Flow
1. **Login as Alice** (alice@demo.com)
2. **Browse gigs** and apply to web development projects
3. **Check applications** and message businesses
4. **Update profile** and skills
5. **View notifications** and saved gigs

### Business Testing Flow
1. **Login as TechFlow Solutions** (info@techflow.com)
2. **Post new gigs** and manage existing ones
3. **Review applications** from students
4. **Message students** about projects
5. **Manage business profile** and settings

### Cross-Platform Testing
1. **Student applies** to business gig
2. **Business reviews** application
3. **Messages exchanged** between parties
4. **Project completion** and review process
5. **Rating and feedback** system

## 📊 Demo Data Includes

### Applications
- Students have applied to various gigs
- Different application statuses (pending, accepted, rejected)
- Application messages and responses

### Messages
- Conversations between students and businesses
- Sample messages for different scenarios
- Message timestamps and read status

### Notifications
- Welcome notifications for new users
- Application status updates
- New gig alerts
- Message notifications

### Reviews
- Sample reviews between users
- Rating system implementation
- Review comments and timestamps

### Saved Gigs
- Students have saved various gigs
- Saved gig timestamps
- User preferences tracking

## 🔧 Technical Details

### Password Hash
All demo accounts use the same password hash for simplicity:
- **Password:** `password`
- **Hash:** `$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi`

### Database Structure
- **Users table:** 12 demo accounts (6 students, 6 businesses)
- **Gigs table:** 6 active demo gigs
- **Applications table:** 6 demo applications
- **Messages table:** Sample conversations
- **Notifications table:** Various notification types
- **Reviews table:** Sample reviews and ratings

### Skills & Categories
- **Skills:** 20+ technical and soft skills
- **Categories:** 7 main gig categories
- **User Skills:** Skill proficiency levels
- **Gig Categories:** Categorized gigs

## 🚀 Quick Start Testing

### 1. Start with Student Account
- **Login:** alice@demo.com / password
- **Browse gigs** and apply to projects
- **Check dashboard** and profile

### 2. Switch to Business Account
- **Login:** info@techflow.com / password
- **Post new gigs** and manage applications
- **Review student profiles**

### 3. Test Messaging
- **Send messages** between accounts
- **Check notification** system
- **Test conversation** features

### 4. Test Applications
- **Apply to gigs** as student
- **Review applications** as business
- **Test approval/rejection** workflow

## 📝 Notes

- All demo accounts are **verified** and **active**
- Accounts have realistic **ratings** and **reviews**
- **Sample data** includes conversations, applications, and notifications
- **Skills and categories** are properly linked
- **Timestamps** are set to current time for realistic testing
- **Passwords** are simple for easy testing (change in production)

## 🎯 Next Steps

1. **Import the demo data** using the provided SQL files
2. **Test all user flows** with the demo accounts
3. **Verify functionality** across different user types
4. **Check responsive design** on different devices
5. **Test API endpoints** with the demo data

---

**Happy Testing! 🚀**
