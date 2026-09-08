resource "libvirt_volume" "base" {
  name   = "noble-base.qcow2"
  pool   = var.pool
  source = "/var/lib/libvirt/${var.pool}/noble-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_volume" "node" {
  for_each = var.nodes

  name           = "${each.key}.qcow2"
  pool           = var.pool
  base_volume_id = libvirt_volume.base.id
  size           = each.value.disk * 1024 * 1024 * 1024 # bytes
  format         = "qcow2"
}

resource "libvirt_cloudinit_disk" "node" {
  for_each = var.nodes
  name = "${each.key}-seed.iso"
  pool = var.pool

  user_data = templatefile("${path.module}/templates/cloud-init.yaml.tftpl", {
    hostname = each.key
    fqdn = "${each.key}.lab.local"
    ssh_key  = var.ssh_public_key
  })

  network_config = templatefile("${path.module}/templates/network.yaml.tftpl", {
    macaddress     = each.value.mac
    ip             = each.value.ip
    gateway = var.gateway
  })
}

resource "libvirt_domain" "node" {
  for_each = var.nodes

  name      = each.key
  memory    = each.value.memory
  vcpu      = each.value.vcpu

  autostart = false

  cloudinit = libvirt_cloudinit_disk.node[each.key].id

  cpu {
    mode = "host-passthrough"
  }

  disk {
    volume_id = libvirt_volume.node[each.key].id
  }

  network_interface {
    network_name   = var.network_name
    mac            = each.value.mac
    wait_for_lease = false
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  qemu_agent = true

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}