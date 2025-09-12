variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "Existing EC2 key pair name"
}

variable "allow_cidr" {
  type        = string
  description = "CIDR allowed to SSH"
  default     = "0.0.0.0/0"
}

variable "image" {
  type        = string
  description = "GHCR image to deploy"
}


