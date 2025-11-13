// Real-time notifications module for FunaGig
// Handles trigger-based notifications and real-time updates

class NotificationManager {
    constructor() {
        this.eventSource = null;
        this.isConnected = false;
        this.unreadCount = 0;
        this.notifications = [];
        this._lastErrorLogAt = 0;
        this.callbacks = {
            onNotification: [],
            onUnreadCountChange: [],
            onConnectionChange: []
        };
        
        this.init();
    }
    
    init() {
        // Wait for apiFetch to be available before initializing
        if (typeof apiFetch === 'undefined') {
            if (typeof window !== 'undefined') {
                window.addEventListener('appReady', () => this.init());
            }
            return;
        }
        
        // Determine API base for real-time events
        this.apiBase = (typeof window !== 'undefined' && window.APP_API_BASE_URL)
            ? window.APP_API_BASE_URL
            : `${location.protocol}//${location.host}/php/api.php`;
        
        // Load initial notifications
        this.loadNotifications();
        
        // Set up periodic unread count check
        this.startUnreadCountPolling();
        
        // Set up real-time connection if user is logged in
        if (typeof Auth !== 'undefined' && Auth.isLoggedIn()) {
            this.connectRealTime();
        }
    }
    
    // Load notifications from server
    async loadNotifications(page = 1, limit = 20) {
        try {
            const response = await apiFetch(`/notifications?page=${page}&limit=${limit}`);
            if (response.success) {
                this.notifications = response.notifications;
                this.updateNotificationDisplay();
                return response;
            }
        } catch (error) {
            console.error('Failed to load notifications:', error);
            this.showNotification('Failed to load notifications', 'error');
        }
    }
    
    // Get unread count
    async getUnreadCount() {
        try {
            const response = await apiFetch('/notifications/unread');
            if (response.success) {
                const newCount = response.unread_count;
                if (newCount !== this.unreadCount) {
                    this.unreadCount = newCount;
                    this.updateUnreadCountDisplay();
                    this.triggerCallbacks('onUnreadCountChange', newCount);
                }
                return newCount;
            }
        } catch (error) {
            console.error('Failed to get unread count:', error);
        }
        return 0;
    }
    
    // Mark notification as read
    async markAsRead(notificationId) {
        try {
            const response = await apiFetch('/notifications/mark-read', {
                method: 'POST',
                body: JSON.stringify({ notification_id: notificationId })
            });
            
            if (response.success) {
                // Update local notification
                const notification = this.notifications.find(n => n.id === notificationId);
                if (notification) {
                    notification.is_read = true;
                    this.updateNotificationDisplay();
                }
                
                // Update unread count
                this.getUnreadCount();
                
                return true;
            }
        } catch (error) {
            console.error('Failed to mark notification as read:', error);
        }
        return false;
    }
    
    // Clear all notifications
    async clearAll() {
        try {
            const response = await apiFetch('/notifications/clear', {
                method: 'POST'
            });
            
            if (response.success) {
                this.notifications = [];
                this.unreadCount = 0;
                this.updateNotificationDisplay();
                this.updateUnreadCountDisplay();
                this.showNotification('All notifications cleared', 'success');
                return true;
            }
        } catch (error) {
            console.error('Failed to clear notifications:', error);
            this.showNotification('Failed to clear notifications', 'error');
        }
        return false;
    }
    
    // Connect to real-time notifications
    connectRealTime() {
        if (this.isConnected) {
            return;
        }
        
        try {
            const lastCheck = localStorage.getItem('lastNotificationCheck') || Math.floor(Date.now() / 1000);
            
            this.eventSource = new EventSource(`${this.apiBase}/notifications/real-time?last_check=${lastCheck}`, { withCredentials: true });
            
            this.eventSource.onopen = () => {
                this.isConnected = true;
                this.triggerCallbacks('onConnectionChange', true);
                console.log('Real-time notifications connected');
            };
            
            this.eventSource.onmessage = (event) => {
                try {
                    const data = JSON.parse(event.data);
                    this.handleRealTimeMessage(data);
                } catch (error) {
                    console.error('Failed to parse real-time message:', error);
                }
            };
            
            this.eventSource.onerror = (error) => {
                // Browsers fire 'error' when the SSE stream closes (e.g., server timeout).
                // Throttle noisy logs and rely on auto-reconnect.
                const now = Date.now();
                if (now - this._lastErrorLogAt > 30000) { // log at most every 30s
                    console.warn('Real-time notifications disconnected, reconnecting...');
                    this._lastErrorLogAt = now;
                }
                this.isConnected = false;
                this.triggerCallbacks('onConnectionChange', false);
                
                // Attempt to reconnect after 5 seconds
                setTimeout(() => {
                    if (typeof Auth !== 'undefined' && Auth.isLoggedIn()) {
                        this.connectRealTime();
                    }
                }, 5000);
            };
            
        } catch (error) {
            console.error('Failed to connect to real-time notifications:', error);
        }
    }
    
    // Handle real-time messages
    handleRealTimeMessage(data) {
        switch (data.type) {
            case 'connected':
                console.log('Real-time notifications connected');
                break;
                
            case 'notification':
                this.handleNewNotification(data.notification);
                break;
                
            case 'heartbeat':
                // Connection is alive
                break;
                
            case 'disconnected':
                console.log('Real-time notifications disconnected');
                this.isConnected = false;
                this.triggerCallbacks('onConnectionChange', false);
                break;
                
            case 'error':
                console.error('Real-time notifications error:', data.message);
                break;
        }
    }
    
    // Handle new notification
    handleNewNotification(notification) {
        // Add to notifications list
        this.notifications.unshift(notification);
        
        // Update display
        this.updateNotificationDisplay();
        
        // Update unread count
        this.getUnreadCount();
        
        // Show browser notification if permission granted
        this.showBrowserNotification(notification);
        
        // Trigger callbacks
        this.triggerCallbacks('onNotification', notification);
        
        // Update last check time
        localStorage.setItem('lastNotificationCheck', Math.floor(Date.now() / 1000));
    }
    
    // Show browser notification
    showBrowserNotification(notification) {
        if ('Notification' in window && Notification.permission === 'granted') {
            const notificationObj = new Notification(notification.title, {
                body: notification.message,
                icon: '/favicon.ico',
                tag: `funagig-${notification.id}`
            });
            
            notificationObj.onclick = () => {
                window.focus();
                notificationObj.close();
            };
        }
    }
    
    // Request notification permission
    async requestNotificationPermission() {
        if ('Notification' in window) {
            const permission = await Notification.requestPermission();
            return permission === 'granted';
        }
        return false;
    }
    
    // Start polling for unread count
    startUnreadCountPolling() {
        // Check unread count every 30 seconds
        setInterval(() => {
            if (typeof Auth !== 'undefined' && Auth.isLoggedIn()) {
                this.getUnreadCount();
            }
        }, 30000);
    }
    
    // Update notification display
    updateNotificationDisplay() {
        const container = document.getElementById('notifications-container');
        if (!container) return;
        
        if (this.notifications.length === 0) {
            container.innerHTML = `
                <div class="empty-state">
                    <div class="empty-icon">🔔</div>
                    <h3>No notifications</h3>
                    <p>You're all caught up! Check back later for updates.</p>
                </div>
            `;
            return;
        }
        
        const notificationsHtml = this.notifications.map(notification => `
            <div class="notification-item ${notification.is_read ? 'read' : 'unread'}" 
                 data-notification-id="${notification.id}">
                <div class="notification-content">
                    <div class="notification-header">
                        <h4 class="notification-title">${this.escapeHtml(notification.title)}</h4>
                        <span class="notification-time">${this.formatTime(notification.created_at)}</span>
                    </div>
                    <p class="notification-message">${this.escapeHtml(notification.message)}</p>
                    <div class="notification-actions">
                        <button class="btn btn-sm" onclick="notificationManager.markAsRead(${notification.id})">
                            ${notification.is_read ? 'Read' : 'Mark as Read'}
                        </button>
                    </div>
                </div>
                <div class="notification-type ${notification.type}"></div>
            </div>
        `).join('');
        
        container.innerHTML = notificationsHtml;
    }
    
    // Update unread count display
    updateUnreadCountDisplay() {
        const badge = document.getElementById('notification-badge');
        if (badge) {
            if (this.unreadCount > 0) {
                badge.textContent = this.unreadCount;
                badge.style.display = 'inline-block';
            } else {
                badge.style.display = 'none';
            }
        }
        
        // Update page title if there are unread notifications
        if (this.unreadCount > 0) {
            document.title = `(${this.unreadCount}) ${document.title.replace(/^\(\d+\)\s*/, '')}`;
        } else {
            document.title = document.title.replace(/^\(\d+\)\s*/, '');
        }
    }
    
    // Format time for display
    formatTime(timestamp) {
        const now = new Date();
        const time = new Date(timestamp);
        const diff = now - time;
        
        if (diff < 60000) { // Less than 1 minute
            return 'Just now';
        } else if (diff < 3600000) { // Less than 1 hour
            return `${Math.floor(diff / 60000)}m ago`;
        } else if (diff < 86400000) { // Less than 1 day
            return `${Math.floor(diff / 3600000)}h ago`;
        } else {
            return time.toLocaleDateString();
        }
    }
    
    // Escape HTML to prevent XSS
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
    
    // Show notification toast
    showNotification(message, type = 'info') {
        if (typeof showNotification === 'function') {
            showNotification(message, type);
        } else {
            console.log(`[${type.toUpperCase()}] ${message}`);
        }
    }
    
    // Add callback
    addCallback(event, callback) {
        if (this.callbacks[event]) {
            this.callbacks[event].push(callback);
        }
    }
    
    // Remove callback
    removeCallback(event, callback) {
        if (this.callbacks[event]) {
            const index = this.callbacks[event].indexOf(callback);
            if (index > -1) {
                this.callbacks[event].splice(index, 1);
            }
        }
    }
    
    // Trigger callbacks
    triggerCallbacks(event, data) {
        if (this.callbacks[event]) {
            this.callbacks[event].forEach(callback => {
                try {
                    callback(data);
                } catch (error) {
                    console.error('Callback error:', error);
                }
            });
        }
    }
    
    // Disconnect real-time connection
    disconnect() {
        if (this.eventSource) {
            this.eventSource.close();
            this.eventSource = null;
        }
        this.isConnected = false;
        this.triggerCallbacks('onConnectionChange', false);
    }
    
    // Get connection status
    getConnectionStatus() {
        return {
            connected: this.isConnected,
            unreadCount: this.unreadCount,
            notificationsCount: this.notifications.length
        };
    }
}

// Create global instance only after dependencies are available
function initNotificationManager() {
    if (typeof window !== 'undefined' && !window.notificationManager) {
        window.notificationManager = new NotificationManager();
    }
}

// Wait for Auth and apiFetch to be available before creating the global instance
if (typeof Auth !== 'undefined' && typeof apiFetch !== 'undefined') {
    initNotificationManager();
} else {
    window.addEventListener('appReady', initNotificationManager);
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    // Request notification permission
    if ('Notification' in window && Notification.permission === 'default' && window.notificationManager) {
        window.notificationManager.requestNotificationPermission();
    }
    
    // Set up notification dropdown if it exists
    const notificationDropdown = document.getElementById('notification-dropdown');
    if (notificationDropdown) {
        // Load notifications when dropdown is opened
        notificationDropdown.addEventListener('click', function() {
            if (window.notificationManager) {
                window.notificationManager.loadNotifications();
            }
        });
    }
    
    // Set up notification actions
    document.addEventListener('click', function(e) {
        if (e.target.matches('[data-action="mark-read"]')) {
            const notificationId = e.target.dataset.notificationId;
            if (notificationId) {
                if (window.notificationManager) {
                    window.notificationManager.markAsRead(notificationId);
                }
            }
        }
        
        if (e.target.matches('[data-action="clear-all"]')) {
            if (confirm('Are you sure you want to clear all notifications?') && window.notificationManager) {
                window.notificationManager.clearAll();
            }
        }
    });
});

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = NotificationManager;
}
