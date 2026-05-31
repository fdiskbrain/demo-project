# Dev Environment - 3 AZ VPC Configuration with EKS Cluster

name               = "demo-vpc"
project            = "demo-project"
environment        = "dev"
cidr               = "10.0.0.0/16"

# 3 Availability Zones
azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]

# 3 Public Subnets (1 per AZ) - /24 for dev environment
public_subnets     = [
  "10.0.1.0/24",   # public-subnet-az1 (us-east-1a)
  "10.0.2.0/24",   # public-subnet-az2 (us-east-1b)
  "10.0.3.0/24",   # public-subnet-az3 (us-east-1c)
]

# 3 Private Subnets (1 per AZ) - /24 for dev environment
private_subnets    = [
  "10.0.101.0/24",  # private-subnet-az1 (us-east-1a)
  "10.0.102.0/24",  # private-subnet-az2 (us-east-1b)
  "10.0.103.0/24",  # private-subnet-az3 (us-east-1c)
]

# NAT Gateway Configuration
single_nat_gateway      = true
one_nat_gateway_per_az  = false

# EKS Configuration
enable_eks              = true
kubernetes_version      = "1.34"
eks_instance_types      = ["t3.medium"]
eks_min_nodes           = 1
eks_max_nodes           = 3
eks_desired_nodes       = 1
eks_enable_public_endpoint = false
