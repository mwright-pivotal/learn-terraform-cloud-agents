job "WindowsWorkload" {
  
  datacenters = ["edge"]
  update {
    max_parallel      = 3
    health_check      = "checks"
    min_healthy_time  = "10s"
    healthy_deadline  = "10m"
    progress_deadline = "20m"
    auto_revert       = true
    auto_promote      = true
    canary            = 1
    stagger           = "30s"
  }

  group "WindowsVM" {
    count = 1
    network {
      port "ssh" { }
    }
    task "virtual" {
      driver = "qemu"
    
      config {
        image_path  = "local/win2k22.qcow2"
        accelerator = "kvm"
        port_map = {
          ssh = 22
        }
      }
    
      # Specifying an artifact is required with the "qemu"
      # driver. This is the # mechanism to ship the image to be run.
      artifact {
        source = "http://192.168.0.12/win2k22.qcow2.tgz"
      }
    }
  }
}
