# My Hugo Site

A self-hosted Carrd-style homepage with photo feed and microblog using Hugo Theme Stack and Tina CMS.

## Setup on Ubuntu Linux

### Quick One-Step Install (Recommended)
Run this single command to clone, install everything, and start the server:
```
curl -s https://raw.githubusercontent.com/nmemmert/hugo-tina/master/one-step-install.sh | bash
```
This will set up the site in a `hugo-site` directory and start Tina CMS.

### Quick One-Step Uninstall
To remove everything (project, dependencies, and running processes):
```
curl -s https://raw.githubusercontent.com/nmemmert/hugo-tina/master/uninstall.sh | bash
```

### Manual Setup
1. **Install Dependencies**:
   - Hugo: `sudo snap install hugo`
   - Node.js: `sudo apt install nodejs npm`

2. **Clone and Install**:
   - `git clone https://github.com/nmemmert/hugo-tina.git`
   - `cd hugo-tina`
   - `npm install`

3. **Run Locally**:
   - Development with Tina GUI: `npm run dev` (opens at http://localhost:4001/admin)
   - Preview site: http://localhost:1313
   - Build for production: `npm run build` then `npm run start`

## Editing the Site

**Use the Tina CMS GUI** (recommended):
- Visit http://localhost:4001/admin after running `npm run dev`.
- Edit content sections (About, Notes, Photos, Posts) with a visual editor.
- Drag and drop images—uploads save to `static/img/`.
- Changes save to Markdown files in `content/` automatically.

**Manual Editing** (if needed):
- Edit `.md` files in `content/` for text.
- Add images to `static/img/`.
- Run `hugo server` to preview without Tina.

## Content Sections

- **About**: Bio and info page.
- **Notes**: Quick microblog posts.
- **Photos**: Image gallery with captions.
- **Posts**: Longer blog articles.

## Deployment

- **Production**: Build with `npm run build`, serve `public/` via Nginx or any static host.
- **Tina Cloud**: For remote auth/uploads, configure `clientId` and `token` in `.tina/config.ts`.