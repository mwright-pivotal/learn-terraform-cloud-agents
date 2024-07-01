job "openvino" {
  datacenters = ["edge"]

  type = "service"

  group "openvino" {
    count = 1

    network {
       port "http_jupyter" {
         to = 8888
       }
       port "http_models" {
         to = 9000
       }
    }

    service {
      name = "openvino-notebooks"
      port = "http_jupyter"
      provider = "consul"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.openvino.rule=PathPrefix(`/openvino`)"
      ]

      check {
        type     = "http"
        path     = "/openvino/api"
        interval = "2s"
        timeout  = "2s"
      }
    }

    service {
      name = "openvino-model-server"
      port = "http_models"
      provider = "consul"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.tritonserver.rule=PathPrefix(`/ov`)",
        "traefik.http.middlewares.test-stripprefix.stripprefix.prefixes=/ov",
        "traefik.http.routers.tritonserver.middlewares=test-stripprefix"
      ]

      check {
        type     = "http"
        path     = "/metrics"
        interval = "2s"
        timeout  = "2s"
      }
    }

    task "jupyter" {
      env {
        JUPYTER_PORT = "${NOMAD_PORT_http_jupyter}"
        JUPYTERHUB_SERVICE_PREFIX = "/openvino"
      }
   
      driver = "docker"

      config {
        image = "mwrightpivotal/openvino_notebooks:3.2"
        image_pull_timeout = "10m"
        ports = ["http_jupyter"]
        shm_size = 1024
        command = "jupyter"
        args = [
          "lab",
          "--NotebookApp.base_url=/openvino",
          "--ip=*",
          "--allow-root",
          "/opt/app-root/notebooks"
        ]
      }
    }
    task "openvino-model-server" {
      constraint {
        attribute = "${node.class}"
        value     = "intel-igpu"
      }
      artifact {
        source = "http://192.168.0.5/models.tgz"
      }
      env {
        JUPYTER_PORT = "${NOMAD_PORT_http}"
      }
   
      driver = "docker"

      config {
        image = "openvino/model_server:latest-gpu"
        ports = ["http_models"]
        shm_size = 1024
        volumes = [
          "local/.:/models"
        ]
        args = [
          "--model_path",
          "/models/blackjack1",
          "--model_name",
          "quantized_cards_detect-1023",
          "--log_level",
          "INFO",
          "--target_device",
          "GPU"
        ]
        devices = [
          {
            host_path = "/dev/dri"
          }
        ]
        privileged = true
      }
      resources {
        
        cpu    = 1000
        memory = 8192
      }
    }
  }
}
