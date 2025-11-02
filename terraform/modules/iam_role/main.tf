variable "name_prefix" {
  description = "Prefix for IAM role and instance profile names"
  type        = string
}

resource "random_id" "name_suffix" {
  byte_length = 2
}

locals {
  role_name             = "${var.name_prefix}-ec2-role-${random_id.name_suffix.hex}"
  instance_profile_name = "${var.name_prefix}-ec2-instance-profile-${random_id.name_suffix.hex}"
}

resource "aws_iam_role" "ec2" {
  name                  = local.role_name
  force_detach_policies = true
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = local.instance_profile_name
  role = aws_iam_role.ec2.name
}

output "instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = aws_iam_instance_profile.ec2.name
}

output "role_name" {
  description = "Name of the created IAM role"
  value       = aws_iam_role.ec2.name
}
