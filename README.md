# RGBDRIVE (`rgbdrive.com`)

**RGBDRIVE** is a product catalog and technical reference archive for custom and legacy solid-state LED driver hardware solutions, supporting DMX512-A, DALI (IEC 62386-102 / 207), and 0-10V DC dimming protocols.

---

## 📁 Repository Structure

```text
rgbdrive/
├── README.md             # Project overview & repository quick reference
├── DEV-DOCS.md           # [Private / Gitea dev branch] Architecture, DNS, SMTP & operations manual
├── publish-live.ps1      # PowerShell deployer: syncs site to 'main' for GitHub Pages
├── .gitignore            # Git ignore definitions
└── docs/                 # Website source root (served by GitHub Pages)
    ├── CNAME             # Custom domain binding (rgbdrive.com)
    ├── index.html        # Homepage (overview, protocol tables, format specs)
    ├── products.html     # Product catalog with technical specifications & pinouts
    ├── projects.html     # Bespoke hardware & load tester projects
    ├── styles.css        # Global styles, responsive layouts, table rules
    ├── images/           # Product photography, system diagrams, and branding
    └── datasheets/       # Technical reference documentation & spec PDFs
```

---

## 🚀 Quick Start & Local Preview

Because this is a pure static HTML5/CSS3 website, no compilation or build tools are required.

To preview locally:
1. Open a terminal in the project directory.
2. Serve the `docs/` folder using Python or Node:
   ```bash
   # Python 3
   python -m http.server --directory docs 8000
   ```
   Or using `npx serve`:
   ```bash
   npx serve docs
   ```
3. Open `http://localhost:8000` in your web browser.

---

## 🌐 Hosting & Infrastructure

| Layer | Service | Details |
| :--- | :--- | :--- |
| **Production Hosting** | **GitHub Pages** | Serves static site directly from the `docs/` directory of the `main` branch. |
| **CDN & DNS** | **Cloudflare** | Authoritative DNS, SSL/TLS termination (Strict HTTPS), CDN caching, DDoS protection. |
| **Domain** | **Cloudflare Registrar** | Custom domain `rgbdrive.com`. |
| **Email Routing** | **Cloudflare Email Routing** | Inbound addresses (`info@`, `hello@`, `contact@`) forwarded to Gmail. |
| **Outbound SMTP** | **Mailjet SMTP** | Relays outbound emails originating from Gmail with SPF, DKIM, and DMARC verification. |
| **Internal Git** | **Local Gitea** | Canonical self-hosted development repository (`origin/dev`). |

For full infrastructure runbooks, DNS records, SMTP credentials, and emergency rollback procedures, see [`DEV-DOCS.md`](file:///DEV-DOCS.md) (on the internal `dev` branch).

---

## 🚢 Deployment Workflow

The project uses a two-branch workflow:
* **`dev`**: Daily development branch on your private Gitea server.
* **`main`**: Production deployment branch on GitHub (`live`) and Gitea (`origin`).

When ready to publish updates to [rgbdrive.com](https://rgbdrive.com):
```powershell
powershell -ExecutionPolicy Bypass -File .\publish-live.ps1 -Message "Deploy update description"
```

