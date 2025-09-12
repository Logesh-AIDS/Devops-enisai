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

## AWS Deployment (EC2 via Terraform)

This repo includes an AWS stack under `terraform/aws/` to provision an EC2 instance and run the same stack (app, Prometheus, Grafana) with Docker Compose.

### Prerequisites
- AWS account and VPC defaults
- An existing EC2 key pair name (for SSH) in your region
- GitHub OIDC role for Actions (recommended) or long-lived AWS keys

### Required GitHub Secrets
- `AWS_REGION`: e.g., `us-east-1`
- `AWS_ROLE_ARN`: IAM role ARN assumed by GitHub Actions (OIDC)
- `AWS_KEY_NAME`: existing EC2 key pair name

Optional (server-side CD path, used by separate SSH deploy job if enabled):
- `DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_SSH_KEY`, `DEPLOY_PATH`
- `GHCR_USERNAME`, `GHCR_TOKEN` (only if pulling private images)

### What the pipeline does
On push to `main`:
- Build and lint the app
- Build and push Docker image to GHCR
- Security scan with Trivy
- Terraform Plan (`terraform/aws`)
- Terraform Apply (`terraform/aws`) — provisions Security Group + EC2
- User data on EC2 installs Docker and starts services with your GHCR image

Image reference used: `ghcr.io/<owner>/<repo>:latest`

### Manual run (optional)
```bash
cd terraform/aws
terraform init
terraform apply -auto-approve \
  -var "aws_region=<region>" \
  -var "key_name=<ec2-keypair-name>" \
  -var "image=ghcr.io/<owner>/<repo>:latest"
```

Outputs will include the public IP and service URLs.

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
