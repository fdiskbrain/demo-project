# Production Environment - 3 AZ VPC Configuration with 1 Public and 1 Private Subnet per AZ

name               = "demo-vpc"
project            = "demo-project"
environment        = "prod"
cidr               = "10.4.0.0/16"

# 3 Availability Zones
azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]

# 3 Public Subnets (1 per AZ) - /20 for prod environment (larger subnets)
public_subnets     = [
  "10.4.16.0/20",   # public-subnet-az1 (us-east-1a) - 4096 IPs
  "10.4.32.0/20",   # public-subnet-az2 (us-east-1b) - 4096 IPs
  "10.4.48.0/20",   # public-subnet-az3 (us-east-1c) - 4096 IPs
]

# 3 Private Subnets (1 per AZ) - /20 for prod environment (larger subnets)
private_subnets    = [
  "10.4.64.0/20",   # private-subnet-az1 (us-east-1a) - 4096 IPs
  "10.4.80.0/20",   # private-subnet-az2 (us-east-1b) - 4096 IPs
  "10.4.96.0/20",   # private-subnet-az3 (us-east-1c) - 4096 IPs
]

# NAT Gateway Configuration - High availability for production
single_nat_gateway      = false
one_nat_gateway_per_az  = true
