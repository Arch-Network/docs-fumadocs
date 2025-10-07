# GitHub Actions CI/CD Workflows

This directory contains automated workflows for the Fumadocs project.

## Workflows

### 1. `terraform.yml` - Terraform CI/CD

Manages infrastructure changes with Terraform.

**Triggers:**
- Pull requests modifying `terraform/` directory
- Pushes to `main` branch with terraform changes

**Jobs:**
- **terraform-validate**: Validates and formats Terraform code
- **terraform-plan**: Runs `terraform plan` on PRs and comments results
- **terraform-apply**: Automatically applies changes on merge to `main` (production environment)

**Required Secrets:**
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key
- `TF_GITHUB_TOKEN` - GitHub personal access token for Amplify

**Protection:** Uses GitHub Environments for production approval (optional)

### 2. `lint-and-test.yml` - Code Quality Checks

Ensures code quality before deployment.

**Triggers:**
- Pull requests modifying source code
- Pushes to `main`

**Jobs:**
- **lint**: Runs ESLint on the codebase
- **type-check**: Validates TypeScript types
- **build**: Builds the Next.js application
- **link-check**: Checks for broken links in documentation
- **markdown-lint**: Validates markdown formatting

### 3. `deploy-notification.yml` - Deployment Notifications

Sends notifications about deployment status.

**Triggers:**
- Pushes to `main`
- Completion of Terraform workflow

**Jobs:**
- **notify-success**: Creates deployment notifications
- **notify-failure**: Creates issues and alerts on failure

**Optional Integrations:**
- Slack notifications (uncomment and add webhook)
- Discord notifications (uncomment and add webhook)

## Setup Instructions

### 1. Configure GitHub Secrets

Go to your repository → Settings → Secrets and variables → Actions

Add these secrets:

```
AWS_ACCESS_KEY_ID          # Your AWS access key
AWS_SECRET_ACCESS_KEY      # Your AWS secret key
TF_GITHUB_TOKEN           # GitHub token for Amplify (repo scope)
```

Optional (for notifications):
```
SLACK_WEBHOOK             # Slack webhook URL
DISCORD_WEBHOOK           # Discord webhook URL
```

### 2. Enable GitHub Environments (Optional)

For production protection:

1. Go to Settings → Environments
2. Create `production` environment
3. Add protection rules:
   - ✅ Required reviewers
   - ✅ Wait timer
   - ✅ Branch restrictions (main only)

This prevents auto-apply and requires manual approval.

### 3. Configure Branch Protection

Settings → Branches → Add rule for `main`:

- ✅ Require pull request reviews
- ✅ Require status checks to pass before merging
  - Select: `lint`, `type-check`, `build`, `terraform-validate`
- ✅ Require branches to be up to date

### 4. Enable Dependabot

Dependabot is configured in `.github/dependabot.yml` to:
- Update npm dependencies weekly
- Update GitHub Actions monthly
- Group minor/patch updates

## Workflow Behavior

### On Pull Request

```
1. Code pushed to PR branch
   ↓
2. lint-and-test.yml runs
   - ESLint checks
   - TypeScript type checking
   - Test build
   - Link checking
   ↓
3. terraform.yml runs (if terraform/ changed)
   - Format check
   - Validation
   - Plan generation
   - Comment with plan on PR
   ↓
4. Manual review & approval
```

### On Merge to Main

```
1. PR merged to main
   ↓
2. lint-and-test.yml runs
   - Final validation
   ↓
3. terraform.yml runs (if terraform/ changed)
   - Applies infrastructure changes
   - Updates AWS Amplify config
   ↓
4. deploy-notification.yml runs
   - Sends deployment notification
   ↓
5. AWS Amplify auto-deploys
   - Builds from main branch
   - Deploys to production
   ↓
6. Site is live! 🚀
```

## How AWS Amplify Fits In

**Important:** AWS Amplify has its **own built-in CI/CD** that runs **after** GitHub Actions:

```
GitHub Actions              AWS Amplify
─────────────────          ────────────────
Terraform workflows   →    Amplify detects push
Update infrastructure      Pulls latest code
                    →      Runs npm install
Lint & test          →     Runs npm build
                    →      Deploys to CDN
                    →      Site is live!
```

**Two-stage deployment:**
1. **GitHub Actions**: Validates code, manages infrastructure
2. **AWS Amplify**: Builds and deploys the application

## Customization

### Disable Auto-Apply

To require manual approval for Terraform changes, comment out the `terraform-apply` job:

```yaml
# terraform-apply:
#   name: Terraform Apply
#   ...
```

Then manually apply:
```bash
cd terraform
make apply
```

### Add Slack Notifications

1. Create Slack webhook
2. Add `SLACK_WEBHOOK` secret
3. Uncomment Slack steps in `deploy-notification.yml`

### Add Custom Tests

Add to `lint-and-test.yml`:

```yaml
- name: Run custom tests
  run: npm test
```

### Change Node.js Version

Update in all workflows:

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '20'  # Change this
```

## Monitoring

### View Workflow Runs

Repository → Actions tab

### View Terraform Plans

Pull request comments show Terraform plans automatically

### View Amplify Builds

AWS Console → Amplify → Your App → Build History

### View Deployment Status

Check:
- GitHub Actions status badges
- AWS Amplify console
- CloudWatch logs

## Troubleshooting

### Terraform Plan Fails

- Check AWS credentials are valid
- Verify `TF_GITHUB_TOKEN` has correct permissions
- Run locally: `cd terraform && make plan`

### Build Fails

- Check Node.js version matches
- Run locally: `npm ci && npm run build`
- Check environment variables

### Amplify Build Fails

- Check build logs in Amplify console
- Verify build spec in `terraform/main.tf`
- Test locally: `npm run build`

### Secrets Not Working

- Secrets are case-sensitive
- Re-create the secret if it's not working
- Check secret names match exactly

## Cost Considerations

**GitHub Actions:**
- 2,000 minutes/month free (public repos)
- 3,000 minutes/month (private repos with Pro)

**Typical usage:**
- ~5 minutes per PR
- ~3 minutes per merge
- ~$0 for most use cases

## Security Best Practices

1. ✅ Use GitHub Secrets for sensitive data
2. ✅ Limit AWS IAM permissions (least privilege)
3. ✅ Enable branch protection rules
4. ✅ Require code review before merge
5. ✅ Use environment protection rules
6. ✅ Rotate secrets regularly
7. ✅ Enable Dependabot security updates

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS Amplify CI/CD](https://docs.aws.amazon.com/amplify/latest/userguide/welcome.html)
- [Terraform GitHub Actions](https://developer.hashicorp.com/terraform/tutorials/automation/github-actions)
