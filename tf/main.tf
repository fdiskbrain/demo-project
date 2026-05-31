# Main configuration file for 3-AZ VPC with EKS cluster

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Project   = var.project
    }
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

locals {
  common_tags = {
    project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  name_prefix   = "${var.project}-${var.environment}"
  is_production = var.environment == "prod" ? true : false

}
