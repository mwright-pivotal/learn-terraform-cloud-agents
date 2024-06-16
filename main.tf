# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "2.3.0"
    }
    libvirt = {
      source  = "dmacvicar/libvirt"
    }
  }
}

provider "nomad" {
  address = "http://192.168.0.250:4646,http://192.168.0.249:4646"
  region  = "global"
}

# Register a job
resource "nomad_job" "openvino-notebooks" {
  jobspec = file("${path.module}/openvino_job.hcl")
}
# Register a job
resource "nomad_job" "nvidia-triton" {
  jobspec = file("${path.module}/nvidia-triton-job.hcl")
}
