variable "vpc_id" {}
resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id
  tags   = { Name = "igw-lab02" }
}
output "id" { value = aws_internet_gateway.this.id }
