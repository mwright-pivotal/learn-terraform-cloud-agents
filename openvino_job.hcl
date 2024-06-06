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
      provider = "nomad"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.http.rule=Path(`/ov`)",
      ]
    }

    task "server" {
      env {
        JUPYTER_PORT = "${NOMAD_PORT_http}"
      }
   
      driver = "podman"

      config {
        image = "mwrightpivotal/openvino_notebooks:3.2"
        ports = ["http"]
        shm_size = "1024g"
      }
      resources {
        
        cpu    = 2000
        memory = 16484
      }
    }
  }
}
