@echo off
echo Setting up FunaGig Demo Accounts...
echo.

echo Step 1: Make sure XAMPP is running (Apache and MySQL)
echo Step 2: Import the main database schema
echo Step 3: Import the demo accounts
echo.

echo Importing main database schema...
mysql -u root -p funagig < database/database_unified.sql

echo.
echo Importing demo accounts...
mysql -u root -p funagig < database/demo_accounts.sql

echo.
echo Demo accounts setup complete!
echo.
echo Demo Login Credentials:
echo ========================
echo.
echo STUDENT ACCOUNTS:
echo - Email: alice@demo.com, Password: password
echo - Email: david@demo.com, Password: password  
echo - Email: grace@demo.com, Password: password
echo - Email: michael@demo.com, Password: password
echo - Email: sarah@demo.com, Password: password
echo - Email: peter@demo.com, Password: password
echo.
echo BUSINESS ACCOUNTS:
echo - Email: info@techflow.com, Password: password
echo - Email: hello@creativeminds.com, Password: password
echo - Email: contact@shopsmart.ug, Password: password
echo - Email: studio@pixelperfect.com, Password: password
echo - Email: info@datainsights.com, Password: password
echo - Email: team@wordcraft.com, Password: password
echo.
echo You can now test the system with these accounts!
pause
