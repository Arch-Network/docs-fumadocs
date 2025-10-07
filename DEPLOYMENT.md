# AWS Amplify Deployment Guide

This project is set up to deploy to AWS Amplify using Terraform for infrastructure as code.

> 🚀 **First time?** Follow the [SETUP_CHECKLIST.md](./SETUP_CHECKLIST.md) for step-by-step instructions.

## Architecture Overview

```
Developer → GitHub → GitHub Actions → Terraform → AWS Amplify → Users
                          ↓              ↓            ↓
                     Validation    Infrastructure   Build & Deploy
                     Testing       as Code          to CloudFront CDN
```

## Quick Start

### Option 1: Interactive Setup (Easiest)

```bash
cd terraform
./setup.sh
```

Follow the prompts to configure and deploy.

### Option 2: Manual Setup

1. **Install prerequisites:**
   ```bash
   brew install terraform awscli
   aws configure
   ```

2. **Create GitHub Personal Access Token:**
   - Go to https://github.com/settings/tokens
   - Generate token with `repo` scope
   - Save it securely

3. **Configure Terraform:**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

4. **Deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

5. **Get your URLs:**
   ```bash
   terraform output
   ```

## What Gets Deployed

- **AWS Amplify App** with Next.js SSR support
- **Automatic builds** from your GitHub repository
- **CDN distribution** for fast global delivery
- **SSL certificate** (automatic, free)
- **Custom domain support** (optional)
- **Branch previews** (optional)

## Cost

**Estimated monthly cost: $5-20**

- Build minutes: ~$0.01/minute
- Hosting: ~$0.15/GB
- First 15GB/month free

Much cheaper than ECS/EKS ($50-100+/month).

## Architecture

```
GitHub Repo → AWS Amplify → CloudFront CDN → Users
                ↓
           Auto Build/Deploy
```

AWS Amplify automatically:
- Pulls code from GitHub on push
- Installs dependencies
- Builds Next.js app
- Deploys to CDN
- Provides preview URLs

## Custom Domain Setup

1. Add domain in `terraform.tfvars`:
   ```hcl
   custom_domain = "docs.arch.network"
   ```

2. Apply Terraform:
   ```bash
   terraform apply
   ```

3. Add DNS records:
   - Go to AWS Amplify Console
   - Copy the DNS validation records
   - Add them to your DNS provider
   - Wait for validation (5 minutes - 48 hours)

## Environment Variables

Add in `terraform.tfvars`:

```hcl
additional_environment_variables = {
  NEXT_PUBLIC_API_URL = "https://api.example.com"
  OTHER_VAR           = "value"
}
```

## Preview Deployments

Enable automatic preview deployments for PRs:

```hcl
enable_auto_branch_creation   = true
auto_branch_creation_patterns = ["feature/*", "fix/*"]
```

Each PR will get its own preview URL.

## Monitoring

- **Build logs:** AWS Amplify Console → App → Builds
- **Metrics:** AWS Amplify Console → App → Metrics
- **CloudWatch:** For detailed logs and monitoring

## Troubleshooting

### Build fails
1. Check build logs in Amplify Console
2. Test build locally: `npm run build`
3. Check environment variables

### DNS issues
- DNS can take up to 48 hours to propagate
- Check with: `dig docs.arch.network`
- Verify records in DNS provider

### Authentication issues
- Check AWS credentials: `aws sts get-caller-identity`
- Verify GitHub token hasn't expired

## Updating the Deployment

Changes to your code automatically trigger builds when pushed to GitHub.

To update infrastructure:

```bash
cd terraform
terraform plan
terraform apply
```

## Destroying Infrastructure

To completely remove all AWS resources:

```bash
cd terraform
terraform destroy
```

⚠️ **Warning:** This is permanent and will delete everything!

## CI/CD Integration

GitHub Actions workflows are **already configured** in `.github/workflows/`:

### 1. Terraform CI/CD (`terraform.yml`)
- ✅ Validates Terraform on PRs
- ✅ Runs `terraform plan` and comments on PRs
- ✅ Auto-applies infrastructure changes on merge to `main`
- ✅ Uses GitHub Environments for production protection

### 2. Lint & Test (`lint-and-test.yml`)
- ✅ Runs ESLint
- ✅ TypeScript type checking
- ✅ Builds Next.js app
- ✅ Checks for broken links
- ✅ Validates markdown

### 3. Deploy Notifications (`deploy-notification.yml`)
- ✅ Notifies on deployment success
- ✅ Creates issues on failure
- ⚙️ Optional Slack/Discord webhooks

### Setup

Add these secrets to your GitHub repository (Settings → Secrets → Actions):

```
AWS_ACCESS_KEY_ID          # Your AWS access key
AWS_SECRET_ACCESS_KEY      # Your AWS secret key  
TF_GITHUB_TOKEN           # GitHub PAT with 'repo' scope
```

**That's it!** Workflows will run automatically on PRs and merges.

For detailed configuration, see [`.github/workflows/README.md`](./.github/workflows/README.md)

## Comparison with Other Options

| Solution | Cost/Month | Setup Time | Maintenance | Best For |
|----------|-----------|------------|-------------|----------|
| **AWS Amplify** | $5-20 | 15 min | Low | Next.js apps |
| Vercel | $20-150 | 5 min | None | Quick deploys |
| S3 + CloudFront | $1-5 | 30 min | Low | Static only |
| ECS Fargate | $50-100 | 2-4 hours | Medium | Complex apps |
| EKS | $100-300 | 4-8 hours | High | Microservices |

## Support

For detailed information, see [`terraform/README.md`](./terraform/README.md)

## Next Steps

After deployment:
1. ✅ Monitor first build in Amplify Console
2. ✅ Test the deployment URL
3. ✅ Configure custom domain (optional)
4. ✅ Set up monitoring alerts
5. ✅ Enable preview deployments (optional)
6. ✅ Add CI/CD for Terraform (optional)
