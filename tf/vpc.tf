module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"

  #   count = var.cloud_provider == "aws" ? 1 : 0

  name = "${local.name_prefix}-vpc"
  cidr = var.cidr
  azs  = var.azs

  # 3 public subnets (1 per AZ)
  public_subnets = var.public_subnets

  # 3 private subnets (1 per AZ)
  private_subnets = var.private_subnets

  # NAT Gateway configuration - one per AZ
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  enable_nat_gateway = true
  enable_vpn_gateway = true

  # DNS configuration
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tags configuration
  tags = local.common_tags

  # Subnet tags - for identifying different purposes and EKS integration
  public_subnet_tags = merge({
    Name = "Public Subnet"
    Type = "public"
    # EKS tags for external load balancers
    "kubernetes.io/role/elb" = "1"
    }, var.enable_eks ? {
    "kubernetes.io/cluster/${var.project}-${var.environment}-eks" = "shared"
  } : {})

  private_subnet_tags = merge({
    Name = "Private Subnet"
    Type = "private"
    # EKS tags for internal load balancers
    "kubernetes.io/role/internal-elb" = "1"
    }, var.enable_eks ? {
    "kubernetes.io/cluster/${var.project}-${var.environment}-eks" = "shared"
  } : {})
}
