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

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_ecr_repository" "enisai" {
  name                 = "enisai"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_security_group" "enisai" {
  name        = "enisai-sg"
  description = "Allow HTTP app, Prometheus, Grafana"

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

resource "aws_ecs_cluster" "enisai" {
  name = "enisai-cluster"
}

resource "aws_ecs_task_definition" "enisai" {
  family                   = "enisai"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "enisai"
      image = var.image
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      essential = true
    },
    {
      name  = "prometheus"
      image = "prom/prometheus:latest"
      portMappings = [
        {
          containerPort = 9090
          hostPort      = 9090
        }
      ]
      essential = true
    },
    {
      name  = "grafana"
      image = "grafana/grafana:latest"
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      essential = true
    }
  ])
}

resource "aws_ecs_service" "enisai" {
  name            = "enisai-service"
  cluster         = aws_ecs_cluster.enisai.id
  task_definition = aws_ecs_task_definition.enisai.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.enisai.id]
    assign_public_ip = true
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "enisai-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

output "ecr_repository_url" {
  value = aws_ecr_repository.enisai.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.enisai.name
}

output "ecs_service_name" {
  value = aws_ecs_service.enisai.name
}


