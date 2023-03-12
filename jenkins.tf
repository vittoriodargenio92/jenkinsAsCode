terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1"
    }
  }
}

variable "jenkins_data" {
  type = string
  default = "/data/jenkins_home"
}

variable "jenkins_docker_certs" {
  type = string
  default = "/data/jenkins_docker_certs"
}

variable "jenkins_as_code" {
  type = string
  default = "/data/jenkinsAsCode"
}


variable "jenkins_docker_image" {
  type    = string
  default = "localhost:5000/jenkins:2.375.3-2"
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_network" "jenkins_net" {
  name = "jenkins_net"
}

# Pulls the image
resource "docker_image" "dind" {
  name = "docker:dind"
}

# Create a container
resource "docker_container" "jenkinsdocker" {
  image = docker_image.dind.image_id
  name  = "jenkins-docker"
  networks_advanced {
    name = docker_network.jenkins_net.id
    aliases = [
      "docker"
    ]
  }
  env = [
    "DOCKER_TLS_CERTDIR=/certs"
  ]
  privileged = true
  ports {
    internal = 2376
    external = 2376
  }
  volumes {
    host_path = "${path.cwd}${var.jenkins_docker_certs}"
    container_path = "/certs/client"
  }
  volumes {
    host_path = "${path.cwd}${var.jenkins_data}"
    container_path = "/var/jenkins_home"
  }
}

resource "docker_container" "jenkins" {
  image = var.jenkins_docker_image
  name  = "jenkins"
  networks_advanced {
    name = docker_network.jenkins_net.id
    aliases = [
      "docker"
    ]
  }
  env = [
    "DOCKER_HOST=tcp://docker:2376",
    "DOCKER_CERT_PATH=/certs/client",
    "DOCKER_TLS_VERIFY=1"
  ]
  ports {
    internal = 8080
    external = 8080
  }
  ports {
    internal = 50000
    external = 50000
  }
  volumes {
    host_path = "${path.cwd}${var.jenkins_docker_certs}"
    container_path = "/certs/client"
    read_only = true
  }
  volumes {
    host_path = "${path.cwd}${var.jenkins_data}"
    container_path = "/var/jenkins_home"
  }
  volumes {
    host_path = "${path.cwd}${var.jenkins_as_code}"
    container_path = "/var/jenkins_home/jenkinsAsCode"
  }
}

