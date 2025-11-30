# 🔐 AWS Setup Walkthrough - Connect to AWS

This guide walks you through setting up AWS from scratch, step by step.

---

## 🎯 Goal

By the end of this guide, you will have:
- ✅ AWS account created
- ✅ IAM user with proper permissions
- ✅ AWS CLI installed and configured
- ✅ Ability to run AWS commands

**Estimated Time:** 30-45 minutes

---

## Part 1: Create AWS Account (10-15 minutes)

### Step 1: Go to AWS Website

1. Open your browser
2. Go to: [https://aws.amazon.com](https://aws.amazon.com)
3. Click **"Create an AWS Account"** (orange button, top right)

### Step 2: Enter Account Information

1. **Email address:** Enter your email
2. **AWS account name:** Choose a name (e.g., "MyECSProject")
3. Click **"Verify email address"**
4. Check your email for verification code
5. Enter the verification code
6. Click **"Verify"**

### Step 3: Create Password

1. **Password:** Create a strong password
2. **Confirm password:** Re-enter password
3. Click **"Continue"**

### Step 4: Contact Information

1. **Account type:** Select "Personal" (or "Business" if applicable)
2. **Full name:** Your name
3. **Phone number:** Your phone number
4. **Country/Region:** Your country
5. **Address:** Your address
6. **City:** Your city
7. **State/Province:** Your state
8. **Postal code:** Your postal code
9. ✅ Check "I have read and agree to the terms..."
10. Click **"Continue"**

### Step 5: Payment Information

**Note:** AWS requires a credit card even for free tier. You won't be charged unless you exceed free tier limits.

1. **Credit/Debit card number:** Enter card number
2. **Expiration date:** MM/YY
3. **Cardholder name:** Name on card
4. **Billing address:** Same as contact or different
5. Click **"Verify and Continue"**

### Step 6: Identity Verification

1. **Phone number:** Confirm or enter phone number
2. **Security check:** Enter CAPTCHA
3. Click **"Send SMS"** or **"Call me now"**
4. **Verification code:** Enter the code you receive
5. Click **"Continue"**

### Step 7: Choose Support Plan

1. Select **"Basic support - Free"**
2. Click **"Complete sign up"**

### Step 8: Confirmation

You'll see: "Congratulations! Your AWS account is ready"

**Wait 5-10 minutes** for account activation before proceeding.

---

## Part 2: Enable MFA (5 minutes)

**Why?** Multi-Factor Authentication protects your account from unauthorized access.

### Step 1: Sign In to AWS Console

1. Go to: [https://console.aws.amazon.com](https://console.aws.amazon.com)
2. Click **"Root user"**
3. Enter your email address
4. Click **"Next"**
5. Enter your password
6. Click **"Sign in"**

### Step 2: Navigate to Security Credentials

1. Click your account name (top right corner)
2. Click **"Security credentials"**
3. Scroll down to **"Multi-factor authentication (MFA)"**
4. Click **"Activate MFA"**

### Step 3: Set Up MFA Device

1. **Device name:** Enter a name (e.g., "MyPhone")
2. **MFA device:** Select **"Authenticator app"**
3. Click **"Next"**

### Step 4: Install Authenticator App

**If you don't have one, install:**
- **iOS:** Google Authenticator or Microsoft Authenticator
- **Android:** Google Authenticator or Microsoft Authenticator
- **Desktop:** Authy

### Step 5: Scan QR Code

1. Open your authenticator app
2. Tap **"Add account"** or **"+"**
3. Scan the QR code shown on AWS console
4. The app will show a 6-digit code

### Step 6: Enter MFA Codes

1. **MFA code 1:** Enter the current code from your app
2. Wait for the code to refresh (30 seconds)
3. **MFA code 2:** Enter the new code
4. Click **"Add MFA"**

✅ **Success!** Your root account is now protected with MFA.

---

## Part 3: Create IAM User (10-15 minutes)

**Why?** Never use your root account for daily operations. Create an IAM user instead.

### Step 1: Navigate to IAM

1. In AWS Console, search for **"IAM"** in the top search bar
2. Click **"IAM"** (Identity and Access Management)

### Step 2: Create User

1. Click **"Users"** in the left sidebar
2. Click **"Create user"** (orange button)

### Step 3: User Details

1. **User name:** Enter `ecs-admin` (or your preferred name)
2. ✅ Check **"Provide user access to the AWS Management Console"**
3. Select **"I want to create an IAM user"**
4. **Console password:** Select **"Custom password"**
5. Enter a strong password
6. ✅ Check **"Users must create a new password at next sign-in"** (optional)
7. Click **"Next"**

### Step 4: Set Permissions

1. Select **"Attach policies directly"**
2. In the search box, type and select these policies:
   - ✅ `AmazonECS_FullAccess`
   - ✅ `AmazonEC2ContainerRegistryFullAccess`
   - ✅ `AmazonVPCFullAccess`
   - ✅ `IAMFullAccess`
   - ✅ `CloudWatchLogsFullAccess`
   - ✅ `ElasticLoadBalancingFullAccess`
   - ✅ `CloudFrontFullAccess`

**Tip:** Use the search box and check each policy one by one.

3. Click **"Next"**

### Step 5: Review and Create

1. Review the user details
2. Click **"Create user"**

### Step 6: Save Credentials

**CRITICAL:** You'll see a success page with credentials. Save these NOW!

1. Click **"Download .csv file"** - Save this file securely
2. **OR** Copy these values:
   - Console sign-in URL
   - User name
   - Password (if you set custom)

3. **Store in a password manager** (recommended)

### Step 7: Create Access Keys

**For AWS CLI access:**

1. Click on the user name you just created
2. Click **"Security credentials"** tab
3. Scroll down to **"Access keys"**
4. Click **"Create access key"**
5. Select **"Command Line Interface (CLI)"**
6. ✅ Check "I understand..."
7. Click **"Next"**
8. **Description:** Enter "ECS Deployment CLI"
9. Click **"Create access key"**

### Step 8: Save Access Keys

**CRITICAL:** Save these immediately - you won't see them again!

1. **Access key ID:** Copy and save (looks like: AKIAIOSFODNN7EXAMPLE)
2. **Secret access key:** Copy and save (looks like: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY)
3. Click **"Download .csv file"** - Save this file
4. Click **"Done"**

**Store these in a password manager or secure location!**

### Step 9: Enable MFA for IAM User

1. Still in the user's **"Security credentials"** tab
2. Scroll to **"Multi-factor authentication (MFA)"**
3. Click **"Assign MFA device"**
4. Follow the same steps as Part 2 (use your authenticator app)

✅ **Success!** Your IAM user is created and secured.

---

## Part 4: Install AWS CLI (10-15 minutes)

### For Linux (Amazon Linux, Ubuntu, Debian)

```bash
# Download AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Install unzip if needed
sudo yum install -y unzip  # Amazon Linux/RHEL/CentOS
# OR
sudo apt-get install -y unzip  # Ubuntu/Debian

# Unzip the installer
unzip awscliv2.zip

# Run the installer
sudo ./aws/install

# Verify installation
aws --version

# Should output: aws-cli/2.x.x ...
```

### For macOS

**Option 1: Using Homebrew (Recommended)**
```bash
# Install Homebrew if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install AWS CLI
brew install awscli

# Verify
aws --version
```

**Option 2: Using Installer**
```bash
# Download installer
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"

# Install
sudo installer -pkg AWSCLIV2.pkg -target /

# Verify
aws --version
```

### For Windows

**Option 1: Using MSI Installer (Recommended)**

1. Download: [AWS CLI MSI Installer](https://awscli.amazonaws.com/AWSCLIV2.msi)
2. Run the downloaded file
3. Follow the installation wizard
4. Click "Finish"
5. Open **PowerShell** or **Command Prompt**
6. Verify:
   ```powershell
   aws --version
   ```

**Option 2: Using Chocolatey**
```powershell
# Install Chocolatey if you don't have it
# Run PowerShell as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install AWS CLI
choco install awscli

# Verify
aws --version
```

---

## Part 5: Configure AWS CLI (5 minutes)

### Step 1: Run Configuration Command

```bash
aws configure
```

### Step 2: Enter Your Credentials

You'll be prompted for 4 values:

```
AWS Access Key ID [None]: 
```
**Enter:** Your Access Key ID from Part 3, Step 8 (AKIAIOSFODNN7EXAMPLE)

```
AWS Secret Access Key [None]: 
```
**Enter:** Your Secret Access Key from Part 3, Step 8

```
Default region name [None]: 
```
**Enter:** `us-east-1` (or your preferred region)

**Region Options:**
- `us-east-1` - US East (N. Virginia) - Most services, lowest cost
- `us-west-2` - US West (Oregon)
- `eu-west-1` - Europe (Ireland)
- `ap-southeast-1` - Asia Pacific (Singapore)

```
Default output format [None]: 
```
**Enter:** `json`

### Step 3: Verify Configuration

```bash
# Test AWS CLI
aws sts get-caller-identity
```

**Expected Output:**
```json
{
    "UserId": "AIDAXXXXXXXXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/ecs-admin"
}
```

✅ **Success!** If you see this output, your AWS CLI is configured correctly!

### Step 4: Test ECS Access

```bash
# Test ECS access
aws ecs list-clusters --region us-east-1
```

**Expected Output:**
```json
{
    "clusterArns": []
}
```

This is normal - you don't have any clusters yet!

### Step 5: Test ECR Access

```bash
# Test ECR access
aws ecr describe-repositories --region us-east-1
```

**Expected Output:**
```json
{
    "repositories": []
}
```

This is normal - you don't have any repositories yet!

---

## Part 6: Set Up Environment Variables (5 minutes)

### Step 1: Create Environment File

```bash
# Create environment file
cat > ~/.aws-ecs-env << 'EOF'
# AWS Configuration
export AWS_REGION="us-east-1"
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Project Configuration
export PROJECT_NAME="springmvc-hello-world"
export ECR_REPO_NAME="springmvc-hello-world"
export ECS_CLUSTER_NAME="springmvc-cluster"
export ECS_SERVICE_NAME="springmvc-service"

# Computed values
export ECR_REPO_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"

echo "AWS Environment loaded:"
echo "  Region: ${AWS_REGION}"
echo "  Account: ${AWS_ACCOUNT_ID}"
echo "  ECR URI: ${ECR_REPO_URI}"
EOF
```

### Step 2: Load Environment

```bash
# Load environment variables
source ~/.aws-ecs-env
```

**Expected Output:**
```
AWS Environment loaded:
  Region: us-east-1
  Account: 123456789012
  ECR URI: 123456789012.dkr.ecr.us-east-1.amazonaws.com/springmvc-hello-world
```

### Step 3: Add to Shell Profile

**For Linux/macOS:**
```bash
# Add to .bashrc (Linux) or .zshrc (macOS)
echo "" >> ~/.bashrc
echo "# AWS ECS Environment" >> ~/.bashrc
echo "source ~/.aws-ecs-env" >> ~/.bashrc

# For macOS with zsh
echo "" >> ~/.zshrc
echo "# AWS ECS Environment" >> ~/.zshrc
echo "source ~/.aws-ecs-env" >> ~/.zshrc
```

**For Windows PowerShell:**
```powershell
# Add to PowerShell profile
Add-Content $PROFILE "`n# AWS ECS Environment"
Add-Content $PROFILE "`$env:AWS_REGION='us-east-1'"
Add-Content $PROFILE "`$env:AWS_ACCOUNT_ID=(aws sts get-caller-identity --query Account --output text)"
```

---

## ✅ Verification Checklist

Run through this checklist to ensure everything is set up:

### AWS Account
- [ ] AWS account created
- [ ] Email verified
- [ ] Payment method added
- [ ] Account activated (wait 5-10 minutes after creation)

### Security
- [ ] Root account MFA enabled
- [ ] IAM user created
- [ ] IAM user MFA enabled
- [ ] Access keys created and saved
- [ ] Credentials stored securely

### AWS CLI
- [ ] AWS CLI installed
- [ ] `aws --version` works
- [ ] AWS CLI configured
- [ ] `aws sts get-caller-identity` works
- [ ] Shows correct account and user

### Environment
- [ ] Environment file created (~/.aws-ecs-env)
- [ ] Environment variables load correctly
- [ ] Added to shell profile

---

## 🎉 Success!

You're now connected to AWS! Here's what you can do:

### Test Your Setup
```bash
# Run the quick start script
./quick-start.sh

# Or run verification manually
./verify-setup.sh
```

### Next Steps
1. **Build the application** - Follow STEP_BY_STEP_GUIDE.md Phase 1
2. **Containerize** - Follow Phase 2
3. **Deploy to AWS** - Follow Phase 3-5

---

## 🐛 Troubleshooting

### Issue: "aws: command not found"

**Solution:**
```bash
# Check if AWS CLI is installed
which aws

# If not found, reinstall AWS CLI
# Follow Part 4 again

# Check PATH
echo $PATH

# Add AWS CLI to PATH (Linux/macOS)
export PATH=$PATH:/usr/local/bin
```

### Issue: "Unable to locate credentials"

**Solution:**
```bash
# Re-run configuration
aws configure

# Check credentials file
cat ~/.aws/credentials

# Should show:
# [default]
# aws_access_key_id = YOUR_KEY
# aws_secret_access_key = YOUR_SECRET
```

### Issue: "Access Denied" errors

**Solution:**
1. Verify IAM user has correct policies attached
2. Go to IAM Console → Users → Your User → Permissions
3. Ensure all required policies are attached (see Part 3, Step 4)

### Issue: "Region not found"

**Solution:**
```bash
# Set region explicitly
aws configure set region us-east-1

# Or use --region flag
aws ecs list-clusters --region us-east-1
```

### Issue: MFA code not working

**Solution:**
1. Ensure your device time is synchronized
2. Wait for code to refresh and try again
3. If still failing, remove and re-add MFA device

---

## 📞 Getting Help

### AWS Support
- **Free tier:** Basic support included
- **Documentation:** https://docs.aws.amazon.com/
- **Forums:** https://forums.aws.amazon.com/

### Common Resources
- **AWS CLI Docs:** https://docs.aws.amazon.com/cli/
- **IAM Best Practices:** https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html
- **Free Tier:** https://aws.amazon.com/free/

---

## 💡 Tips

### Tip 1: Use Named Profiles
For multiple AWS accounts:
```bash
# Configure additional profile
aws configure --profile work
aws configure --profile personal

# Use specific profile
aws ecs list-clusters --profile work

# Set default profile
export AWS_PROFILE=work
```

### Tip 2: Check Free Tier Usage
```bash
# View current month costs
aws ce get-cost-and-usage \
    --time-period Start=2025-11-01,End=2025-11-30 \
    --granularity MONTHLY \
    --metrics BlendedCost
```

### Tip 3: Set Up Billing Alerts
1. Go to AWS Console → Billing
2. Click "Billing preferences"
3. Enable "Receive Free Tier Usage Alerts"
4. Enable "Receive Billing Alerts"
5. Enter your email
6. Save preferences

### Tip 4: Secure Your Credentials
- ✅ Never commit credentials to Git
- ✅ Use password manager for storage
- ✅ Rotate access keys every 90 days
- ✅ Enable MFA on all accounts
- ✅ Use IAM roles for EC2/ECS (not access keys)

---

## 🎯 What's Next?

Now that you're connected to AWS:

1. **Run Quick Start**
   ```bash
   ./quick-start.sh
   ```

2. **Follow Deployment Guide**
   - Open: `STEP_BY_STEP_GUIDE.md`
   - Start with Phase 1: Build Application

3. **Keep References Handy**
   - `QUICK_REFERENCE.md` - Commands
   - `BUG_ANALYSIS.md` - Troubleshooting

---

**Congratulations! You're ready to deploy to AWS! 🚀**

---

**Guide Version:** 1.0  
**Last Updated:** 2025-11-30  
**Maintained By:** Ona
