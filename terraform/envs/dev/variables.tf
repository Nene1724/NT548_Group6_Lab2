variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "my_ip_cidr" {
  description = "Your PUBLIC IP in CIDR, e.g. 1.2.3.4/32"
  type        = string
  # (không đặt default; truyền lúc chạy plan/apply)
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}
