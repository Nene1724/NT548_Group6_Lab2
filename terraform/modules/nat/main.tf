variable "public_subnet_id" {
  description = "ID of the public subnet where the NAT Gateway will be created"
  type        = string
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "lab02-nat-eip"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_id

  tags = {
    Name = "lab02-nat-gateway"
  }

  depends_on = [aws_eip.nat]
}

output "id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.this.id
}

output "eip" {
  description = "Elastic IP associated with the NAT Gateway"
  value       = aws_eip.nat.public_ip
}
