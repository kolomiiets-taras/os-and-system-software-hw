# Домашнє завдання (модуль 6)

Обраний варіант: **A — Скрипт бекапу логів**.

Система: Ubuntu 24.04.4 LTS

---

## Скрипт `backup.sh`

```bash
#!/bin/bash
#
# backup.sh — створює tar.gz-архів усіх файлів з каталогу логів.
# Використання: ./backup.sh /path/to/logs /path/to/backup
#

# Lock-файл для захисту від паралельного запуску.
LOCK_FILE="/tmp/backup.lock"

# --- 1. Перевірка аргументів ---
# Має бути рівно 2 аргументи, обидва — існуючі каталоги.
if [ "$#" -ne 2 ] || [ ! -d "$1" ] || [ ! -d "$2" ]; then
    echo "Usage: ./backup.sh <log_dir> <backup_dir>"
    exit 1
fi

LOG_DIR="$1"
BACKUP_DIR="$2"

# --- 2. Захист від паралельного запуску ---
# Якщо lock-файл уже існує — інший бекап ще працює, виходимо.
if [ -e "$LOCK_FILE" ]; then
    echo "Backup already running"
    exit 0
fi

# Створюємо lock-файл і гарантуємо його видалення при будь-якому виході зі скрипта.
touch "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

# --- 3. Створення архіву логів ---
# Ім'я файлу містить дату й час: logs_backup_YYYY-MM-DD_HH-MM.tar.gz
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
ARCHIVE_NAME="logs_backup_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${BACKUP_DIR}/${ARCHIVE_NAME}"

# Архівуємо вміст каталогу логів (-C — щоб у архіві не було повного шляху).
tar -czf "$ARCHIVE_PATH" -C "$LOG_DIR" .

# --- 4. Перевірка результату ---
# $? — код завершення tar; ненульовий означає помилку.
if [ "$?" -ne 0 ]; then
    echo "Backup failed"
    exit 2
fi

# Виводимо повний шлях до створеного архіву.
echo "Backup created: $(realpath "$ARCHIVE_PATH")"
```

---

## Перевірка роботи

Підготував тестові каталоги й логи:

```bash
chmod +x backup.sh
mkdir -p logs_t backup_t
echo "log line 1" > logs_t/app.log
echo "error here" > logs_t/error.log
```

### 1. Неправильні аргументи

Один аргумент замість двох:

```bash
./backup.sh logs_t
```

```
Usage: ./backup.sh <log_dir> <backup_dir>
exit=1
```

Другий каталог не існує:

```bash
./backup.sh logs_t /no/such/dir
```

```
Usage: ./backup.sh <log_dir> <backup_dir>
exit=1
```

### 2. Захист від паралельного запуску

Коли lock-файл уже є:

```bash
touch /tmp/backup.lock
./backup.sh logs_t backup_t
```

```
Backup already running
exit=0
```

### 3. Успішний бекап

```bash
rm -f /tmp/backup.lock
./backup.sh logs_t backup_t
```

```
Backup created: /.../backup_t/logs_backup_2026-06-22_20-53.tar.gz
exit=0
```

Вміст архіву (всі файли з каталогу логів на місці):

```bash
ls -l backup_t/
tar -tzf backup_t/logs_backup_*.tar.gz
```

```
-rw-rw-r-- 1 leg-p21555 leg-p21555 186 июн 22 20:53 logs_backup_2026-06-22_20-53.tar.gz
./
./error.log
./app.log
```

Після завершення lock-файл прибирається автоматично (через `trap ... EXIT`):

```bash
ls /tmp/backup.lock
```

```
ls: cannot access '/tmp/backup.lock': No such file or directory
```

---

**Підсумок:** усі вимоги виконані — перевірка аргументів (код 1), захист lock-файлом, архів `logs_backup_YYYY-MM-DD_HH-MM.tar.gz` з датою/часом у каталозі бекапів, перевірка результату й вивід повного шляху до архіву.
