// Distributed Deployment Configuration for FunaGig
// Update these values based on your network setup

const DISTRIBUTED_CONFIG = {
    // Backend Server Configuration
    backend: {
        // Your backend server's IP address
        ip: 'localhost',
        port: '8080',
        // Path to your FunaGig backend
        path: '/php/api.php'
    },
    
    // Frontend Server Configuration  
    frontend: {
        // Replace with your frontend server's IP address
        ip: '192.168.1.100', // Update this with your frontend computer IP
        port: '3000'
    },
    
    // Network Configuration
    network: {
        // Set to true if both computers are on the same network
        sameNetwork: true,
        // Set to true if you need to configure firewall rules
        configureFirewall: true
    }
};

// Generate API URL
const API_BASE_URL = `http://${DISTRIBUTED_CONFIG.backend.ip}:${DISTRIBUTED_CONFIG.backend.port}${DISTRIBUTED_CONFIG.backend.path}`;

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { DISTRIBUTED_CONFIG, API_BASE_URL };
}

// Make available globally
window.DISTRIBUTED_CONFIG = DISTRIBUTED_CONFIG;
window.API_BASE_URL = API_BASE_URL;
