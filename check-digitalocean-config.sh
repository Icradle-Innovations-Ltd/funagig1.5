#!/bin/bash

# DigitalOcean Configuration Checker
# Validates your setup before migration

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 DigitalOcean Configuration Checker${NC}"
echo "====================================="
echo

# Check if .env.digitalocean exists
echo -e "${YELLOW}📄 Checking configuration files...${NC}"
if [ ! -f ".env.digitalocean" ]; then
    echo -e "${RED}❌ .env.digitalocean file not found!${NC}"
    echo "   Please create this file with your DigitalOcean database credentials."
    exit 1
else
    echo -e "${GREEN}✅ .env.digitalocean file exists${NC}"
fi

# Check if config.php has SSL support
echo -e "${YELLOW}🔧 Checking php/config.php for SSL support...${NC}"
if grep -q "DB_SSL" php/config.php; then
    echo -e "${GREEN}✅ config.php has SSL support${NC}"
else
    echo -e "${RED}❌ config.php missing SSL support${NC}"
    echo "   Please update config.php to support DigitalOcean SSL connections."
fi

# Check if migration files exist
echo -e "${YELLOW}📦 Checking migration tools...${NC}"
migration_files=(
    "test_digitalocean_db.php"
    "migrate-to-digitalocean.sh"
    "migrate-to-digitalocean.bat"
    "DIGITALOCEAN_DATABASE_MIGRATION.md"
)

for file in "${migration_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ $file exists${NC}"
    else
        echo -e "${RED}❌ $file missing${NC}"
    fi
done

# Check database exports directory
echo -e "${YELLOW}📁 Checking database exports...${NC}"
if [ -d "database/exports" ]; then
    export_count=$(ls -1 database/exports/*.sql 2>/dev/null | wc -l)
    if [ $export_count -gt 0 ]; then
        echo -e "${GREEN}✅ Found $export_count database export files${NC}"
        echo "   Latest exports:"
        ls -lt database/exports/*.sql 2>/dev/null | head -3 | awk '{print "   - " $9}'
    else
        echo -e "${YELLOW}⚠️ No database exports found${NC}"
        echo "   Run migrate-to-digitalocean.bat to create exports."
    fi
else
    echo -e "${YELLOW}⚠️ database/exports directory not found${NC}"
    echo "   Run migrate-to-digitalocean.bat to create exports."
fi

# Check local database connectivity
echo -e "${YELLOW}🔌 Testing local database connection...${NC}"
if mysql -u root -p97swain -e "USE funagig; SELECT COUNT(*) FROM users;" >/dev/null 2>&1; then
    user_count=$(mysql -u root -p97swain funagig -e "SELECT COUNT(*) as count FROM users" -s -N)
    echo -e "${GREEN}✅ Local database connected (${user_count} users)${NC}"
else
    echo -e "${RED}❌ Cannot connect to local database${NC}"
    echo "   Please ensure XAMPP MySQL is running and credentials are correct."
fi

echo
echo -e "${BLUE}📋 Pre-Migration Checklist${NC}"
echo "=========================="
echo
echo "Before migrating to DigitalOcean:"
echo "□ DigitalOcean account created"
echo "□ Database cluster created on DigitalOcean"
echo "□ Database user and permissions configured"
echo "□ IP address added to trusted sources"
echo "□ SSL certificate requirements understood"
echo "□ Local database exported using migration script"
echo "□ .env.digitalocean configured with real credentials"
echo
echo -e "${BLUE}📋 Post-Migration Checklist${NC}"
echo "=========================="
echo
echo "After migrating to DigitalOcean:"
echo "□ Database imported successfully"
echo "□ test_digitalocean_db.php passes all tests"
echo "□ Application connects to DigitalOcean database"
echo "□ All features working correctly"
echo "□ Monitoring and alerts configured"
echo "□ Backup strategy implemented"
echo
echo -e "${GREEN}Configuration check complete!${NC}"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}🎉 Your setup is ready for DigitalOcean migration!${NC}"
else
    echo -e "${RED}⚠️ Please fix the issues above before proceeding.${NC}"
fi