// Global navigation bar for FunaGig
// Injects a consistent nav UI with back/forward and quick links

(function() {
	function createNavButton(label, onClick, className) {
		const btn = document.createElement('button');
		btn.textContent = label;
		btn.className = className || 'btn';
		btn.addEventListener('click', function(e) {
			e.preventDefault();
			onClick();
		});
		return btn;
	}

	function resolveDashboardHref(user) {
		if (!user) return 'auth.html';
		return user.type === 'business' ? 'business-dashboard.html' : 'student-dashboard.html';
	}

	function resolveProfileHref(user) {
		if (!user) return 'auth.html';
		return user.type === 'business' ? 'business-profile.html' : 'student-profile.html';
	}

	function renderGlobalNav() {
		// Avoid duplicate renders
		if (document.getElementById('global-nav-bar')) return;

		const container = document.createElement('div');
		container.id = 'global-nav-bar';
		container.style.cssText = [
			'position: sticky',
			'top: 0',
			'width: 100%',
			'background: #ffffffcc',
			'backdrop-filter: blur(6px)',
			'border-bottom: 1px solid #e5e7eb',
			'padding: 8px 12px',
			'display: flex',
			'align-items: center',
			'justify-content: space-between',
			'z-index: 1000'
		].join(';');

		const left = document.createElement('div');
		left.style.display = 'flex';
		left.style.gap = '8px';

		const right = document.createElement('div');
		right.style.display = 'flex';
		right.style.gap = '8px';

		// Back/Forward
		left.appendChild(createNavButton('← Back', () => history.back(), 'btn secondary'));
		left.appendChild(createNavButton('Forward →', () => history.forward(), 'btn secondary'));

		// Context-aware links
		const user = (typeof Auth !== 'undefined') ? Auth.getUser() : null;
		const dashboardLink = document.createElement('a');
		dashboardLink.href = resolveDashboardHref(user);
		dashboardLink.className = 'btn';
		dashboardLink.textContent = 'Dashboard';

		const notificationsLink = document.createElement('a');
		notificationsLink.href = 'notifications.html';
		notificationsLink.className = 'btn secondary';
		notificationsLink.textContent = 'Notifications';

		const profileLink = document.createElement('a');
		profileLink.href = resolveProfileHref(user);
		profileLink.className = 'btn secondary';
		profileLink.textContent = 'Profile';

		right.appendChild(dashboardLink);
		right.appendChild(notificationsLink);
		right.appendChild(profileLink);

		// Logout (if available)
		if (typeof Auth !== 'undefined') {
			const logoutBtn = createNavButton('Logout', () => Auth.logout(), 'btn danger');
			right.appendChild(logoutBtn);
		}

		container.appendChild(left);
		container.appendChild(right);

		// Insert after any existing header.navbar if present, else at top of body
		const header = document.querySelector('header.navbar');
		if (header && header.parentNode) {
			header.parentNode.insertBefore(container, header.nextSibling);
		} else if (document.body.firstChild) {
			document.body.insertBefore(container, document.body.firstChild);
		} else {
			document.body.appendChild(container);
		}

		// Highlight active link
		[dashboardLink, notificationsLink, profileLink].forEach(a => {
			if (!a) return;
			if (location.pathname.endsWith(a.getAttribute('href'))) {
				a.classList.add('active');
			}
		});
	}

	document.addEventListener('DOMContentLoaded', renderGlobalNav);
})();


