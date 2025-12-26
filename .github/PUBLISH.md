# Инструкция по публикации в GitHub

## ✅ Проверка перед публикацией

Все секретные файлы уже добавлены в `.gitignore`:

- ✅ `terraform.tfvars` - игнорируется
- ✅ `terraform.tfstate*` - игнорируется  
- ✅ `.terraform/` - игнорируется
- ✅ `.terraform.lock.hcl` - игнорируется

## 🚀 Быстрая публикация

```bash
# 1. Проверьте статус (секретные файлы не должны быть в списке)
git status

# 2. Добавьте все файлы
git add .

# 3. Проверьте еще раз (terraform.tfvars НЕ должен быть в staged)
git status

# 4. Создайте коммит
git commit -m "Initial commit: WireGuard VPN server for Yandex Cloud"

# 5. Создайте репозиторий на GitHub и добавьте remote
git remote add origin https://github.com/ваш-username/wireguard-yandex.git

# 6. Отправьте код
git push -u origin main
```

## ⚠️ Если секреты уже в истории Git

Если вы случайно закоммитили `terraform.tfvars` или другие секреты:

```bash
# Удалите файл из истории (замените HEAD~N на нужное количество коммитов)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch terraform.tfvars terraform.tfstate*" \
  --prune-empty --tag-name-filter cat -- --all

# Или используйте BFG Repo-Cleaner (проще)
# brew install bfg
# bfg --delete-files terraform.tfvars
# git reflog expire --expire=now --all && git gc --prune=now --aggressive
```

## 📝 Что будет опубликовано

- ✅ Все `.tf` файлы
- ✅ `terraform.tfvars.example` (без секретов)
- ✅ `cloud-init.yaml`
- ✅ `README.md`
- ✅ `.gitignore`
- ✅ `LICENSE`
- ✅ `setup-tfvars.sh`

## 🔒 Что НЕ будет опубликовано

- ❌ `terraform.tfvars` (содержит cloud_id, folder_id, пароли)
- ❌ `terraform.tfstate*` (содержит состояние инфраструктуры)
- ❌ `.terraform/` (кэш провайдеров)

