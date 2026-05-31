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
  default = [
    # AZ1 Public Subnet
    "10.0.1.0/24", # public-subnet-az1
    # AZ2 Public Subnet
    "10.0.2.0/24", # public-subnet-az2
    # AZ3 Public Subnet
    "10.0.3.0/24", # public-subnet-az3
  ]
}

variable "private_subnets" {
  description = "Private subnet CIDRs (3 subnets total - 1 per AZ)"
  type        = list(string)
  default = [
    # AZ1 Private Subnet
    "10.0.101.0/24", # private-subnet-az1
    # AZ2 Private Subnet
    "10.0.102.0/24", # private-subnet-az2
    # AZ3 Private Subnet
    "10.0.103.0/24", # private-subnet-az3
  ]
}

variable "single_nat_gateway" {
  description = "Whether to use single NAT gateway"
  type        = bool
  default     = false # Set to false for one NAT Gateway per AZ
}

variable "one_nat_gateway_per_az" {
  description = "Whether to create one NAT gateway per availability zone"
  type        = bool
  default     = true # One NAT Gateway per AZ for high availability
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

# EKS Configuration Variables
variable "enable_eks" {
  description = "Whether to enable EKS cluster deployment"
  type        = bool
  default     = false
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.34"
}

variable "eks_instance_types" {
  description = "List of instance types for EKS node groups"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_min_nodes" {
  description = "Minimum number of nodes in EKS node group"
  type        = number
  default     = 1
}

variable "eks_max_nodes" {
  description = "Maximum number of nodes in EKS node group"
  type        = number
  default     = 3
}

variable "eks_desired_nodes" {
  description = "Desired number of nodes in EKS node group"
  type        = number
  default     = 1
}

variable "eks_enable_public_endpoint" {
  description = "Whether to enable public endpoint for EKS cluster"
  type        = bool
  default     = false
}
