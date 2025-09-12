terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "devops_enisai" {
  name = "devops-enisai"
}

resource "docker_image" "enisai" {
  name = "enisai:local"
  build {
    context    = "${path.module}/.."
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "enisai" {
  name  = "enisai"
  image = docker_image.enisai.name
  ports {
    internal = 5000
    external = 5000
  }
  networks_advanced {
    name = docker_network.devops_enisai.name
  }
}

resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = "prom/prometheus:latest"
  ports {
    internal = 9090
    external = 9090
  }
  volumes {
    host_path      = "${path.module}/../monitoring/prometheus.yml"
    container_path = "/etc/prometheus/prometheus.yml"
    read_only      = true
  }
  networks_advanced {
    name = docker_network.devops_enisai.name
  }
}

resource "docker_container" "grafana" {
  name  = "grafana"
  image = "grafana/grafana:latest"
  ports {
    internal = 3000
    external = 3000
  }
  networks_advanced {
    name = docker_network.devops_enisai.name
  }
}

