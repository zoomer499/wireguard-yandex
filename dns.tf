# DNS record for WireGuard VPN server (optional)
# Only created if domain_name and dns_zone_id are provided

resource "yandex_dns_recordset" "wireguard_dns" {
  count   = var.domain_name != "" && var.dns_zone_id != "" ? 1 : 0
  zone_id = var.dns_zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 300
  data    = [yandex_compute_instance.wireguard_vm.network_interface[0].nat_ip_address]
}

