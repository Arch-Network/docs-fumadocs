# AWS Amplify + GitHub Actions Setup Checklist

Complete this checklist to get your automated deployment pipeline running.

## ✅ Prerequisites

- [ ] **AWS Account** created and active
- [ ] **AWS CLI** installed (`brew install awscli`)
- [ ] **Terraform** installed (`brew install terraform`)
- [ ] **GitHub repository** created
- [ ] **Admin access** to GitHub repository

## ✅ Step 1: Configure AWS Credentials

> 📘 **Don't have AWS credentials yet?** See [`AWS_CREDENTIALS_GUIDE.md`](./AWS_CREDENTIALS_GUIDE.md) for detailed instructions on getting your AWS Access Keys.

```bash
# Configure AWS CLI
aws configure

# You'll be prompted for:
# - AWS Access Key ID
# - AWS Secret Access Key  
# - Default region (use: us-east-1)
# - Output format (use: json)

# Test credentials
aws sts get-caller-identity
```

**Expected output:** Your AWS account details

## ✅ Step 2: Create GitHub Personal Access Token

1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Name: `Amplify Terraform Access`
4. Select scopes:
   - ✅ `repo` (Full control of private repositories)
5. Click "Generate token"
6. **Save the token securely!** You won't see it again.

## ✅ Step 3: Add GitHub Secrets

Go to: `https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions`

Add these secrets:

| Secret Name | Value | How to Get |
|-------------|-------|------------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key | From AWS Console → IAM → Users → Security credentials |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key | Same as above |
| `TF_GITHUB_TOKEN` | GitHub token from Step 2 | The token you just created |

### How to Add Secrets:
1. Click "New repository secret"
2. Enter name (exactly as shown above)
3. Paste value
4. Click "Add secret"

## ✅ Step 4: Configure Terraform Variables

```bash
cd terraform

# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars  # or use your favorite editor
```

**Required values:**
```hcl
github_repository    = "https://github.com/YOUR_USERNAME/YOUR_REPO"
github_access_token  = "ghp_your_token_here"
site_url            = "https://docs.arch.network"  # or your URL
```

**Optional:**
```hcl
custom_domain = "docs.arch.network"  # if you have a custom domain
```

## ✅ Step 5: Deploy Infrastructure

### Option A: Interactive (Recommended for first time)

```bash
cd terraform
./setup.sh
```

Follow the prompts!

### Option B: Manual

```bash
cd terraform
make init
make plan    # Review what will be created
make apply   # Deploy!
```

**Wait for completion** (2-3 minutes)

## ✅ Step 6: Verify Deployment

```bash
# Get deployment URLs
cd terraform
terraform output
```

Visit the URL shown! You should see a blank Amplify page (no build yet).

## ✅ Step 7: Trigger First Build

### Option A: Push to main

```bash
git add .
git commit -m "Configure AWS Amplify deployment"
git push origin main
```

### Option B: Trigger in AWS Console

1. Go to: https://console.aws.amazon.com/amplify
2. Find your app
3. Click "Run build"

**Wait for build** (5-8 minutes for first build)

## ✅ Step 8: Verify GitHub Actions

1. Go to: `https://github.com/YOUR_USERNAME/YOUR_REPO/actions`
2. You should see workflows running
3. Wait for all checks to pass (✅)

## ✅ Step 9: Access Your Live Site!

After build completes:
- **Amplify URL:** Check output from Step 6
- **Custom domain:** Configure DNS (see below)

## 🌐 Optional: Custom Domain Setup

If you added a custom domain in Step 4:

### Using Route53 (AWS)

Amplify will automatically configure Route53 if your domain is there.

### Using Other DNS Providers (Cloudflare, Namecheap, etc.)

1. Go to AWS Amplify Console
2. Select your app → Domain management
3. Copy the DNS records shown
4. Add them to your DNS provider:
   - Type: CNAME
   - Name: `docs` (or leave empty for root)
   - Value: (from Amplify console)
5. Wait for DNS propagation (5 mins - 48 hours)

## ✅ Step 10: Configure Branch Protection (Recommended)

Protect your `main` branch:

1. Go to: `https://github.com/YOUR_USERNAME/YOUR_REPO/settings/branches`
2. Click "Add rule"
3. Branch name pattern: `main`
4. Enable:
   - ✅ Require pull request reviews before merging
   - ✅ Require status checks to pass before merging
     - Select: `lint`, `type-check`, `build`, `terraform-validate`
   - ✅ Require branches to be up to date before merging
5. Click "Create"

## ✅ Step 11: Test the Pipeline

Create a test PR:

```bash
# Create feature branch
git checkout -b test-deployment

# Make a small change
echo "# Test" >> content/docs/test.mdx

# Commit and push
git add .
git commit -m "Test deployment pipeline"
git push origin test-deployment
```

**Expected behavior:**
1. GitHub Actions runs automatically
2. You see status checks on the PR
3. Terraform validates (if terraform files changed)
4. All checks pass ✅

Merge the PR:
1. Click "Merge pull request"
2. Wait for GitHub Actions to run
3. Amplify automatically builds and deploys
4. Your change is live! 🚀

## 🎉 Success Checklist

You're fully set up when:

- [ ] ✅ Infrastructure deployed via Terraform
- [ ] ✅ GitHub Actions workflows passing
- [ ] ✅ First Amplify build completed
- [ ] ✅ Site accessible via URL
- [ ] ✅ Test PR successfully merged
- [ ] ✅ Branch protection configured
- [ ] ✅ (Optional) Custom domain working

## 🔧 Troubleshooting

### Terraform fails with "Access Denied"
- Check AWS credentials: `aws sts get-caller-identity`
- Verify IAM permissions include Amplify

### GitHub Actions fails with "Invalid token"
- Regenerate GitHub token
- Update `TF_GITHUB_TOKEN` secret
- Re-run workflow

### Amplify build fails
- Check build logs in Amplify Console
- Verify `package.json` scripts
- Test locally: `npm ci && npm run build`

### Custom domain not working
- Verify DNS records are correct
- Wait longer (DNS can take 48 hours)
- Check validation status in Amplify Console

## 📚 Next Steps

Now that you're deployed:

1. **Enable monitoring:**
   - AWS CloudWatch alarms
   - Amplify build notifications

2. **Optional integrations:**
   - Slack notifications (`.github/workflows/deploy-notification.yml`)
   - Discord webhooks
   - Status page integration

3. **Security hardening:**
   - Enable MFA on AWS account
   - Rotate credentials regularly
   - Set up AWS CloudTrail logging

4. **Performance optimization:**
   - Configure caching headers
   - Enable image optimization
   - Set up performance monitoring

## 📞 Getting Help

- **Terraform Issues:** See `terraform/README.md`
- **GitHub Actions:** See `.github/workflows/README.md`
- **AWS Amplify:** Check AWS Console build logs
- **General Setup:** See `DEPLOYMENT.md`

## 🎯 Quick Commands Reference

```bash
# Terraform
cd terraform
make init     # Initialize
make plan     # Preview changes
make apply    # Deploy
make output   # Show URLs

# Local development
npm run dev   # Start dev server
npm run build # Test build
npm run lint  # Run linter

# Git workflow
git checkout -b feature-name
git add .
git commit -m "Description"
git push origin feature-name
# Create PR on GitHub
# Merge after approval
```

---

**Estimated Setup Time:** 15-30 minutes (excluding DNS propagation)

**Total Cost:** ~$5-20/month for typical documentation site

**Support:** Open an issue on GitHub if you get stuck!
