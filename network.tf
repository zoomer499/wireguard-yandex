resource "yandex_vpc_network" "wireguard_network" {
  name = "wireguard-network"
}

resource "yandex_vpc_subnet" "wireguard_subnet" {
  name           = "wireguard-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.wireguard_network.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

