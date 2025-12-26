data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_vpc_security_group" "wireguard_sg" {
  name        = "wireguard-security-group"
  description = "Security group for WireGuard VPN server"
  network_id  = yandex_vpc_network.wireguard_network.id

  # Allow WireGuard UDP from anywhere
  ingress {
    description    = "WireGuard UDP"
    protocol       = "UDP"
    port           = 51820
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH from my IP
  ingress {
    description    = "SSH"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [var.my_ip]
  }

  # Allow wg-easy Web UI from my IP (direct access) - only when enabled
  dynamic "ingress" {
    for_each = var.enable_wg_ui ? [1] : []
    content {
      description    = "WireGuard Web UI (Direct)"
      protocol       = "TCP"
      port           = 51821
      v4_cidr_blocks = [var.my_ip]
    }
  }

  # Allow HTTP for Let's Encrypt certificate validation
  ingress {
    description    = "HTTP (Let's Encrypt)"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS for secure web UI access
  ingress {
    description    = "HTTPS (Secure Web UI)"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = var.domain_name != "" ? ["0.0.0.0/0"] : [var.my_ip]
  }

  # Allow all egress
  egress {
    description    = "All egress"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_instance" "wireguard_vm" {
  name        = var.vm_name
  platform_id = "standard-v2"
  zone        = "ru-central1-a"

  resources {
    cores  = var.vm_cores
    memory = var.vm_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.vm_disk_size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.wireguard_subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.wireguard_sg.id]
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yaml", {
      wg_easy_password    = var.wg_easy_password
      domain_name         = var.domain_name
      email_for_letsencrypt = var.email_for_letsencrypt
    })
  }

  scheduling_policy {
    preemptible = false
  }
}

