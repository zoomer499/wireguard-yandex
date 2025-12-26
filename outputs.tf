output "vpn_ip" {
  description = "Public IP address of the WireGuard VPN server"
  value       = yandex_compute_instance.wireguard_vm.network_interface[0].nat_ip_address
}

output "vpn_ui_url" {
  description = "Web UI URL for WireGuard management (wg-easy)"
  value       = "http://${yandex_compute_instance.wireguard_vm.network_interface[0].nat_ip_address}:51821"
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ubuntu@${yandex_compute_instance.wireguard_vm.network_interface[0].nat_ip_address}"
}

