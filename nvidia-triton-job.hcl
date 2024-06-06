job "tritonserver" {
  datacenters = ["edge"]

  type = "service"

  group "tritonserver" {
    count = 1

    network {
       port "http" {
         to = 8000
       }
       port "grpc" {
         to = 8001
       }
       port "metrics" {
         to = 8002
       }
    }

    service {
      name = "tritonserver"
      port = "http"
      provider = "consul"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.http.rule=Path(`/triton`)",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "2s"
        timeout  = "2s"
      }
    }

    task "server" {
      artifact {
        source = "http://192.168.0.78/models.tgz"
      }
      env {
        JUPYTER_PORT = "${NOMAD_PORT_http}"
      }
   
      driver = "podman"

      config {
        image = "nvcr.io/nvidia/tritonserver:24.05-py3"
        ports = ["http","metrics","grpc"]
        shm_size = "1024g"
        command = "tritonserver"
        volumes = [
          "local/.:/models:ro,noexec"
        ]
        args = [
          "--model-repository=/models"
        ]
        privileged = true
      }
      resources {
        
        cpu    = 2000
        memory = 16484
        
        device "nvidia/gpu" {
          count = 1
        }
      }
    }
  }
}
