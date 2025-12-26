# WireGuard VPN сервер в Yandex Cloud

Этот Terraform проект разворачивает готовый к продакшену WireGuard VPN сервер в Yandex Cloud с использованием wg-easy и Docker Compose.

## Возможности

- **WireGuard VPN сервер** через wg-easy с веб-интерфейсом
- **Автоматическая настройка** с помощью cloud-init
- **Безопасная конфигурация** с группами безопасности
- **Публичный IP** для доступа к VPN
- **Веб-интерфейс** для простого создания конфигураций клиентов и QR-кодов

## ✅ Что уже готово

Проект полностью настроен и готов к использованию:

- ✅ Все Terraform файлы созданы и настроены
- ✅ Провайдер Yandex Cloud настроен
- ✅ Конфигурация сети (VPC, подсеть)
- ✅ Конфигурация виртуальной машины с security groups
- ✅ Cloud-init скрипт для автоматической установки Docker и wg-easy
- ✅ Скрипт `setup-tfvars.sh` для автоматического создания `terraform.tfvars`
- ✅ Переменные окружения YC_TOKEN, YC_CLOUD_ID, YC_FOLDER_ID настроены

## Требования

1. **Terraform** >= 0.13
   ```bash
   # Установка Terraform (macOS)
   brew install terraform
   
   # Или скачайте с https://www.terraform.io/downloads
   ```

2. **Yandex Cloud CLI (yc)**
   ```bash
   # Установка yc CLI (macOS)
   curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
   
   # Или следуйте инструкциям: https://cloud.yandex.ru/docs/cli/quickstart
   ```

3. **Аккаунт Yandex Cloud** с:
   - Активным облаком
   - Созданной папкой (folder)
   - Сервисным аккаунтом с правами администратора compute (или используйте свой пользовательский аккаунт)

## Быстрый старт

### 1. Аутентификация в Yandex Cloud

```bash
# Инициализация yc CLI
yc init

# Или аутентификация с OAuth токеном
yc config set token <ваш-токен>
```

**✅ Готово**: Вы уже настроили переменные окружения:
```bash
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```

### 2. Получение Cloud ID и Folder ID

Если переменные окружения уже установлены, можно пропустить этот шаг.

```bash
# Список облаков
yc resource-manager cloud list

# Список папок в облаке
yc resource-manager folder list --cloud-id <cloud-id>
```

Альтернативно, вы можете найти эти значения в консоли Yandex Cloud:
- **Cloud ID**: Настройки облака → Обзор
- **Folder ID**: Настройки папки → Обзор

### 3. Получение вашего публичного IP

```bash
# Получить текущий публичный IP
curl -4 ifconfig.me

# Или используйте любой онлайн-сервис, например https://ifconfig.me
```

### 4. Настройка переменных Terraform

**Автоматический способ** (рекомендуется):

```bash
# В терминале, где установлены переменные YC_CLOUD_ID и YC_FOLDER_ID
./setup-tfvars.sh
```

Скрипт автоматически:
- Использует `YC_CLOUD_ID` и `YC_FOLDER_ID` из переменных окружения
- Получает ваш текущий IP адрес
- Создает файл `terraform.tfvars` с правильными значениями

**Ручной способ**:

```bash
# Копируем пример файла
cp terraform.tfvars.example terraform.tfvars

# Редактируем terraform.tfvars со своими значениями
nano terraform.tfvars
```

Заполните необходимые переменные:
```hcl
cloud_id  = "b1gxxxxxxxxxxxxx"
folder_id = "b1gxxxxxxxxxxxxx"
my_ip     = "1.2.3.4/32"  # Ваш публичный IP в CIDR нотации
```

**Примечание**: Используйте `/32` для одного IP адреса (например, `1.2.3.4/32`).

### 5. Инициализация Terraform

```bash
terraform init
```

Это загрузит провайдер Yandex Cloud.

### 6. Просмотр плана

```bash
terraform plan
```

Проверьте, что будет создано:
- VPC сеть и подсеть
- Группа безопасности
- Вычислительный инстанс (2 vCPU, 2 GB RAM, Ubuntu 22.04)

### 7. Применение конфигурации

```bash
terraform apply
```

Введите `yes` при запросе. Развертывание займет примерно 2-3 минуты.

### 8. Получение выходных данных

После завершения `terraform apply` вы увидите:

```bash
terraform output
```

Вы получите:
- `vpn_ip`: Публичный IP адрес VPN сервера
- `vpn_ui_url`: URL веб-интерфейса для управления клиентами WireGuard
- `ssh_command`: Команда для SSH подключения к VM

Пример вывода:
```
vpn_ip = "51.250.XX.XX"
vpn_ui_url = "http://51.250.XX.XX:51821"
ssh_command = "ssh ubuntu@51.250.XX.XX"
```

## Использование VPN

### 1. Доступ к веб-интерфейсу

Откройте `vpn_ui_url` в браузере (например, `http://51.250.XX.XX:51821`).

**Пароль по умолчанию**: `changeme123`

**⚠️ Важно для безопасности**: Измените пароль, отредактировав `/opt/wireguard/docker-compose.yml` на VM и перезапустив контейнер.

### 2. Создание конфигурации клиента

1. Нажмите **"New Client"** в веб-интерфейсе
2. Введите имя для вашего устройства
3. Нажмите **"Create"**
4. Скачайте файл конфигурации или отсканируйте QR-код

### 3. Подключение к VPN

#### macOS/iOS
- Импортируйте файл `.conf` в приложение WireGuard
- Или отсканируйте QR-код приложением WireGuard
- Включите подключение

#### Linux
```bash
# Установка WireGuard
sudo apt install wireguard

# Копирование конфигурации в директорию WireGuard
sudo cp client.conf /etc/wireguard/wg0.conf

# Запуск VPN
sudo wg-quick up wg0

# Остановка VPN
sudo wg-quick down wg0
```

#### Windows
- Скачайте WireGuard для Windows
- Импортируйте файл `.conf`
- Нажмите "Activate"

### 4. Проверка подключения

```bash
# Проверьте ваш публичный IP (должен показывать IP VPN сервера)
curl -4 ifconfig.me

# Или посетите https://ifconfig.me
```

## Структура проекта

```
.
├── providers.tf              # Конфигурация провайдера Terraform
├── variables.tf              # Определения переменных
├── terraform.tfvars.example  # Пример файла переменных
├── network.tf                # VPC сеть и подсеть
├── vm.tf                     # Вычислительный инстанс и группа безопасности
├── cloud-init.yaml           # Cloud-init скрипт для начальной настройки VM
├── outputs.tf                # Выходные данные Terraform
├── setup-tfvars.sh           # Скрипт для автоматического создания terraform.tfvars
├── .gitignore                # Игнорируемые файлы Git
└── README.md                 # Этот файл
```

## Детали конфигурации

### Правила группы безопасности

- **UDP 51820**: Открыт для `0.0.0.0/0` (WireGuard VPN)
- **TCP 22**: Открыт только для `my_ip` (SSH)
- **TCP 51821**: Открыт только для `my_ip` (Веб-интерфейс)
- **Весь исходящий трафик**: Разрешен

### Характеристики VM

- **Образ**: Ubuntu 22.04 LTS
- **vCPU**: 2 ядра
- **RAM**: 2 GB
- **Диск**: 20 GB
- **Зона**: ru-central1-a

### Конфигурация wg-easy

- **WG_HOST**: Динамически устанавливается в публичный IP VM
- **WG_ALLOWED_IPS**: `0.0.0.0/0` (маршрутизировать весь трафик через VPN)
- **WG_PORT**: 51820 (UDP)
- **Порт веб-интерфейса**: 51821 (TCP)
- **Хранение данных**: `/opt/wireguard/wg-data`

## Решение проблем

### Не могу получить доступ к веб-интерфейсу

1. Проверьте, что ваш IP правильный в `terraform.tfvars`:
   ```bash
   curl -4 ifconfig.me
   ```

2. Проверьте правила группы безопасности:
   ```bash
   terraform show | grep -A 10 security_group
   ```

3. Подключитесь по SSH к VM и проверьте Docker:
   ```bash
   ssh ubuntu@<vpn_ip>
   docker ps
   docker logs wg-easy
   ```

### VPN не подключается

1. Проверьте, что WireGuard запущен:
   ```bash
   ssh ubuntu@<vpn_ip>
   docker ps | grep wg-easy
   ```

2. Проверьте правила файрвола:
   ```bash
   sudo iptables -L -n
   ```

3. Проверьте логи WireGuard:
   ```bash
   docker logs wg-easy
   ```

### Изменение пароля веб-интерфейса

1. Подключитесь по SSH к VM:
   ```bash
   ssh ubuntu@<vpn_ip>
   ```

2. Отредактируйте docker-compose.yml:
   ```bash
   sudo nano /opt/wireguard/docker-compose.yml
   # Измените PASSWORD=changeme123 на ваш пароль
   ```

3. Перезапустите контейнер:
   ```bash
   cd /opt/wireguard
   sudo docker compose down
   sudo docker compose up -d
   ```

## Очистка

Для удаления всех ресурсов:

```bash
terraform destroy
```

Введите `yes` при запросе. Это удалит:
- Вычислительный инстанс
- Группу безопасности
- Подсеть
- VPC сеть

**⚠️ Предупреждение**: Это навсегда удалит ваш VPN сервер и все конфигурации клиентов.

## Оценка стоимости

Примерная месячная стоимость в Yandex Cloud:
- **VM (2 vCPU, 2 GB RAM)**: ~$15-20/месяц
- **Публичный IP**: Обычно включен
- **Трафик**: Зависит от использования

Проверьте актуальные цены: https://cloud.yandex.ru/docs/compute/pricing

## Рекомендации по безопасности

1. **Измените пароль по умолчанию**: Обновите пароль wg-easy немедленно
2. **Используйте SSH ключи**: Настройте аутентификацию по SSH ключам вместо паролей
3. **Ограничьте доступ к веб-интерфейсу**: Обновляйте `my_ip`, если ваш IP изменился
4. **Регулярные обновления**: Поддерживайте VM и Docker образы в актуальном состоянии
5. **Мониторинг использования**: Регулярно проверяйте биллинг Yandex Cloud

## Поддержка

При проблемах с:
- **Terraform**: См. [Документацию Terraform Yandex Provider](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs)
- **wg-easy**: См. [wg-easy GitHub](https://github.com/wg-easy/wg-easy)
- **WireGuard**: См. [Документацию WireGuard](https://www.wireguard.com/)

## Лицензия

Этот проект предоставляется как есть для личного использования.
