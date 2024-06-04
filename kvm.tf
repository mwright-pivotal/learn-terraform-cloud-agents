resource "tls_private_key" "ecdsa-p384-bastion" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

provider "libvirt" {
  uri = "qemu+ssh://hero@192.168.165.100/system"
}

module "vm" {
  source  = "MonolithProjects/vm/libvirt"
  version = "1.8.0"

  vm_hostname_prefix = "server"
  vm_count    = 3
  memory      = "2048"
  vcpu        = 1
  pool        = "terra_pool"
  system_volume = 20
  dhcp        = true
  local_admin = "local-admin"
  ssh_admin   = "ci-user"
  ssh_private_key = "~/.ssh/id_ed25519"
  local_admin_passwd = "$6$rounds=4096$xxxxxxxxHASHEDxxxPASSWORD"
  ssh_keys    = [
    "ssh-ed25519 AAAAxxxxxxxxxxxxSSHxxxKEY example",
    ]
  bastion_host = "10.0.0.1"
  bastion_user = "admin"
  bastion_ssh_private_key = tls_private_key.ecdsa-p384-bastion.private_key_pem
  time_zone   = "CET"
  os_img_url  = "file:///home/edge-admin/ubuntu-20.04-server-cloudimg-amd64.img"
  xml_override = {
      hugepages = true,
      usb_controllers = [
        {
          model = "qemu-xhci"
        }
      ],
      usb_devices = [
        {
          vendor = "0x0bc2",
          product = "0xab28"
        }
      ]
      pci_devices_passthrough = [
        {
          src_domain = "0x0000",
          src_bus    = "0xc1",
          src_slot   = "0x00",
          src_func   = "0x0",
          dst_domain = "0x0000",
          dst_bus    = "0x00",
          dst_slot   = "0x08"
          dst_func   = "0x0"
        },
        {
          src_domain = "0x0000",
          src_bus    = "0xc1",
          src_slot   = "0x00",
          src_func   = "0x1",
          dst_domain = "0x0000",
          dst_bus    = "0x00",
          dst_slot   = "0x09"
          dst_func   = "0x0"
        }
      ]      
    }
}

output "ip_addresses" {
  value = module.nodes
}
