# Quick Reference Card

## 📋 Essential Commands

### First Time Setup
```bash
cd terraform
./setup.sh              # Interactive setup wizard
```

### Daily Operations
```bash
# Deploy changes
cd terraform && make apply

# Check what will change
cd terraform && make plan

# View deployment URLs
cd terraform && make output

# Local development
npm run dev

# Build locally
npm run build
```

### Git Workflow
```bash
# Create feature
git checkout -b feature-name

# Push and create PR
git push origin feature-name
# → GitHub Actions runs automatically

# After merge to main
# → Automatically deploys! 🚀
```

## 🔗 Quick Links

| What | Where |
|------|-------|
| **Complete Overview** | [`AWS_DEPLOYMENT_SUMMARY.md`](./AWS_DEPLOYMENT_SUMMARY.md) |
| **Setup Instructions** | [`SETUP_CHECKLIST.md`](./SETUP_CHECKLIST.md) |
| **Get AWS Credentials** | [`AWS_CREDENTIALS_GUIDE.md`](./AWS_CREDENTIALS_GUIDE.md) |
| **Deployment Guide** | [`DEPLOYMENT.md`](./DEPLOYMENT.md) |
| **Terraform Docs** | [`terraform/README.md`](./terraform/README.md) |
| **GitHub Actions** | [`.github/workflows/README.md`](./.github/workflows/README.md) |
| **Architecture** | [`.github/workflows/ARCHITECTURE.md`](./.github/workflows/ARCHITECTURE.md) |

## 🎯 Three Ways to Deploy

### 1️⃣ Automated (Recommended)
- Push to `main` → Auto-deploys
- Requires: GitHub Secrets configured
- Time: Instant

### 2️⃣ Interactive
```bash
cd terraform && ./setup.sh
```

### 3️⃣ Manual
```bash
cd terraform && make apply
```

## 🔐 Required Secrets

Add to: GitHub → Settings → Secrets → Actions

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
TF_GITHUB_TOKEN
```

## 🏗️ What Gets Created

```
✅ AWS Amplify App
✅ IAM Roles & Policies  
✅ CloudFront CDN
✅ SSL Certificate (automatic)
✅ Custom Domain (optional)
✅ Auto-scaling (included)
```

## 💰 Cost

**~$5-20/month** for typical docs site

Includes:
- Hosting
- CDN
- SSL
- Auto-scaling
- First 15GB free

## 🎊 Features

✅ Auto-deploy on push to main
✅ Preview deployments (optional)
✅ Global CDN distribution
✅ Automatic HTTPS
✅ Zero downtime deploys
✅ Infrastructure as Code
✅ Full CI/CD pipeline

## 🆘 Troubleshooting

| Issue | Solution |
|-------|----------|
| Terraform fails | Check AWS credentials: `aws sts get-caller-identity` |
| Build fails | Test locally: `npm run build` |
| GitHub Actions fails | Check secrets are set correctly |
| Domain not working | Wait 24-48h for DNS propagation |

## 📊 Monitoring

- **GitHub Actions**: Repo → Actions tab
- **AWS Amplify**: [AWS Console](https://console.aws.amazon.com/amplify)
- **Build Logs**: Amplify Console → App → Build history

## 🔄 How It Works

```
You push code
     ↓
GitHub Actions validates
     ↓
Terraform updates infrastructure (if needed)
     ↓
AWS Amplify builds & deploys
     ↓
✅ Live on CDN!
```

## 📁 Files Created (18 total)

```
✅ terraform/                   # Infrastructure as Code
✅ .github/workflows/          # CI/CD automation
✅ AWS_DEPLOYMENT_SUMMARY.md   # Complete overview
✅ SETUP_CHECKLIST.md          # Step-by-step guide
✅ DEPLOYMENT.md               # Deployment guide
✅ QUICK_REFERENCE.md          # This file!
```

## ⏱️ Time Estimates

- **Initial setup**: 15-30 minutes
- **Deploy time**: 10-15 minutes
- **Subsequent deploys**: Automatic (push to main)

## 🎓 Need Help?

1. Check the relevant guide above
2. Search AWS Amplify console logs
3. Check GitHub Actions logs
4. Create an issue on GitHub

---

**Everything you need is documented in this repository!** 🚀
