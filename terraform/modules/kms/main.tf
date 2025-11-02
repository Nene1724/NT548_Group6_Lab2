variable "name" {
  description = "Name suffix for the KMS key alias"
  type        = string
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "this" {
  description             = "KMS key for ${var.name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAccountAdministration"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.this.key_id
}

output "key_arn" {
  description = "ARN of the created KMS key"
  value       = aws_kms_key.this.arn
}
