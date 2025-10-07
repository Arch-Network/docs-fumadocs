# Terraform AWS Amplify Deployment

This directory contains Terraform configuration for deploying the Fumadocs site to AWS Amplify.

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** configured with credentials
3. **Terraform** installed (v1.0+)
4. **GitHub Personal Access Token** with `repo` scope

## Setup Instructions

### 1. Install Required Tools

```bash
# Install Terraform (macOS)
brew install terraform

# Install AWS CLI (if not already installed)
brew install awscli

# Configure AWS CLI with your credentials
aws configure
```

### 2. Create GitHub Personal Access Token

1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Select scopes:
   - ✅ `repo` (Full control of private repositories)
4. Generate token and save it securely

### 3. Configure Terraform Variables

```bash
# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
# IMPORTANT: Never commit terraform.tfvars to git!
```

Edit `terraform.tfvars`:

```hcl
github_repository    = "https://github.com/YOUR_USERNAME/docs-fumadocs"
github_access_token  = "ghp_your_github_token_here"
site_url            = "https://docs.arch.network"

# Optional: Add custom domain
custom_domain = "docs.arch.network"
domain_prefix = ""  # Leave empty for root domain, or use "www"
```

### 4. Initialize Terraform

```bash
cd terraform
terraform init
```

### 5. Review the Plan

```bash
terraform plan
```

This will show you what resources Terraform will create.

### 6. Deploy to AWS

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### 7. Get Deployment URLs

```bash
terraform output
```

You'll see:
- **amplify_app_url**: Your Amplify default URL
- **custom_domain_url**: Your custom domain (if configured)

## Custom Domain Setup

If you configured a custom domain:

1. Terraform will output DNS validation records
2. Add these records to your DNS provider (Route53, Cloudflare, etc.)
3. Wait for DNS propagation (can take 5-48 hours)
4. Amplify will automatically provision an SSL certificate

### Using AWS Route53

If your domain is managed by Route53, you can automate this. Add to `main.tf`:

```hcl
# Get the hosted zone
data "aws_route53_zone" "main" {
  name = var.custom_domain
}

# Create DNS validation records
resource "aws_route53_record" "amplify_validation" {
  for_each = {
    for dvo in aws_amplify_domain_association.main[0].certificate_verification_dns_record : dvo.name => {
      name   = dvo.name
      record = dvo.value
      type   = dvo.type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}
```

## Environment Variables

To add environment variables to your build:

Edit `terraform.tfvars`:

```hcl
additional_environment_variables = {
  NEXT_PUBLIC_API_URL = "https://api.example.com"
  SOME_OTHER_VAR      = "value"
}
```

## Auto Branch Creation

Enable preview deployments for pull requests:

```hcl
enable_auto_branch_creation   = true
auto_branch_creation_patterns = ["feature/*", "fix/*", "pr-*"]
```

This will automatically create Amplify branches and deploy previews for matching branch names.

## Remote State (Recommended for Teams)

For production use, store Terraform state in S3:

1. Create an S3 bucket for state:

```bash
aws s3 mb s3://your-terraform-state-bucket
```

2. Create a DynamoDB table for locking:

```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

3. Uncomment the backend configuration in `main.tf`:

```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "fumadocs/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-state-lock"
}
```

4. Run `terraform init -migrate-state`

## Managing Multiple Environments

To deploy to multiple environments (staging, production):

```bash
# Create workspace for staging
terraform workspace new staging
terraform apply -var-file=staging.tfvars

# Switch to production
terraform workspace new production
terraform apply -var-file=production.tfvars
```

## Common Commands

```bash
# Check current state
terraform show

# View outputs
terraform output

# Update infrastructure
terraform apply

# Destroy infrastructure (careful!)
terraform destroy

# Format Terraform files
terraform fmt

# Validate configuration
terraform validate
```

## Troubleshooting

### Build Failures

1. Check build logs in AWS Amplify Console
2. Verify environment variables are set correctly
3. Ensure `package.json` scripts are correct

### Domain Verification Issues

- DNS propagation can take up to 48 hours
- Verify DNS records are correct with: `dig docs.arch.network`
- Check Amplify console for validation status

### Authentication Errors

- Ensure AWS CLI is configured: `aws sts get-caller-identity`
- Verify GitHub token has correct permissions
- Check token hasn't expired

## Cost Estimation

**AWS Amplify Pricing:**
- Build minutes: ~$0.01 per minute
- Hosting: ~$0.15/GB stored + $0.15/GB served
- Requests: First 15GB free per month

**Estimated Monthly Cost:**
- ~$5-20 for typical documentation site
- Much cheaper than ECS (~$50-100+)

## Security Best Practices

1. ✅ Never commit `terraform.tfvars` to git
2. ✅ Use AWS Secrets Manager for sensitive values (advanced)
3. ✅ Enable MFA on your AWS account
4. ✅ Use least-privilege IAM policies
5. ✅ Enable Terraform state encryption
6. ✅ Regularly rotate GitHub tokens

## CI/CD Integration

GitHub Actions workflows are pre-configured in `.github/workflows/`:

1. **`terraform.yml`**: Automatically validates Terraform on PRs and applies on merge to main
2. **`lint-and-test.yml`**: Runs linting, type checking, and builds
3. **`deploy-notification.yml`**: Sends deployment notifications

### Setup GitHub Actions

1. Add secrets to your GitHub repository (Settings → Secrets):
   ```
   AWS_ACCESS_KEY_ID
   AWS_SECRET_ACCESS_KEY
   TF_GITHUB_TOKEN (GitHub PAT for Amplify)
   ```

2. Enable workflows in `.github/workflows/`

3. (Optional) Configure production environment protection

See [`.github/workflows/README.md`](../.github/workflows/README.md) for detailed instructions.

## Next Steps

1. ✅ Set up CI/CD (already configured! See `.github/workflows/`)
2. Configure branch protection rules
3. Set up monitoring and alerts
4. Enable AWS CloudWatch logs
5. Configure backup/disaster recovery

## Resources

- [AWS Amplify Terraform Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_app)
- [Next.js on Amplify](https://docs.aws.amazon.com/amplify/latest/userguide/deploy-nextjs-app.html)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
