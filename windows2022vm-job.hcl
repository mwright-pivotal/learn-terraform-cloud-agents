job "WindowsWorkload" {
  
  datacenters = ["edge"]
  
  group "WindowsVM" {
    count = 1

    task "virtual" {
      driver = "qemu"
    
      config {
        image_path  = "local/win2k22.qcow2"
        accelerator = "kvm"
        args        = ["-nodefaults", "-nodefconfig"]
      }
    
      # Specifying an artifact is required with the "qemu"
      # driver. This is the # mechanism to ship the image to be run.
      artifact {
        source = "http://192.168.0.78/win2k22.qcow2"
      }
    }
  }
}
