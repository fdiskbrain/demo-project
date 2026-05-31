# Performance Test Environment - 3 AZ VPC Configuration with 1 Public and 1 Private Subnet per AZ

name               = "demo-vpc"
project            = "demo-project"
environment        = "perf"
cidr               = "10.3.0.0/16"

# 3 Availability Zones
azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]

# 3 Public Subnets (1 per AZ) - /20 for perf environment (larger subnets)
public_subnets     = [
  "10.3.16.0/20",   # public-subnet-az1 (us-east-1a) - 4096 IPs
  "10.3.32.0/20",   # public-subnet-az2 (us-east-1b) - 4096 IPs
  "10.3.48.0/20",   # public-subnet-az3 (us-east-1c) - 4096 IPs
]

# 3 Private Subnets (1 per AZ) - /20 for perf environment (larger subnets)
private_subnets    = [
  "10.3.64.0/20",   # private-subnet-az1 (us-east-1a) - 4096 IPs
  "10.3.80.0/20",   # private-subnet-az2 (us-east-1b) - 4096 IPs
  "10.3.96.0/20",   # private-subnet-az3 (us-east-1c) - 4096 IPs
]

# NAT Gateway Configuration
single_nat_gateway      = false
one_nat_gateway_per_az  = true
