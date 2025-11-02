variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "igw_id" {
  description = "Internet Gateway ID for public route"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs to associate with the public route table"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "Private subnet IDs to associate with the private route table"
  type        = list(string)
  default     = []
}

variable "nat_gateway_id" {
  description = "NAT Gateway ID for private route table"
  type        = string
  default     = null
}

resource "aws_route_table" "public" {
  count  = length(var.public_subnet_ids) > 0 ? 1 : 0
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = {
    Name = "rtb-public"
  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnet_ids)
  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_ids) > 0 ? 1 : 0
  vpc_id = var.vpc_id

  dynamic "route" {
    for_each = var.nat_gateway_id != null ? [var.nat_gateway_id] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = route.value
    }
  }

  tags = {
    Name = "rtb-private"
  }
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(var.private_subnet_ids)
  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private[0].id
}

output "public_route_table_id" {
  description = "ID of the created public route table"
  value       = length(aws_route_table.public) > 0 ? aws_route_table.public[0].id : null
}

output "private_route_table_id" {
  description = "ID of the created private route table"
  value       = length(aws_route_table.private) > 0 ? aws_route_table.private[0].id : null
}
