#!/bin/bash
set -euo pipefail

# Переход в домашний каталог пользователя, от имени которого запущен скрипт
cd "$HOME"

TARGET_DIR="$HOME/system_info"

# Проверка существования каталога и его создание
if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
    echo "Создан каталог $TARGET_DIR"
fi

# 1: Текущая дата
date '+%Y-%m-%d %H:%M:%S' > "$TARGET_DIR/1"

# 2: Версия ядра Linux
uname -r > "$TARGET_DIR/2"

# 3: Сетевое имя компьютера (hostname)
hostname > "$TARGET_DIR/3"

# 4: Список файлов домашнего каталога пользователя
ls -la "$HOME" > "$TARGET_DIR/4"

# Фиксация PID и пауза для возможности мониторинга процесса
echo "Процесс PID: $$ запущен от имени пользователя: $(whoami)"
sleep 5

echo "Сбор системных данных успешно завершён."
exit 0
