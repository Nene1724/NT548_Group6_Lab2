variable "subnet_id" {}
variable "security_group_ids" { type = list(string) }
variable "key_name" {}
variable "instance_name" {}
variable "public_ip" { type = bool }
variable "iam_instance_profile" {
  description = "Optional IAM instance profile name to attach"
  type        = string
  default     = null
}

data "aws_ami" "amazon_linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "this" {
  #checkov:skip=CKV_AWS_88:The bastion use-case requires a public IP when var.public_ip is true for remote access.
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  associate_public_ip_address = var.public_ip
  monitoring                  = true
  ebs_optimized               = true
  iam_instance_profile        = var.iam_instance_profile

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
  }

  tags = {
    Name = var.instance_name
  }
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance (null for private instances)"
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.this.private_ip
}
