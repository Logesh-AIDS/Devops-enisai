# Devops-enisai

Simple, clean DevOps scaffold with:
- Containerized `Flask` app (`enisai`) with `/metrics` endpoint
- `docker-compose` for local run, Prometheus + Grafana monitoring
- CI/CD via GitHub Actions (lint, build, and push to GHCR)
- Terraform IaC (Docker provider) to provision app and monitoring

## Quickstart (Local)

1) Build and run with Docker Compose:
```bash
docker compose up --build
```

Services:
- App: `http://localhost:5000/`
- Metrics: `http://localhost:5000/metrics`
- Prometheus: `http://localhost:9090/`
- Grafana: `http://localhost:3000/`

## CI/CD

GitHub Actions workflow: `.github/workflows/ci.yml`
- Lints Python code with flake8
- Builds Docker image and pushes to GHCR on push to `main`

Image URL format: `ghcr.io/<owner>/<repo>:<tag>`

## IaC (Terraform with Docker Provider)

Directory: `terraform/`

Initialize and apply:
```bash
cd terraform
terraform init
terraform apply -auto-approve
```

Outputs include app, Prometheus, and Grafana URLs.

## AWS Deployment (ECS + ECR via Terraform)

This repo includes an AWS stack under `terraform/aws/` to provision ECS Fargate cluster with ECR repository and run the same stack (app, Prometheus, Grafana) as containers.

### Prerequisites
- AWS account with default VPC
- IAM user with permissions for ECS, ECR, VPC, Security Groups

### Required GitHub Secrets
- `AWS_REGION`: e.g., `us-east-1`
- `AWS_ACCESS_KEY_ID`: IAM user access key
- `AWS_SECRET_ACCESS_KEY`: IAM user secret key

### What the pipeline does
On push to `main`:
- Build and lint the app
- Build and push Docker image to ECR
- Security scan with Trivy
- Terraform Plan (`terraform/aws`)
- Terraform Apply (`terraform/aws`) — provisions ECR repo + ECS cluster + task definition + service
- Force new ECS deployment

Image reference used: `<account>.dkr.ecr.<region>.amazonaws.com/enisai:<commit-sha>`

### Manual run (optional)
```bash
cd terraform/aws
terraform init
terraform apply -auto-approve \
  -var "aws_region=<region>" \
  -var "image=<account>.dkr.ecr.<region>.amazonaws.com/enisai:latest"
```

Outputs will include ECR repository URL and ECS cluster/service names.

## Repo Layout

```
enisai/
  app.py
Dockerfile
requirements.txt
docker-compose.yml
monitoring/
  prometheus.yml
.github/workflows/
  ci.yml
terraform/
  main.tf
  outputs.tf
```

## Notes
- For production, prefer a registry-hosted image and an orchestrator (e.g., Kubernetes).
- Add secrets as repository secrets for GHCR push if needed; default `GITHUB_TOKEN` works for the same org.
