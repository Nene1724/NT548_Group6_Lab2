variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "my_ip_cidr" {
  description = "CIDR of the operator's IP address for SSH access"
  type        = string
}

resource "aws_security_group" "public_ssh" {
  name        = "lab02-public-ssh"
  description = "Allow SSH only from my IP"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from operator IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-public-ssh"
  }
}

resource "aws_security_group" "private_internal" {
  name        = "lab02-private-internal"
  description = "Allow SSH only from public bastion"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow SSH from public bastion SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_ssh.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-private-ssh"
  }
}

output "public_ssh_sg_id" {
  description = "Security group ID for the public EC2 instance"
  value       = aws_security_group.public_ssh.id
}

output "private_ssh_sg_id" {
  description = "Security group ID for the private EC2 instance"
  value       = aws_security_group.private_internal.id
}
