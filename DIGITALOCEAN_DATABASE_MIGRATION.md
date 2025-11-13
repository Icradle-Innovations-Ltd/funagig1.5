# DigitalOcean Managed Database Migration Guide

## 🎯 **Overview**
This guide will help you migrate your local MySQL database to a DigitalOcean Managed Database, providing better reliability, automatic backups, and scalability.

## 💰 **Pricing Overview**
- **Basic Plan**: $15/month (1GB RAM, 1 vCPU, 10GB storage)
- **Professional Plan**: $60/month (4GB RAM, 2 vCPU, 25GB storage)
- **Business Plan**: $240/month (8GB RAM, 4 vCPU, 50GB storage)

## 🚀 **Step 1: Create DigitalOcean Managed Database**

### 1.1 Via DigitalOcean Control Panel
1. Log into your DigitalOcean account
2. Go to **Databases** in the left sidebar
3. Click **Create Database Cluster**
4. Configure your database:
   ```
   Engine: MySQL 8.0
   Plan: Basic ($15/month recommended for start)
   Datacenter: Choose closest to your users
   Database Name: funagig
   ```
5. Click **Create Database Cluster**

### 1.2 Via DigitalOcean CLI (Optional)
```bash
# Install DigitalOcean CLI
curl -sL https://github.com/digitalocean/doctl/releases/download/v1.95.0/doctl-1.95.0-linux-amd64.tar.gz | tar -xzv
sudo mv doctl /usr/local/bin

# Authenticate
doctl auth init

# Create database cluster
doctl databases create funagig-cluster \
  --engine mysql \
  --version 8 \
  --size db-s-1vcpu-1gb \
  --region nyc1 \
  --num-nodes 1
```

## 🔧 **Step 2: Configure Database Access**

### 2.1 Create Database and User
Once your cluster is ready:
1. Go to **Databases** → **Your Cluster** → **Users & Databases**
2. Create a new database: `funagig`
3. Create a new user: `funagig_user` with a strong password
4. Grant all privileges on `funagig` database to `funagig_user`

### 2.2 Configure Connection Pool (Optional but Recommended)
1. Go to **Connection Pools**
2. Create pool:
   ```
   Name: funagig-pool
   Database: funagig
   User: funagig_user
   Pool Mode: Transaction
   Pool Size: 10
   ```

## 📊 **Step 3: Export Your Current Database**

### 3.1 Export Schema and Data
```bash
cd d:/XAMMP/htdocs/funagig1.5

# Export your current database
mysqldump -u root -p97swain \
  --routines \
  --triggers \
  --single-transaction \
  --lock-tables=false \
  funagig > funagig_export_$(date +%Y%m%d).sql

# Verify export
ls -la funagig_export_*.sql
```

### 3.2 Clean Export for DigitalOcean (Remove XAMPP-specific settings)
```bash
# Create cleaned version for DigitalOcean
sed 's/DEFINER=[^*]*\*/\*/g' funagig_export_$(date +%Y%m%d).sql > funagig_digitalocean.sql
```

## 🔄 **Step 4: Import to DigitalOcean Database**

### 4.1 Get Connection Details
From your DigitalOcean database cluster page, note:
- **Host**: `your-cluster-name-do-user-123456-0.b.db.ondigitalocean.com`
- **Port**: `25060`
- **Database**: `funagig`
- **Username**: `funagig_user`
- **Password**: `your-secure-password`

### 4.2 Import Your Database
```bash
# Test connection first
mysql -h your-cluster-name-do-user-123456-0.b.db.ondigitalocean.com \
      -P 25060 \
      -u funagig_user \
      -p \
      --ssl-mode=REQUIRED \
      -e "SELECT VERSION();"

# Import your database
mysql -h your-cluster-name-do-user-123456-0.b.db.ondigitalocean.com \
      -P 25060 \
      -u funagig_user \
      -p \
      --ssl-mode=REQUIRED \
      funagig < funagig_digitalocean.sql
```

### 4.3 Verify Import
```bash
# Check tables
mysql -h your-cluster-name-do-user-123456-0.b.db.ondigitalocean.com \
      -P 25060 \
      -u funagig_user \
      -p \
      --ssl-mode=REQUIRED \
      funagig \
      -e "SHOW TABLES; SELECT COUNT(*) as user_count FROM users;"
```

## ⚙️ **Step 5: Update Application Configuration**

### 5.1 Update .env.digitalocean
```env
# DigitalOcean Managed Database Configuration
DB_HOST=your-cluster-name-do-user-123456-0.b.db.ondigitalocean.com
DB_NAME=funagig
DB_USER=funagig_user
DB_PASS=your-secure-password
DB_PORT=25060
DB_SSL=true
DB_SSL_MODE=REQUIRED

# Connection Pool (if using)
# DB_HOST=your-cluster-name-do-user-123456-0.c.db.ondigitalocean.com
# DB_PORT=25061

# Application settings remain the same...
```

### 5.2 Update php/config.php for SSL Support
The configuration will be updated to support SSL connections required by DigitalOcean.

## 🧪 **Step 6: Test the Migration**

### 6.1 Test Local Connection to DigitalOcean
```bash
# Create a test script
php test_do_connection.php
```

### 6.2 Update Your Local Environment
1. Copy `.env.digitalocean` to `.env`
2. Update your local config to point to DigitalOcean
3. Test your application functionality

## 🔒 **Step 7: Security Hardening**

### 7.1 Configure Firewall Rules
In DigitalOcean database settings:
1. Go to **Settings** → **Trusted Sources**
2. Add your application server IPs
3. Remove any unnecessary access

### 7.2 Enable VPC (Recommended)
1. Create a VPC for your resources
2. Add your database and application servers to the same VPC
3. Configure private networking

## 📈 **Step 8: Monitoring and Maintenance**

### 8.1 Set Up Monitoring
1. Enable database metrics in DigitalOcean
2. Set up alerts for:
   - High CPU usage (>80%)
   - High memory usage (>80%)
   - Connection count approaching limit
   - Disk space usage (>80%)

### 8.2 Configure Automated Backups
DigitalOcean provides:
- Daily automated backups (7-day retention)
- Point-in-time recovery
- Manual backup creation

### 8.3 Regular Maintenance
```bash
# Weekly optimization (run on your application server)
mysql -h your-do-host -P 25060 -u funagig_user -p --ssl-mode=REQUIRED funagig -e "
OPTIMIZE TABLE users, gigs, applications, notifications;
ANALYZE TABLE users, gigs, applications, notifications;
"
```

## 🚨 **Step 9: Backup and Recovery Plan**

### 9.1 Create Manual Backup
```bash
# Create backup before major changes
mysqldump -h your-do-host \
  -P 25060 \
  -u funagig_user \
  -p \
  --ssl-mode=REQUIRED \
  --single-transaction \
  --routines \
  --triggers \
  funagig > backup_$(date +%Y%m%d_%H%M%S).sql
```

### 9.2 Disaster Recovery
1. **Point-in-time recovery**: Available through DigitalOcean interface
2. **Full restore**: Use automated backups
3. **Cross-region backup**: Set up replication to another region

## 📋 **Step 10: Performance Optimization**

### 10.1 Connection Pooling
```php
// Update your database class to use persistent connections
$mysqli = new mysqli(
    'p:' . DB_HOST,  // 'p:' prefix enables persistent connections
    DB_USER,
    DB_PASS,
    DB_NAME,
    DB_PORT
);
```

### 10.2 Query Optimization
```sql
-- Add indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_gigs_status ON gigs(status);
CREATE INDEX idx_applications_user_gig ON applications(user_id, gig_id);
CREATE INDEX idx_notifications_user_read ON notifications(user_id, is_read);
```

## 🎯 **Benefits of DigitalOcean Managed Database**

✅ **Reliability**: 99.95% uptime SLA  
✅ **Security**: Automatic security updates, SSL encryption  
✅ **Backups**: Automated daily backups with point-in-time recovery  
✅ **Scaling**: Easy vertical and horizontal scaling  
✅ **Monitoring**: Built-in performance metrics and alerting  
✅ **Maintenance**: Automatic patches and updates  
✅ **Global**: Multiple regions for reduced latency  

## 🚀 **Next Steps After Migration**

1. **Monitor Performance**: Watch for any performance issues after migration
2. **Update Documentation**: Update your deployment docs with new DB config
3. **Team Training**: Ensure your team knows how to access the new database
4. **Cost Monitoring**: Set up billing alerts in DigitalOcean
5. **Scaling Plan**: Plan for database scaling as your app grows

## 🆘 **Troubleshooting Common Issues**

### Connection Issues
```bash
# Test SSL connection
openssl s_client -connect your-do-host:25060 -servername your-do-host

# Check if SSL is required
mysql -h your-do-host -P 25060 -u funagig_user -p funagig -e "SHOW VARIABLES LIKE 'require_secure_transport';"
```

### Performance Issues
```sql
-- Check slow queries
SHOW FULL PROCESSLIST;

-- Check table sizes
SELECT 
    table_name AS 'Table',
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.tables 
WHERE table_schema = 'funagig'
ORDER BY (data_length + index_length) DESC;
```

Your database migration to DigitalOcean Managed Database is now ready! This will provide better reliability, security, and scalability for your FunaGig application.