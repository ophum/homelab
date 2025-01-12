terraform {
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "2.2.0"
    }
  }
}

provider "lxd" {
  remote {
    name = "optiplex"
  }

  remote {
    name = "ryzen7-5700x"
  }
}

resource "lxd_instance" "clickhouse" {
  count = 2
  name  = format("clickhouse%d", count.index + 1)
  image = "ubuntu:24.04"

  config = {
    "boot.autostart" = true
    "cloud-init.network-config" = templatefile("network-config.yaml.tmpl", {
      iface_name      = "eth0",
      ip_address      = cidrhost("10.1.0.0/24", 10 + count.index)
      prefix          = 24
      default_gateway = "10.1.0.1"
    })
    "cloud-init.user-data" = templatefile("user-data.yaml.tmpl", {})
  }

  limits = {
    cpu    = 4
    memory = "16GiB"
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network = "internal0"
    }
  }
  remote = "ryzen7-5700x"
}

resource "lxd_instance" "keeper" {
  count = 3
  name  = format("keeper%d", count.index + 1)
  image = "ubuntu:24.04"

  config = {
    "boot.autostart" = true
    "cloud-init.network-config" = templatefile("network-config.yaml.tmpl", {
      iface_name      = "eth0",
      ip_address      = cidrhost("10.1.0.0/24", 20 + count.index)
      prefix          = 24
      default_gateway = "10.1.0.1"
    })
    "cloud-init.user-data" = templatefile("user-data.yaml.tmpl", {})
  }

  limits = {
    cpu    = 1
    memory = "4GiB"
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network = "internal0"
    }
  }
  remote = "ryzen7-5700x"
}

