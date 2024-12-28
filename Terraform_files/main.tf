provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.27"
  subnets        = var.subnets
  vpc_id          = var.vpc_id

  node_groups = {
    webapp = {
      desired_capacity = 2
      max_size         = 3
      min_size         = 1
      instance_type    = "t3.medium"
    }
  }
}