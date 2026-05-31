variable "name" {
  description = "VPC name"
  type        = string
}

variable "cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnets" {
  description = "Public subnet CIDRs (3 subnets total - 1 per AZ)"
  type        = list(string)
  default     = [
    # AZ1 Public Subnet
    "10.0.1.0/24",   # public-subnet-az1
    # AZ2 Public Subnet
    "10.0.2.0/24",   # public-subnet-az2
    # AZ3 Public Subnet
    "10.0.3.0/24",   # public-subnet-az3
  ]
}

variable "private_subnets" {
  description = "Private subnet CIDRs (3 subnets total - 1 per AZ)"
  type        = list(string)
  default     = [
    # AZ1 Private Subnet
    "10.0.101.0/24",  # private-subnet-az1
    # AZ2 Private Subnet
    "10.0.102.0/24",  # private-subnet-az2
    # AZ3 Private Subnet
    "10.0.103.0/24",  # private-subnet-az3
  ]
}

variable "single_nat_gateway" {
  description = "Whether to use single NAT gateway"
  type        = bool
  default     = false  # Set to false for one NAT Gateway per AZ
}

variable "one_nat_gateway_per_az" {
  description = "Whether to create one NAT gateway per availability zone"
  type        = bool
  default     = true   # One NAT Gateway per AZ for high availability
}

variable "project" {
  description = "Project Name"
  type        = string
}

variable "environment" {
  description = "Environment Name"
  type        = string
  default     = "dev"
}
