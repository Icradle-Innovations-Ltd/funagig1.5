## FunaGig — Copilot instructions for editing and codegen

This short reference helps AI coding agents be productive in this repo. Keep changes minimal, run local checks, and follow the project's configuration conventions.

- Project types: PHP (XAMPP) backend + vanilla HTML/CSS/JS frontend with a Vite dev server.
- Key folders/files:
  - `php/` — backend: `config.php` (DB, feature flags, CORS), `api.php` (main router)
  - `database/` — `database_unified.sql` (schema + sample data)
  - `js/` — `app.js` (API wrapper, auth, storage), `dashboard.js`, `messaging.js`
  - `dev-server.js` / `package.json` — frontend dev flow using Vite
  - `vite.config.js` — build entries for each HTML page

Quick architecture summary
- Backend: single PHP entry router at `php/api.php`. Routes are matched by path (e.g. `/login`, `/gigs`, `/messages`) and return JSON. Authentication is session/cookie-based (see `php/config.php`).
- Frontend: static HTML pages that call the API via `js/app.js` using fetch with `credentials: 'include'`. API base URL is produced in `js/app.js` (defaults to `http://<BACKEND>/<XAMPP_BASE_PATH>/php/api.php`).

Developer workflows (explicit)
- Local Apache + MySQL + Vite dev:
  1. Start Apache (port 80) and MySQL services via XAMPP Control Panel
  2. Import `database/database_unified.sql` into `funagig` database
  3. Ensure `php/config.php` DB constants match your environment (DB_HOST, DB_USER, DB_PASS, APP_URL)
  4. Start the frontend dev server: preferred helper is `node dev-server.js` (it checks Apache, runs `npm install` if needed and starts Vite). Alternatively `npm run dev` runs Vite directly
  5. Frontend dev server default: http://localhost:3000 (Vite). API endpoints served via Apache at the APP_URL in `php/config.php` (default: `http://localhost/funagig1.5`)

Important conventions & patterns (project-specific)
- API routing: `php/api.php` subtracts the script name from REQUEST_URI then switch-cases on the path string; when adding endpoints, add a case and a handler function in the same file.
- JSON in/out: API expects JSON bodies and responds with JSON; use `file_get_contents('php://input')` + `json_decode`. Return shape uses `sendResponse()` / `sendError()` helpers in `config.php`.
- Session auth: server sets cookie `funagig_session` and frontend sends credentials (see `apiFetch` in `js/app.js`). Never assume JWT—session cookie flows are used.
- CORS: allowed origins are explicitly set in `php/config.php`. If running Vite on port 3000, ensure `http://localhost:3000` is whitelisted.
- Feature flags: `php/config.php` contains toggles like `RATE_LIMIT_ENABLED` (default false). Use toggles rather than removing related code.

Integration points & quick examples
- API endpoints examples (see `php/api.php`): `/login`, `/signup`, `/logout`, `/dashboard`, `/gigs`, `/gigs/active`, `/applications`, `/conversations`, `/messages`.
- Frontend API call example (from `js/app.js`): apiFetch('/profile') will issue a request to `${APP_API_BASE_URL}/profile` with credentials included.
- DB schema: use `database/database_unified.sql` to set up test data (sample users and gigs included).

Security & scanning
- Snyk: repository includes an always-on Snyk rule (`.cursor/rules/snyk_rules.mdc`). For any generated or modified first-party code in supported languages, run the Snyk code scan and fix reported issues: run `snyk code test`/`snyk code scan` per your environment (CI or local). Rescan after fixes.

What to avoid / common pitfalls
- Do not change API paths or request/response shapes without updating `php/api.php` and `js/*` callers.
- When modifying auth/session behavior, update cookie handling in `php/config.php` and `js/app.js` (fetch credentials). Tests and manual checks should validate login/logout flows.
- Avoid committing secrets: `php/config.php` currently holds development credentials—do not promote these to production. If changing DB credentials, prefer local env or documented config.

When you finish a change
- Run the dev flow (start Apache via XAMPP Control Panel, run `node dev-server.js`, exercise endpoints in browser/Postman), and test login/profile flows.
- For Javascript changes: verify Vite dev server reloads and pages still mount (check console for CORS / network errors).
- For PHP changes: enable debug in `php/config.php` (temporarily) to surface errors during development: `error_reporting(E_ALL); ini_set('display_errors', 1);`.

If anything is unclear or you'd like this trimmed/expanded for a particular automation (tests, PR bot), tell me which sections to expand. 
