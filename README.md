# WireGuard VPN Server on Yandex Cloud

This Terraform project provisions a production-ready WireGuard VPN server in Yandex Cloud using wg-easy and Docker Compose.

## Features

- **WireGuard VPN Server** via wg-easy with web UI
- **Automatic Setup** using cloud-init
- **Secure Configuration** with security groups
- **Public IP** for VPN access
- **Web UI** for easy client configuration and QR code generation

## Prerequisites

1. **Terraform** >= 1.0
   ```bash
   # Install Terraform (macOS)
   brew install terraform
   
   # Or download from https://www.terraform.io/downloads
   ```

2. **Yandex Cloud CLI (yc)**
   ```bash
   # Install yc CLI (macOS)
   curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
   
   # Or follow: https://cloud.yandex.ru/docs/cli/quickstart
   ```

3. **Yandex Cloud Account** with:
   - Active cloud
   - Folder created
   - Service account with compute admin permissions (or use your user account)

## Getting Started

### 1. Authenticate with Yandex Cloud

```bash
# Initialize yc CLI
yc init

# Or authenticate with OAuth token
yc config set token <your-token>
```

### 2. Get Cloud ID and Folder ID

```bash
# List clouds
yc resource-manager cloud list

# List folders in a cloud
yc resource-manager folder list --cloud-id <cloud-id>
```

Alternatively, you can find these in the Yandex Cloud Console:
- **Cloud ID**: Cloud settings → Overview
- **Folder ID**: Folder settings → Overview

### 3. Get Your Public IP

```bash
# Get your current public IP
curl -4 ifconfig.me

# Or use any online service like https://ifconfig.me
```

### 4. Configure Terraform Variables

```bash
# Copy the example file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
nano terraform.tfvars
```

Fill in the required variables:
```hcl
cloud_id  = "b1gxxxxxxxxxxxxx"
folder_id = "b1gxxxxxxxxxxxxx"
my_ip     = "1.2.3.4/32"  # Your public IP in CIDR notation
```

**Note**: Use `/32` for a single IP address (e.g., `1.2.3.4/32`).

### 5. Initialize Terraform

```bash
terraform init
```

This will download the Yandex Cloud provider.

### 6. Review the Plan

```bash
terraform plan
```

Review what will be created:
- VPC network and subnet
- Security group
- Compute instance (2 vCPU, 2 GB RAM, Ubuntu 22.04)

### 7. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted. The deployment takes approximately 2-3 minutes.

### 8. Get Outputs

After `terraform apply` completes, you'll see:

```bash
terraform output
```

You'll receive:
- `vpn_ip`: Public IP address of the VPN server
- `vpn_ui_url`: Web UI URL for managing WireGuard clients
- `ssh_command`: Command to SSH into the VM

Example output:
```
vpn_ip = "51.250.XX.XX"
vpn_ui_url = "http://51.250.XX.XX:51821"
ssh_command = "ssh ubuntu@51.250.XX.XX"
```

## Using the VPN

### 1. Access the Web UI

Open the `vpn_ui_url` in your browser (e.g., `http://51.250.XX.XX:51821`).

**Default password**: `changeme123`

**⚠️ Security Note**: Change the password by editing `/opt/wireguard/docker-compose.yml` on the VM and restarting the container.

### 2. Create a Client Configuration

1. Click **"New Client"** in the web UI
2. Enter a name for your device
3. Click **"Create"**
4. Download the configuration file or scan the QR code

### 3. Connect to VPN

#### macOS/iOS
- Import the `.conf` file into the WireGuard app
- Or scan the QR code with the WireGuard app
- Toggle the connection on

#### Linux
```bash
# Install WireGuard
sudo apt install wireguard

# Copy config to WireGuard directory
sudo cp client.conf /etc/wireguard/wg0.conf

# Start VPN
sudo wg-quick up wg0

# Stop VPN
sudo wg-quick down wg0
```

#### Windows
- Download WireGuard for Windows
- Import the `.conf` file
- Click "Activate"

### 4. Verify Your Connection

```bash
# Check your public IP (should show VPN server IP)
curl -4 ifconfig.me

# Or visit https://ifconfig.me
```

## Project Structure

```
.
├── providers.tf              # Terraform provider configuration
├── variables.tf              # Variable definitions
├── terraform.tfvars.example  # Example variables file
├── network.tf                # VPC network and subnet
├── vm.tf                     # Compute instance and security group
├── cloud-init.yaml           # Cloud-init script for VM bootstrap
├── outputs.tf                # Terraform outputs
└── README.md                 # This file
```

## Configuration Details

### Security Group Rules

- **UDP 51820**: Open to `0.0.0.0/0` (WireGuard VPN)
- **TCP 22**: Open only to `my_ip` (SSH)
- **TCP 51821**: Open only to `my_ip` (Web UI)
- **All egress**: Allowed

### VM Specifications

- **Image**: Ubuntu 22.04 LTS
- **vCPU**: 2 cores
- **RAM**: 2 GB
- **Disk**: 20 GB
- **Zone**: ru-central1-a

### wg-easy Configuration

- **WG_HOST**: Dynamically set to VM public IP
- **WG_ALLOWED_IPS**: `0.0.0.0/0` (route all traffic through VPN)
- **WG_PORT**: 51820 (UDP)
- **Web UI Port**: 51821 (TCP)
- **Data Persistence**: `/opt/wireguard/wg-data`

## Troubleshooting

### Cannot Access Web UI

1. Verify your IP is correct in `terraform.tfvars`:
   ```bash
   curl -4 ifconfig.me
   ```

2. Check security group rules:
   ```bash
   terraform show | grep -A 10 security_group
   ```

3. SSH into the VM and check Docker:
   ```bash
   ssh ubuntu@<vpn_ip>
   docker ps
   docker logs wg-easy
   ```

### VPN Not Connecting

1. Check WireGuard is running:
   ```bash
   ssh ubuntu@<vpn_ip>
   docker ps | grep wg-easy
   ```

2. Verify firewall rules:
   ```bash
   sudo iptables -L -n
   ```

3. Check WireGuard logs:
   ```bash
   docker logs wg-easy
   ```

### Change Web UI Password

1. SSH into the VM:
   ```bash
   ssh ubuntu@<vpn_ip>
   ```

2. Edit docker-compose.yml:
   ```bash
   sudo nano /opt/wireguard/docker-compose.yml
   # Change PASSWORD=changeme123 to your password
   ```

3. Restart the container:
   ```bash
   cd /opt/wireguard
   sudo docker compose down
   sudo docker compose up -d
   ```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

Type `yes` when prompted. This will delete:
- The compute instance
- Security group
- Subnet
- VPC network

**⚠️ Warning**: This will permanently delete your VPN server and all client configurations.

## Cost Estimation

Approximate monthly cost in Yandex Cloud:
- **VM (2 vCPU, 2 GB RAM)**: ~$15-20/month
- **Public IP**: Usually included
- **Traffic**: Depends on usage

Check current pricing: https://cloud.yandex.ru/docs/compute/pricing

## Security Recommendations

1. **Change Default Password**: Update the wg-easy password immediately
2. **Use SSH Keys**: Configure SSH key authentication instead of passwords
3. **Restrict Web UI Access**: Keep `my_ip` updated if your IP changes
4. **Regular Updates**: Keep the VM and Docker images updated
5. **Monitor Usage**: Check Yandex Cloud billing regularly

## Support

For issues with:
- **Terraform**: Check [Terraform Yandex Provider Docs](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs)
- **wg-easy**: Check [wg-easy GitHub](https://github.com/wg-easy/wg-easy)
- **WireGuard**: Check [WireGuard Documentation](https://www.wireguard.com/)

## License

This project is provided as-is for personal use.

