# How to Get AWS Access Keys

## What Are These Credentials?

- **AWS_ACCESS_KEY_ID**: A public identifier for your AWS account access
- **AWS_SECRET_ACCESS_KEY**: A private key (like a password) for authentication

Together, these allow Terraform and GitHub Actions to manage your AWS resources.

## 🔐 Method 1: Create IAM User (Recommended)

### Step 1: Log into AWS Console

1. Go to: https://console.aws.amazon.com/
2. Sign in with your AWS account

### Step 2: Navigate to IAM

1. In the search bar at the top, type **"IAM"**
2. Click on **"IAM"** (Identity and Access Management)
3. Or go directly to: https://console.aws.amazon.com/iam/

### Step 3: Create a New IAM User

1. In the left sidebar, click **"Users"**
2. Click the **"Create user"** button (orange button, top right)
3. Enter a username: `terraform-deploy` (or any name you prefer)
4. Click **"Next"**

### Step 4: Set Permissions

**Option A: Quick Setup (Use existing policy)**
1. Select **"Attach policies directly"**
2. Search for and check these policies:
   - ✅ `AdministratorAccess-Amplify` (for Amplify management)
   - ✅ `IAMFullAccess` (to create IAM roles)
   - ✅ `CloudWatchLogsFullAccess` (for logging)

**Option B: Least Privilege (More secure, more setup)**
1. Create a custom policy with minimum required permissions
2. Attach the custom policy to the user

**For now, Option A is easier to get started.**

3. Click **"Next"**
4. Review and click **"Create user"**

### Step 5: Create Access Keys

1. Click on the username you just created
2. Click the **"Security credentials"** tab
3. Scroll down to **"Access keys"** section
4. Click **"Create access key"**
5. Select use case: **"Command Line Interface (CLI)"**
6. Check the box: "I understand the above recommendation..."
7. Click **"Next"**
8. (Optional) Add a description tag: "Terraform Amplify Deployment"
9. Click **"Create access key"**

### Step 6: Save Your Credentials

⚠️ **IMPORTANT:** You can only see the secret key once!

**You'll see:**
```
Access key ID: AKIAIOSFODNN7EXAMPLE
Secret access key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

**Save these immediately:**

**Option 1: Download the CSV file**
- Click **"Download .csv file"**
- Store it securely
- ⚠️ Never commit this to git!

**Option 2: Copy to a secure note**
- Copy both values to a password manager
- Or temporarily to a secure note app

**Do NOT:**
- ❌ Email them
- ❌ Store in a text file
- ❌ Commit to git
- ❌ Share publicly

### Step 7: Configure AWS CLI (Optional but Recommended)

```bash
# Run this command
aws configure

# You'll be prompted:
AWS Access Key ID [None]: YOUR_ACCESS_KEY_ID_HERE
AWS Secret Access Key [None]: YOUR_SECRET_KEY_HERE
Default region name [None]: us-east-1
Default output format [None]: json
```

### Step 8: Test Your Credentials

```bash
# This should show your AWS account information
aws sts get-caller-identity
```

**Expected output:**
```json
{
    "UserId": "AIDAEXAMPLE",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/terraform-deploy"
}
```

✅ If you see this, your credentials are working!

---

## 🏢 Method 2: Use Root Account Keys (NOT Recommended)

If you're using the root AWS account (not recommended for production):

1. Log into AWS Console as root user
2. Click your account name (top right)
3. Select **"Security credentials"**
4. Scroll down to **"Access keys"**
5. Click **"Create access key"**
6. Follow the warnings (AWS will encourage you to create IAM user instead)
7. Save the credentials

⚠️ **Warning:** Root account keys have unlimited access. Create an IAM user instead!

---

## 🔒 Security Best Practices

### DO ✅

1. **Use IAM users, not root account**
2. **Enable MFA** (Multi-Factor Authentication)
3. **Use least-privilege permissions**
4. **Rotate keys regularly** (every 90 days)
5. **Store in AWS Secrets Manager** (for production)
6. **Use GitHub Secrets** for CI/CD
7. **Monitor access** with CloudTrail

### DON'T ❌

1. ❌ Share credentials
2. ❌ Commit to git
3. ❌ Use root account keys
4. ❌ Use same keys across environments
5. ❌ Leave unused keys active
6. ❌ Store in plain text files

---

## 📝 Where to Use These Credentials

### 1. AWS CLI Configuration

```bash
aws configure
# Enter your keys when prompted
```

**Stored in:** `~/.aws/credentials`

### 2. Terraform (Local Development)

Edit `terraform/terraform.tfvars`:
```hcl
# Don't put AWS keys here!
# Use AWS CLI configuration instead
```

Terraform will automatically use credentials from `~/.aws/credentials`

### 3. GitHub Secrets (For CI/CD)

1. Go to: `https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions`
2. Click **"New repository secret"**
3. Add each secret:

**Secret 1:**
- Name: `AWS_ACCESS_KEY_ID`
- Value: `YOUR_ACCESS_KEY_ID`
- Click "Add secret"

**Secret 2:**
- Name: `AWS_SECRET_ACCESS_KEY`
- Value: `YOUR_SECRET_KEY`
- Click "Add secret"

---

## 🔄 How to Rotate Keys (Every 90 Days)

### Step 1: Create New Key

1. Go to IAM → Users → Your User
2. Security credentials tab
3. Create access key
4. Save the new credentials

### Step 2: Update Everywhere

Update in all places you use them:
- ✅ AWS CLI: `aws configure`
- ✅ GitHub Secrets: Update both secrets
- ✅ Any other tools

### Step 3: Test New Key

```bash
aws sts get-caller-identity
```

### Step 4: Delete Old Key

1. Go back to IAM → Users → Your User → Security credentials
2. Find the old access key
3. Click "Delete"
4. Confirm deletion

---

## 🆘 Troubleshooting

### "Invalid security token" or "Access Denied"

**Causes:**
- Keys copied incorrectly (extra spaces, missing characters)
- Keys not yet propagated (wait 5 minutes)
- Insufficient permissions

**Solutions:**
```bash
# Test credentials
aws sts get-caller-identity

# Check for extra spaces
echo "AWS_ACCESS_KEY_ID: '$AWS_ACCESS_KEY_ID'"
echo "AWS_SECRET_ACCESS_KEY: '$AWS_SECRET_ACCESS_KEY'"
```

### "The security token included in the request is expired"

- Keys may have been deleted in AWS Console
- Create new keys following steps above

### "User not authorized to perform iam:CreateRole"

- Your IAM user needs additional permissions
- Add `IAMFullAccess` policy to your user

---

## 📊 Required Permissions for This Project

Your IAM user needs these permissions:

### Amplify Permissions
- `amplify:*` (or `AdministratorAccess-Amplify` policy)

### IAM Permissions
- `iam:CreateRole`
- `iam:AttachRolePolicy`
- `iam:GetRole`
- `iam:PutRolePolicy`

### CloudWatch Logs
- `logs:CreateLogGroup`
- `logs:CreateLogStream`
- `logs:PutLogEvents`

**Easiest approach:** Attach these managed policies:
- ✅ `AdministratorAccess-Amplify`
- ✅ `IAMFullAccess`
- ✅ `CloudWatchLogsFullAccess`

For production, create a custom policy with only these specific permissions.

---

## 🎯 Quick Start Checklist

- [ ] Create IAM user in AWS Console
- [ ] Attach required policies
- [ ] Create access key
- [ ] Download and save credentials securely
- [ ] Configure AWS CLI: `aws configure`
- [ ] Test: `aws sts get-caller-identity`
- [ ] Add to GitHub Secrets (if using CI/CD)
- [ ] Delete the CSV file after saving credentials

---

## 🔗 Helpful Links

- [AWS IAM Console](https://console.aws.amazon.com/iam/)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Managing Access Keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

---

## 🔐 Alternative: AWS SSO (Advanced)

For organizations using AWS SSO:

```bash
# Configure SSO
aws configure sso

# Login
aws sso login --profile your-profile

# Use with Terraform
export AWS_PROFILE=your-profile
```

This is more secure but requires additional setup.

---

**Next Step:** Once you have your credentials, continue with [`SETUP_CHECKLIST.md`](./SETUP_CHECKLIST.md) Step 4!
