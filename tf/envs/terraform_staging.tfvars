# Staging Environment - 3 AZ VPC Configuration with EKS Cluster

name               = "demo-vpc"
project            = "demo-project"
environment        = "staging"
cidr               = "10.2.0.0/16"

# 3 Availability Zones
azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]

# 3 Public Subnets (1 per AZ) - /20 for staging environment (larger subnets)
public_subnets     = [
  "10.2.16.0/20",   # public-subnet-az1 (us-east-1a) - 4096 IPs
  "10.2.32.0/20",   # public-subnet-az2 (us-east-1b) - 4096 IPs
  "10.2.48.0/20",   # public-subnet-az3 (us-east-1c) - 4096 IPs
]

# 3 Private Subnets (1 per AZ) - /20 for staging environment (larger subnets)
private_subnets    = [
  "10.2.64.0/20",   # private-subnet-az1 (us-east-1a) - 4096 IPs
  "10.2.80.0/20",   # private-subnet-az2 (us-east-1b) - 4096 IPs
  "10.2.96.0/20",   # private-subnet-az3 (us-east-1c) - 4096 IPs
]

# NAT Gateway Configuration
single_nat_gateway      = false
one_nat_gateway_per_az  = true

# EKS Configuration - Staging environment
enable_eks              = true
kubernetes_version      = "1.34"
eks_instance_types      = ["t3.medium"]
eks_min_nodes           = 2
eks_max_nodes           = 5
eks_desired_nodes       = 2
eks_enable_public_endpoint = false
