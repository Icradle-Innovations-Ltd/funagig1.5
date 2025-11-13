# 🌊 FunaGig DigitalOcean Deployment Guide

## 📋 **Prerequisites**
- DigitalOcean account (Get $200 free credit: https://m.do.co/c/signup)
- Domain name (optional but recommended)
- Your FunaGig code ready in git repository

---

## 🚀 **DEPLOYMENT METHODS**

### **Method 1: App Platform (Recommended - Easy)**
### **Method 2: Droplet with LAMP Stack (More Control)**

---

## 🎯 **METHOD 1: DigitalOcean App Platform (Easiest)**

### **Step 1: Prepare Your Repository**
```bash
# Ensure your code is in GitHub/GitLab
cd d:/XAMMP/htdocs/funagig1.5
git remote add origin https://github.com/yourusername/funagig.git
git push -u origin main
```

### **Step 2: Create App Platform Service**
1. **Login to DigitalOcean Console**
2. **Create App** → **Apps** → **Create App**
3. **Connect GitHub/GitLab** → Select your funagig repository
4. **Configure Build Settings**:
   - **Source Directory**: `/` (root)
   - **Build Command**: `npm install && npm run build`
   - **Run Command**: `php -S 0.0.0.0:8080 php/api.php`

### **Step 3: Add Database**
1. **Add Component** → **Database**
2. **Choose MySQL**
3. **Plan**: $15/month (Development), $25/month (Production)
4. **Name**: `funagig-db`

### **Step 4: Environment Variables**
Add these in App Platform settings:
```env
DB_HOST=${funagig-db.HOSTNAME}
DB_NAME=${funagig-db.DATABASE}
DB_USER=${funagig-db.USERNAME}
DB_PASS=${funagig-db.PASSWORD}
APP_URL=https://your-app-name.ondigitalocean.app
HTTPS_REQUIRED=true
PRODUCTION_MODE=true
DEBUG_MODE=false
```

### **Step 5: Deploy**
- **Review & Create** → **Create Resources**
- **Wait 5-10 minutes** for deployment

**Cost**: $20-30/month (App + Database)

---

## 🔧 **METHOD 2: Droplet LAMP Stack (More Control)**

### **Step 1: Create Droplet**
1. **Create** → **Droplets**
2. **Choose Image**: Ubuntu 22.04 LTS
3. **Choose Plan**: $6/month (Basic, 1GB RAM)
4. **Add-ons**: 
   - ✅ Monitoring
   - ✅ Automated Backups (+$1.20/month)
5. **Authentication**: SSH Key (recommended) or Password
6. **Create Droplet**

### **Step 2: Initial Server Setup**
```bash
# Connect to your droplet
ssh root@your-droplet-ip

# Update system
apt update && apt upgrade -y

# Install LAMP stack
apt install apache2 mysql-server php libapache2-mod-php php-mysql php-curl php-json php-mbstring php-xml php-zip unzip git -y

# Secure MySQL
mysql_secure_installation
```

### **Step 3: Configure Apache**
```bash
# Enable Apache modules
a2enmod rewrite
a2enmod headers
a2enmod ssl

# Create virtual host
nano /etc/apache2/sites-available/funagig.conf
```

**Add this configuration:**
```apache
<VirtualHost *:80>
    ServerName your-domain.com
    ServerAlias www.your-domain.com
    DocumentRoot /var/www/funagig

    <Directory /var/www/funagig>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/funagig_error.log
    CustomLog ${APACHE_LOG_DIR}/funagig_access.log combined
</VirtualHost>
```

```bash
# Enable site and restart Apache
a2ensite funagig.conf
a2dissite 000-default.conf
systemctl restart apache2
```

### **Step 4: Deploy Your Code**
```bash
# Clone your repository
cd /var/www
git clone https://github.com/yourusername/funagig.git
chown -R www-data:www-data funagig/
chmod -R 755 funagig/

# Create logs and uploads directories
mkdir -p /var/www/funagig/logs
mkdir -p /var/www/funagig/uploads
chown -R www-data:www-data /var/www/funagig/logs
chown -R www-data:www-data /var/www/funagig/uploads
```

### **Step 5: Setup Database**
```bash
# Login to MySQL
mysql -u root -p

# Create database and user
CREATE DATABASE funagig;
CREATE USER 'funagig_user'@'localhost' IDENTIFIED BY 'your-secure-password';
GRANT ALL PRIVILEGES ON funagig.* TO 'funagig_user'@'localhost';
FLUSH PRIVILEGES;
USE funagig;

# Import your database
exit
mysql -u root -p funagig < /var/www/funagig/database/database_unified.sql
```

### **Step 6: Configure Environment**
```bash
# Copy environment file
cd /var/www/funagig
cp .env.example .env
nano .env
```

**Update .env with your values:**
```env
DB_HOST=localhost
DB_NAME=funagig
DB_USER=funagig_user
DB_PASS=your-secure-password
APP_URL=https://your-domain.com
HTTPS_REQUIRED=true
PRODUCTION_MODE=true
DEBUG_MODE=false
```

### **Step 7: SSL Certificate (Let's Encrypt)**
```bash
# Install Certbot
apt install certbot python3-certbot-apache -y

# Get SSL certificate
certbot --apache -d your-domain.com -d www.your-domain.com

# Auto-renewal
systemctl enable certbot.timer
```

**Cost**: $6-12/month (Droplet + Backups)

---

## 🔐 **SECURITY HARDENING**

### **Firewall Setup**
```bash
# Enable UFW firewall
ufw enable
ufw allow OpenSSH
ufw allow 'Apache Full'

# Check status
ufw status
```

### **Remove Setup Files (CRITICAL)**
```bash
cd /var/www/funagig
rm setup_*.php test_*.php
rm php/config.php.backup
```

### **Secure File Permissions**
```bash
# Secure sensitive files
chmod 600 .env
chmod -R 644 *.php
chmod -R 755 css/ js/
chmod 755 php/
```

---

## 📊 **DOMAIN CONFIGURATION**

### **Point Domain to DigitalOcean**
1. **Go to your domain registrar**
2. **Update nameservers to**:
   - `ns1.digitalocean.com`
   - `ns2.digitalocean.com`
   - `ns3.digitalocean.com`

### **Add Domain in DigitalOcean**
1. **Networking** → **Domains**
2. **Add Domain** → Enter your domain
3. **Create DNS Records**:
   - **A Record**: `@` → Your droplet IP
   - **A Record**: `www` → Your droplet IP

---

## 🚀 **DEPLOYMENT AUTOMATION**

### **Auto-Deploy Script**
Create `/var/www/deploy.sh`:
```bash
#!/bin/bash
cd /var/www/funagig
git pull origin main
chown -R www-data:www-data .
systemctl reload apache2
echo "Deployment completed at $(date)"
```

### **GitHub Actions (Optional)**
Create `.github/workflows/deploy.yml` in your repository:
```yaml
name: Deploy to DigitalOcean
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy
        uses: appleboy/ssh-action@v0.1.4
        with:
          host: ${{ secrets.HOST }}
          username: root
          key: ${{ secrets.KEY }}
          script: |
            cd /var/www/funagig
            git pull origin main
            chown -R www-data:www-data .
            systemctl reload apache2
```

---

## 📈 **MONITORING & MAINTENANCE**

### **Essential Monitoring**
```bash
# Install monitoring tools
apt install htop iotop ncdu fail2ban -y

# Check logs
tail -f /var/log/apache2/funagig_error.log
tail -f /var/www/funagig/logs/php_errors.log
```

### **Backup Strategy**
```bash
# Database backup script
#!/bin/bash
mysqldump -u funagig_user -p funagig > /backups/funagig-$(date +%Y%m%d).sql
```

### **Performance Optimization**
```bash
# Install PHP OpCache
apt install php-opcache -y

# Configure in /etc/php/8.1/apache2/conf.d/10-opcache.ini
opcache.enable=1
opcache.memory_consumption=128
opcache.max_accelerated_files=4000
```

---

## 💰 **COST BREAKDOWN**

### **App Platform Method**
- **App**: $12/month
- **Database**: $15/month
- **Total**: $27/month

### **Droplet Method**
- **Droplet**: $6/month
- **Backups**: $1.20/month
- **Total**: $7.20/month

---

## 🎯 **QUICK START CHECKLIST**

### **For App Platform:**
- [ ] Push code to GitHub/GitLab
- [ ] Create DigitalOcean App
- [ ] Add MySQL database
- [ ] Configure environment variables
- [ ] Deploy and test

### **For Droplet:**
- [ ] Create Ubuntu droplet
- [ ] Install LAMP stack
- [ ] Configure Apache virtual host
- [ ] Deploy code via Git
- [ ] Setup MySQL database
- [ ] Configure SSL certificate
- [ ] Remove setup files

---

## 🆘 **TROUBLESHOOTING**

### **Common Issues:**

**1. 500 Internal Server Error**
```bash
# Check Apache error log
tail -f /var/log/apache2/error.log

# Check PHP errors
tail -f /var/www/funagig/logs/php_errors.log
```

**2. Database Connection Failed**
```bash
# Test MySQL connection
mysql -u funagig_user -p -h localhost funagig

# Check MySQL status
systemctl status mysql
```

**3. Permission Issues**
```bash
# Fix ownership
chown -R www-data:www-data /var/www/funagig/
chmod -R 755 /var/www/funagig/
```

---

## 📞 **Support Resources**

- **DigitalOcean Docs**: https://docs.digitalocean.com/
- **Community**: https://www.digitalocean.com/community
- **Support**: https://cloud.digitalocean.com/support

---

**Ready to deploy? Choose your method and follow the steps above!** 🚀