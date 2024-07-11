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
        "traefik.http.routers.tritonserver.rule=PathPrefix(`/triton`)",
        "traefik.http.middlewares.test-stripprefix.stripprefix.prefixes=/triton",
        "traefik.http.routers.tritonserver.middlewares=test-stripprefix"
      ]

      check {
        type     = "http"
        path     = "/v2/health/ready"
        interval = "2s"
        timeout  = "2s"
      }
    }

    task "server" {
      artifact {
        source = "http://192.168.0.5/models.tgz"
      }
      env {
        JUPYTER_PORT = "${NOMAD_PORT_http}"
      }
      constraint {
        attribute = "${node.class}"
        value     = "nvidia-gpu"
      }
   
      driver = "docker"

      config {
        image = "nvcr.io/nvidia/tritonserver:24.05-py3"
        ports = ["http","metrics","grpc"]
        shm_size = 1024
        command = "tritonserver"
        volumes = [
          "local/.:/models"
        ]
        args = [
          "--model-repository=/models",
          "--allow-http=true",
          "--log-verbose=9"
        ]
        #privileged = true
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
