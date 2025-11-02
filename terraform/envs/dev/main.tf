terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.region
}

locals {
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
}

# VPC
module "vpc" {
  source               = "../../modules/vpc"
  name                 = "lab02-vpc"
  cidr                 = local.vpc_cidr
  flow_log_kms_key_arn = module.flow_logs_kms.key_arn
}

# Subnets
module "subnets" {
  source = "../../modules/subnets"
  vpc_id = module.vpc.id

  public_subnets = [
    {
      name = "lab02-public-1"
      cidr = local.public_subnet_cidr
    }
  ]

  private_subnets = [
    {
      name = "lab02-private-1"
      cidr = local.private_subnet_cidr
    }
  ]
}

# IGW + NAT + route tables
module "igw" {
  source = "../../modules/igw"
  vpc_id = module.vpc.id
}

module "nat" {
  source           = "../../modules/nat"
  public_subnet_id = module.subnets.public_ids[0]
}

module "route_tables" {
  source             = "../../modules/route_tables"
  vpc_id             = module.vpc.id
  igw_id             = module.igw.id
  nat_gateway_id     = module.nat.id
  public_subnet_ids  = module.subnets.public_ids
  private_subnet_ids = module.subnets.private_ids
}

# SG: chỉ cho SSH từ IP của bạn
module "sg" {
  source              = "../../modules/security_groups"
  vpc_id              = module.vpc.id
  my_ip_cidr          = var.my_ip_cidr
  private_subnet_cidr = local.private_subnet_cidr
  vpc_cidr            = local.vpc_cidr
}

module "flow_logs_kms" {
  source = "../../modules/kms"
  name   = "lab02-flow-logs"
}

module "ec2_iam" {
  source      = "../../modules/iam_role"
  name_prefix = "lab02"
}

# EC2 public
module "ec2_public" {
  source               = "../../modules/ec2"
  subnet_id            = module.subnets.public_ids[0]
  security_group_ids   = [module.sg.public_ssh_sg_id]
  key_name             = var.key_name
  instance_name        = "lab02-public-bastion"
  public_ip            = true
  iam_instance_profile = module.ec2_iam.instance_profile_name
}

module "ec2_private" {
  source               = "../../modules/ec2"
  subnet_id            = module.subnets.private_ids[0]
  security_group_ids   = [module.sg.private_ssh_sg_id]
  key_name             = var.key_name
  instance_name        = "lab02-private-app"
  public_ip            = false
  iam_instance_profile = module.ec2_iam.instance_profile_name
}

# outputs tiện xem
output "vpc_id" {
  value = module.vpc.id
}

output "public_instance_id" {
  value = module.ec2_public.instance_id
}

output "public_instance_ip" {
  value = module.ec2_public.public_ip
}

output "private_instance_id" {
  value = module.ec2_private.instance_id
}

output "private_instance_private_ip" {
  value = module.ec2_private.private_ip
}
