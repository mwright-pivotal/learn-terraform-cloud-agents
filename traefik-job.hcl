job "traefik" {
  region      = "global"
  datacenters = ["edge"]
  type        = "service"

  group "traefik" {
    count = 1

    network {
      port "http" {
        static = 8080
      }

      port "api" {
        static = 8081
      }
    }

    service {
      name = "traefik"

      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "keepalived" {
      driver = "docker"
      env {
        KEEPALIVED_VIRTUAL_IPS = "192.168.0.248/24"
        KEEPALIVED_UNICAST_PEERS = ""
        KEEPALIVED_STATE       = "MASTER"
        KEEPALIVED_VIRTUAL_ROUTES = ""
      }
      config {
        image        = "visibilityspots/keepalived:2.2.7"
        network_mode = "host"
        privileged   = true
        cap_add      = ["NET_ADMIN", "NET_BROADCAST", "NET_RAW"]
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image        = "traefik:latest"
        network_mode = "host"

        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
        ]
      }

      template {
        data = <<EOF
[entryPoints]
    [entryPoints.http]
    address = ":8080"
    [entryPoints.traefik]
    address = ":8081"

[api]
    dashboard = true
    insecure  = true

# Enable Consul Catalog configuration backend.
[providers.consulCatalog]
    prefix           = "traefik"
    exposedByDefault = false

    [providers.consulCatalog.endpoint]
      address = "127.0.0.1:8500"
      scheme  = "http"
EOF

        destination = "local/traefik.toml"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
