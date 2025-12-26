output "vpn_ip" {
  description = "Public IP address of the WireGuard VPN server"
  value       = yandex_compute_instance.wireguard_vm.network_interface[0].nat_ip_address
}

output "vpn_ui_url" {
  description = "Web UI URL for WireGuard management (wg-easy). Only shown when enable_wg_ui is true."
  value = var.enable_wg_ui ? (var.domain_name != "" ? "https://${var.domain_name}" : "http://${yandex_compute_instance.wireguard_vm.network_interface[0].nat_ip_address}:51821") : null
}

output "vpn_ui_url_direct" {
  description = "Direct Web UI URL (by IP, if domain is not set). Only shown when enable_wg_ui is true."
  value       = var.enable_wg_ui ? "http://${yandex_compute_instance.wireguard_vm.network_interface[0].nat_ip_address}:51821" : null
}

output "domain_name" {
  description = "Domain name for WireGuard (if set)"
  value       = var.domain_name != "" ? var.domain_name : null
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ubuntu@${yandex_compute_instance.wireguard_vm.network_interface[0].nat_ip_address}"
}

