# Домашнє завдання №3. Процеси, пріоритети та ресурси

## Завдання 1. Огляд активних процесів

### 1.1. Список усіх процесів
```bash
ps aux
```
Вивід (перші рядки та загальна кількість):
```
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.0  24144 15672 ?        Ss   мар31   0:32 /sbin/init splash
root           2  0.0  0.0      0     0 ?        S    мар31   0:00 [kthreadd]
root           3  0.0  0.0      0     0 ?        S    мар31   0:00 [pool_workqueue_release]
root          14  0.0  0.0      0     0 ?        S    мар31   1:32 [ksoftirqd/0]
root          15  0.1  0.0      0     0 ?        I    мар31  19:50 [rcu_preempt]
...
```
Усього в системі — **450 рядків** (з них перший — заголовок).

### 1.2. Інтерактивний монітор і найжадніший по RAM
```bash
top
```
(`htop` не встановлено, користувався `top`; з нього вийшов через `q`.)

Аби побачити те саме "зверху" не інтерактивно, я відсортував `ps` по `%MEM`:
```bash
ps aux --sort=-%mem | head -6
```
```
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
leg-p21+    7646 23.5 13.1 277252972 8633564 ?   Sl   мар31 4557:41 .../ReSharperHost/.../dotnet ... JetBrains.DPA.Protocol.Backend.exe ...
leg-p21+    6307  4.7  5.2 8488292 3463016 ?     SLl  мар31 918:37  .../pycharm/bin/pycharm
leg-p21+ 2879280  6.2  4.6 7655640 3056964 ?     Sl   апр12 100:52  .../webstorm/bin/webstorm
leg-p21+    6197  6.4  4.5 7884288 2967768 ?     Sl   мар31 1252:57 .../rider/bin/rider
leg-p21+ 2879991  0.1  2.8 3547388 1841940 ?     Sl   апр12   1:39  .../sonarlint-intellij/.../server.cjs ...
```
Найбільше RAM споживає процес **Rider ReSharper backend** (PID 7646, ~13.1% пам'яті, ~8.6 ГБ RSS).

### 1.3. PID поточної оболонки
```bash
echo $$
ps -p $$ -o pid,comm
```
```
3086792
    PID COMMAND
3086792 bash
```

---

## Завдання 2. Робота у фоні та керування процесами

### 2.1. Запустити довгу команду у фоні
```bash
sleep 1000 &
```
```
[1] 3087029
```

### 2.2. Список фонових завдань
```bash
jobs
```
```
[1]+  Running                 sleep 1000 &
```

### 2.3. Повернути процес на передній план
```bash
fg %1
```
```
sleep 1000
```
Термінал "повис" на виконанні `sleep`.

### 2.4. Зупинити і примусово завершити
Зупиняю `Ctrl+Z`, далі `kill`:
```
^Z
[1]+  Stopped                 sleep 1000
```
```bash
jobs
kill -9 %1
jobs
```
```
[1]+  Stopped                 sleep 1000
[1]+  Killed                  sleep 1000
```

### 2.5. `nohup`
```bash
nohup sleep 300 > /tmp/nohup_demo.out 2>&1 &
```
```
[1] 3087119
nohup: ignoring input and redirecting stderr to stdout
```
Процес продовжує роботу навіть якщо термінал закрити — бо `nohup` ігнорує сигнал `SIGHUP`, який надсилається при виході з сесії.

---

## Завдання 3. Пріоритети та обмеження

### 3.1. Запустити команду з підвищеним nice (нижчим пріоритетом)
```bash
nice -n 10 yes > /dev/null &
ps -o pid,ni,cmd -p $!
```
```
    PID  NI CMD
3087133  10 yes
```

### 3.2. Змінити пріоритет уже запущеного процесу
```bash
renice -n 15 -p 3087133
ps -o pid,ni,cmd -p 3087133
```
```
3087133 (process ID) old priority 10, new priority 15
    PID  NI CMD
3087133  15 yes
```

### 3.3. Обмеження ресурсів поточного користувача
```bash
ulimit -a
```
```
real-time non-blocking time  (microseconds, -R) 200000
core file size              (blocks, -c) 0
data seg size               (kbytes, -d) unlimited
scheduling priority                 (-e) 0
file size                   (blocks, -f) unlimited
pending signals                     (-i) 254882
max locked memory           (kbytes, -l) 8190812
max memory size             (kbytes, -m) unlimited
open files                          (-n) 1048576
pipe size                (512 bytes, -p) 8
POSIX message queues         (bytes, -q) 819200
real-time priority                  (-r) 0
stack size                  (kbytes, -s) 8192
cpu time                   (seconds, -t) unlimited
max user processes                  (-u) 254882
virtual memory              (kbytes, -v) unlimited
file locks                          (-x) unlimited
```

---

## Завдання 4. Моніторинг ресурсів

### 4.1. Використання дискового простору
```bash
df -h
```
```
Filesystem                         Size  Used Avail Use% Mounted on
tmpfs                              6,3G  4,0M  6,3G   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv  935G  415G  473G  47% /
tmpfs                               32G  394M   31G   2% /dev/shm
tmpfs                              5,0M   12K  5,0M   1% /run/lock
efivarfs                           268K  163K  101K  62% /sys/firmware/efi/efivars
/dev/nvme0n1p2                     2,0G  222M  1,6G  13% /boot
/dev/nvme0n1p1                     1,1G   17M  1,1G   2% /boot/efi
tmpfs                              6,3G  2,8M  6,3G   1% /run/user/1000
```

### 4.2. Використання оперативної пам'яті
```bash
free -h
```
```
               total        used        free      shared  buff/cache   available
Mem:            62Gi        34Gi       4,6Gi       2,9Gi        27Gi        27Gi
Swap:          8,0Gi       400Mi       7,6Gi
```
