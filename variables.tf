variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "my_ip" {
  description = "Your IP address in CIDR notation (e.g., 1.2.3.4/32) for SSH and Web UI access"
  type        = string
}

variable "vm_name" {
  description = "Name of the VM instance"
  type        = string
  default     = "wireguard-vpn"
}

variable "vm_cores" {
  description = "Number of CPU cores for the VM"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Amount of memory in GB for the VM"
  type        = number
  default     = 2
}

variable "vm_disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "wg_easy_password" {
  description = "Password for wg-easy web UI"
  type        = string
  default     = "kRa9z3YqTvLpDu5F2nfzrrbeZ"
  sensitive   = true
}

variable "domain_name" {
  description = "Domain name for WireGuard web UI (e.g., vpn.example.com). Leave empty to use IP only."
  type        = string
  default     = ""
}

variable "dns_zone_id" {
  description = "Yandex Cloud DNS zone ID (optional, required if domain_name is set)"
  type        = string
  default     = ""
}

variable "email_for_letsencrypt" {
  description = "Email address for Let's Encrypt certificate registration"
  type        = string
  default     = ""
}

variable "enable_wg_ui" {
  description = "Enable or disable WireGuard Web UI (TCP 51821). Set to false after creating VPN clients for better security."
  type        = bool
  default     = true
}

