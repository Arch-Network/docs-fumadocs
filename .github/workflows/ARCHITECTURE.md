# CI/CD Architecture

## Complete Deployment Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     Developer Workflow                           │
└─────────────────────────────────────────────────────────────────┘

Developer pushes code to feature branch
              ↓
        Creates Pull Request
              ↓
┌─────────────────────────────────────────────────────────────────┐
│                  GitHub Actions (PR Checks)                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   ESLint     │  │ TypeScript   │  │    Build     │          │
│  │   Check      │  │ Type Check   │  │   Next.js    │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│         ↓                 ↓                  ↓                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Markdown   │  │    Link      │  │  Terraform   │          │
│  │   Lint       │  │   Check      │  │  Validate    │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                              ↓                   │
│                                    ┌──────────────────┐         │
│                                    │  Terraform Plan  │         │
│                                    │  (Post comment)  │         │
│                                    └──────────────────┘         │
│                                                                   │
│  ✅ All checks pass → Ready for review                          │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
              ↓
        Code Review & Approval
              ↓
        Merge to main branch
              ↓
┌─────────────────────────────────────────────────────────────────┐
│              GitHub Actions (Main Branch)                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────┐               │
│  │         Re-run all validation checks          │               │
│  └──────────────────────────────────────────────┘               │
│                      ↓                                           │
│  ┌──────────────────────────────────────────────┐               │
│  │  Terraform Apply (if infrastructure changed)  │               │
│  │  • Updates AWS Amplify configuration         │               │
│  │  • Modifies infrastructure                   │               │
│  │  • Updates environment variables             │               │
│  └──────────────────────────────────────────────┘               │
│                      ↓                                           │
│  ┌──────────────────────────────────────────────┐               │
│  │         Send deployment notification          │               │
│  └──────────────────────────────────────────────┘               │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────────────┐
│                AWS Amplify (Auto-Deploy)                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  1. Detects push to main branch                                 │
│              ↓                                                   │
│  2. Pulls latest code from GitHub                               │
│              ↓                                                   │
│  3. Installs dependencies (npm ci)                              │
│              ↓                                                   │
│  4. Runs build (npm run build)                                  │
│              ↓                                                   │
│  5. Deploys to CloudFront CDN                                   │
│              ↓                                                   │
│  6. ✅ Site is LIVE!                                            │
│                                                                   │
│  📍 URL: https://main.d1234567890.amplifyapp.com               │
│  📍 Custom: https://docs.arch.network (if configured)          │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
              ↓
      Users access the site
```

## Two-Stage CI/CD

### Stage 1: GitHub Actions (Infrastructure & Quality)

**Purpose:** Validate code, manage infrastructure, ensure quality

**Responsibilities:**
- ✅ Code linting and formatting
- ✅ Type checking
- ✅ Build validation
- ✅ Terraform infrastructure management
- ✅ Security scanning
- ✅ Broken link detection

**Triggers:**
- Pull requests
- Pushes to main

**Duration:** ~3-5 minutes

### Stage 2: AWS Amplify (Application Deployment)

**Purpose:** Build and deploy the actual application

**Responsibilities:**
- ✅ Install dependencies
- ✅ Build Next.js application
- ✅ Optimize assets
- ✅ Deploy to CDN
- ✅ Invalidate cache
- ✅ Serve traffic

**Triggers:**
- Pushes to main (automatic)
- Manual triggers
- Webhook events

**Duration:** ~5-8 minutes

## Parallel Deployment Flow

```
Merge to main
     │
     ├─────────────────┬─────────────────┐
     │                 │                 │
     ↓                 ↓                 ↓
Lint & Test      Terraform        Notifications
(3 minutes)      (2 minutes)      (instant)
     │                 │                 │
     └────────┬────────┘                 │
              ↓                          ↓
        AWS Amplify Build          Slack/Discord
        (5-8 minutes)              (optional)
              ↓
         ✅ DEPLOYED
```

## Infrastructure Components

```
┌─────────────────────────────────────────────────────────────────┐
│                        GitHub                                    │
│  • Source code repository                                       │
│  • Actions runner                                               │
│  • Secrets management                                           │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                     AWS Amplify                                  │
│  • Build environment                                            │
│  • Next.js SSR support                                          │
│  • CloudFront CDN                                               │
│  • SSL/TLS certificates                                         │
│  • Environment variables                                        │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                 Global Users                                     │
│  • Fast CDN delivery                                            │
│  • HTTPS encryption                                             │
│  • Custom domain                                                │
└─────────────────────────────────────────────────────────────────┘
```

## Failure Handling

### GitHub Actions Failure

```
PR Check Fails
     ↓
❌ Blocks merge
     ↓
Developer fixes code
     ↓
Pushes new commit
     ↓
Re-runs checks
     ↓
✅ Passes → Ready to merge
```

### Terraform Apply Failure

```
Terraform Apply Fails
     ↓
❌ Stops deployment
     ↓
Creates GitHub issue
     ↓
Sends alert notification
     ↓
Manual investigation required
     ↓
Fix and re-run
```

### AWS Amplify Build Failure

```
Amplify Build Fails
     ↓
❌ Deployment aborted
     ↓
Previous version still live
     ↓
Build logs available
     ↓
Developer fixes issue
     ↓
Push new commit
     ↓
Auto-retry build
```

## Security Flow

```
Developer → GitHub → AWS
             ↑         ↑
             │         │
        GitHub      AWS IAM
        Secrets     Roles
             │         │
        Protected  Protected
```

**Security Layers:**
1. ✅ GitHub repository access control
2. ✅ GitHub Secrets encryption
3. ✅ AWS IAM role permissions
4. ✅ GitHub Environment protection
5. ✅ Branch protection rules
6. ✅ Required code reviews

## Monitoring & Observability

```
┌──────────────┐
│ GitHub       │ → Workflow status, logs, artifacts
└──────────────┘

┌──────────────┐
│ AWS Amplify  │ → Build logs, deployment status
└──────────────┘

┌──────────────┐
│ CloudWatch   │ → Metrics, logs, alarms
└──────────────┘

┌──────────────┐
│ Slack/Discord│ → Real-time notifications (optional)
└──────────────┘
```

## Environment Variables Flow

```
terraform.tfvars (local)
        ↓
GitHub Secrets (secure)
        ↓
GitHub Actions (runtime)
        ↓
Terraform Variables
        ↓
AWS Amplify Config
        ↓
Next.js Build Process
        ↓
Application Runtime
```

## Rollback Strategy

### Option 1: Git Revert
```bash
git revert <commit-hash>
git push origin main
# Triggers automatic rebuild
```

### Option 2: AWS Amplify Console
```
1. Go to AWS Amplify Console
2. Select your app
3. Click "Redeploy this version" on previous build
```

### Option 3: Terraform State
```bash
cd terraform
terraform state pull > backup.tfstate
# Restore if needed
terraform state push backup.tfstate
```

## Cost Breakdown

### GitHub Actions (Free Tier)
- ✅ 2,000 minutes/month (public repos)
- ✅ 500 MB storage
- ✅ Unlimited for public repos

### AWS Amplify (~$5-20/month)
- Build minutes: $0.01/minute
- Hosting: $0.15/GB stored + $0.15/GB served
- First 1,000 build minutes free
- First 15 GB served free

### Total Estimated Cost
- **Small docs site:** $5-10/month
- **Medium traffic:** $10-20/month
- **High traffic:** $20-50/month

## Performance Metrics

**Typical Timings:**
- PR validation: 3-5 minutes
- Terraform apply: 1-3 minutes
- Amplify build: 5-8 minutes
- **Total merge to live:** ~10-15 minutes

**Optimization Tips:**
- Use npm caching (✅ already configured)
- Parallel job execution (✅ already configured)
- Incremental builds where possible
