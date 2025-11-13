#!/bin/bash

# DigitalOcean Droplet Setup Script for FunaGig
# Run this on a fresh Ubuntu 22.04 droplet

echo "🚀 Setting up FunaGig on DigitalOcean Droplet..."

# Update system
sudo apt update && sudo apt upgrade -y

# Install LAMP stack
sudo apt install -y apache2 mysql-client php8.2 php8.2-mysql php8.2-curl php8.2-json php8.2-mbstring php8.2-xml php8.2-zip

# Enable Apache modules
sudo a2enmod rewrite ssl headers

# Install Composer
cd ~
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Clone repository (you'll need to update this)
cd /var/www/html
sudo rm index.html
sudo git clone https://github.com/yourusername/funagig.git .

# Set permissions
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# Copy production environment
sudo cp .env.production .env

# Install dependencies
sudo -u www-data npm install
sudo -u www-data npm run build

# Configure Apache
sudo tee /etc/apache2/sites-available/funagig.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName your-domain.com
    DocumentRoot /var/www/html
    
    # Redirect all to HTTPS
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</VirtualHost>

<VirtualHost *:443>
    ServerName your-domain.com
    DocumentRoot /var/www/html
    
    # SSL Configuration (Let's Encrypt certificates)
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/your-domain.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/your-domain.com/privkey.pem
    
    # Security Headers
    Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
    
    # PHP API handling
    <Directory /var/www/html>
        AllowOverride All
        Require all granted
        
        # API routing
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^api/(.*)$ php/api.php [QSA,L]
    </Directory>
    
    # Serve built frontend
    <Directory /var/www/html/dist>
        Options -Indexes
        AllowOverride None
        Require all granted
        
        # SPA routing
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule . /index.html [L]
    </Directory>
</VirtualHost>
EOF

# Enable site
sudo a2ensite funagig
sudo a2dissite 000-default
sudo systemctl reload apache2

# Install SSL certificates
sudo apt install -y certbot python3-certbot-apache
sudo certbot --apache -d your-domain.com

# Configure firewall
sudo ufw allow OpenSSH
sudo ufw allow 'Apache Full'
sudo ufw enable

echo "✅ FunaGig setup complete!"
echo ""
echo "Next steps:"
echo "1. Update your domain DNS to point to this droplet's IP"
echo "2. Replace 'your-domain.com' in Apache config with your actual domain"
echo "3. Run: sudo certbot --apache -d yourdomain.com"
echo "4. Test your application!"
echo ""
echo "Your app will be available at: https://your-domain.com"