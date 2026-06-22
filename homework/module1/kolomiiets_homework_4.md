# Домашнє завдання 4

Система: Ubuntu 24.04.4 LTS (Noble Numbat)

---

## Завдання 1. Менеджери пакетів

Оновив список пакетів:

```bash
sudo apt update
```

```
...
Fetched 8.537 kB in 4s (2.198 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
29 packages can be upgraded. Run 'apt list --upgradable' to see them.
```

Встановив утиліту `tree` (htop у мене вже є, тому поставив tree):

```bash
sudo apt install -y tree
```

```
The following NEW packages will be installed:
  tree
0 upgraded, 1 newly installed, 0 to remove and 29 not upgraded.
...
Unpacking tree (2.1.1-2ubuntu3.24.04.2) ...
Setting up tree (2.1.1-2ubuntu3.24.04.2) ...
```

Перевірив, що пакет встановлено, і подивився версію:

```bash
dpkg -l tree | tail -1
tree --version
```

```
ii  tree           2.1.1-2ubuntu3.24.04.2 amd64        displays an indented directory tree, in color
tree v2.1.1 © 1996 - 2023 by Steve Baker, Thomas Moore, Francesc Rocher, Florian Sesser, Kyosuke Tokoro
```

Видалив пакет:

```bash
sudo apt remove -y tree
```

```
The following packages will be REMOVED:
  tree
0 upgraded, 0 newly installed, 1 to remove and 29 not upgraded.
...
Removing tree (2.1.1-2ubuntu3.24.04.2) ...
```

---

## Завдання 2. Керування сервісами через systemctl

Сервісу `ssh` у системі немає, тому працював із `cron`.

Перевірив статус:

```bash
systemctl status cron --no-pager | head -5
```

```
● cron.service - Regular background program processing daemon
     Loaded: loaded (/usr/lib/systemd/system/cron.service; enabled; preset: enabled)
     Active: active (running) since Mon 2026-06-15 10:23:54 EEST; 1 week 0 days ago
       Docs: man:cron(8)
   Main PID: 1248 (cron)
```

Зупинив сервіс і переконався, що він не активний:

```bash
sudo systemctl stop cron
systemctl is-active cron
```

```
inactive
```

Запустив знову:

```bash
sudo systemctl start cron
systemctl is-active cron
```

```
active
```

Додав у автозавантаження:

```bash
sudo systemctl enable cron
```

```
Synchronizing state of cron.service with SysV service script with /usr/lib/systemd/systemd-sysv-install.
Executing: /usr/lib/systemd/systemd-sysv-install enable cron
```

---

## Завдання 3. Робота з логами

Перейшов у `/var/log` і вивів останні 10 рядків `syslog`:

```bash
cd /var/log
tail -n 10 syslog
```

```
2026-06-22T20:13:14.031123+03:00 leg-p21555 systemd[1]: update-notifier-motd.service: Deactivated successfully.
2026-06-22T20:13:14.031363+03:00 leg-p21555 systemd[1]: Finished update-notifier-motd.service - Check to see whether there is a new version of Ubuntu available.
2026-06-22T20:13:14.400026+03:00 leg-p21555 systemd[1]: apt-daily.service: Deactivated successfully.
2026-06-22T20:13:14.400138+03:00 leg-p21555 systemd[1]: Finished apt-daily.service - Daily apt download activities.
2026-06-22T20:13:17.548270+03:00 leg-p21555 systemd[3026]: Started vte-spawn-6e4ce1ca-73d2-460e-a3c3-eba3359ef439.scope - VTE child process 3414887 launched by gnome-terminal-server process 3408746.
2026-06-22T20:13:23.635783+03:00 leg-p21555 update-notifier.desktop[3415089]: Reading package lists... Done
2026-06-22T20:13:23.771072+03:00 leg-p21555 update-notifier.desktop[3415089]: Building dependency tree... Done
2026-06-22T20:13:23.771927+03:00 leg-p21555 update-notifier.desktop[3415089]: Reading state information... Done
2026-06-22T20:13:34.303435+03:00 leg-p21555 check-new-release-gtk[3414757]: WARNING:root:timeout reached, exiting
2026-06-22T20:13:34.330659+03:00 leg-p21555 systemd[3026]: Finished update-notifier-release.service - Notification regarding a new release of Ubuntu.
```

Переглянув через `journalctl` лише помилки (priority `err`):

```bash
journalctl -p err -n 20 --no-pager
```

```
июн 15 10:23:24 leg-p21555 systemd-cryptsetup[3818]: Device dm_crypt-0 is still in use.
июн 15 10:23:24 leg-p21555 systemd-cryptsetup[3818]: Failed to deactivate 'dm_crypt-0': Device or resource busy
-- Boot 78a7bc4ab32549e897690dabe9480bf0 --
июн 15 10:23:53 leg-p21555 kernel: ucsi_acpi USBC000:00: unknown error 256
июн 15 10:23:53 leg-p21555 kernel: ucsi_acpi USBC000:00: GET_CABLE_PROPERTY failed (-5)
июн 15 10:23:55 leg-p21555 bluetoothd[1156]: sap-server: Operation not permitted (1)
июн 15 10:23:55 leg-p21555 bluetoothd[1156]: Failed to set mode: Failed (0x03)
июн 15 10:24:20 leg-p21555 gdm-password][2827]: gkr-pam: unable to locate daemon control file
июн 15 10:24:21 leg-p21555 gdm3[1798]: Gdm: on_display_added: assertion 'GDM_IS_REMOTE_DISPLAY (display)' failed
июн 22 20:09:44 leg-p21555 sudo[3411819]: pam_unix(sudo:auth): auth could not identify password for [leg-p21555]
```

Знайшов у журналі записи про зупинку та запуск сервісу `cron` із Завдання 2:

```bash
journalctl -u cron --no-pager | tail -15
```

```
июн 22 20:12:47 leg-p21555 systemd[1]: Stopping cron.service - Regular background program processing daemon...
июн 22 20:12:47 leg-p21555 systemd[1]: cron.service: Deactivated successfully.
июн 22 20:12:47 leg-p21555 systemd[1]: Stopped cron.service - Regular background program processing daemon.
июн 22 20:12:59 leg-p21555 systemd[1]: Started cron.service - Regular background program processing daemon.
июн 22 20:12:59 leg-p21555 cron[3414204]: (CRON) INFO (pidfile fd = 3)
июн 22 20:12:59 leg-p21555 cron[3414204]: (CRON) INFO (Skipping @reboot jobs -- not system startup)
```

Тут видно рядки `Stopped cron.service` (20:12:47) та `Started cron.service` (20:12:59) — момент, коли я зупиняв і запускав сервіс.

---

## Завдання 4. Створення власного сервісу

Створив у домашньому каталозі bash-скрипт, який щосекунди дописує поточну дату у файл. Робив через `printf`, бо при вставці heredoc термінал додавав зайві пробіли і ламав shebang:

```bash
printf '#!/bin/bash\nwhile true; do\n    date >> /home/leg-p21555/date_log.txt\n    sleep 1\ndone\n' > ~/date_logger.sh
chmod +x ~/date_logger.sh
cat ~/date_logger.sh
```

```
#!/bin/bash
while true; do
    date >> /home/leg-p21555/date_log.txt
    sleep 1
done
```

Створив файл конфігурації сервісу `/etc/systemd/system/myscript.service`:

```bash
sudo tee /etc/systemd/system/myscript.service <<'EOF'
[Unit]
Description=My date logger service
After=network.target

[Service]
ExecStart=/home/leg-p21555/date_logger.sh
Restart=always
User=leg-p21555

[Install]
WantedBy=multi-user.target
EOF
```

Перезавантажив systemd і запустив сервіс:

```bash
sudo systemctl daemon-reload
sudo systemctl restart myscript
systemctl status myscript --no-pager | head -8
```

```
● myscript.service - My date logger service
     Loaded: loaded (/etc/systemd/system/myscript.service; disabled; preset: enabled)
     Active: active (running) since Mon 2026-06-22 20:20:04 EEST; 3s ago
   Main PID: 3417726 (date_logger.sh)
      Tasks: 2 (limit: 76463)
     Memory: 808.0K (peak: 1.4M)
        CPU: 7ms
     CGroup: /system.slice/myscript.service
```

Перевірив, що дані пишуться у файл:

```bash
tail -n 5 ~/date_log.txt
```

```
Пн 22 июн 2026 20:20:34 EEST
Пн 22 июн 2026 20:20:35 EEST
Пн 22 июн 2026 20:20:36 EEST
Пн 22 июн 2026 20:20:37 EEST
Пн 22 июн 2026 20:20:38 EEST
```

Дата дописується щосекунди — сервіс працює. Після перевірки зупинив його:

```bash
sudo systemctl stop myscript
systemctl is-active myscript
```

```
inactive
```
