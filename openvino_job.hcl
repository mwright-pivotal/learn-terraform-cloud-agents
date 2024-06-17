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
        "traefik.http.routers.openvino.rule=PathPrefix(`/openvino`)",
        "traefik.http.middlewares.ov-stripprefix.stripprefix.prefixes=/openvino",
        "traefik.http.routers.openvino.middlewares=ov-stripprefix"
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
        JUPYTERHUB_SERVICE_PREFIX = "/openvino"
      }
   
      driver = "docker"

      config {
        image = "mwrightpivotal/openvino_notebooks:3.2"
        image_pull_timeout = "10m"
        ports = ["http"]
        shm_size = 1024
        command = "jupyter"
        args {
          "lab"
          "--NotebookApp.base_url=/openvino"
          "--ip=*"
          "--allow-root"
      }
      resources {
        
        cpu    = 2000
        memory = 16484
      }
    }
  }
}
