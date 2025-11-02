variable "name" {
  description = "Name suffix for the KMS key alias"
  type        = string
}

variable "region" {
  description = "Region of the AWS deployment"
  type        = string
}

data "aws_caller_identity" "current" {}

resource "random_id" "suffix" {
  byte_length = 2
}

locals {
  key_alias_name = "alias/${var.name}-${random_id.suffix.hex}"
}

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
      },
      {
        Sid    = "AllowCloudWatchLogsEncryption"
        Effect = "Allow"
        Principal = {
          Service = "logs.${var.region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "this" {
  name          = local.key_alias_name
  target_key_id = aws_kms_key.this.key_id
}

output "key_arn" {
  description = "ARN of the created KMS key"
  value       = aws_kms_key.this.arn
}

output "alias_name" {
  description = "Alias name created for the KMS key"
  value       = local.key_alias_name
}
