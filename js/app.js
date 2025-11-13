// Core JavaScript utilities for FunaGig
// Shared utilities, API calls, localStorage management

// API Configuration - Environment-aware API URL
// Production: Uses environment variable or deployed backend URL
// Development: Uses local XAMPP server

// Check for Vite environment variables first (production)
const VITE_API_BASE_URL = import.meta?.env?.VITE_API_BASE_URL;

// Development fallback configuration
const BACKEND_SERVER_IP = 'localhost'; // Your backend server IP
const XAMPP_BASE_PATH = '/funagig1.5'; // XAMPP project path in htdocs

// Determine API base URL based on environment
let APP_API_BASE_URL;
if (VITE_API_BASE_URL) {
    // Production: Use environment variable
    APP_API_BASE_URL = VITE_API_BASE_URL;
} else if (typeof window !== 'undefined' && typeof window.API_BASE_URL === 'string' && window.API_BASE_URL) {
    // Distributed config fallback
    APP_API_BASE_URL = window.API_BASE_URL;
} else {
    // Development: Use production backend for testing with created accounts
    // DigitalOcean App Platform serves the PHP API directly
    APP_API_BASE_URL = 'https://plankton-app-3beec.ondigitalocean.app';
    // Local backend alternative (uncomment if you want to use local XAMPP):
    // APP_API_BASE_URL = `http://${BACKEND_SERVER_IP}${XAMPP_BASE_PATH}/php/api.php`;
}

// Expose API base for other scripts (e.g., notifications.js)
if (typeof window !== 'undefined') {
    window.APP_API_BASE_URL = APP_API_BASE_URL;
}

// Global notification manager instance
let globalNotificationManager = null;

// Utility Functions
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    // Sanitize input to prevent XSS attacks
    const sanitizedMessage = String(message || 'Unknown error').replace(/<[^>]*>/g, '');
    notification.textContent = sanitizedMessage;
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 12px 20px;
        background: ${type === 'success' ? '#10b981' : type === 'error' ? '#ef4444' : '#3b82f6'};
        color: white;
        border-radius: 8px;
        z-index: 1000;
        animation: slideIn 0.3s ease;
    `;
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.remove();
    }, 3000);
}

// API Fetch wrapper
async function apiFetch(endpoint, options = {}) {
    const url = `${APP_API_BASE_URL}${endpoint}`;
    const defaultOptions = {
        headers: {
            'Content-Type': 'application/json',
        },
        credentials: 'include',
        mode: 'cors'
    };
    
    const config = { ...defaultOptions, ...options };
    
    try {
        const response = await fetch(url, config);
        
        // Check if response is ok
        if (!response.ok) {
            let errorMessage = 'Request failed';
            try {
                const errorData = await response.json();
                errorMessage = errorData.error || errorMessage;
            } catch (parseError) {
                errorMessage = `HTTP ${response.status}: ${response.statusText}`;
            }
            throw new Error(errorMessage);
        }
        
        // Try to parse JSON response
        let data;
        try {
            data = await response.json();
        } catch (parseError) {
            throw new Error('Invalid response format from server');
        }
        
        return data;
    } catch (error) {
        console.error('API Error:', error);
        
        // Show user-friendly error message
        let userMessage = 'Network error. Please try again.';
        if (error.message.includes('Failed to fetch')) {
            userMessage = 'Unable to connect to server. Please check your internet connection.';
        } else if (error.message.includes('Invalid response format')) {
            userMessage = 'Server returned invalid data. Please try again.';
        } else if (error.message) {
            userMessage = error.message;
        }
        
        showNotification(userMessage, 'error');
        throw error;
    }
}

// Local Storage utilities
const Storage = {
    set(key, value) {
        try {
            if (typeof key !== 'string') {
                throw new Error('Storage key must be a string');
            }
            localStorage.setItem(key, JSON.stringify(value));
            return true;
        } catch (error) {
            console.error('Storage error:', error);
            showNotification('Failed to save data locally', 'error');
            return false;
        }
    },
    
    get(key, defaultValue = null) {
        try {
            if (typeof key !== 'string') {
                throw new Error('Storage key must be a string');
            }
            const item = localStorage.getItem(key);
            return item ? JSON.parse(item) : defaultValue;
        } catch (error) {
            console.error('Storage error:', error);
            return defaultValue;
        }
    },
    
    remove(key) {
        try {
            if (typeof key !== 'string') {
                throw new Error('Storage key must be a string');
            }
            localStorage.removeItem(key);
            return true;
        } catch (error) {
            console.error('Storage error:', error);
            return false;
        }
    },
    
    clear() {
        try {
            localStorage.clear();
            return true;
        } catch (error) {
            console.error('Storage error:', error);
            return false;
        }
    },
    
    // Check if localStorage is available
    isAvailable() {
        try {
            const test = '__localStorage_test__';
            localStorage.setItem(test, test);
            localStorage.removeItem(test);
            return true;
        } catch (error) {
            return false;
        }
    }
};

// Authentication utilities
const Auth = {
    isLoggedIn() {
        try {
            const user = Storage.get('user');
            return user !== null && typeof user === 'object';
        } catch (error) {
            console.error('Auth check error:', error);
            return false;
        }
    },
    
    getUser() {
        try {
            const user = Storage.get('user');
            if (user && typeof user === 'object') {
                return user;
            }
            return null;
        } catch (error) {
            console.error('Get user error:', error);
            return null;
        }
    },
    
    setUser(user) {
        try {
            if (!user || typeof user !== 'object') {
                throw new Error('Invalid user data');
            }
            Storage.set('user', user);
            return true;
        } catch (error) {
            console.error('Set user error:', error);
            showNotification('Failed to save user data', 'error');
            return false;
        }
    },
    
    logout() {
        try {
            // Call server logout
            apiFetch('/logout', {
                method: 'POST'
            }).catch(error => {
                console.error('Server logout error:', error);
                // Continue with client logout even if server call fails
            });
            
            // Clear local storage
            Storage.remove('user');
            Storage.remove('userType');
            Storage.remove('isLoggedIn');
            Storage.clear(); // Clear all stored data
            
            // Clear session cookie
            this.deleteCookie('funagig_session');
            
            window.location.href = 'index.html';
        } catch (error) {
            console.error('Logout error:', error);
            // Force redirect even if storage fails
            window.location.href = 'index.html';
        }
    },
    
    requireAuth() {
        if (!this.isLoggedIn()) {
            window.location.href = 'auth.html';
            return false;
        }
        return true;
    },
    
    // Cookie management functions
    setCookie(name, value, days) {
        const expires = new Date();
        expires.setTime(expires.getTime() + (days * 24 * 60 * 60 * 1000));
        document.cookie = `${name}=${value};expires=${expires.toUTCString()};path=/;SameSite=Lax`;
    },
    
    getCookie(name) {
        const nameEQ = name + "=";
        const ca = document.cookie.split(';');
        for (let i = 0; i < ca.length; i++) {
            let c = ca[i];
            while (c.charAt(0) === ' ') c = c.substring(1, c.length);
            if (c.indexOf(nameEQ) === 0) return c.substring(nameEQ.length, c.length);
        }
        return null;
    },
    
    deleteCookie(name) {
        document.cookie = `${name}=;expires=Thu, 01 Jan 1970 00:00:00 UTC;path=/;`;
    },
    
    // Session validation
    async validateSession() {
        try {
            const response = await apiFetch('/profile');
            if (response.success) {
                return true;
            }
            return false;
        } catch (error) {
            console.error('Session validation error:', error);
            return false;
        }
    }
};

// Form validation utilities
const Validation = {
    email(email) {
        const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return regex.test(email);
    },
    
    password(password) {
        return password.length >= 6;
    },
    
    required(value) {
        return value && value.trim().length > 0;
    }
};

// UI utilities
const UI = {
    showLoading(element) {
        element.innerHTML = '<div class="loading">Loading...</div>';
    },
    
    hideLoading(element, content) {
        element.innerHTML = content;
    },
    
    formatDate(date) {
        return new Date(date).toLocaleDateString();
    },
    
    formatCurrency(amount) {
        return new Intl.NumberFormat('en-UG', {
            style: 'currency',
            currency: 'UGX'
        }).format(amount);
    }
};

// Initialize app
document.addEventListener('DOMContentLoaded', function() {
    // Add smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({ behavior: 'smooth' });
            }
        });
    });
    
    // Initialize tooltips and other UI enhancements
    initializeTooltips();
});

function initializeTooltips() {
    // Add tooltip functionality if needed
    console.log('App initialized');
}

// Initialize notification manager when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    // Dynamically load global navigation so every page gets consistent nav
    if (typeof window !== 'undefined' && !window.__navLoaded) {
        const script = document.createElement('script');
        script.src = 'js/nav.js';
        script.async = true;
        script.onload = function() { window.__navLoaded = true; };
        document.head.appendChild(script);
    }
    // Initialize global notification manager if notifications.js is loaded
    if (typeof window !== 'undefined' && window.notificationManager) {
        globalNotificationManager = window.notificationManager;

        // Set up global notification callbacks
        globalNotificationManager.addCallback('onNotification', function(notification) {
            // Show browser notification
            if ('Notification' in window && Notification.permission === 'granted') {
                new Notification(notification.title, {
                    body: notification.message,
                    icon: '/favicon.ico'
                });
            }
        });
        
        globalNotificationManager.addCallback('onUnreadCountChange', function(count) {
            // Update any notification badges on the page
            const badges = document.querySelectorAll('.notification-badge');
            badges.forEach(badge => {
                if (count > 0) {
                    badge.textContent = count;
                    badge.style.display = 'inline-block';
                } else {
                    badge.style.display = 'none';
                }
            });
        });
    }
});

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { apiFetch, Storage, Auth, Validation, UI, showNotification };
}

// Expose functions to global window object for inline scripts
if (typeof window !== 'undefined') {
    console.log('Exposing functions to window object...');
    window.apiFetch = apiFetch;
    window.Storage = Storage;
    window.Auth = Auth;
    window.Validation = Validation;
    window.UI = UI;
    window.showNotification = showNotification;
    console.log('Functions exposed. apiFetch type:', typeof window.apiFetch);
}

