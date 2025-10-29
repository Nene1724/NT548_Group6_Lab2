variable "vpc_id" {}
variable "public_cidrs"  { type = list(string) }
variable "private_cidrs" {
  type    = list(string)
  default = []
}

resource "aws_subnet" "public" {
  for_each                 = toset(var.public_cidrs)
  vpc_id                   = var.vpc_id
  cidr_block               = each.value
  map_public_ip_on_launch  = true
  tags = { Name = "public-${each.value}" }
}

output "public_ids" { value = [for s in aws_subnet.public : s.id] }
