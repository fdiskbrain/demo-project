# EKS Cluster Configuration

module "eks" {
  source = "./modules/eks"

  count = var.enable_eks ? 1 : 0

  cluster_name       = "${var.project}-${var.environment}-eks"
  kubernetes_version = var.kubernetes_version

  vpc_id             = module.aws_vpc.vpc_id
  subnet_ids         = concat(module.aws_vpc.public_subnets, module.aws_vpc.private_subnets)
  private_subnet_ids = module.aws_vpc.private_subnets

  enable_public_endpoint = var.eks_enable_public_endpoint

  instance_types = var.eks_instance_types
  min_nodes      = var.eks_min_nodes
  max_nodes      = var.eks_max_nodes
  desired_nodes  = var.eks_desired_nodes

  tags = local.common_tags
}
