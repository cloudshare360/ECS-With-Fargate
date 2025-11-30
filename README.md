# ECS-With-Fargate

# AWS ECS Deployment Guide: Spring MVC Application with JSP and Servlets

## Requirements

This comprehensive guide covers the following deployment scenarios for a Spring MVC application with JSP and Servlets on Tomcat 10.1.49:

1. **AWS ECS - Manual Approach - Step by Step Instructions**
   - ECS with Multiple Containers with auto scaling and scale down
2. **AWS ECS with Fargate**
3. **AWS ECS with Fargate with Side Car**
4. **AWS Enable Application Load Balancer**
5. **Add CloudFront**

### Technology Stack
- **Application Framework**: Spring MVC with JSP and Servlets
- **Application Server**: Apache Tomcat 10.1.49
- **Base Image**: Amazon Linux 2023
- **Java Version**: Amazon Corretto 17
- **Container Orchestration**: AWS ECS (Elastic Container Service)
- **Compute Options**: EC2 and AWS Fargate
- **Load Balancing**: Application Load Balancer (ALB)
- **CDN**: Amazon CloudFront
- **Monitoring**: CloudWatch, Container Insights
- **CI/CD**: GitLab CI/CD (future phase)
- **Infrastructure as Code**: Terraform (future phase)

### Prerequisites
- AWS Account with appropriate permissions
- AWS CLI installed and configured
- Docker installed locally
- Basic understanding of Spring MVC, JSP, and Servlets
- Git installed
- Text editor or IDE

---

## Section 1: AWS ECS - Manual Approach

### 1.1 Create a Simple Spring MVC Application with JSP

#### Step 1.1.1: Create Project Structure

```bash
mkdir -p springmvc-hello-world/src/main/java/com/example/controller
mkdir -p springmvc-hello-world/src/main/java/com/example/config
mkdir -p springmvc-hello-world/src/main/webapp/WEB-INF/views
mkdir -p springmvc-hello-world/src/main/webapp/WEB-INF
cd springmvc-hello-world
```

#### Step 1.1.2: Create pom.xml

Create `pom.xml` in the root directory:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <groupId>com.example</groupId>
    <artifactId>springmvc-hello-world</artifactId>
    <version>1.0.0</version>
    <packaging>war</packaging>
    
    <name>Spring MVC Hello World</name>
    
    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <spring.version>6.0.11</spring.version>
    </properties>
    
    <dependencies>
        <!-- Spring MVC -->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-webmvc</artifactId>
            <version>${spring.version}</version>
        </dependency>
        
        <!-- Servlet API -->
        <dependency>
            <groupId>jakarta.servlet</groupId>
            <artifactId>jakarta.servlet-api</artifactId>
            <version>6.0.0</version>
            <scope>provided</scope>
        </dependency>
        
        <!-- JSP API -->
        <dependency>
            <groupId>jakarta.servlet.jsp</groupId>
            <artifactId>jakarta.servlet.jsp-api</artifactId>
            <version>3.1.1</version>
            <scope>provided</scope>
        </dependency>
        
        <!-- JSTL -->
        <dependency>
            <groupId>jakarta.servlet.jsp.jstl</groupId>
            <artifactId>jakarta.servlet.jsp.jstl-api</artifactId>
            <version>3.0.0</version>
        </dependency>
        
        <dependency>
            <groupId>org.glassfish.web</groupId>
            <artifactId>jakarta.servlet.jsp.jstl</artifactId>
            <version>3.0.1</version>
        </dependency>
        
        <!-- Actuator-like health endpoint -->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
            <version>${spring.version}</version>
        </dependency>
    </dependencies>
    
    <build>
        <finalName>springmvc-hello-world</finalName>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-war-plugin</artifactId>
                <version>3.3.2</version>
                <configuration>
                    <failOnMissingWebXml>false</failOnMissingWebXml>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.11.0</version>
                <configuration>
                    <source>17</source>
                    <target>17</target>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

#### Step 1.1.3: Create Spring Configuration

Create `src/main/java/com/example/config/WebConfig.java`:

```java
package com.example.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.view.InternalResourceViewResolver;
import org.springframework.web.servlet.view.JstlView;

@Configuration
@EnableWebMvc
@ComponentScan(basePackages = "com.example.controller")
public class WebConfig implements WebMvcConfigurer {
    
    @Bean
    public InternalResourceViewResolver viewResolver() {
        InternalResourceViewResolver viewResolver = new InternalResourceViewResolver();
        viewResolver.setViewClass(JstlView.class);
        viewResolver.setPrefix("/WEB-INF/views/");
        viewResolver.setSuffix(".jsp");
        return viewResolver;
    }
    
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/static/**")
                .addResourceLocations("/static/");
    }
}
```

Create `src/main/java/com/example/config/WebAppInitializer.java`:

```java
package com.example.config;

import org.springframework.web.servlet.support.AbstractAnnotationConfigDispatcherServletInitializer;

public class WebAppInitializer extends AbstractAnnotationConfigDispatcherServletInitializer {
    
    @Override
    protected Class<?>[] getRootConfigClasses() {
        return null;
    }
    
    @Override
    protected Class<?>[] getServletConfigClasses() {
        return new Class[] { WebConfig.class };
    }
    
    @Override
    protected String[] getServletMappings() {
        return new String[] { "/" };
    }
}
```

#### Step 1.1.4: Create Controller

Create `src/main/java/com/example/controller/HelloController.java`:

```java
package com.example.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.net.InetAddress;

@Controller
public class HelloController {
    
    @GetMapping("/")
    public String home(Model model) {
        model.addAttribute("message", "Hello World from Spring MVC!");
        model.addAttribute("timestamp", LocalDateTime.now()
            .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        
        try {
            String hostname = InetAddress.getLocalHost().getHostName();
            model.addAttribute("hostname", hostname);
        } catch (Exception e) {
            model.addAttribute("hostname", "Unknown");
        }
        
        return "index";
    }
    
    @GetMapping("/health")
    @ResponseBody
    public String health() {
        return "{\"status\":\"UP\",\"timestamp\":\"" + 
               LocalDateTime.now().toString() + "\"}";
    }
    
    @GetMapping("/info")
    public String info(Model model) {
        model.addAttribute("appName", "Spring MVC Hello World");
        model.addAttribute("version", "1.0.0");
        model.addAttribute("javaVersion", System.getProperty("java.version"));
        model.addAttribute("tomcatVersion", "10.1.49");
        
        return "info";
    }
}
```

#### Step 1.1.5: Create JSP Views

Create `src/main/webapp/WEB-INF/views/index.jsp`:

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Spring MVC Hello World</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            border-bottom: 3px solid #007bff;
            padding-bottom: 10px;
        }
        .info {
            background-color: #e7f3ff;
            padding: 15px;
            border-left: 4px solid #007bff;
            margin: 20px 0;
        }
        .links {
            margin-top: 20px;
        }
        .links a {
            display: inline-block;
            margin-right: 15px;
            color: #007bff;
            text-decoration: none;
        }
        .links a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>${message}</h1>
        
        <div class="info">
            <p><strong>Container Hostname:</strong> ${hostname}</p>
            <p><strong>Current Time:</strong> ${timestamp}</p>
            <p><strong>Application:</strong> Running on AWS ECS</p>
        </div>
        
        <div class="links">
            <a href="/health">Health Check</a>
            <a href="/info">Application Info</a>
        </div>
    </div>
</body>
</html>
```

Create `src/main/webapp/WEB-INF/views/info.jsp`:

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Application Info</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #007bff;
            color: white;
        }
        a {
            color: #007bff;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Application Information</h1>
        
        <table>
            <tr>
                <th>Property</th>
                <th>Value</th>
            </tr>
            <tr>
                <td>Application Name</td>
                <td>${appName}</td>
            </tr>
            <tr>
                <td>Version</td>
                <td>${version}</td>
            </tr>
            <tr>
                <td>Java Version</td>
                <td>${javaVersion}</td>
            </tr>
            <tr>
                <td>Tomcat Version</td>
                <td>${tomcatVersion}</td>
            </tr>
        </table>
        
        <p style="margin-top: 20px;">
            <a href="/">← Back to Home</a>
        </p>
    </div>
</body>
</html>
```

#### Step 1.1.6: Build the Application

```bash
# Build the WAR file
mvn clean package

# Verify the WAR file is created
ls -lh target/springmvc-hello-world.war
```

---

### 1.2 Create Dockerfile

Create `Dockerfile` in the project root:

```dockerfile
# Use Amazon Linux 2023 as base image
FROM amazonlinux:2023

# Set maintainer label
LABEL maintainer="your-email@example.com"
LABEL description="Spring MVC Hello World on Tomcat 10.1.49 with Amazon Corretto 17"

# Install Amazon Corretto 17 and required tools
RUN yum update -y && \
    yum install -y java-17-amazon-corretto-devel wget tar curl && \
    yum clean all

# Verify Java installation
RUN java -version

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
ENV PATH=$PATH:$JAVA_HOME/bin

# Set Tomcat version
ENV TOMCAT_VERSION=10.1.49
ENV CATALINA_HOME=/opt/tomcat

# Download and install Tomcat
RUN wget https://archive.apache.org/dist/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/tomcat.tar.gz && \
    mkdir -p ${CATALINA_HOME} && \
    tar xzf /tmp/tomcat.tar.gz -C ${CATALINA_HOME} --strip-components=1 && \
    rm /tmp/tomcat.tar.gz && \
    rm -rf ${CATALINA_HOME}/webapps/*

# Copy the WAR file
COPY target/springmvc-hello-world.war ${CATALINA_HOME}/webapps/ROOT.war

# Create tomcat user
RUN groupadd -r tomcat && \
    useradd -r -g tomcat -d ${CATALINA_HOME} -s /sbin/nologin tomcat && \
    chown -R tomcat:tomcat ${CATALINA_HOME}

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Switch to tomcat user
USER tomcat

# Set working directory
WORKDIR ${CATALINA_HOME}

# Start Tomcat
CMD ["bin/catalina.sh", "run"]
```

Create `.dockerignore`:

```
target/
.git/
.gitignore
*.md
.mvn/
mvnw
mvnw.cmd
.idea/
.vscode/
.settings/
*.iml
.DS_Store
*.log
.env
.env.*
```

#### Step 1.2.1: Build Docker Image Locally

```bash
# Build the Docker image
docker build -t springmvc-hello-world:1.0.0 .

# Test the image locally
docker run -d -p 8080:8080 --name springmvc-test springmvc-hello-world:1.0.0

# Check if it's running
docker ps

# Test the application
curl http://localhost:8080/
curl http://localhost:8080/health

# View logs
docker logs springmvc-test

# Stop and remove the test container
docker stop springmvc-test
docker rm springmvc-test
```

---

### 1.3 Setup AWS Infrastructure

#### Step 1.3.1: Create Amazon ECR Repository

```bash
# Set variables
AWS_REGION="us-east-1"
ECR_REPO_NAME="springmvc-hello-world"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create ECR repository
aws ecr create-repository \
    --repository-name ${ECR_REPO_NAME} \
    --region ${AWS_REGION} \
    --image-scanning-configuration scanOnPush=true \
    --encryption-configuration encryptionType=AES256

# Get the repository URI
ECR_REPO_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
echo "ECR Repository URI: ${ECR_REPO_URI}"
```

#### Step 1.3.2: Push Docker Image to ECR

```bash
# Authenticate Docker to ECR
aws ecr get-login-password --region ${AWS_REGION} | \
    docker login --username AWS --password-stdin ${ECR_REPO_URI}

# Tag the image
docker tag springmvc-hello-world:1.0.0 ${ECR_REPO_URI}:1.0.0
docker tag springmvc-hello-world:1.0.0 ${ECR_REPO_URI}:latest

# Push the image
docker push ${ECR_REPO_URI}:1.0.0
docker push ${ECR_REPO_URI}:latest

# Verify the image is in ECR
aws ecr describe-images \
    --repository-name ${ECR_REPO_NAME} \
    --region ${AWS_REGION}
```

---

### 1.4 Create VPC and Networking

#### Step 1.4.1: Create VPC

```bash
# Create VPC
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=ecs-springmvc-vpc}]' \
    --region ${AWS_REGION} \
    --query 'Vpc.VpcId' \
    --output text)

echo "VPC ID: ${VPC_ID}"

# Enable DNS hostname support
aws ec2 modify-vpc-attribute \
    --vpc-id ${VPC_ID} \
    --enable-dns-hostnames

aws ec2 modify-vpc-attribute \
    --vpc-id ${VPC_ID} \
    --enable-dns-support
```

#### Step 1.4.2: Create Internet Gateway

```bash
# Create Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=ecs-springmvc-igw}]' \
    --region ${AWS_REGION} \
    --query 'InternetGateway.InternetGatewayId' \
    --output text)

echo "Internet Gateway ID: ${IGW_ID}"

# Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway \
    --vpc-id ${VPC_ID} \
    --internet-gateway-id ${IGW_ID} \
    --region ${AWS_REGION}
```

#### Step 1.4.3: Create Public Subnets

```bash
# Create Public Subnet 1 (us-east-1a)
PUBLIC_SUBNET_1=$(aws ec2 create-subnet \
    --vpc-id ${VPC_ID} \
    --cidr-block 10.0.1.0/24 \
    --availability-zone ${AWS_REGION}a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=ecs-public-subnet-1}]' \
    --region ${AWS_REGION} \
    --query 'Subnet.SubnetId' \
    --output text)

echo "Public Subnet 1 ID: ${PUBLIC_SUBNET_1}"

# Create Public Subnet 2 (us-east-1b)
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
aws ec2 modify-subnet-attribute \
    --subnet-id ${PUBLIC_SUBNET_1} \
    --map-public-ip-on-launch

aws ec2 modify-subnet-attribute \
    --subnet-id ${PUBLIC_SUBNET_2} \
    --map-public-ip-on-launch
```

#### Step 1.4.4: Create Route Table

```bash
# Create Route Table
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

# Associate subnets with route table
aws ec2 associate-route-table \
    --subnet-id ${PUBLIC_SUBNET_1} \
    --route-table-id ${ROUTE_TABLE_ID} \
    --region ${AWS_REGION}

aws ec2 associate-route-table \
    --subnet-id ${PUBLIC_SUBNET_2} \
    --route-table-id ${ROUTE_TABLE_ID} \
    --region ${AWS_REGION}
```

---

### 1.5 Create Security Groups

#### Step 1.5.1: Create ECS Task Security Group

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

# Allow inbound traffic on port 8080
aws ec2 authorize-security-group-ingress \
    --group-id ${ECS_SG_ID} \
    --protocol tcp \
    --port 8080 \
    --cidr 0.0.0.0/0 \
    --region ${AWS_REGION}

# Allow all outbound traffic (default, but explicitly setting)
aws ec2 authorize-security-group-egress \
    --group-id ${ECS_SG_ID} \
    --protocol -1 \
    --cidr 0.0.0.0/0 \
    --region ${AWS_REGION} 2>/dev/null || true
```

---

### 1.6 Create IAM Roles

#### Step 1.6.1: Create ECS Task Execution Role

Create `ecs-task-execution-role-trust-policy.json`:

```json
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
```

```bash
# Create the role
aws iam create-role \
    --role-name ecsTaskExecutionRole \
    --assume-role-policy-document file://ecs-task-execution-role-trust-policy.json

# Attach the AWS managed policy
aws iam attach-role-policy \
    --role-name ecsTaskExecutionRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

# Get the role ARN
TASK_EXECUTION_ROLE_ARN=$(aws iam get-role \
    --role-name ecsTaskExecutionRole \
    --query 'Role.Arn' \
    --output text)

echo "Task Execution Role ARN: ${TASK_EXECUTION_ROLE_ARN}"
```

#### Step 1.6.2: Create ECS Task Role (for CloudWatch logging)

Create `ecs-task-role-trust-policy.json`:

```json
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
```

Create `ecs-task-role-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricData"
      ],
      "Resource": "*"
    }
  ]
}
```

```bash
# Create the role
aws iam create-role \
    --role-name ecsTaskRole \
    --assume-role-policy-document file://ecs-task-role-trust-policy.json

# Create and attach the policy
aws iam put-role-policy \
    --role-name ecsTaskRole \
    --policy-name ecsTaskRolePolicy \
    --policy-document file://ecs-task-role-policy.json

# Get the role ARN
TASK_ROLE_ARN=$(aws iam get-role \
    --role-name ecsTaskRole \
    --query 'Role.Arn' \
    --output text)

echo "Task Role ARN: ${TASK_ROLE_ARN}"
```

---

### 1.7 Create CloudWatch Log Group

```bash
# Create log group
aws logs create-log-group \
    --log-group-name /ecs/springmvc-hello-world \
    --region ${AWS_REGION}

# Set retention policy (optional - 7 days)
aws logs put-retention-policy \
    --log-group-name /ecs/springmvc-hello-world \
    --retention-in-days 7 \
    --region ${AWS_REGION}
```

---

### 1.8 Create ECS Cluster

```bash
# Create ECS cluster
CLUSTER_NAME="springmvc-cluster"

aws ecs create-cluster \
    --cluster-name ${CLUSTER_NAME} \
    --region ${AWS_REGION} \
    --settings name=containerInsights,value=enabled

# Verify cluster creation
aws ecs describe-clusters \
    --clusters ${CLUSTER_NAME} \
    --region ${AWS_REGION}
```

---

### 1.9 Create ECS Task Definition

Create `springmvc-task-definition.json`:

```json
{
  "family": "springmvc-hello-world",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["EC2", "FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "TASK_EXECUTION_ROLE_ARN_PLACEHOLDER",
  "taskRoleArn": "TASK_ROLE_ARN_PLACEHOLDER",
  "containerDefinitions": [
    {
      "name": "springmvc-app",
      "image": "ECR_REPO_URI_PLACEHOLDER:latest",
      "cpu": 512,
      "memory": 1024,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "JAVA_OPTS",
          "value": "-Xms512m -Xmx1024m"
        }
      ],
      "healthCheck": {
        "command": [
          "CMD-SHELL",
          "curl -f http://localhost:8080/health || exit 1"
        ],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      },
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/springmvc-hello-world",
          "awslogs-region": "AWS_REGION_PLACEHOLDER",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

```bash
# Replace placeholders
sed -i "s|TASK_EXECUTION_ROLE_ARN_PLACEHOLDER|${TASK_EXECUTION_ROLE_ARN}|g" springmvc-task-definition.json
sed -i "s|TASK_ROLE_ARN_PLACEHOLDER|${TASK_ROLE_ARN}|g" springmvc-task-definition.json
sed -i "s|ECR_REPO_URI_PLACEHOLDER|${ECR_REPO_URI}|g" springmvc-task-definition.json
sed -i "s|AWS_REGION_PLACEHOLDER|${AWS_REGION}|g" springmvc-task-definition.json

# Register task definition
aws ecs register-task-definition \
    --cli-input-json file://springmvc-task-definition.json \
    --region ${AWS_REGION}

# Verify task definition
aws ecs describe-task-definition \
    --task-definition springmvc-hello-world \
    --region ${AWS_REGION}
```

---

### 1.10 Create ECS Service (EC2 Launch Type)

#### Step 1.10.1: Create EC2 Launch Configuration

First, we need EC2 instances in our ECS cluster.

Create `ecs-instance-role-trust-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

```bash
# Create EC2 instance role for ECS
aws iam create-role \
    --role-name ecsInstanceRole \
    --assume-role-policy-document file://ecs-instance-role-trust-policy.json

# Attach AWS managed policy
aws iam attach-role-policy \
    --role-name ecsInstanceRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role

# Create instance profile
aws iam create-instance-profile \
    --instance-profile-name ecsInstanceProfile

# Add role to instance profile
aws iam add-role-to-instance-profile \
    --instance-profile-name ecsInstanceProfile \
    --role-name ecsInstanceRole

# Wait for the instance profile to be ready
sleep 10
```

Create user data script `ecs-user-data.sh`:

```bash
#!/bin/bash
echo ECS_CLUSTER=springmvc-cluster >> /etc/ecs/ecs.config
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
```

```bash
# Get the latest ECS-optimized AMI
ECS_AMI_ID=$(aws ssm get-parameters \
    --names /aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id \
    --region ${AWS_REGION} \
    --query 'Parameters[0].Value' \
    --output text)

echo "ECS AMI ID: ${ECS_AMI_ID}"

# Create EC2 Security Group for ECS instances
EC2_SG_ID=$(aws ec2 create-security-group \
    --group-name ecs-ec2-instance-sg \
    --description "Security group for ECS EC2 instances" \
    --vpc-id ${VPC_ID} \
    --region ${AWS_REGION} \
    --query 'GroupId' \
    --output text)

echo "EC2 Security Group ID: ${EC2_SG_ID}"

# Allow SSH (optional, for debugging)
aws ec2 authorize-security-group-ingress \
    --group-id ${EC2_SG_ID} \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0 \
    --region ${AWS_REGION}

# Allow all traffic from ECS task security group
aws ec2 authorize-security-group-ingress \
    --group-id ${EC2_SG_ID} \
    --protocol -1 \
    --source-group ${ECS_SG_ID} \
    --region ${AWS_REGION}

# Launch EC2 instances for ECS cluster
# Note: You'll need to have an EC2 key pair created. Replace 'your-key-name' with your actual key pair name
# If you don't have one, create it first:
# aws ec2 create-key-pair --key-name ecs-key --query 'KeyMaterial' --output text > ecs-key.pem
# chmod 400 ecs-key.pem

# Launch instance 1
INSTANCE_ID_1=$(aws ec2 run-instances \
    --image-id ${ECS_AMI_ID} \
    --instance-type t3.small \
    --iam-instance-profile Name=ecsInstanceProfile \
    --security-group-ids ${EC2_SG_ID} \
    --subnet-id ${PUBLIC_SUBNET_1} \
    --user-data file://ecs-user-data.sh \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ecs-instance-1}]' \
    --region ${AWS_REGION} \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "Instance 1 ID: ${INSTANCE_ID_1}"

# Wait for instances to be running and registered with ECS
echo "Waiting for EC2 instance to be registered with ECS cluster..."
sleep 60

# Check container instances
aws ecs list-container-instances \
    --cluster ${CLUSTER_NAME} \
    --region ${AWS_REGION}
```

#### Step 1.10.2: Create ECS Service

```bash
# Create ECS service with EC2 launch type
aws ecs create-service \
    --cluster ${CLUSTER_NAME} \
    --service-name springmvc-service \
    --task-definition springmvc-hello-world \
    --desired-count 1 \
    --launch-type EC2 \
    --network-configuration "awsvpcConfiguration={subnets=[${PUBLIC_SUBNET_1},${PUBLIC_SUBNET_2}],securityGroups=[${ECS_SG_ID}],assignPublicIp=ENABLED}" \
    --region ${AWS_REGION}

# Verify service is running
aws ecs describe-services \
    --cluster ${CLUSTER_NAME} \
    --services springmvc-service \
    --region ${AWS_REGION}

# List running tasks
aws ecs list-tasks \
    --cluster ${CLUSTER_NAME} \
    --service-name springmvc-service \
    --region ${AWS_REGION}
```

#### Step 1.10.3: Get Public IP and Test

```bash
# Get task ARN
TASK_ARN=$(aws ecs list-tasks \
    --cluster ${CLUSTER_NAME} \
    --service-name springmvc-service \
    --region ${AWS_REGION} \
    --query 'taskArns[0]' \
    --output text)

echo "Task ARN: ${TASK_ARN}"

# Get task details
aws ecs describe-tasks \
    --cluster ${CLUSTER_NAME} \
    --tasks ${TASK_ARN} \
    --region ${AWS_REGION}

# Get the ENI ID
ENI_ID=$(aws ecs describe-tasks \
    --cluster ${CLUSTER_NAME} \
    --tasks ${TASK_ARN} \
    --region ${AWS_REGION} \
    --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' \
    --output text)

echo "ENI ID: ${ENI_ID}"

# Get public IP
PUBLIC_IP=$(aws ec2 describe-network-interfaces \
    --network-interface-ids ${ENI_ID} \
    --region ${AWS_REGION} \
    --query 'NetworkInterfaces[0].Association.PublicIp' \
    --output text)

echo "Public IP: ${PUBLIC_IP}"

# Test the application
curl http://${PUBLIC_IP}:8080/
curl http://${PUBLIC_IP}:8080/health
curl http://${PUBLIC_IP}:8080/info
```

---

### 1.11 Configure Auto Scaling (EC2 Launch Type)

#### Step 1.11.1: Create Auto Scaling Target

```bash
# Register scalable target
aws application-autoscaling register-scalable-target \
    --service-namespace ecs \
    --resource-id service/${CLUSTER_NAME}/springmvc-service \
    --scalable-dimension ecs:service:DesiredCount \
    --min-capacity 1 \
    --max-capacity 5 \
    --region ${AWS_REGION}
```

#### Step 1.11.2: Create Scale-Out Policy

Create `scale-out-policy.json`:

```json
{
  "TargetValue": 70.0,
  "PredefinedMetricSpecification": {
    "PredefinedMetricType": "ECSServiceAverageCPUUtilization"
  },
  "ScaleOutCooldown": 60,
  "ScaleInCooldown": 60
}
```

```bash
# Create scaling policy
aws application-autoscaling put-scaling-policy \
    --service-namespace ecs \
    --resource-id service/${CLUSTER_NAME}/springmvc-service \
    --scalable-dimension ecs:service:DesiredCount \
    --policy-name springmvc-cpu-scaling-policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-scaling-policy-configuration file://scale-out-policy.json \
    --region ${AWS_REGION}
```

#### Step 1.11.3: Verify Auto Scaling Configuration

```bash
# Describe scaling policies
aws application-autoscaling describe-scaling-policies \
    --service-namespace ecs \
    --resource-id service/${CLUSTER_NAME}/springmvc-service \
    --region ${AWS_REGION}

# Describe scalable targets
aws application-autoscaling describe-scalable-targets \
    --service-namespace ecs \
    --resource-ids service/${CLUSTER_NAME}/springmvc-service \
    --region ${AWS_REGION}
```

---

### 1.12 Enable CloudWatch Container Insights

```bash
# Container Insights was already enabled during cluster creation
# Verify it's enabled
aws ecs describe-clusters \
    --clusters ${CLUSTER_NAME} \
    --include SETTINGS \
    --region ${AWS_REGION} \
    --query 'clusters[0].settings'

# View metrics in CloudWatch Console or via CLI
aws cloudwatch get-metric-statistics \
    --namespace AWS/ECS \
    --metric-name CPUUtilization \
    --dimensions Name=ServiceName,Value=springmvc-service Name=ClusterName,Value=${CLUSTER_NAME} \
    --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
    --period 300 \
    --statistics Average \
    --region ${AWS_REGION}
```

---

### 1.13 Monitoring and Logging

#### Step 1.13.1: View CloudWatch Logs

```bash
# List log streams
aws logs describe-log-streams \
    --log-group-name /ecs/springmvc-hello-world \
    --order-by LastEventTime \
    --descending \
    --max-items 5 \
    --region ${AWS_REGION}

# Get latest log stream name
LOG_STREAM=$(aws logs describe-log-streams \
    --log-group-name /ecs/springmvc-hello-world \
    --order-by LastEventTime \
    --descending \
    --max-items 1 \
    --region ${AWS_REGION} \
    --query 'logStreams[0].logStreamName' \
    --output text)

# View logs
aws logs get-log-events \
    --log-group-name /ecs/springmvc-hello-world \
    --log-stream-name ${LOG_STREAM} \
    --limit 50 \
    --region ${AWS_REGION}
```

#### Step 1.13.2: Create CloudWatch Dashboard

Create `dashboard-config.json`:

```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/ECS", "CPUUtilization", {"stat": "Average"}],
          [".", "MemoryUtilization", {"stat": "Average"}]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "ECS Service Metrics",
        "yAxis": {
          "left": {
            "min": 0,
            "max": 100
          }
        }
      }
    }
  ]
}
```

```bash
# Create dashboard
aws cloudwatch put-dashboard \
    --dashboard-name SpringMVC-ECS-Dashboard \
    --dashboard-body file://dashboard-config.json \
    --region ${AWS_REGION}
```

---

## Section 2: AWS ECS with Fargate

### 2.1 Create Fargate Task Definition

Create `springmvc-fargate-task-definition.json`:

```json
{
  "family": "springmvc-fargate",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "TASK_EXECUTION_ROLE_ARN_PLACEHOLDER",
  "taskRoleArn": "TASK_ROLE_ARN_PLACEHOLDER",
  "containerDefinitions": [
    {
      "name": "springmvc-app",
      "image": "ECR_REPO_URI_PLACEHOLDER:latest",
      "cpu": 512,
      "memory": 1024,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "JAVA_OPTS",
          "value": "-Xms512m -Xmx1024m"
        },
        {
          "name": "LAUNCH_TYPE",
          "value": "FARGATE"
        }
      ],
      "healthCheck": {
        "command": [
          "CMD-SHELL",
          "curl -f http://localhost:8080/health || exit 1"
        ],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      },
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/springmvc-fargate",
          "awslogs-region": "AWS_REGION_PLACEHOLDER",
          "awslogs-stream-prefix": "fargate"
        }
      }
    }
  ]
}
```

```bash
# Create log group for Fargate
aws logs create-log-group \
    --log-group-name /ecs/springmvc-fargate \
    --region ${AWS_REGION}

aws logs put-retention-policy \
    --log-group-name /ecs/springmvc-fargate \
    --retention-in-days 7 \
    --region ${AWS_REGION}

# Replace placeholders
sed "s|TASK_EXECUTION_ROLE_ARN_PLACEHOLDER|${TASK_EXECUTION_ROLE_ARN}|g" springmvc-fargate-task-definition.json | \
sed "s|TASK_ROLE_ARN_PLACEHOLDER|${TASK_ROLE_ARN}|g" | \
sed "s|ECR_REPO_URI_PLACEHOLDER|${ECR_REPO_URI}|g" | \
sed "s|AWS_REGION_PLACEHOLDER|${AWS_REGION}|g" > springmvc-fargate-task-definition-final.json

# Register Fargate task definition
aws ecs register-task-definition \
    --cli-input-json file://springmvc-fargate-task-definition-final.json \
    --region ${AWS_REGION}
```

### 2.2 Create Fargate Service

```bash
# Create Fargate service
aws ecs create-service \
    --cluster ${CLUSTER_NAME} \
    --service-name springmvc-fargate-service \
    --task-definition springmvc-fargate \
    --desired-count 2 \
    --launch-type FARGATE \
    --platform-version LATEST \
    --network-configuration "awsvpcConfiguration={subnets=[${PUBLIC_SUBNET_1},${PUBLIC_SUBNET_2}],securityGroups=[${ECS_SG_ID}],assignPublicIp=ENABLED}" \
    --region ${AWS_REGION}

# Verify service
aws ecs describe-services \
    --cluster ${CLUSTER_NAME} \
    --services springmvc-fargate-service \
    --region ${AWS_REGION}
```

### 2.3 Configure Fargate Auto Scaling

```bash
# Register scalable target for Fargate
aws application-autoscaling register-scalable-target \
    --service-namespace ecs \
    --resource-id service/${CLUSTER_NAME}/springmvc-fargate-service \
    --scalable-dimension ecs:service:DesiredCount \
    --min-capacity 2 \
    --max-capacity 10 \
    --region ${AWS_REGION}

# Create scaling policy for Fargate
aws application-autoscaling put-scaling-policy \
    --service-namespace ecs \
    --resource-id service/${CLUSTER_NAME}/springmvc-fargate-service \
    --scalable-dimension ecs:service:DesiredCount \
    --policy-name springmvc-fargate-cpu-scaling \
    --policy-type TargetTrackingScaling \
    --target-tracking-scaling-policy-configuration file://scale-out-policy.json \
    --region ${AWS_REGION}
```

### 2.4 Test Fargate Deployment

```bash
# Get Fargate task ARNs
FARGATE_TASKS=$(aws ecs list-tasks \
    --cluster ${CLUSTER_NAME} \
    --service-name springmvc-fargate-service \
    --region ${AWS_REGION} \
    --query 'taskArns' \
    --output text)

# Get first task
FARGATE_TASK=$(echo ${FARGATE_TASKS} | awk '{print $1}')

# Get task details
aws ecs describe-tasks \
    --cluster ${CLUSTER_NAME} \
    --tasks ${FARGATE_TASK} \
    --region ${AWS_REGION}

# Get ENI and Public IP
FARGATE_ENI=$(aws ecs describe-tasks \
    --cluster ${CLUSTER_NAME} \
    --tasks ${FARGATE_TASK} \
    --region ${AWS_REGION} \
    --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' \
    --output text)

FARGATE_PUBLIC_IP=$(aws ec2 describe-network-interfaces \
    --network-interface-ids ${FARGATE_ENI} \
    --region ${AWS_REGION} \
    --query 'NetworkInterfaces[0].Association.PublicIp' \
    --output text)

echo "Fargate Task Public IP: ${FARGATE_PUBLIC_IP}"

# Test the application
curl http://${FARGATE_PUBLIC_IP}:8080/
curl http://${FARGATE_PUBLIC_IP}:8080/health
```

---

## Section 3: AWS ECS with Fargate and Sidecar Container

### 3.1 Create Sidecar Container (Fluent Bit for Log Aggregation)

Create `springmvc-fargate-sidecar-task-definition.json`:

```json
{
  "family": "springmvc-fargate-sidecar",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "1024",
  "memory": "2048",
  "executionRoleArn": "TASK_EXECUTION_ROLE_ARN_PLACEHOLDER",
  "taskRoleArn": "TASK_ROLE_ARN_PLACEHOLDER",
  "containerDefinitions": [
    {
      "name": "springmvc-app",
      "image": "ECR_REPO_URI_PLACEHOLDER:latest",
      "cpu": 512,
      "memory": 1024,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "JAVA_OPTS",
          "value": "-Xms512m -Xmx1024m"
        },
        {
          "name": "LAUNCH_TYPE",
          "value": "FARGATE_SIDECAR"
        }
      ],
      "healthCheck": {
        "command": [
          "CMD-SHELL",
          "curl -f http://localhost:8080/health || exit 1"
        ],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      },
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/springmvc-fargate-sidecar",
          "awslogs-region": "AWS_REGION_PLACEHOLDER",
          "awslogs-stream-prefix": "app"
        }
      },
      "dependsOn": [
        {
          "containerName": "log-router",
          "condition": "START"
        }
      ]
    },
    {
      "name": "log-router",
      "image": "public.ecr.aws/aws-observability/aws-for-fluent-bit:latest",
      "cpu": 512,
      "memory": 1024,
      "essential": true,
      "firelensConfiguration": {
        "type": "fluentbit",
        "options": {
          "enable-ecs-log-metadata": "true"
        }
      },
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/springmvc-fargate-sidecar",
          "awslogs-region": "AWS_REGION_PLACEHOLDER",
          "awslogs-stream-prefix": "firelens"
        }
      }
    }
  ]
}
```

### 3.2 Register and Deploy Sidecar Task

```bash
# Create log group
aws logs create-log-group \
    --log-group-name /ecs/springmvc-fargate-sidecar \
    --region ${AWS_REGION}

# Replace placeholders
sed "s|TASK_EXECUTION_ROLE_ARN_PLACEHOLDER|${TASK_EXECUTION_ROLE_ARN}|g" springmvc-fargate-sidecar-task-definition.json | \
sed "s|TASK_ROLE_ARN_PLACEHOLDER|${TASK_ROLE_ARN}|g" | \
sed "s|ECR_REPO_URI_PLACEHOLDER|${ECR_REPO_URI}|g" | \
sed "s|AWS_REGION_PLACEHOLDER|${AWS_REGION}|g" > springmvc-fargate-sidecar-final.json

# Register task definition
aws ecs register-task-definition \
    --cli-input-json file://springmvc-fargate-sidecar-final.json \
    --region ${AWS_REGION}

# Create service with sidecar
aws ecs create-service \
    --cluster ${CLUSTER_NAME} \
    --service-name springmvc-sidecar-service \
    --task-definition springmvc-fargate-sidecar \
    --desired-count 2 \
    --launch-type FARGATE \
    --platform-version LATEST \
    --network-configuration "awsvpcConfiguration={subnets=[${PUBLIC_SUBNET_1},${PUBLIC_SUBNET_2}],securityGroups=[${ECS_SG_ID}],assignPublicIp=ENABLED}" \
    --region ${AWS_REGION}
```

---

## Section 4: Enable Application Load Balancer

### 4.1 Create Application Load Balancer

```bash
# Create ALB Security Group
ALB_SG_ID=$(aws ec2 create-security-group \
    --group-name springmvc-alb-sg \
    --description "Security group for Spring MVC ALB" \
    --vpc-id ${VPC_ID} \
    --region ${AWS_REGION} \
    --query 'GroupId' \
    --output text)

echo "ALB Security Group ID: ${ALB_SG_ID}"

# Allow HTTP traffic
aws ec2 authorize-security-group-ingress \
    --group-id ${ALB_SG_ID} \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0 \
    --region ${AWS_REGION}

# Allow HTTPS traffic (optional)
aws ec2 authorize-security-group-ingress \
    --group-id ${ALB_SG_ID} \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0 \
    --region ${AWS_REGION}

# Update ECS security group to allow traffic from ALB
aws ec2 authorize-security-group-ingress \
    --group-id ${ECS_SG_ID} \
    --protocol tcp \
    --port 8080 \
    --source-group ${ALB_SG_ID} \
    --region ${AWS_REGION}

# Create Application Load Balancer
ALB_ARN=$(aws elbv2 create-load-balancer \
    --name springmvc-alb \
    --subnets ${PUBLIC_SUBNET_1} ${PUBLIC_SUBNET_2} \
    --security-groups ${ALB_SG_ID} \
    --scheme internet-facing \
    --type application \
    --ip-address-type ipv4 \
    --region ${AWS_REGION} \
    --query 'LoadBalancers[0].LoadBalancerArn' \
    --output text)

echo "ALB ARN: ${ALB_ARN}"

# Get ALB DNS name
ALB_DNS=$(aws elbv2 describe-load-balancers \
    --load-balancer-arns ${ALB_ARN} \
    --region ${AWS_REGION} \
    --query 'LoadBalancers[0].DNSName' \
    --output text)

echo "ALB DNS Name: ${ALB_DNS}"
```

### 4.2 Create Target Group

```bash
# Create Target Group
TARGET_GROUP_ARN=$(aws elbv2 create-target-group \
    --name springmvc-tg \
    --protocol HTTP \
    --port 8080 \
    --vpc-id ${VPC_ID} \
    --target-type ip \
    --health-check-enabled \
    --health-check-protocol HTTP \
    --health-check-path /health \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3 \
    --region ${AWS_REGION} \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text)

echo "Target Group ARN: ${TARGET_GROUP_ARN}"
```

### 4.3 Create Listener

```bash
# Create HTTP Listener
LISTENER_ARN=$(aws elbv2 create-listener \
    --load-balancer-arn ${ALB_ARN} \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=${TARGET_GROUP_ARN} \
    --region ${AWS_REGION} \
    --query 'Listeners[0].ListenerArn' \
    --output text)

echo "Listener ARN: ${LISTENER_ARN}"
```

### 4.4 Update ECS Service to Use ALB

```bash
# Update Fargate service to use ALB
aws ecs update-service \
    --cluster ${CLUSTER_NAME} \
    --service springmvc-fargate-service \
    --load-balancers "targetGroupArn=${TARGET_GROUP_ARN},containerName=springmvc-app,containerPort=8080" \
    --health-check-grace-period-seconds 60 \
    --region ${AWS_REGION}

# Wait for service to stabilize
aws ecs wait services-stable \
    --cluster ${CLUSTER_NAME} \
    --services springmvc-fargate-service \
    --region ${AWS_REGION}

# Test via ALB
echo "Testing application via ALB:"
curl http://${ALB_DNS}/
curl http://${ALB_DNS}/health
curl http://${ALB_DNS}/info
```

Alternatively, create a new service with ALB from the start:

```bash
# Create new Fargate service with ALB
aws ecs create-service \
    --cluster ${CLUSTER_NAME} \
    --service-name springmvc-alb-service \
    --task-definition springmvc-fargate \
    --desired-count 3 \
    --launch-type FARGATE \
    --platform-version LATEST \
    --load-balancers "targetGroupArn=${TARGET_GROUP_ARN},containerName=springmvc-app,containerPort=8080" \
    --network-configuration "awsvpcConfiguration={subnets=[${PUBLIC_SUBNET_1},${PUBLIC_SUBNET_2}],securityGroups=[${ECS_SG_ID}],assignPublicIp=ENABLED}" \
    --health-check-grace-period-seconds 60 \
    --region ${AWS_REGION}
```

---

## Section 5: Add CloudFront Distribution

### 5.1 Create CloudFront Distribution

Create `cloudfront-distribution-config.json`:

```json
{
  "CallerReference": "springmvc-cf-TIMESTAMP",
  "Comment": "CloudFront distribution for Spring MVC application",
  "Enabled": true,
  "DefaultCacheBehavior": {
    "TargetOriginId": "springmvc-alb-origin",
    "ViewerProtocolPolicy": "redirect-to-https",
    "AllowedMethods": {
      "Quantity": 7,
      "Items": ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"],
      "CachedMethods": {
        "Quantity": 2,
        "Items": ["GET", "HEAD"]
      }
    },
    "ForwardedValues": {
      "QueryString": true,
      "Cookies": {
        "Forward": "all"
      },
      "Headers": {
        "Quantity": 3,
        "Items": ["Host", "CloudFront-Forwarded-Proto", "User-Agent"]
      }
    },
    "MinTTL": 0,
    "DefaultTTL": 86400,
    "MaxTTL": 31536000,
    "Compress": true,
    "TrustedSigners": {
      "Enabled": false,
      "Quantity": 0
    }
  },
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "springmvc-alb-origin",
        "DomainName": "ALB_DNS_PLACEHOLDER",
        "CustomOriginConfig": {
          "HTTPPort": 80,
          "HTTPSPort": 443,
          "OriginProtocolPolicy": "http-only",
          "OriginSslProtocols": {
            "Quantity": 3,
            "Items": ["TLSv1", "TLSv1.1", "TLSv1.2"]
          }
        }
      }
    ]
  },
  "PriceClass": "PriceClass_100"
}
```

```bash
# Replace placeholder with actual ALB DNS
TIMESTAMP=$(date +%s)
sed "s|ALB_DNS_PLACEHOLDER|${ALB_DNS}|g" cloudfront-distribution-config.json | \
sed "s|TIMESTAMP|${TIMESTAMP}|g" > cloudfront-distribution-final.json

# Create CloudFront distribution
CF_DISTRIBUTION_ID=$(aws cloudfront create-distribution \
    --distribution-config file://cloudfront-distribution-final.json \
    --region ${AWS_REGION} \
    --query 'Distribution.Id' \
    --output text)

echo "CloudFront Distribution ID: ${CF_DISTRIBUTION_ID}"

# Get CloudFront domain name
CF_DOMAIN=$(aws cloudfront get-distribution \
    --id ${CF_DISTRIBUTION_ID} \
    --query 'Distribution.DomainName' \
    --output text)

echo "CloudFront Domain: ${CF_DOMAIN}"

# Wait for distribution to be deployed (this can take 15-20 minutes)
echo "Waiting for CloudFront distribution to deploy (this may take 15-20 minutes)..."
aws cloudfront wait distribution-deployed \
    --id ${CF_DISTRIBUTION_ID}

echo "CloudFront distribution deployed!"
echo "Access your application at: https://${CF_DOMAIN}"
```

### 5.2 Test CloudFront Distribution

```bash
# Test via CloudFront (wait for deployment to complete first)
curl https://${CF_DOMAIN}/
curl https://${CF_DOMAIN}/health
curl https://${CF_DOMAIN}/info
```

### 5.3 Create Invalidation (when updating content)

```bash
# Create cache invalidation
aws cloudfront create-invalidation \
    --distribution-id ${CF_DISTRIBUTION_ID} \
    --paths "/*"
```

---

## Summary of Resources Created

### Infrastructure
- **VPC**: 10.0.0.0/16
- **Public Subnets**: 2 (10.0.1.0/24, 10.0.2.0/24)
- **Internet Gateway**: Attached to VPC
- **Security Groups**: ECS tasks, EC2 instances, ALB
- **IAM Roles**: Task execution role, task role, EC2 instance role

### Container Services
- **ECR Repository**: springmvc-hello-world
- **ECS Cluster**: springmvc-cluster (with Container Insights enabled)
- **Task Definitions**: EC2, Fargate, Fargate with sidecar
- **Services**: EC2 service, Fargate service, Fargate sidecar service, ALB-backed service

### Load Balancing & CDN
- **Application Load Balancer**: internet-facing
- **Target Group**: Health checks on /health endpoint
- **CloudFront Distribution**: HTTPS enabled, caching configured

### Monitoring
- **CloudWatch Log Groups**: /ecs/springmvc-hello-world, /ecs/springmvc-fargate, /ecs/springmvc-fargate-sidecar
- **Container Insights**: Enabled for cluster-level metrics
- **Auto Scaling**: CPU-based scaling for both EC2 and Fargate services

---

## Next Steps

This completes the manual setup. In the next phases, you'll:
1. Set up GitLab CI/CD pipelines for automated deployments
2. Convert all manual steps to Terraform for Infrastructure as Code

Would you like me to create the GitLab CI/CD configuration and Terraform modules next?