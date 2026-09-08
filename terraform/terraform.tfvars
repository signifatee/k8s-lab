ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3tgaeTQKrmn08oJRIfpmRpHjL2N0x0JEb4cg0DDVGE k8s-lab"

nodes = {
  "cp-1" = {
    role = "control_plane", vcpu = 2, memory = 4096, disk = 25,
    ip = "192.168.100.11", mac = "52:54:00:aa:00:11"
  }
  "worker-1" = {
    role = "worker", vcpu = 4, memory = 5120, disk = 25,
    ip = "192.168.100.21", mac = "52:54:00:aa:00:21"
  }
  "worker-2" = {
    role = "worker", vcpu = 4, memory = 5120, disk = 25,
    ip = "192.168.100.22", mac = "52:54:00:aa:00:22"
  }
  "worker-3" = {
    role = "worker", vcpu = 4, memory = 5120, disk = 25,
    ip = "192.168.100.23", mac = "52:54:00:aa:00:23"
  }
}