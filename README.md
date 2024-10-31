# **EN.605.702 Project 2**

This project implements a **Distributed Order Processing System** using **Docker**, **Kubernetes (EKS)**, **microservices**, **AWS CodePipeline**, and **Terraform** for infrastructure as code. The system manages e-commerce orders and includes a frontend, order processing microservice, and a PostgreSQL database. It is deployed on AWS with a CI/CD pipeline via AWS CodePipeline.

This README provides instructions on:

1. Building and pushing Docker images to Amazon ECR.
2. Configuring environment-specific Terraform variables.
3. Deploying AWS infrastructure and application components using Terraform.
---

## **Prerequisites**

Before building and deploying the project, ensure you have the following:

1. **AWS CLI**: [Install and configure AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).
2. **Docker**: [Install Docker](https://docs.docker.com/get-docker/) to build and manage containers.
3. **Packer**: [Install Packer](https://www.packer.io/downloads) if generating AMIs for additional resources.
4. **Terraform**: [Install Terraform](https://www.terraform.io/downloads) to deploy infrastructure.
5. **Amazon ECR Repository**: Amazon ECR repositories to host Docker images for the frontend and order processor microservices.

---

## **Project Setup**

### **1. Configure `terraform.tfvars`**

The `terraform.tfvars` file defines environment-specific variables required for deployment. Before running Terraform, update this file with your AWS configuration details and application settings.

#### **Example `terraform.tfvars`**

```hcl
aws_access_key      = "<YOUR_VALUE_HERE>"
aws_secret_key      = "<YOUR_VALUE_HERE>"
backend_image_id    = "<YOUR_VALUE_HERE>"
frontend_image_id   = "<YOUR_VALUE_HERE>"
database_image_id   = "<YOUR_VALUE_HERE>"
db_username         = "<YOUR_VALUE_HERE>"
db_password         = "<YOUR_VALUE_HERE>"
subnet_id           = "<YOUR_VALUE_HERE>"
subnet_id2          = "<YOUR_VALUE_HERE>"
```

Replace the placeholders with your values.
### **2. Build and Push Docker Images**

This project includes Docker images for the **frontend** and **order processor** microservices. You’ll need to build and push these images to Amazon ECR.

#### **2.1 Build Docker Images**

Navigate to the project directory for each service and build the Docker images.

- **Frontend Microservice**:

  ```bash
  cd docker/frontend
  docker build -t frontend .
  ```

- **Order Processor Microservice**:

  ```bash
  cd docker/order-processor
  docker build -t order-processor .
  ```

#### **2.2 Tag and Push Docker Images to ECR**

1. **Log in to ECR**:

   ```bash
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
   ```

2. **Tag the Docker Images**:

   ```bash
   docker tag frontend:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/frontend:latest
   docker tag order-processor:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/order-processor:latest
   ```

3. **Push the Docker Images to ECR**:

   ```bash
   docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/frontend:latest
   docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/order-processor:latest
   ```

Replace `<account-id>` with your AWS account ID.

### **3. Deploy the Infrastructure Using Terraform**

This project uses Terraform to set up the necessary AWS infrastructure, including EKS, CodePipeline, and associated services.

#### **3.1 Initialize Terraform**

Navigate to the root `terraform` directory and initialize Terraform to download required providers and modules.

```bash
cd terraform
terraform init
```

#### **3.2 Plan the Terraform Deployment**

Generate an execution plan to review the resources that Terraform will create:

```bash
terraform plan
```

#### **3.3 Apply the Terraform Configuration**

Apply the Terraform configuration to create the infrastructure:

```bash
terraform apply
```

Confirm with `yes` when prompted. Terraform will deploy the EKS cluster, CodePipeline, CodeBuild projects, ECR repositories, and other AWS resources.

---

## **CI/CD Pipeline Configuration (CodePipeline)**

AWS CodePipeline is configured to automate the build and deployment process:

1. **Source Stage**: CodePipeline pulls the latest code from your GitHub repository.
2. **Build Stage**: CodeBuild builds the Docker images, pushes them to ECR, and deploys the Kubernetes manifests to the EKS cluster.
3. **Deploy Stage**: CodePipeline applies Kubernetes manifests to EKS, updating the microservices.

---

## **Kubernetes Deployment**

### **4. Kubernetes Manifests**

Kubernetes manifests for each microservice are located in the `kubernetes/` directory:

- **frontend-deployment.yaml**: Deploys the frontend microservice.
- **order-processor-deployment.yaml**: Deploys the order processor microservice.
- **postgres-deployment.yaml**: Deploys the PostgreSQL database.
- **values.yaml**: Stores helm values used by multiple deployments.

### **5. Accessing the Application**

After deployment, you can access the frontend via the Kubernetes service IP. The frontend will allow users to place orders, which the order processor microservice will read and store in the PostgreSQL database.

---

## **Verification**

1. **Access the Frontend Microservice**:
    - Get the service IP from Kubernetes and visit the frontend microservice’s endpoint.

2. **Order Processing**:
    - Verify that orders are processed and stored in PostgreSQL. You can connect to PostgreSQL to query the database for stored orders.

3. **Monitor Pipeline**:
    - Check AWS CodePipeline to confirm that the pipeline is running successfully and deploying updates automatically.

---

## **Cleaning Up**

To avoid incurring charges, destroy the infrastructure when testing is complete:

```bash
terraform destroy
```

Confirm with `yes` to proceed, and Terraform will remove all resources created by the configuration.
