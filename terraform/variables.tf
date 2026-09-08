variable "nodes" {
  description = "Ноды кластера"
  type = map(object({
    role   = string
    vcpu   = number
    memory = number     # МБ
    disk   = number     # ГБ
    ip     = string
    mac    = string
  }))
}

variable "network_name" {
  type    = string
  default = "k8s-lab"
}

variable "gateway" {
  type    = string
  default = "192.168.100.1"
}

variable "ssh_public_key" {
  type = string
}

variable "pool" {
  type    = string
  default = "images"
}