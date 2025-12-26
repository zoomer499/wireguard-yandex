#!/bin/bash
# Скрипт для автоматического создания terraform.tfvars из переменных окружения

if [ -z "$YC_CLOUD_ID" ] || [ -z "$YC_FOLDER_ID" ]; then
  echo "Ошибка: Переменные YC_CLOUD_ID и YC_FOLDER_ID должны быть установлены"
  echo "Выполните:"
  echo "  export YC_TOKEN=\$(yc iam create-token)"
  echo "  export YC_CLOUD_ID=\$(yc config get cloud-id)"
  echo "  export YC_FOLDER_ID=\$(yc config get folder-id)"
  exit 1
fi

MY_IP=$(curl -s -4 ifconfig.me)
if [ -z "$MY_IP" ]; then
  echo "Ошибка: Не удалось получить ваш IP адрес"
  exit 1
fi

cat > terraform.tfvars <<TFVARS
cloud_id  = "$YC_CLOUD_ID"
folder_id = "$YC_FOLDER_ID"
my_ip     = "$MY_IP/32"
TFVARS

echo "✓ Создан файл terraform.tfvars"
echo "  cloud_id  = $YC_CLOUD_ID"
echo "  folder_id = $YC_FOLDER_ID"
echo "  my_ip     = $MY_IP/32"
