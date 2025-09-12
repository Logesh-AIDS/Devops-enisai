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
