# Quick Reference Guide

## 🚀 Getting Started in 5 Minutes

### 1. Run Quick Start Script
```bash
./quick-start.sh
```

This will:
- ✅ Check all prerequisites
- ✅ Verify AWS credentials
- ✅ Set up environment variables
- ✅ Create verification script

---

## 📚 Documentation Structure

| File | Purpose | When to Use |
|------|---------|-------------|
| **README.md** | Complete technical guide | Reference for all deployment scenarios |
| **STEP_BY_STEP_GUIDE.md** | Detailed walkthrough | Follow for first-time deployment |
| **BUG_ANALYSIS.md** | Known issues and fixes | Troubleshooting |
| **QUICK_REFERENCE.md** | This file | Quick commands and tips |

---

## 🔧 Essential Commands

### Environment Setup
```bash
# Load environment variables
source ~/.aws-ecs-env

# Verify setup
./verify-setup.sh

# Check AWS credentials
aws sts get-caller-identity
```

### Docker Commands
```bash
# Build image
docker build -t springmvc-hello-world:1.0.0 .

# Test locally
docker run -d -p 8080:8080 --name test springmvc-hello-world:1.0.0

# Check logs
docker logs test

# Stop and remove
docker stop test && docker rm test
```

### AWS ECR Commands
```bash
# Login to ECR
aws ecr get-login-password --region ${AWS_REGION} | \
    docker login --username AWS --password-stdin ${ECR_REPO_URI}

# Push image
docker push ${ECR_REPO_URI}:latest

# List images
aws ecr describe-images --repository-name ${ECR_REPO_NAME}
```

### AWS ECS Commands
```bash
# List clusters
aws ecs list-clusters

# Describe service
aws ecs describe-services \
    --cluster ${ECS_CLUSTER_NAME} \
    --services ${ECS_SERVICE_NAME}

# List tasks
aws ecs list-tasks --cluster ${ECS_CLUSTER_NAME}

# View logs
aws logs tail /ecs/springmvc --follow
```

---

## 📋 Deployment Phases

### Phase 0: Environment Setup (30-45 min)
**Goal:** Set up AWS account, IAM, CLI, Docker, Maven, Java

**Key Steps:**
1. Create AWS account and IAM user
2. Install AWS CLI, Docker, Maven, Java
3. Configure AWS credentials
4. Run `./quick-start.sh`

**Verification:**
```bash
./verify-setup.sh
# All items should show ✅
```

---

### Phase 1: Build Application (20-30 min)
**Goal:** Create Spring MVC application and build WAR file

**Key Steps:**
1. Create project structure
2. Create pom.xml, Java files, JSP views
3. Build with Maven

**Verification:**
```bash
ls -lh target/springmvc-hello-world.war
# Should show ~10-20 MB file
```

---

### Phase 2: Containerize (15-20 min)
**Goal:** Create Docker image and test locally

**Key Steps:**
1. Create Dockerfile (with curl!)
2. Build Docker image
3. Test locally

**Verification:**
```bash
curl http://localhost:8080/health
# Should return: {"status":"UP",...}
```

---

### Phase 3: AWS Infrastructure (30-45 min)
**Goal:** Set up VPC, subnets, security groups, ECR

**Key Steps:**
1. Create ECR repository
2. Push Docker image
3. Create VPC and networking
4. Create security groups

**Verification:**
```bash
aws ecr describe-images --repository-name ${ECR_REPO_NAME}
# Should show your image
```

---

### Phase 4: Deploy to ECS (20-30 min)
**Goal:** Deploy application to ECS Fargate

**Key Steps:**
1. Create ECS cluster
2. Create IAM roles
3. Register task definition
4. Create ECS service

**Verification:**
```bash
aws ecs describe-services \
    --cluster ${ECS_CLUSTER_NAME} \
    --services ${ECS_SERVICE_NAME} \
    --query 'services[0].runningCount'
# Should show: 2
```

---

### Phase 5: Test & Verify (10-15 min)
**Goal:** Access application and verify it works

**Key Steps:**
1. Get task public IPs
2. Test endpoints
3. View logs

**Verification:**
```bash
curl http://<PUBLIC_IP>:8080/
# Should return HTML page
```

---

## 🐛 Common Issues & Quick Fixes

### Issue: AWS CLI not found
```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Issue: Docker daemon not running
```bash
# Start Docker
sudo systemctl start docker

# Or start Docker Desktop (macOS/Windows)
```

### Issue: Health check failing
```bash
# Verify curl is in Dockerfile
grep "curl" Dockerfile
# Should show: yum install -y ... curl ...

# Rebuild if missing
docker build -t springmvc-hello-world:1.0.0 .
```

### Issue: Cannot access application
```bash
# Check security group allows port 8080
aws ec2 describe-security-groups --group-ids ${ECS_SG_ID}

# Check task has public IP
aws ecs describe-tasks --cluster ${ECS_CLUSTER_NAME} --tasks <task-arn>
```

### Issue: ECR authentication expired
```bash
# Re-authenticate
aws ecr get-login-password --region ${AWS_REGION} | \
    docker login --username AWS --password-stdin ${ECR_REPO_URI}
```

---

## 💰 Cost Management

### Estimated Monthly Costs
- **ECS Fargate (2 tasks):** ~$30/month
- **ECR Storage:** ~$0.05/month
- **Data Transfer:** ~$1-5/month
- **CloudWatch Logs:** ~$0.50/month
- **Total:** ~$32-36/month

### Free Tier Benefits
- First 12 months: Some services included
- Always free: 1M CloudWatch Logs per month

### ⚠️ IMPORTANT: Cleanup to Avoid Charges
```bash
# Delete ECS service
aws ecs update-service --cluster ${ECS_CLUSTER_NAME} \
    --service ${ECS_SERVICE_NAME} --desired-count 0
aws ecs delete-service --cluster ${ECS_CLUSTER_NAME} \
    --service ${ECS_SERVICE_NAME} --force

# Delete ECS cluster
aws ecs delete-cluster --cluster ${ECS_CLUSTER_NAME}

# Delete ECR repository
aws ecr delete-repository --repository-name ${ECR_REPO_NAME} --force

# See STEP_BY_STEP_GUIDE.md Phase 6 for complete cleanup
```

---

## 🎯 Quick Tips

### Tip 1: Save Your IDs
After creating AWS resources, save their IDs:
```bash
# Add to ~/.aws-ecs-env
echo "export VPC_ID=vpc-xxxxx" >> ~/.aws-ecs-env
echo "export ECS_SG_ID=sg-xxxxx" >> ~/.aws-ecs-env
source ~/.aws-ecs-env
```

### Tip 2: Use Named Profiles
For multiple AWS accounts:
```bash
aws configure --profile project-dev
export AWS_PROFILE=project-dev
```

### Tip 3: Monitor Costs
```bash
# Check current month costs
aws ce get-cost-and-usage \
    --time-period Start=2025-11-01,End=2025-11-30 \
    --granularity MONTHLY \
    --metrics BlendedCost
```

### Tip 4: View All Resources
```bash
# List all ECS clusters
aws ecs list-clusters

# List all ECR repositories
aws ecr describe-repositories

# List all VPCs
aws ec2 describe-vpcs
```

### Tip 5: Tail Logs in Real-Time
```bash
# Follow logs
aws logs tail /ecs/springmvc --follow

# Filter logs
aws logs tail /ecs/springmvc --filter-pattern "ERROR"
```

---

## 📞 Getting Help

### Documentation
- **AWS ECS:** https://docs.aws.amazon.com/ecs/
- **Spring MVC:** https://docs.spring.io/spring-framework/reference/web/webmvc.html
- **Docker:** https://docs.docker.com/

### Troubleshooting Steps
1. Check **BUG_ANALYSIS.md** for known issues
2. Review **STEP_BY_STEP_GUIDE.md** troubleshooting section
3. Check CloudWatch logs: `aws logs tail /ecs/springmvc`
4. Verify security groups and networking
5. Check IAM permissions

### Useful AWS CLI Help
```bash
# Get help for any command
aws ecs help
aws ecs create-service help

# List available commands
aws ecs <tab><tab>
```

---

## ✅ Pre-Deployment Checklist

Before deploying to production:

- [ ] All prerequisites installed and verified
- [ ] AWS credentials configured with proper permissions
- [ ] Application builds successfully (`mvn clean package`)
- [ ] Docker image builds without errors
- [ ] Application works locally (test with curl)
- [ ] Health check endpoint returns 200 OK
- [ ] Environment variables configured
- [ ] Security groups properly configured
- [ ] IAM roles created with correct permissions
- [ ] Cost estimation reviewed
- [ ] Cleanup plan documented

---

## 🎓 Learning Path

### Beginner
1. Complete Phase 0-2 (local development)
2. Understand Docker basics
3. Test application locally

### Intermediate
1. Complete Phase 3-5 (AWS deployment)
2. Understand VPC and networking
3. Learn ECS concepts

### Advanced
1. Add Application Load Balancer (Section 4)
2. Add CloudFront CDN (Section 5)
3. Implement auto-scaling
4. Set up CI/CD pipeline

---

## 🔄 Next Steps After Deployment

1. **Add Load Balancer**
   - Follow Section 4 of README.md
   - Distribute traffic across tasks
   - Enable health checks

2. **Add CloudFront**
   - Follow Section 5 of README.md
   - Improve global performance
   - Add HTTPS/SSL

3. **Implement Monitoring**
   - Set up CloudWatch dashboards
   - Create alarms for errors
   - Monitor costs

4. **Add Auto Scaling**
   - Configure service auto-scaling
   - Set up target tracking
   - Test scaling policies

5. **Implement CI/CD**
   - Set up GitLab/GitHub Actions
   - Automate builds and deployments
   - Add testing pipeline

---

**Last Updated:** 2025-11-30  
**Version:** 1.0  
**Maintained By:** Ona
