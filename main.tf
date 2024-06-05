# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
    libvirt = {
      source  = "dmacvicar/libvirt"
    }
  }
}

provider "docker" {
  host = "unix:///run/user/1000/podman/podman.sock"
}

resource "docker_image" "openvino_notebooks" {
  name         = "mwrightpivotal/openvino_notebooks:3.2"
  keep_locally = false
}

resource "docker_container" "openvino_notebooks" {
  image = docker_image.openvino_notebooks.name
  name  = "openvino_notebooks"
  ports {
    internal = 8888
    external = 8000
  }
}
