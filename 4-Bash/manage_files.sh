#!/bin/bash
set -euo pipefail

# Проверка передачи обязательного первого аргумента (целевой каталог)
if [ $# -lt 1 ] || [ -z "$1" ]; then
    echo "Ошибка: Не указан обязательный аргумент — целевой рабочий каталог." >&2
    echo "Использование: $0 <целевой_каталог>" >&2
    exit 1
fi

TARGET_DIR="$1"
LOG_FILE="${TARGET_DIR}/script_operations.log"

# Проверка существования каталога для предотвращения перезаписи без предупреждения
if [ -d "$TARGET_DIR" ]; then
    echo "Предупреждение: Каталог '$TARGET_DIR' уже существует. Существующие данные не удаляются."
else
    mkdir -p "$TARGET_DIR"
    echo "Создан новый рабочий каталог: $TARGET_DIR"
fi

# Запись заголовка сессии в лог
echo "[$(date '+%Y-%m-%d %H:%M:%S')] СТАРТ: запуск скрипта пользователем $(whoami)" >> "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Целевой каталог: $TARGET_DIR" >> "$LOG_FILE"

# Создание структуры подкаталогов и файлов
mkdir -p "$TARGET_DIR/docs" "$TARGET_DIR/backup"
touch "$TARGET_DIR/docs/report.txt" "$TARGET_DIR/docs/data.csv"

# Запись данных в файлы
echo "Системный отчёт сформирован: $(date)" > "$TARGET_DIR/docs/report.txt"
echo "id,service,status;1,sshd,active;2,cron,active" > "$TARGET_DIR/docs/data.csv"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Созданы файлы report.txt и data.csv" >> "$LOG_FILE"

# Копирование в резервный каталог
cp "$TARGET_DIR/docs/report.txt" "$TARGET_DIR/backup/report.txt.bak"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Создана резервная копия в backup/report.txt.bak" >> "$LOG_FILE"

# Просмотр дерева файлов
echo "=== Содержимое рабочего каталога ==="
ls -laR "$TARGET_DIR"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] УСПЕХ: работа скрипта завершена успешно" >> "$LOG_FILE"
echo "Работа завершена. Журнал операций сохранён в $LOG_FILE"
exit 0
