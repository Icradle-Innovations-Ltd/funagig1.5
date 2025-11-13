# FunaGig Production Deployment Checklist

## 🔐 Security Configuration

### ✅ COMPLETED (Fixed in this update):
- [x] **Strong JWT Secret**: Generated cryptographically secure random secret
- [x] **Password Hashing**: Upgraded to Argon2ID for maximum security
- [x] **Rate Limiting**: Enabled to prevent brute force attacks
- [x] **Input Sanitization**: All user inputs sanitized and validated
- [x] **XSS Protection**: Frontend sanitizes display content
- [x] **Security Headers**: CSP, XSS protection, clickjacking prevention
- [x] **Error Handling**: Production mode hides sensitive error details
- [x] **Session Security**: HTTPOnly, Secure, SameSite cookies configured
- [x] **CSRF Protection**: Tokens generated and validated

### 🚨 CRITICAL - MUST UPDATE BEFORE PRODUCTION:

1. **Database Credentials**:
   ```bash
   # Update in php/config.php or use .env file
   DB_USER=secure_db_user  # NOT 'root'
   DB_PASS=strong_random_password_here
   ```

2. **Remove Setup Files** (SECURITY RISK):
   ```bash
   rm setup_xampp.php
   rm setup_database.php
   rm setup_demo.php
   rm setup_triggers.php
   rm setup_triggers_simple.php
   rm test_*.php
   ```

3. **HTTPS Configuration**:
   ```bash
   # Update in php/config.php
   define('HTTPS_REQUIRED', true);
   define('APP_URL', 'https://your-domain.com');
   ```

4. **Environment Variables**:
   ```bash
   # Copy .env.example to .env and update values
   cp .env.example .env
   # Edit .env with production values
   ```

## 🌐 Infrastructure Requirements

### Web Server Configuration:
- **Apache/Nginx**: Configure HTTPS with SSL certificates
- **PHP**: Version 8.0+ with required extensions
- **MySQL**: Version 8.0+ with proper user privileges
- **File Permissions**: Proper write access for upload directories

### Database Setup:
1. Create production database with restricted user
2. Import schema from `database/database_unified.sql`
3. Create database user with minimal required privileges
4. Configure SSL connection if available

### File System:
```bash
# Create required directories
mkdir logs/
mkdir uploads/
chmod 755 uploads/
chmod 755 logs/

# Set proper ownership
chown -R www-data:www-data uploads/
chown -R www-data:www-data logs/
```

## 🔍 Pre-Launch Testing

### Security Testing:
- [ ] Run Snyk security scan: `snyk code test`
- [ ] Test HTTPS redirects
- [ ] Verify rate limiting works
- [ ] Test CSRF protection
- [ ] Validate input sanitization

### Functionality Testing:
- [ ] User registration/login
- [ ] Dashboard access
- [ ] Gig creation/viewing
- [ ] Messaging system
- [ ] Notifications
- [ ] File uploads

### Performance Testing:
- [ ] Database connection pooling
- [ ] API response times
- [ ] Frontend loading speed
- [ ] Mobile responsiveness

## 📝 Monitoring & Logging

### Log Files to Monitor:
- `logs/php_errors.log` - PHP errors
- `logs/security.log` - Security events
- Apache/Nginx access logs
- Database slow query logs

### Health Checks:
- Database connectivity
- API endpoint availability
- SSL certificate expiration
- Disk space usage

## 🚀 Go-Live Steps

1. **Final Security Scan**:
   ```bash
   snyk code test --severity-threshold=high
   ```

2. **Database Backup**:
   ```bash
   mysqldump funagig > funagig_backup_$(date +%Y%m%d).sql
   ```

3. **Deploy Code**:
   - Upload files to production server
   - Update configuration files
   - Remove setup/test files

4. **Verify Configuration**:
   - Test database connection
   - Verify HTTPS works
   - Check security headers

5. **Monitor Launch**:
   - Watch error logs
   - Monitor performance
   - Test critical user flows

## 📞 Emergency Contacts

- Database Admin: [contact]
- Server Admin: [contact]  
- Security Team: [contact]
- Development Team: [contact]

---

## ⚠️ IMPORTANT SECURITY NOTES

1. **NEVER** commit production credentials to version control
2. **ALWAYS** use HTTPS in production
3. **REMOVE** all setup/debug files before going live
4. **MONITOR** security logs regularly
5. **UPDATE** dependencies regularly for security patches

## 🔧 Post-Launch Maintenance

### Daily:
- Check error logs
- Monitor database performance
- Review security logs

### Weekly:
- Update system packages
- Check SSL certificate status
- Review access logs

### Monthly:
- Security dependency updates
- Database optimization
- Performance analysis
- Backup verification