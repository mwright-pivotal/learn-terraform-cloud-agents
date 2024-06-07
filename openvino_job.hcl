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
        "traefik.http.routers.openvino-notebooks.rule=Path(`/openvino`)",
      ]

      check {
        type     = "http"
        path     = "/lab"
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
