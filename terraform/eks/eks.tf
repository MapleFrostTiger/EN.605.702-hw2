provider "aws" {
  region = "us-east-1"
}

# EKS Cluster and Node Group
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "order-processing-cluster"
  cluster_version = "1.31"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  # Node groups
  node_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_size         = 3
      min_size         = 1
      instance_type    = "t3.medium"
    }
  }
}
