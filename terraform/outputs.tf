output "node_ips" {
  value = { for k, v in var.nodes : k => v.ip }
}

resource "local_file" "inventory" {
  filename        = "${path.module}/../ansible/inventory/hosts.yaml"
  file_permission = "0644"
  content = templatefile("${path.module}/templates/inventory.yaml.tftpl", {
    nodes = var.nodes
  })
}