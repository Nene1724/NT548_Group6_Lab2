variable "subnet_id" {}
variable "security_group_ids" { type = list(string) }
variable "key_name" {}
variable "instance_name" {}
variable "public_ip" { type = bool }

data "aws_ami" "amazon_linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  associate_public_ip_address = var.public_ip
  tags = { Name = var.instance_name }
}

output "instance_id" { value = aws_instance.this.id }
output "public_ip"   { value = aws_instance.this.public_ip }
