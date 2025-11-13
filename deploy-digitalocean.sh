#!/bin/bash

# FunaGig DigitalOcean Deployment Script
# Run this script to deploy updates to your DigitalOcean droplet

echo "🌊 FunaGig DigitalOcean Deployment Script"
echo "========================================="

# Configuration
DROPLET_IP="${1:-YOUR_DROPLET_IP}"  # Pass IP as first argument or set here
DOMAIN="${2:-your-domain.com}"       # Pass domain as second argument or set here
APP_PATH="/var/www/funagig"

if [ "$DROPLET_IP" = "YOUR_DROPLET_IP" ]; then
    echo "❌ Error: Please set your droplet IP"
    echo "Usage: ./deploy-digitalocean.sh DROPLET_IP [DOMAIN]"
    echo "Example: ./deploy-digitalocean.sh 165.22.123.456 funagig.com"
    exit 1
fi

echo "📡 Deploying to: $DROPLET_IP"
echo "🌐 Domain: $DOMAIN"
echo ""

# Function to run commands on remote server
run_remote() {
    echo "🔧 $1"
    ssh root@$DROPLET_IP "$1"
}

# Function to copy files to remote server
copy_files() {
    echo "📁 Copying files to server..."
    rsync -avz --exclude='.git' --exclude='node_modules' --exclude='logs' --exclude='setup_*.php' --exclude='test_*.php' ./ root@$DROPLET_IP:$APP_PATH/
}

echo "🚀 Starting deployment..."

# 1. Backup current version
echo ""
echo "📦 Creating backup..."
run_remote "cd $APP_PATH && tar -czf ~/funagig-backup-$(date +%Y%m%d-%H%M%S).tar.gz ."

# 2. Copy new files
echo ""
copy_files

# 3. Set proper permissions
echo ""
echo "🔐 Setting permissions..."
run_remote "chown -R www-data:www-data $APP_PATH"
run_remote "chmod -R 755 $APP_PATH"
run_remote "chmod 600 $APP_PATH/.env"

# 4. Remove setup files (security)
echo ""
echo "🛡️ Removing setup files..."
run_remote "cd $APP_PATH && rm -f setup_*.php test_*.php php/config.php.backup"

# 5. Update database if needed
echo ""
read -p "🗄️ Do you want to update the database? (y/N): " update_db
if [ "$update_db" = "y" ] || [ "$update_db" = "Y" ]; then
    echo "📊 Updating database..."
    run_remote "cd $APP_PATH && mysql -u funagig_user -p funagig < database/database_unified.sql"
fi

# 6. Restart services
echo ""
echo "🔄 Restarting services..."
run_remote "systemctl reload apache2"
run_remote "systemctl restart mysql"

# 7. Test deployment
echo ""
echo "🧪 Testing deployment..."
response=$(curl -s -o /dev/null -w "%{http_code}" http://$DROPLET_IP)
if [ "$response" = "200" ] || [ "$response" = "301" ] || [ "$response" = "302" ]; then
    echo "✅ Server responding (HTTP $response)"
else
    echo "❌ Server not responding properly (HTTP $response)"
    echo "Check logs: ssh root@$DROPLET_IP 'tail -f /var/log/apache2/error.log'"
fi

# 8. Check SSL if domain provided
if [ "$DOMAIN" != "your-domain.com" ]; then
    echo ""
    echo "🔒 Testing SSL..."
    ssl_response=$(curl -s -o /dev/null -w "%{http_code}" https://$DOMAIN)
    if [ "$ssl_response" = "200" ] || [ "$ssl_response" = "301" ] || [ "$ssl_response" = "302" ]; then
        echo "✅ SSL working (HTTPS $ssl_response)"
    else
        echo "❌ SSL not working (HTTPS $ssl_response)"
    fi
fi

echo ""
echo "🎉 Deployment completed!"
echo ""
echo "📍 URLs:"
echo "   HTTP:  http://$DROPLET_IP"
if [ "$DOMAIN" != "your-domain.com" ]; then
    echo "   HTTPS: https://$DOMAIN"
fi
echo ""
echo "📊 Useful commands:"
echo "   SSH: ssh root@$DROPLET_IP"
echo "   Logs: ssh root@$DROPLET_IP 'tail -f /var/log/apache2/funagig_error.log'"
echo "   App Logs: ssh root@$DROPLET_IP 'tail -f $APP_PATH/logs/php_errors.log'"
echo ""
echo "✅ Happy coding! 🚀"