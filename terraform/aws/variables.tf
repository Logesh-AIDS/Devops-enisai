variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "image" {
  type        = string
  description = "ECR image to deploy"
}


