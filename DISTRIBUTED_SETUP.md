# FunaGig Distributed Deployment Setup

This guide will help you run the FunaGig backend on one computer and the frontend on another computer.

## Prerequisites

- Two computers on the same network
- XAMPP installed on the backend computer
- Node.js installed on the frontend computer
- Both computers can communicate over the network

## Backend Computer Setup (Computer 1)

### 1. Install and Configure XAMPP
```bash
# Install XAMPP and start Apache
# Make sure Apache is running on port 8080
```

### 2. Configure Database
- Import your database using the provided SQL files
- Update `php/config.php` with your database credentials

### 3. Update Network Configuration
Edit `php/config.php` and update the allowed origins:
```php
$allowedOrigins = [
    'http://localhost:3000',
    'http://127.0.0.1:3000',
    'http://YOUR_FRONTEND_IP:3000',  // Replace with frontend computer IP
    // Add more IPs as needed
];
```

### 4. Configure Firewall
```bash
# Windows (Run as Administrator)
netsh advfirewall firewall add rule name="XAMPP Apache" dir=in action=allow protocol=TCP localport=8080

# Linux
sudo ufw allow 8080
```

### 5. Find Your Backend Computer IP
```bash
# Windows
ipconfig

# Linux/Mac
ifconfig
# or
ip addr show
```

## Frontend Computer Setup (Computer 2)

### 1. Install Dependencies
```bash
npm install
```

### 2. Update API Configuration
Edit `js/app.js` and update the backend server IP:
```javascript
const BACKEND_SERVER_IP = 'YOUR_BACKEND_IP'; // Replace with backend computer IP
const BACKEND_PORT = '8080';
```

### 3. Update Distributed Config
Edit `distributed-config.js`:
```javascript
const DISTRIBUTED_CONFIG = {
    backend: {
        ip: 'YOUR_BACKEND_IP',  // Backend computer IP
        port: '8080',
        path: '/funagig/php/api.php'
    },
    frontend: {
        ip: 'YOUR_FRONTEND_IP',  // Frontend computer IP
        port: '3000'
    }
};
```

### 4. Start Frontend Server
```bash
npm run dev
# or
node dev-server.js
```

## Network Configuration

### 1. Ensure Both Computers Are on Same Network
- Both computers should be connected to the same WiFi network or LAN
- Check that they can ping each other

### 2. Test Connectivity
From frontend computer, test backend connection:
```bash
# Test if backend is accessible
curl http://BACKEND_IP:8080/funagig/php/api.php

# Or use browser to visit:
# http://BACKEND_IP:8080/funagig/
```

### 3. Configure Firewall Rules
**Backend Computer:**
```bash
# Allow incoming connections on port 8080
# Windows Firewall: Allow XAMPP through firewall
# Linux: sudo ufw allow 8080
```

**Frontend Computer:**
```bash
# Allow incoming connections on port 3000
# Windows Firewall: Allow Node.js through firewall
# Linux: sudo ufw allow 3000
```

## Testing the Setup

### 1. Backend Test
Visit `http://BACKEND_IP:8080/funagig/` in browser
- Should see FunaGig application
- Database should be accessible

### 2. Frontend Test
Visit `http://FRONTEND_IP:3000` in browser
- Should see FunaGig frontend
- API calls should work to backend

### 3. Full Integration Test
1. Open frontend in browser: `http://FRONTEND_IP:3000`
2. Try to login/create account
3. Check if data is saved in backend database
4. Verify real-time features work

## Troubleshooting

### Common Issues

1. **CORS Errors**
   - Check that frontend IP is in `$allowedOrigins` array in `php/config.php`
   - Verify CORS headers are properly set

2. **Connection Refused**
   - Check firewall settings on both computers
   - Verify IP addresses are correct
   - Ensure services are running on correct ports

3. **Database Connection Issues**
   - Verify database credentials in `php/config.php`
   - Check that MySQL is running on backend computer
   - Ensure database exists and is accessible

4. **Session Issues**
   - Check that cookies are enabled
   - Verify session configuration in PHP
   - Clear browser cache and cookies

### Network Commands

```bash
# Test connectivity
ping BACKEND_IP
ping FRONTEND_IP

# Test port connectivity
telnet BACKEND_IP 8080
telnet FRONTEND_IP 3000

# Check if services are running
netstat -an | grep :8080  # Backend
netstat -an | grep :3000  # Frontend
```

## Security Considerations

1. **Firewall Configuration**
   - Only allow necessary ports (8080 for backend, 3000 for frontend)
   - Consider using VPN for remote access

2. **Network Security**
   - Use HTTPS in production
   - Implement proper authentication
   - Regular security updates

3. **Database Security**
   - Use strong passwords
   - Limit database access to necessary users
   - Regular backups

## Production Deployment

For production deployment:
1. Use HTTPS instead of HTTP
2. Configure proper domain names
3. Set up SSL certificates
4. Use environment variables for configuration
5. Implement proper logging
6. Set up monitoring and alerting

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Verify network connectivity between computers
3. Check firewall and port configurations
4. Review application logs for errors
