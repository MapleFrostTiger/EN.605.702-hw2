variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "backend_image_id" {
  description = "ECR Image ID for the backend processor"
  type        = string
}

variable "frontend_image_id" {
  description = "ECR Image ID for the frontend web server"
  type        = string
}

variable "database_image_id" {
  description = "ECR Image ID for the frontend web server"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}

variable "subnet_id" {
  description = "VPC Subnet ID for resources"
  type        = string
}

variable "subnet_id2" {
  description = "Additional VPC Subnet ID for resources requiring multi-AZ deployment"
  type        = string
}