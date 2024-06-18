job "ray.io" {
  
  datacenters = ["edge"]
  
  group "ray_head" {
    count = 1

    task "setup" {
      driver = "raw_exec"

      lifecycle {
        hook    = "prestart"
      }

      config {
        command = "/usr/bin/pip"
        args    = ["install", "ray[default]"]
      }
    }

    task "ray_node" {
      driver = "raw_exec"

      config {
        command = "/usr/bin/python"
        args    = ["ray start -node-ip-address=192.168.0.250 --head"]
      }

    }
  }
}
