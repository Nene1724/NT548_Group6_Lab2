variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "my_ip_cidr" {
  description = "CIDR of the operator's IP address for SSH access"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block of the private subnet"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

resource "aws_security_group" "public_ssh" {
  #checkov:skip=CKV2_AWS_5:Security group is attached to EC2 bastion instances via module outputs.
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
    description = "SSH access to private subnet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_cidr]
  }

  egress {
    description = "HTTPS outbound for patching"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-public-ssh"
  }
}

resource "aws_security_group" "private_internal" {
  #checkov:skip=CKV2_AWS_5:Security group is attached to EC2 private instances via module outputs.
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
    description = "Allow HTTPS outbound through NAT"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow VPC internal traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
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
