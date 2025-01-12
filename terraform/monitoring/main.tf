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

resource "lxd_instance" "otelcol" {
  count = 1
  name  = format("otelcol%d", count.index + 1)
  image = "ubuntu:24.04"

  config = {
    "boot.autostart" = true
    "cloud-init.network-config" = templatefile("network-config.yaml.tmpl", {
      iface_name      = "eth0",
      ip_address      = cidrhost("10.1.0.0/24", 30 + count.index)
      prefix          = 24
      default_gateway = "10.1.0.1"
    })
    "cloud-init.user-data" = templatefile("user-data.yaml.tmpl", {})
  }

  limits = {
    cpu    = 1
    memory = "2GiB"
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

resource "lxd_instance" "prometheus" {
  name  = "prometheus"
  image = "ubuntu:24.04"

  config = {
    "boot.autostart" = true
    "cloud-init.network-config" = templatefile("network-config.yaml.tmpl", {
      iface_name      = "eth0",
      ip_address      = cidrhost("10.1.0.0/24", 40)
      prefix          = 24
      default_gateway = "10.1.0.1"
    })
    "cloud-init.user-data" = templatefile("user-data.yaml.tmpl", {})
  }

  limits = {
    cpu    = 1
    memory = "1GiB"
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

resource "lxd_instance" "grafana" {
  name  = "grafana"
  image = "ubuntu:24.04"

  config = {
    "boot.autostart" = true
    "cloud-init.network-config" = templatefile("network-config.yaml.tmpl", {
      iface_name      = "eth0",
      ip_address      = cidrhost("10.1.0.0/24", 41)
      prefix          = 24
      default_gateway = "10.1.0.1"
    })
    "cloud-init.user-data" = templatefile("user-data.yaml.tmpl", {})
  }

  limits = {
    cpu    = 2
    memory = "2GiB"
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

