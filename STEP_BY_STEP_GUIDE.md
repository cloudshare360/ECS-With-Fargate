# Step-by-Step Implementation Guide
## AWS ECS Deployment with Spring MVC Application

This guide provides a complete walkthrough for deploying a Spring MVC application to AWS ECS with Fargate.

---

## 📋 Table of Contents

1. [Phase 0: Environment Setup](#phase-0-environment-setup)
2. [Phase 1: Build the Application](#phase-1-build-the-application)
3. [Phase 2: Containerize the Application](#phase-2-containerize-the-application)
4. [Phase 3: AWS Infrastructure Setup](#phase-3-aws-infrastructure-setup)
5. [Phase 4: Deploy to ECS](#phase-4-deploy-to-ecs)
6. [Phase 5: Testing and Verification](#phase-5-testing-and-verification)
7. [Phase 6: Cleanup](#phase-6-cleanup)
8. [Troubleshooting](#troubleshooting)

---

## Phase 0: Environment Setup

### Estimated Time: 30-45 minutes

Follow **Section 0** in the main README.md to complete:

#### Checklist:
- [ ] AWS Account created
- [ ] MFA enabled on root account
- [ ] IAM admin user created with proper permissions
- [ ] MFA enabled on IAM user
- [ ] AWS CLI installed
- [ ] AWS CLI configured with credentials
- [ ] Docker installed and running
- [ ] Maven installed
- [ ] Java 17 (Corretto) installed
- [ ] Environment variables configured
- [ ] Verification script passes all checks

#### Verification Command:
```bash
# Run the verification script
./verify-setup.sh

# All items should show ✅
```

#### Common Issues:
- **AWS CLI not found**: Ensure installation path is in your PATH
- **Docker daemon not running**: Start Docker Desktop or run `sudo systemctl start docker`
- **Permission denied on Docker**: Run `sudo usermod -aG docker $USER` and log out/in
- **AWS credentials error**: Re-run `aws configure` with correct credentials

---

## Phase 1: Build the Application

### Estimated Time: 20-30 minutes

### Step 1.1: Create Project Structure

```bash
# Create project directories
mkdir -p springmvc-hello-world/src/main/java/com/example/controller
mkdir -p springmvc-hello-world/src/main/java/com/example/config
mkdir -p springmvc-hello-world/src/main/webapp/WEB-INF/views
mkdir -p springmvc-hello-world/src/main/webapp/WEB-INF

# Navigate to project
cd springmvc-hello-world

# Verify structure
tree src/  # or use: find src/ -type d
```

**Expected Output:**
```
src/
└── main
    ├── java
    │   └── com
    │       └── example
    │           ├── config
    │           └── controller
    └── webapp
        └── WEB-INF
            └── views
```

### Step 1.2: Create pom.xml

Copy the `pom.xml` content from **Section 1.1.2** of README.md

```bash
# Create pom.xml
nano pom.xml  # or use your preferred editor
```

Paste the complete pom.xml content and save.

**Verify:**
```bash
# Validate pom.xml
mvn validate

# Should output: BUILD SUCCESS
```

### Step 1.3: Create Configuration Files

#### Create WebConfig.java:
```bash
nano src/main/java/com/example/config/WebConfig.java
```

Copy content from **Section 1.1.3** of README.md

#### Create WebAppInitializer.java:
```bash
nano src/main/java/com/example/config/WebAppInitializer.java
```

Copy content from **Section 1.1.3** of README.md

### Step 1.4: Create Controller

```bash
nano src/main/java/com/example/controller/HelloController.java
```

Copy content from **Section 1.1.4** of README.md

### Step 1.5: Create JSP Views

#### Create index.jsp:
```bash
nano src/main/webapp/WEB-INF/views/index.jsp
```

Copy content from **Section 1.1.5** of README.md

#### Create info.jsp:
```bash
nano src/main/webapp/WEB-INF/views/info.jsp
```

Copy content from **Section 1.1.5** of README.md

### Step 1.6: Build the Application

```bash
# Clean and build
mvn clean package

# This will:
# 1. Download dependencies
# 2. Compile Java code
# 3. Package into WAR file
```

**Expected Output:**
```
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  XX.XXX s
```

**Verify WAR file:**
```bash
ls -lh target/springmvc-hello-world.war

# Should show a file around 10-20 MB
```

#### Troubleshooting Build Issues:

**Issue: "Cannot resolve dependencies"**
```bash
# Clear Maven cache and retry
rm -rf ~/.m2/repository
mvn clean package
```

**Issue: "Java version mismatch"**
```bash
# Check Java version
java -version
javac -version

# Should both show version 17
# If not, set JAVA_HOME correctly
```

---

## Phase 2: Containerize the Application

### Estimated Time: 15-20 minutes

### Step 2.1: Create Dockerfile

```bash
# In project root (springmvc-hello-world/)
nano Dockerfile
```

Copy the **corrected** Dockerfile from **Section 1.2** of README.md (includes curl)

**Key points to verify:**
- ✅ `curl` is in the yum install line
- ✅ WAR file path is correct: `target/springmvc-hello-world.war`
- ✅ HEALTHCHECK uses curl

### Step 2.2: Create .dockerignore

```bash
nano .dockerignore
```

Copy the **enhanced** .dockerignore from **Section 1.2** of README.md

### Step 2.3: Build Docker Image

```bash
# Build the image
docker build -t springmvc-hello-world:1.0.0 .

# This will take 5-10 minutes on first build
```

**Expected Output:**
```
Successfully built <image-id>
Successfully tagged springmvc-hello-world:1.0.0
```

**Verify image:**
```bash
docker images | grep springmvc-hello-world

# Should show:
# springmvc-hello-world   1.0.0   <image-id>   X minutes ago   XXX MB
```

### Step 2.4: Test Locally

```bash
# Run container
docker run -d -p 8080:8080 --name springmvc-test springmvc-hello-world:1.0.0

# Wait 30 seconds for Tomcat to start
sleep 30

# Check container status
docker ps | grep springmvc-test

# Should show STATUS as "healthy"
```

**Test endpoints:**
```bash
# Test home page
curl http://localhost:8080/

# Should return HTML with "Hello World from Spring MVC!"

# Test health endpoint
curl http://localhost:8080/health

# Should return: {"status":"UP","timestamp":"..."}

# Test info endpoint
curl http://localhost:8080/info

# Should return HTML with application info
```

**View logs:**
```bash
docker logs springmvc-test

# Should show Tomcat startup logs without errors
```

**Check health status:**
```bash
docker inspect springmvc-test | grep -A 5 Health

# Should show "Status": "healthy"
```

### Step 2.5: Cleanup Test Container

```bash
# Stop and remove test container
docker stop springmvc-test
docker rm springmvc-test

# Verify removal
docker ps -a | grep springmvc-test
# Should return nothing
```

#### Troubleshooting Docker Issues:

**Issue: "Health check failing"**
```bash
# Check if curl is installed in container
docker run --rm springmvc-hello-world:1.0.0 which curl

# Should output: /usr/bin/curl
# If not, rebuild with curl in Dockerfile
```

**Issue: "Application not responding"**
```bash
# Check Tomcat logs
docker logs springmvc-test

# Look for errors like:
# - Port already in use
# - WAR file not found
# - Java exceptions
```

**Issue: "Port 8080 already in use"**
```bash
# Find what's using port 8080
sudo lsof -i :8080

# Kill the process or use different port
docker run -d -p 8081:8080 --name springmvc-test springmvc-hello-world:1.0.0
```

---

## Phase 3: AWS Infrastructure Setup

### Estimated Time: 30-45 minutes

### Step 3.1: Load Environment Variables

```bash
# Load AWS environment
source ~/.aws-ecs-env

# Verify
echo $AWS_REGION
echo $AWS_ACCOUNT_ID
echo $ECR_REPO_URI
```

### Step 3.2: Create ECR Repository

```bash
# Create ECR repository
aws ecr create-repository \
    --repository-name ${ECR_REPO_NAME} \
    --region ${AWS_REGION} \
    --image-scanning-configuration scanOnPush=true \
    --encryption-configuration encryptionType=AES256

# Save the repository URI
echo "ECR Repository URI: ${ECR_REPO_URI}"
```

**Expected Output:**
```json
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:us-east-1:...",
        "registryId": "123456789012",
        "repositoryName": "springmvc-hello-world",
        "repositoryUri": "123456789012.dkr.ecr.us-east-1.amazonaws.com/springmvc-hello-world"
    }
}
```

### Step 3.3: Push Image to ECR

```bash
# Authenticate Docker to ECR
aws ecr get-login-password --region ${AWS_REGION} | \
    docker login --username AWS --password-stdin ${ECR_REPO_URI}

# Should output: Login Succeeded

# Tag the image
docker tag springmvc-hello-world:1.0.0 ${ECR_REPO_URI}:1.0.0
docker tag springmvc-hello-world:1.0.0 ${ECR_REPO_URI}:latest

# Push the image (this will take a few minutes)
docker push ${ECR_REPO_URI}:1.0.0
docker push ${ECR_REPO_URI}:latest
```

**Verify image in ECR:**
```bash
aws ecr describe-images \
    --repository-name ${ECR_REPO_NAME} \
    --region ${AWS_REGION}

# Should show both tags: 1.0.0 and latest
```

### Step 3.4: Create VPC and Networking

Follow **Section 1.4** of README.md to create:

#### Create VPC:
```bash
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=ecs-springmvc-vpc}]' \
    --region ${AWS_REGION} \
    --query 'Vpc.VpcId' \
    --output text)

echo "VPC ID: ${VPC_ID}"

# Enable DNS
aws ec2 modify-vpc-attribute --vpc-id ${VPC_ID} --enable-dns-hostnames
aws ec2 modify-vpc-attribute --vpc-id ${VPC_ID} --enable-dns-support
```

#### Create Internet Gateway:
```bash
IGW_ID=$(aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=ecs-springmvc-igw}]' \
    --region ${AWS_REGION} \
    --query 'InternetGateway.InternetGatewayId' \
    --output text)

echo "Internet Gateway ID: ${IGW_ID}"

# Attach to VPC
aws ec2 attach-internet-gateway \
    --vpc-id ${VPC_ID} \
    --internet-gateway-id ${IGW_ID} \
    --region ${AWS_REGION}
```

#### Create Subnets:
```bash
# Public Subnet 1
PUBLIC_SUBNET_1=$(aws ec2 create-subnet \
    --vpc-id ${VPC_ID} \
    --cidr-block 10.0.1.0/24 \
    --availability-zone ${AWS_REGION}a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=ecs-public-subnet-1}]' \
    --region ${AWS_REGION} \
    --query 'Subnet.SubnetId' \
    --output text)

echo "Public Subnet 1 ID: ${PUBLIC_SUBNET_1}"

# Public Subnet 2
PUBLIC_SUBNET_2=$(aws ec2 create-subnet \
    --vpc-id ${VPC_ID} \
    --cidr-block 10.0.2.0/24 \
    --availability-zone ${AWS_REGION}b \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=ecs-public-subnet-2}]' \
    --region ${AWS_REGION} \
    --query 'Subnet.SubnetId' \
    --output text)

echo "Public Subnet 2 ID: ${PUBLIC_SUBNET_2}"

# Enable auto-assign public IP
aws ec2 modify-subnet-attribute --subnet-id ${PUBLIC_SUBNET_1} --map-public-ip-on-launch
aws ec2 modify-subnet-attribute --subnet-id ${PUBLIC_SUBNET_2} --map-public-ip-on-launch
```

#### Create Route Table:
```bash
ROUTE_TABLE_ID=$(aws ec2 create-route-table \
    --vpc-id ${VPC_ID} \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=ecs-public-rt}]' \
    --region ${AWS_REGION} \
    --query 'RouteTable.RouteTableId' \
    --output text)

echo "Route Table ID: ${ROUTE_TABLE_ID}"

# Create route to Internet Gateway
aws ec2 create-route \
    --route-table-id ${ROUTE_TABLE_ID} \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id ${IGW_ID} \
    --region ${AWS_REGION}

# Associate subnets
aws ec2 associate-route-table \
    --subnet-id ${PUBLIC_SUBNET_1} \
    --route-table-id ${ROUTE_TABLE_ID} \
    --region ${AWS_REGION}

aws ec2 associate-route-table \
    --subnet-id ${PUBLIC_SUBNET_2} \
    --route-table-id ${ROUTE_TABLE_ID} \
    --region ${AWS_REGION}
```

### Step 3.5: Create Security Groups

```bash
# Create Security Group for ECS Tasks
ECS_SG_ID=$(aws ec2 create-security-group \
    --group-name ecs-springmvc-sg \
    --description "Security group for ECS Spring MVC tasks" \
    --vpc-id ${VPC_ID} \
    --region ${AWS_REGION} \
    --query 'GroupId' \
    --output text)

echo "ECS Security Group ID: ${ECS_SG_ID}"

# Allow inbound HTTP traffic on port 8080
aws ec2 authorize-security-group-ingress \
    --group-id ${ECS_SG_ID} \
    --protocol tcp \
    --port 8080 \
    --cidr 0.0.0.0/0 \
    --region ${AWS_REGION}

# Allow all outbound traffic (default)
```

### Step 3.6: Save Infrastructure IDs

```bash
# Append to environment file
cat >> ~/.aws-ecs-env << EOF

# Infrastructure IDs
export VPC_ID="${VPC_ID}"
export IGW_ID="${IGW_ID}"
export PUBLIC_SUBNET_1="${PUBLIC_SUBNET_1}"
export PUBLIC_SUBNET_2="${PUBLIC_SUBNET_2}"
export ROUTE_TABLE_ID="${ROUTE_TABLE_ID}"
export ECS_SG_ID="${ECS_SG_ID}"
EOF

# Reload environment
source ~/.aws-ecs-env
```

---

## Phase 4: Deploy to ECS

### Estimated Time: 20-30 minutes

### Step 4.1: Create ECS Cluster

```bash
# Create Fargate cluster
aws ecs create-cluster \
    --cluster-name ${ECS_CLUSTER_NAME} \
    --region ${AWS_REGION} \
    --capacity-providers FARGATE FARGATE_SPOT \
    --default-capacity-provider-strategy \
        capacityProvider=FARGATE,weight=1,base=1 \
        capacityProvider=FARGATE_SPOT,weight=4

echo "ECS Cluster created: ${ECS_CLUSTER_NAME}"
```

### Step 4.2: Create IAM Roles

#### Create Task Execution Role:
```bash
# Create trust policy
cat > task-execution-trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create role
aws iam create-role \
    --role-name ecsTaskExecutionRole \
    --assume-role-policy-document file://task-execution-trust-policy.json

# Attach AWS managed policy
aws iam attach-role-policy \
    --role-name ecsTaskExecutionRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

# Get role ARN
TASK_EXECUTION_ROLE_ARN=$(aws iam get-role \
    --role-name ecsTaskExecutionRole \
    --query 'Role.Arn' \
    --output text)

echo "Task Execution Role ARN: ${TASK_EXECUTION_ROLE_ARN}"
```

### Step 4.3: Create Task Definition

```bash
# Create task definition JSON
cat > task-definition.json << EOF
{
  "family": "springmvc-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "${TASK_EXECUTION_ROLE_ARN}",
  "containerDefinitions": [
    {
      "name": "springmvc-container",
      "image": "${ECR_REPO_URI}:latest",
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      },
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/springmvc",
          "awslogs-region": "${AWS_REGION}",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
EOF

# Create CloudWatch log group
aws logs create-log-group \
    --log-group-name /ecs/springmvc \
    --region ${AWS_REGION}

# Register task definition
aws ecs register-task-definition \
    --cli-input-json file://task-definition.json \
    --region ${AWS_REGION}

echo "Task definition registered"
```

### Step 4.4: Create ECS Service

```bash
# Create service
aws ecs create-service \
    --cluster ${ECS_CLUSTER_NAME} \
    --service-name ${ECS_SERVICE_NAME} \
    --task-definition springmvc-task \
    --desired-count 2 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[${PUBLIC_SUBNET_1},${PUBLIC_SUBNET_2}],securityGroups=[${ECS_SG_ID}],assignPublicIp=ENABLED}" \
    --region ${AWS_REGION}

echo "ECS Service created: ${ECS_SERVICE_NAME}"
```

---

## Phase 5: Testing and Verification

### Estimated Time: 10-15 minutes

### Step 5.1: Check Service Status

```bash
# Check service status
aws ecs describe-services \
    --cluster ${ECS_CLUSTER_NAME} \
    --services ${ECS_SERVICE_NAME} \
    --region ${AWS_REGION} \
    --query 'services[0].{Status:status,Running:runningCount,Desired:desiredCount}'

# Wait for tasks to be running (may take 2-3 minutes)
```

### Step 5.2: Get Task Public IPs

```bash
# List tasks
TASK_ARNS=$(aws ecs list-tasks \
    --cluster ${ECS_CLUSTER_NAME} \
    --service-name ${ECS_SERVICE_NAME} \
    --region ${AWS_REGION} \
    --query 'taskArns[]' \
    --output text)

# Get task details and public IPs
for TASK_ARN in $TASK_ARNS; do
    echo "Task: $TASK_ARN"
    
    # Get ENI ID
    ENI_ID=$(aws ecs describe-tasks \
        --cluster ${ECS_CLUSTER_NAME} \
        --tasks $TASK_ARN \
        --region ${AWS_REGION} \
        --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' \
        --output text)
    
    # Get public IP
    PUBLIC_IP=$(aws ec2 describe-network-interfaces \
        --network-interface-ids $ENI_ID \
        --region ${AWS_REGION} \
        --query 'NetworkInterfaces[0].Association.PublicIp' \
        --output text)
    
    echo "Public IP: $PUBLIC_IP"
    echo "---"
done
```

### Step 5.3: Test Application

```bash
# Test each task (replace <PUBLIC_IP> with actual IP from above)
PUBLIC_IP="<replace-with-actual-ip>"

# Test home page
curl http://${PUBLIC_IP}:8080/

# Test health endpoint
curl http://${PUBLIC_IP}:8080/health

# Test info endpoint
curl http://${PUBLIC_IP}:8080/info
```

### Step 5.4: View Logs

```bash
# View CloudWatch logs
aws logs tail /ecs/springmvc --follow --region ${AWS_REGION}

# Press Ctrl+C to stop following logs
```

---

## Phase 6: Cleanup

### Estimated Time: 10-15 minutes

**Important:** Run these commands to avoid AWS charges!

```bash
# 1. Delete ECS Service
aws ecs update-service \
    --cluster ${ECS_CLUSTER_NAME} \
    --service ${ECS_SERVICE_NAME} \
    --desired-count 0 \
    --region ${AWS_REGION}

aws ecs delete-service \
    --cluster ${ECS_CLUSTER_NAME} \
    --service ${ECS_SERVICE_NAME} \
    --force \
    --region ${AWS_REGION}

# 2. Delete ECS Cluster
aws ecs delete-cluster \
    --cluster ${ECS_CLUSTER_NAME} \
    --region ${AWS_REGION}

# 3. Deregister Task Definitions
aws ecs list-task-definitions \
    --family-prefix springmvc-task \
    --region ${AWS_REGION} \
    --query 'taskDefinitionArns[]' \
    --output text | \
    xargs -I {} aws ecs deregister-task-definition --task-definition {} --region ${AWS_REGION}

# 4. Delete CloudWatch Log Group
aws logs delete-log-group \
    --log-group-name /ecs/springmvc \
    --region ${AWS_REGION}

# 5. Delete ECR Repository
aws ecr delete-repository \
    --repository-name ${ECR_REPO_NAME} \
    --force \
    --region ${AWS_REGION}

# 6. Delete Security Group
aws ec2 delete-security-group \
    --group-id ${ECS_SG_ID} \
    --region ${AWS_REGION}

# 7. Delete Route Table Associations
aws ec2 disassociate-route-table \
    --association-id $(aws ec2 describe-route-tables \
        --route-table-ids ${ROUTE_TABLE_ID} \
        --query 'RouteTables[0].Associations[0].RouteTableAssociationId' \
        --output text) \
    --region ${AWS_REGION}

aws ec2 disassociate-route-table \
    --association-id $(aws ec2 describe-route-tables \
        --route-table-ids ${ROUTE_TABLE_ID} \
        --query 'RouteTables[0].Associations[1].RouteTableAssociationId' \
        --output text) \
    --region ${AWS_REGION}

# 8. Delete Route Table
aws ec2 delete-route-table \
    --route-table-id ${ROUTE_TABLE_ID} \
    --region ${AWS_REGION}

# 9. Delete Subnets
aws ec2 delete-subnet --subnet-id ${PUBLIC_SUBNET_1} --region ${AWS_REGION}
aws ec2 delete-subnet --subnet-id ${PUBLIC_SUBNET_2} --region ${AWS_REGION}

# 10. Detach and Delete Internet Gateway
aws ec2 detach-internet-gateway \
    --internet-gateway-id ${IGW_ID} \
    --vpc-id ${VPC_ID} \
    --region ${AWS_REGION}

aws ec2 delete-internet-gateway \
    --internet-gateway-id ${IGW_ID} \
    --region ${AWS_REGION}

# 11. Delete VPC
aws ec2 delete-vpc --vpc-id ${VPC_ID} --region ${AWS_REGION}

# 12. Delete IAM Role
aws iam detach-role-policy \
    --role-name ecsTaskExecutionRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

aws iam delete-role --role-name ecsTaskExecutionRole

echo "Cleanup complete!"
```

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: Task fails to start

**Symptoms:** Tasks keep stopping and restarting

**Solutions:**
```bash
# Check task stopped reason
aws ecs describe-tasks \
    --cluster ${ECS_CLUSTER_NAME} \
    --tasks <task-arn> \
    --region ${AWS_REGION} \
    --query 'tasks[0].stoppedReason'

# Check CloudWatch logs
aws logs tail /ecs/springmvc --region ${AWS_REGION}

# Common causes:
# - Health check failing (curl not installed)
# - Insufficient memory/CPU
# - Image pull errors (ECR permissions)
```

#### Issue: Cannot access application

**Symptoms:** curl times out or connection refused

**Solutions:**
```bash
# Verify security group allows port 8080
aws ec2 describe-security-groups \
    --group-ids ${ECS_SG_ID} \
    --region ${AWS_REGION}

# Verify task has public IP
# (Check Step 5.2 output)

# Verify task is healthy
aws ecs describe-tasks \
    --cluster ${ECS_CLUSTER_NAME} \
    --tasks <task-arn> \
    --region ${AWS_REGION} \
    --query 'tasks[0].healthStatus'
```

#### Issue: Image push to ECR fails

**Symptoms:** "denied: Your authorization token has expired"

**Solutions:**
```bash
# Re-authenticate to ECR
aws ecr get-login-password --region ${AWS_REGION} | \
    docker login --username AWS --password-stdin ${ECR_REPO_URI}

# Retry push
docker push ${ECR_REPO_URI}:latest
```

#### Issue: AWS CLI commands fail

**Symptoms:** "Unable to locate credentials"

**Solutions:**
```bash
# Verify AWS configuration
aws configure list

# Re-configure if needed
aws configure

# Check credentials are valid
aws sts get-caller-identity
```

---

## Next Steps

After successfully deploying to ECS:

1. **Add Application Load Balancer** - See Section 4 of README.md
2. **Add CloudFront CDN** - See Section 5 of README.md
3. **Implement Auto Scaling** - Configure service auto scaling
4. **Add CI/CD Pipeline** - Automate deployments
5. **Implement Monitoring** - Set up CloudWatch dashboards and alarms

---

## Cost Estimation

**Approximate monthly costs (us-east-1):**

- **ECS Fargate (2 tasks, 0.5 vCPU, 1GB RAM):** ~$30/month
- **ECR Storage (1 image, ~500MB):** ~$0.05/month
- **Data Transfer:** ~$1-5/month (depending on usage)
- **CloudWatch Logs:** ~$0.50/month

**Total:** ~$32-36/month

**Free Tier Benefits:**
- First 12 months: Some services included in free tier
- Always free: 1M CloudWatch Logs ingestion per month

---

## Support and Resources

- **AWS Documentation:** https://docs.aws.amazon.com/ecs/
- **Spring MVC Documentation:** https://docs.spring.io/spring-framework/reference/web/webmvc.html
- **Docker Documentation:** https://docs.docker.com/
- **Tomcat Documentation:** https://tomcat.apache.org/tomcat-10.1-doc/

---

**Guide Version:** 1.0  
**Last Updated:** 2025-11-30  
**Maintained By:** Ona
