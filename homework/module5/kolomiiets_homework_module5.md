# Домашнє завдання (модуль 5)

Система: Ubuntu 24.04.4 LTS

> Реальні адреси/логіни сервера в звіті приховані (`<server_ip>`, `<user>`).

---

## Завдання 1. Мережева діагностика

Вивів IP-адреси та інтерфейси:

```bash
ip a
```

```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 ...
    inet 127.0.0.1/8 scope host lo
2: enp122s0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 ... state DOWN
3: wlp0s20f3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 ... state UP
    inet 192.168.20.185/24 brd 192.168.20.255 scope global dynamic noprefixroute wlp0s20f3
7: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 ... state DOWN
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
```

Перевірив доступність публічного вузла:

```bash
ping -c 4 8.8.8.8
```

```
64 bytes from 8.8.8.8: icmp_seq=1 ttl=116 time=14.4 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=116 time=15.2 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=116 time=16.8 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=116 time=38.8 ms

--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3003ms
rtt min/avg/max/mdev = 14.386/21.297/38.754/10.117 ms
```

Перевірив відкриті listening-порти:

```bash
ss -tulpn
```

```
Netid State  Recv-Q Send-Q  Local Address:Port  Peer Address:Port Process
udp   UNCONN 0      0       127.0.0.53%lo:53        0.0.0.0:*
tcp   LISTEN 0      4096          0.0.0.0:6379      0.0.0.0:*       redis
tcp   LISTEN 0      4096       127.0.0.54:53        0.0.0.0:*       systemd-resolved
tcp   LISTEN 0      4096          0.0.0.0:8081      0.0.0.0:*
```

**Коротко:**
- Локальна IP-адреса інтерфейсу: **192.168.20.185/24** (Wi-Fi `wlp0s20f3`).
- Доступ до інтернету: **є** — ping 8.8.8.8 без втрат (0% packet loss), середній час ~21 ms.
- Приклад сервісу, що слухає порт: **redis на 6379**, а також `systemd-resolved` на 53 (DNS).

---

## Завдання 2. SSH-доступ з ключами та config

SSH-ключ уже згенерований раніше (`ssh-keygen` створює пару `vps-key` / `vps-key.pub`):

```bash
ls -l ~/.ssh/vps-key ~/.ssh/vps-key.pub
```

```
-rw------- 1 leg-p21555 leg-p21555 387 ... /home/leg-p21555/.ssh/vps-key
-rw-r--r-- 1 leg-p21555 leg-p21555  85 ... /home/leg-p21555/.ssh/vps-key.pub
```

Публічний ключ був скопійований на сервер (раніше, командою):

```bash
ssh-copy-id -i ~/.ssh/vps-key.pub <user>@<server_ip>
```

У файлі `~/.ssh/config` є Host-запис для сервера:

```
Host test
  HostName <server_ip>
  User <user>
  IdentityFile ~/.ssh/vps-key
```

Підключився короткою командою (перевірив, що пароль не запитується — `BatchMode=yes` падає, якщо потрібен пароль):

```bash
ssh -o BatchMode=yes test 'echo CONNECTED_OK; hostname; whoami'
```

```
CONNECTED_OK
<remote_hostname>
<user>
```

**Коротко:**
- Ім'я Host у config: **`test`**.
- Підключення без пароля: **працює** (вхід лише за ключем `vps-key`, `BatchMode` не запитав пароль).

---

## Завдання 3. Копіювання файлів між машинами

Створив локальний тестовий файл:

```bash
echo "test" > test.txt
```

Передав файл на сервер через `scp` (попередньо створив каталог):

```bash
ssh test 'mkdir -p ~/hw5_sync'
scp test.txt test:~/hw5_sync/
```

Синхронізував локальну папку з сервером через `rsync`:

```bash
rsync -av ./ test:~/hw5_sync/
```

```
sending incremental file list
./
file2.txt
test.txt

sent 215 bytes  received 63 bytes  111,20 bytes/sec
total size is 19  speedup is 0,07
```

Підключився через `sftp` і перевірив, що файли на місці:

```bash
sftp test
sftp> cd hw5_sync
sftp> pwd
sftp> ls -l
```

```
Remote working directory: /home/<user>/hw5_sync
-rw-rw-r--    ? <user> <user>   14 Jun 22 20:44 file2.txt
-rw-rw-r--    ? <user> <user>    5 Jun 22 20:44 test.txt
```

**Коротко:**
- Шлях до файлів на сервері: **`~/hw5_sync`** (`/home/<user>/hw5_sync`).
- Для перевірки використовував **`sftp test`** → `cd hw5_sync` → `ls -l` (файли `test.txt` і `file2.txt` присутні).
