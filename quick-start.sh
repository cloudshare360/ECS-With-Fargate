#!/bin/bash

# Quick Start Script for AWS ECS Deployment
# This script helps you get started with the deployment process

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

print_success() {
    echo -e "${GREEN}✅ ${NC}$1"
}

print_warning() {
    echo -e "${YELLOW}⚠️  ${NC}$1"
}

print_error() {
    echo -e "${RED}❌ ${NC}$1"
}

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to prompt user
prompt_continue() {
    echo ""
    read -p "Press Enter to continue or Ctrl+C to exit..."
    echo ""
}

# Main script
clear
print_header "AWS ECS Deployment - Quick Start"

echo "This script will guide you through the deployment process."
echo "It will check prerequisites and help you set up your environment."
echo ""

prompt_continue

# Step 1: Check Prerequisites
print_header "Step 1: Checking Prerequisites"

PREREQ_FAILED=0

# Check AWS CLI
if command_exists aws; then
    AWS_VERSION=$(aws --version 2>&1 | cut -d' ' -f1)
    print_success "AWS CLI installed: $AWS_VERSION"
else
    print_error "AWS CLI not found"
    print_info "Install from: https://aws.amazon.com/cli/"
    PREREQ_FAILED=1
fi

# Check Docker
if command_exists docker; then
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | tr -d ',')
    print_success "Docker installed: $DOCKER_VERSION"
    
    # Check if Docker daemon is running
    if docker ps >/dev/null 2>&1; then
        print_success "Docker daemon is running"
    else
        print_error "Docker daemon is not running"
        print_info "Start Docker Desktop or run: sudo systemctl start docker"
        PREREQ_FAILED=1
    fi
else
    print_error "Docker not found"
    print_info "Install from: https://www.docker.com/products/docker-desktop"
    PREREQ_FAILED=1
fi

# Check Maven
if command_exists mvn; then
    MVN_VERSION=$(mvn --version | head -1 | cut -d' ' -f3)
    print_success "Maven installed: $MVN_VERSION"
else
    print_error "Maven not found"
    print_info "Install Maven: sudo yum install -y maven (Amazon Linux)"
    PREREQ_FAILED=1
fi

# Check Java
if command_exists java; then
    JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2)
    print_success "Java installed: $JAVA_VERSION"
    
    if [[ $JAVA_VERSION == 17.* ]]; then
        print_success "Java 17 detected"
    else
        print_warning "Java 17 recommended, you have: $JAVA_VERSION"
    fi
else
    print_error "Java not found"
    print_info "Install Java 17: sudo yum install -y java-17-amazon-corretto-devel"
    PREREQ_FAILED=1
fi

# Check Git
if command_exists git; then
    GIT_VERSION=$(git --version | cut -d' ' -f3)
    print_success "Git installed: $GIT_VERSION"
else
    print_error "Git not found"
    PREREQ_FAILED=1
fi

if [ $PREREQ_FAILED -eq 1 ]; then
    echo ""
    print_error "Some prerequisites are missing. Please install them and run this script again."
    exit 1
fi

echo ""
print_success "All prerequisites are installed!"

prompt_continue

# Step 2: Check AWS Configuration
print_header "Step 2: Checking AWS Configuration"

if aws sts get-caller-identity >/dev/null 2>&1; then
    AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
    AWS_USER=$(aws sts get-caller-identity --query Arn --output text)
    print_success "AWS credentials configured"
    print_info "Account: $AWS_ACCOUNT"
    print_info "User: $AWS_USER"
else
    print_error "AWS credentials not configured"
    echo ""
    print_info "Run: aws configure"
    print_info "You'll need:"
    print_info "  - AWS Access Key ID"
    print_info "  - AWS Secret Access Key"
    print_info "  - Default region (e.g., us-east-1)"
    echo ""
    read -p "Do you want to configure AWS now? (y/n): " configure_aws
    if [[ $configure_aws == "y" || $configure_aws == "Y" ]]; then
        aws configure
        echo ""
        if aws sts get-caller-identity >/dev/null 2>&1; then
            print_success "AWS credentials configured successfully"
        else
            print_error "AWS configuration failed"
            exit 1
        fi
    else
        print_error "AWS credentials required to continue"
        exit 1
    fi
fi

prompt_continue

# Step 3: Set up environment variables
print_header "Step 3: Setting Up Environment Variables"

# Get AWS region
AWS_REGION=$(aws configure get region)
if [ -z "$AWS_REGION" ]; then
    AWS_REGION="us-east-1"
    print_warning "No default region set, using: $AWS_REGION"
else
    print_info "Using region: $AWS_REGION"
fi

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Set project variables
PROJECT_NAME="springmvc-hello-world"
ECR_REPO_NAME="springmvc-hello-world"
ECS_CLUSTER_NAME="springmvc-cluster"
ECS_SERVICE_NAME="springmvc-service"
ECR_REPO_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"

print_info "Project: $PROJECT_NAME"
print_info "ECR Repository: $ECR_REPO_NAME"
print_info "ECS Cluster: $ECS_CLUSTER_NAME"
print_info "ECS Service: $ECS_SERVICE_NAME"

# Create environment file
ENV_FILE="$HOME/.aws-ecs-env"
cat > "$ENV_FILE" << EOF
# AWS Configuration
export AWS_REGION="$AWS_REGION"
export AWS_ACCOUNT_ID="$AWS_ACCOUNT_ID"

# Project Configuration
export PROJECT_NAME="$PROJECT_NAME"
export ECR_REPO_NAME="$ECR_REPO_NAME"
export ECS_CLUSTER_NAME="$ECS_CLUSTER_NAME"
export ECS_SERVICE_NAME="$ECS_SERVICE_NAME"

# Computed values
export ECR_REPO_URI="\${AWS_ACCOUNT_ID}.dkr.ecr.\${AWS_REGION}.amazonaws.com/\${ECR_REPO_NAME}"

echo "AWS Environment loaded:"
echo "  Region: \${AWS_REGION}"
echo "  Account: \${AWS_ACCOUNT_ID}"
echo "  ECR URI: \${ECR_REPO_URI}"
EOF

print_success "Environment file created: $ENV_FILE"

# Add to shell profile if not already there
SHELL_PROFILE=""
if [ -f "$HOME/.bashrc" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
elif [ -f "$HOME/.zshrc" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
fi

if [ -n "$SHELL_PROFILE" ]; then
    if ! grep -q "source $ENV_FILE" "$SHELL_PROFILE"; then
        echo "" >> "$SHELL_PROFILE"
        echo "# AWS ECS Environment" >> "$SHELL_PROFILE"
        echo "source $ENV_FILE" >> "$SHELL_PROFILE"
        print_success "Added to $SHELL_PROFILE"
    fi
fi

# Load environment
source "$ENV_FILE"

prompt_continue

# Step 4: Create verification script
print_header "Step 4: Creating Verification Script"

cat > verify-setup.sh << 'VERIFY_EOF'
#!/bin/bash

echo "=== AWS ECS Environment Verification ==="
echo ""

# Check AWS CLI
echo "1. AWS CLI:"
aws --version && echo "   ✅ AWS CLI installed" || echo "   ❌ AWS CLI not found"
echo ""

# Check AWS credentials
echo "2. AWS Credentials:"
aws sts get-caller-identity > /dev/null 2>&1 && echo "   ✅ AWS credentials configured" || echo "   ❌ AWS credentials not configured"
echo ""

# Check Docker
echo "3. Docker:"
docker --version && echo "   ✅ Docker installed" || echo "   ❌ Docker not found"
docker ps > /dev/null 2>&1 && echo "   ✅ Docker daemon running" || echo "   ❌ Docker daemon not running"
echo ""

# Check Maven
echo "4. Maven:"
mvn --version | head -1 && echo "   ✅ Maven installed" || echo "   ❌ Maven not found"
echo ""

# Check Java
echo "5. Java:"
java -version 2>&1 | head -1 && echo "   ✅ Java installed" || echo "   ❌ Java not found"
echo ""

# Check Git
echo "6. Git:"
git --version && echo "   ✅ Git installed" || echo "   ❌ Git not found"
echo ""

echo "=== Verification Complete ==="
VERIFY_EOF

chmod +x verify-setup.sh
print_success "Verification script created: verify-setup.sh"

echo ""
print_info "Running verification..."
echo ""
./verify-setup.sh

prompt_continue

# Step 5: Next Steps
print_header "Setup Complete! 🎉"

echo "Your environment is ready for AWS ECS deployment!"
echo ""
echo "Next steps:"
echo ""
echo "1. Review the guides:"
echo "   - README.md - Complete deployment guide"
echo "   - STEP_BY_STEP_GUIDE.md - Detailed walkthrough"
echo "   - BUG_ANALYSIS.md - Known issues and fixes"
echo ""
echo "2. Start with Phase 1: Build the Application"
echo "   Follow STEP_BY_STEP_GUIDE.md starting from Phase 1"
echo ""
echo "3. Useful commands:"
echo "   - source ~/.aws-ecs-env    # Load environment variables"
echo "   - ./verify-setup.sh        # Verify setup anytime"
echo ""
echo "4. Quick reference:"
echo "   - AWS Region: $AWS_REGION"
echo "   - AWS Account: $AWS_ACCOUNT_ID"
echo "   - Project: $PROJECT_NAME"
echo ""

print_success "Happy deploying! 🚀"
echo ""
