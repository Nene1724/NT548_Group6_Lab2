variable "vpc_id" {}
variable "my_ip_cidr" {}

resource "aws_security_group" "public_ssh" {
  name        = "lab02-public-ssh"
  description = "Allow SSH only from my IP"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "sg-public-ssh" }
}

output "public_ssh_sg_id" { value = aws_security_group.public_ssh.id }
