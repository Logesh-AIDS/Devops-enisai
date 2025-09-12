#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

if command -v yum >/dev/null 2>&1; then
  sudo yum update -y
  sudo amazon-linux-extras install docker -y || sudo yum install -y docker
  sudo service docker start
  sudo usermod -aG docker ec2-user
else
  sudo apt-get update -y
  sudo apt-get install -y docker.io docker-compose-plugin
fi

IMAGE="${image}"

mkdir -p /opt/enisai
cat >/opt/enisai/docker-compose.yml <<'YAML'
services:
  enisai:
    image: ${IMAGE_NAME}
    ports:
      - "5000:5000"
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
YAML

echo "Starting services with image: $IMAGE"
export IMAGE_NAME="$IMAGE"
IMAGE_NAME="$IMAGE" docker compose -f /opt/enisai/docker-compose.yml up -d


