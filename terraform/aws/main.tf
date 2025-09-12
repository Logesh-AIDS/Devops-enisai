terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "enisai" {
  name        = "enisai-sg"
  description = "Allow HTTP app, Prometheus, Grafana, and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allow_cidr]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "enisai" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.enisai.id]
  key_name               = var.key_name

  user_data = templatefile(
    "${path.module}/user_data.sh",
    {
      image = var.image
    }
  )

  tags = {
    Name = "enisai"
  }
}

output "public_ip" {
  value = aws_instance.enisai.public_ip
}

output "app_url" {
  value = "http://${aws_instance.enisai.public_ip}:5000/"
}

output "prometheus_url" {
  value = "http://${aws_instance.enisai.public_ip}:9090/"
}

output "grafana_url" {
  value = "http://${aws_instance.enisai.public_ip}:3000/"
}


