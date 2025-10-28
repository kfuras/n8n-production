# Production n8n Stack with Self-Hosted AI Tools

> **Real production infrastructure** running my AI automation workflows.  
> GitOps deployment with encrypted secrets - safe for public repos.

[![Deploy](https://github.com/kjetilfuras/n8n-production-stack/actions/workflows/deploy.yml/badge.svg)](https://github.com/kjetilfuras/n8n-production-stack/actions)

## 🏗️ Architecture
```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Traefik    │────▶│     n8n      │────▶│  PostgreSQL  │
│  (Reverse    │     │  (Workflows) │     │  (Database)  │
│   Proxy)     │     └──────────────┘     └──────────────┘
└──────────────┘            │
       │                    ├────▶ Kokoro TTS (Self-hosted)
       │                    ├────▶ MinIO (S3-compatible)
       │                    ├────▶ NCA Toolkit (Video processing)
       │                    └────▶ Baserow (Airtable alternative)
       │
    HTTPS (Let's Encrypt)
```

## 💰 Cost Comparison

| Service | SaaS Monthly Cost | Self-Hosted | Savings |
|---------|------------------|-------------|---------|
| **TTS** (ElevenLabs/OpenAI) | $22-330 | $0 (Kokoro) | $22-330 |
| **Storage** (AWS S3) | $23+ | $0 (MinIO) | $23+ |
| **Database** (Airtable) | $20+ | $0 (Baserow) | $20+ |
| **Automation** (Zapier) | $20-600 | $0 (n8n) | $20-600 |
| **Total** | **$85-973/mo** | **€20/mo** | **$65-953/mo** |

*Running on a single Hetzner VPS (CPX21): €20/month*

## 🚀 Tech Stack

- **[n8n](https://n8n.io)** - Workflow automation (self-hosted Zapier alternative)
- **[Traefik v3](https://traefik.io)** - Reverse proxy with automatic HTTPS
- **[PostgreSQL 16](https://www.postgresql.org)** - Database
- **[MinIO](https://min.io)** - S3-compatible object storage
- **[Kokoro TTS](https://github.com/remsky/kokoro-fastapi)** - Self-hosted text-to-speech
- **[NCA Toolkit](https://github.com/No-Code-Architects)** - FFmpeg-based video processing
- **[Baserow](https://baserow.io)** - Self-hosted database UI
- **[SOPS](https://github.com/mozilla/sops)** - Secret encryption with age

## 🔐 Security Features

- **GitOps**: Infrastructure as Code with full git history
- **Encrypted Secrets**: SOPS encryption (safe for public repos)
- **Automated Deployments**: GitHub Actions CI/CD pipeline
- **Zero-Trust Networking**: Traefik with TLS, IP whitelisting
- **Layered Firewall**: Hetzner Cloud Firewall + UFW + Docker networks
- **Secret Rotation**: Change secrets via git, auto-deploys

## 📖 What I Use This For

This is my **actual production environment**, not a demo:

- 🎥 Automated video content creation for YouTube
- 🤖 AI-powered Telegram assistant
- 📧 Email and calendar automation
- 📊 Data processing workflows
- 🎙️ Text-to-speech generation (300+ requests/day)

## 🎓 Learn From This Repo

### Key Concepts Demonstrated

1. **[Secrets in Public Repos](docs/sops-encryption.md)** - How to safely encrypt secrets with SOPS
2. **[GitOps Deployment](docs/gitops-workflow.md)** - Push to GitHub → Auto-deploy to production
3. **[Self-Hosted vs Cloud](docs/cost-analysis.md)** - Real cost comparison with usage data
4. **[Production Docker](docs/docker-networking.md)** - Networking, security, and best practices

## ⚡ Quick Start

### Prerequisites

- Ubuntu/Debian server
- Docker & Docker Compose installed
- Domain with DNS pointing to your server

### Deploy
```bash
# Clone repo
git clone https://github.com/kfuras/n8n-production.git -o n8n-stack
cd n8n-stack

# Install SOPS
wget https://github.com/mozilla/sops/releases/latest/download/sops-linux-amd64
sudo mv sops-linux-amd64 /usr/local/bin/sops
sudo chmod +x /usr/local/bin/sops

# Create your secrets (copy example and edit)
cp secrets/production.env.example secrets/production.env
nano secrets/production.env

# Generate age key for encryption
age-keygen -o ~/.config/sops/age/keys.txt

# Update .sops.yaml with your public key
nano .sops.yaml

# Encrypt your secrets
sops --encrypt --input-type binary secrets/production.env > secrets/production.env.enc
rm secrets/production.env

# Deploy
docker compose up -d
```

## 🔄 GitOps Workflow

### Change Secrets
```bash
# Edit encrypted secrets (auto-decrypts, then re-encrypts)
sops --input-type binary --output-type binary secrets/production.env.enc

# Commit and push
git add secrets/production.env.enc
git commit -m "rotate: Update MinIO password"
git push  # Automatically deploys to production!
```

### Change Infrastructure
```bash
# Edit docker-compose.yml
nano docker-compose.yml

# Deploy
git add docker-compose.yml
git commit -m "feat: Add Redis service"
git push  # Automatically deploys!
```

### Rollback
```bash
git log --oneline
git revert abc123
git push  # Automatically rolls back!
```

## 📊 Monitoring & Logs
```bash
# View all services
docker compose ps

# Stream logs
docker compose logs -f n8n-core

# Deployment history
tail -f deploy.log
```

## 📝 License

MIT - Feel free to use this as a template for your own infrastructure!

## 🔗 Links

- **Blog**: [kjetilfuras.com](https://kjetilfuras.com)
- **LinkedIn**: [Kjetil Furås](https://www.linkedin.com/in/kjetil-furas/)

---

**Built with ❤️ by [Kjetil Furås](https://kjetilfuras.com)**

*Questions? Open an issue or reach out on LinkedIn!*
###
Test Deployment
###