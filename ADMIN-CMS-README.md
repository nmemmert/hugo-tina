Decap (Netlify) CMS setup

This branch contains a minimal Decap (Netlify) CMS configuration using Netlify Identity + Git Gateway.

How to enable locally / on Netlify:

1. Host on Netlify and enable Identity in the Netlify dashboard.
2. Under Identity > Services enable Git Gateway (or use GitHub app if you prefer).
3. Configure Identity settings and invite users.
4. The CMS is available at `/admin` and reads configuration from `static/admin/config.yml`.

Notes:
- `media_folder` is `static/img` and `public_folder` is `/img` to match the site's static images.
- Collections scaffolded: `posts` (content/posts), `pages` (content/pages), `photos` (content/photos).

Quick local verification (after running the installer):
- Confirm Hugo binary:
  - hugo version
- Confirm Hugo service is running:
  - sudo systemctl status hugo
- Confirm Hugo responds locally:
  - curl -I http://127.0.0.1:1313/  (should return 200)
- Confirm Decap admin UI (if `static/admin` exists):
  - curl -sS http://127.0.0.1:1313/admin/ | grep -i "netlify-cms\|Netlify CMS"

If you want GitHub App backend instead, I can update `static/admin/config.yml` to use `backend: name: github` and repo details.