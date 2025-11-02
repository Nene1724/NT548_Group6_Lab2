variable "vpc_id" {
  description = "ID of the VPC to place the subnets in"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnets with name, cidr, and optional az"
  type = list(object({
    name = string
    cidr = string
    az   = optional(string)
  }))
  default = []
}

variable "private_subnets" {
  description = "List of private subnets with name, cidr, and optional az"
  type = list(object({
    name = string
    cidr = string
    az   = optional(string)
  }))
  default = []
}

resource "aws_subnet" "public" {
  for_each                = { for subnet in var.public_subnets : subnet.name => subnet }
  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = true
  availability_zone       = try(each.value.az, null)

  tags = {
    Name = each.value.name
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  for_each                = { for subnet in var.private_subnets : subnet.name => subnet }
  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = false
  availability_zone       = try(each.value.az, null)

  tags = {
    Name = each.value.name
    Tier = "private"
  }
}

output "public_ids" {
  description = "List of public subnet IDs"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_ids" {
  description = "List of private subnet IDs"
  value       = [for subnet in aws_subnet.private : subnet.id]
}
