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
