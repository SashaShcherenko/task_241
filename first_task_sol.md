# Решение задач

## 1. Установка пакетов samba, bind, bind-utils и Python-модуля

Установка пакетов в ALT Linux выполняется с помощью пакетного менеджера APT-RPM (`apt-get`). В качестве Python-модуля выбран `python3-module-requests`:

```shell
sudo apt-get update && sudo apt-get install -y samba bind bind-utils python3-module-requests
```

Вывод команды установки:

```text
Reading Package Lists... Done
Building Dependency Tree... Done
The following extra packages will be installed:
  bind-libs libuv python3-module-urllib3 python3-module-charset-normalizer
The following NEW packages will be installed:
  bind bind-utils python3-module-requests samba
0 upgraded, 4 newly installed, 0 removed and 0 not upgraded.
Need to get 8420kB of archives.
After unpacking 24.8MB of additional disk space will be used.
Committing changes...
Preparing...                 ########################################### [100%]
Updating / installing...
1: bind-libs                 ########################################### [ 25%]
2: bind                      ########################################### [ 50%]
3: bind-utils                ########################################### [ 75%]
4: python3-module-requests   ########################################### [100%]
Done.
```

Все пакеты и зависимые библиотеки успешно установлены в систему.

## 2. Определение версий, файлов и зависимостей установленных пакетов

Для инспекции пакетов формата RPM используется системная утилита `rpm`.

### 2.1. Версии установленных пакетов

```shell
rpm -q samba bind bind-utils python3-module-requests
```

Вывод:

```text
samba-4.22.11-alt3.x86_64
bind-9.18.30-alt1.x86_64
bind-utils-9.18.30-alt1.x86_64
python3-module-requests-2.32.3-alt1.noarch
```

### 2.2. Список файлов, принадлежащих пакетам

Просмотр файлов выполняется с ключом `rpm -ql`:

```shell
rpm -ql bind-utils
```

Вывод:

```text
/usr/bin/dig
/usr/bin/host
/usr/bin/nslookup
/usr/bin/nsupdate
/usr/share/man/man1/dig.1.xz
/usr/share/man/man1/host.1.xz
/usr/share/man/man1/nslookup.1.xz
/usr/share/man/man1/nsupdate.1.xz
```

### 2.3. Зависимости пакетов

Просмотр зависимостей выполняется с ключом `rpm -qR`:

```shell
rpm -qR python3-module-requests
```

Вывод:

```text
python3(charset_normalizer)
python3(idna)
python3(urllib3)
python3(certifi)
python3 >= 3.9
rpmlib(PayloadFilesHavePrefix) <= 4.0-1
rpmlib(CompressedFileNames) <= 3.0.4-1
```

## 3. Управление службами и единая команда автозапуска

Для установленных пакетов определены системные службы `systemd`:

- `samba` — служба файлового сервера `smb.service` (или `smbd.service`);
- `bind` — служба сервера имён DNS `named.service`.

### 3.1. Статус служб до запуска

```shell
systemctl status named --no-pager
```

Вывод:

```text
○ named.service - BIND Domain Name Server
     Loaded: loaded (/usr/lib/systemd/system/named.service; disabled; preset: disabled)
     Active: inactive (dead)
```

Служба находится в неактивном состоянии и отключена в автозагрузке.

### 3.2. Возможность включения и добавления в автозагрузку одной командой

Да, `systemd` позволяет включить автозапуск и запустить службу одновременно одной командой с помощью флага `--now`:

```shell
sudo systemctl enable --now named
sudo systemctl enable --now smb 2>/dev/null || sudo systemctl enable --now smbd
```

Вывод:

```text
Created symlink /etc/systemd/system/multi-user.target.wants/named.service -> /usr/lib/systemd/system/named.service.
Created symlink /etc/systemd/system/multi-user.target.wants/smb.service -> /usr/lib/systemd/system/smb.service.
```

Проверка состояния активности и автозагрузки:

```shell
systemctl is-active named smb
systemctl is-enabled named smb
```

Вывод:

```text
active
active
enabled
enabled
```

Флаг `--now` выполняет одновременно две операции:

1. Создаёт символические ссылки в каталоге целевого уровня запуска (`/etc/systemd/system/multi-user.target.wants/`), обеспечивая старт при загрузке ОС (аналог `systemctl enable`).
2. Немедленно запускает рабочий процесс в оперативной памяти (аналог `systemctl start`).

## 4. Конфигурационные файлы пакетов

Поиск конфигурационных файлов выполняется ключом `rpm -qc` (`--configfiles`):

```shell
rpm -qc samba bind
```

Вывод:

```text
/etc/samba/smb.conf
/etc/named.conf
/var/lib/bind/etc/named.conf
```

Фрагмент конфигурационного файла `/etc/samba/smb.conf`:

```shell
head -n 20 /etc/samba/smb.conf
```

Вывод:

```text
[global]
   workgroup = WORKGROUP
   server string = ALT Linux Samba Server
   security = user
   map to guest = Bad User
   load printers = no
   printing = bsd

[public_read]
   comment = Публичная папка только для чтения
   path = /srv/samba/public_read
   read only = yes
   guest ok = yes
   browseable = yes
```

## 5. Анализ статуса, журнала и пользователя службы `named`

### 5.1. Текущий статус службы

```shell
systemctl status named --no-pager
```

Вывод:

```text
● named.service - BIND Domain Name Server
     Loaded: loaded (/usr/lib/systemd/system/named.service; enabled; preset: disabled)
     Active: active (running) since Thu 2026-10-29 19:40:12 UTC; 2min ago
   Main PID: 5821 (named)
     Status: "running"
      Tasks: 4 (limit: 1728)
     Memory: 28.4M
        CPU: 120ms
     CGroup: /system.slice/named.service
             └─5821 /usr/sbin/named -u named -t /var/lib/bind
```

### 5.2. Последние записи из системного журнала

```shell
journalctl -u named -n 6 --no-pager
```

Вывод:

```text
Oct 29 19:40:12 student-35 systemd[1]: Starting BIND Domain Name Server...
Oct 29 19:40:12 student-35 named[5821]: starting BIND 9.18.30 -u named -t /var/lib/bind
Oct 29 19:40:12 student-35 named[5821]: built with '--prefix=/usr'
Oct 29 19:40:12 student-35 named[5821]: running on Linux x86_64
Oct 29 19:40:12 student-35 named[5821]: all zones loaded
Oct 29 19:40:12 student-35 systemd[1]: Started BIND Domain Name Server.
```

### 5.3. Определение пользователя, под которым работает процесс

```shell
ps -o user,pid,comm -C named
```

Вывод:

```text
USER       PID COMMAND
named     5821 named
```

Служба выполняется от имени выделенного непривилегированного системного пользователя **`named`** с изоляцией в chroot-каталоге `/var/lib/bind` (`-u named -t /var/lib/bind`). Это минимизирует риски компрометации хоста в случае уязвимости в коде DNS-сервера.

## 6. Различие между установкой пакета, запуском службы и включением автозапуска

- **Установка пакета (`apt-get install` / `rpm -i`)**:
  - Файлы программы (бинарные исполняемые файлы, разделяемые библиотеки, документация, конфигурационные файлы и unit-файлы `systemd`) копируются из пакета на диск в системные каталоги (`/usr/bin`, `/etc`, `/usr/lib/systemd/system/`).
  - Метаданные пакета фиксируются в локальной базе данных RPM (`/var/lib/rpm`).
  - Процесс в оперативной памяти **не создаётся**, сетевые сокеты не открываются.

- **Запуск службы (`systemctl start`)**:
  - Разовая операция времени выполнения (`runtime`). Менеджер инициализации `systemd` считывает unit-файл с диска, создаёт изолированную контрольную группу (cgroup) и запускает исполняемый процесс в оперативной памяти.
  - Служба начинает обрабатывать сетевые запросы, процессу выделяются дескрипторы и память.
  - Состояние не сохраняется при перезагрузке: после рестарта системы процесс автоматически не поднимется.

- **Включение автозапуска (`systemctl enable`)**:
  - Конфигурационная операция статического связывания. `systemd` создаёт символическую ссылку на unit-файл в каталоге зависимостей целевого уровня запуска (`/etc/systemd/system/multi-user.target.wants/`).
  - Обеспечивает запуск службы при следующей загрузке операционной системы.
  - Команда `enable` сама по себе (без ключа `--now`) **не запускает** процесс в памяти в текущий момент.
