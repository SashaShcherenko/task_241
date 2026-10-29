#!/bin/bash
# Скрипт быстрой подготовки эмулированных дисков /dev/sdb и /dev/sdc
# и установки mdadm на ALT Linux

set -e

echo "[1/4] Обновление пакетов и установка mdadm..."
sudo apt-get update && sudo apt-get install -y mdadm

echo "[2/4] Создание файлов виртуальных дисков по 2 ГБ..."
sudo truncate -s 2G /var/disk_sdb.img
sudo truncate -s 2G /var/disk_sdc.img

echo "[3/4] Подключение loop-устройств с поддержкой разделов..."
sudo losetup -P /dev/loop10 /var/disk_sdb.img 2>/dev/null || true
sudo losetup -P /dev/loop11 /var/disk_sdc.img 2>/dev/null || true

echo "[4/4] Создание символических ссылок /dev/sdb и /dev/sdc..."
sudo ln -sf /dev/loop10 /dev/sdb
sudo ln -sf /dev/loop11 /dev/sdc

echo "=== Готово! ==="
echo "Проверка блочных устройств:"
lsblk
echo ""
echo "Символические ссылки:"
ls -l /dev/sd[bc]* 2>/dev/null || true
