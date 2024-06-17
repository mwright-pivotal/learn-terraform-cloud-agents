job "openvino" {
  datacenters = ["edge"]

  type = "service"

  group "openvino-notebooks" {
    count = 1

    network {
       port "http" {
         to = 8888
       }
    }

    service {
      name = "openvino-notebooks"
      port = "http"
      provider = "consul"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.tritonserver.rule=PathPrefix(`/openvino`)",
        "traefik.http.middlewares.test-stripprefix.stripprefix.prefixes=/openvino",
        "traefik.http.routers.tritonserver.middlewares=test-stripprefix"
      ]

      check {
        type     = "http"
        path     = "/api"
        interval = "2s"
        timeout  = "2s"
      }
    }

    task "server" {
      env {
        JUPYTER_PORT = "${NOMAD_PORT_http}"
      }
   
      driver = "docker"

      config {
        image = "mwrightpivotal/openvino_notebooks:3.2"
        image_pull_timeout = "10m"
        ports = ["http"]
        shm_size = 1024
      }
      resources {
        
        cpu    = 2000
        memory = 16484
      }
    }
  }
}
