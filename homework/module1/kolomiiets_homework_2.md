# Домашнє завдання №2. Файлова система і права доступу

## Завдання 1. Ієрархія каталогів Linux

### 1.1. Перейти в `/` і показати вміст
```bash
cd /
ls
```
```
bin    cdrom  etc   lib    lib.usr-is-merged  media  opt   root  sbin                srv      swap.img  tmp  var
bin.usr-is-merged  boot   dev   home  lib64  lost+found     mnt    proc  run   sbin.usr-is-merged  snap     sys       usr
```

### 1.2. Перейти в `/etc` і показати вміст
```bash
cd /etc
ls
```
Файлів тут дуже багато (249), тому навожу перші рядки виводу:
```
adduser.conf
alsa
alternatives
anacrontab
apparmor
apparmor.d
apt
bash.bashrc
bash_completion
ca-certificates
cron.d
crontab
...
```

### 1.3. Перейти в `/home` і показати список користувачів
```bash
cd /home
ls
```
```
leg-p21555
```
На машині лише один звичайний користувач.

---

## Завдання 2. Файли, каталоги та посилання

```bash
mkdir ~/lab2                         # 1. створили каталог
cd ~/lab2
echo "hello" > file.txt              # 2. створили файл
cp file.txt file_copy.txt            # 3. скопіювали
mv file_copy.txt file_renamed.txt    # 4. перейменували копію
ln file.txt file_hard.txt            # 5. жорстке посилання
ln -s file.txt file_sym.txt          # 6. символічне посилання
find ~ -name "file.txt"              # 7. пошук за ім'ям
```

Після всіх команд `ls -la` у `~/lab2` показує:
```
-rw-rw-r-- 2 leg-p21555 leg-p21555 6 апр 13 22:09 file.txt
-rw-rw-r-- 2 leg-p21555 leg-p21555 6 апр 13 22:09 file_hard.txt
-rw-rw-r-- 1 leg-p21555 leg-p21555 6 апр 13 22:09 file_renamed.txt
lrwxrwxrwx 1 leg-p21555 leg-p21555 8 апр 13 22:09 file_sym.txt -> file.txt
```
У `file.txt` і `file_hard.txt` однаковий inode (кількість посилань — `2`), `file_sym.txt` — це символьне посилання (`l` на початку прав, `-> file.txt`).

Результат `find`:
```
/home/leg-p21555/lab2/file.txt
```

---

## Завдання 3. Права доступу

```bash
cd ~/lab2
ls -l file.txt
```
```
-rw-rw-r-- 2 leg-p21555 leg-p21555 6 апр 13 22:09 file.txt
```

Зробити файл тільки для читання:
```bash
chmod 444 file.txt
ls -l file.txt
```
```
-r--r--r-- 2 leg-p21555 leg-p21555 6 апр 13 22:09 file.txt
```

Повернути власнику право на запис:
```bash
chmod u+w file.txt
ls -l file.txt
```
```
-rw-r--r-- 2 leg-p21555 leg-p21555 6 апр 13 22:09 file.txt
```

Переглянути `umask` і встановити `022`:
```bash
umask
```
```
0002
```
```bash
umask 022
umask
```
```
0022
```

---

## Завдання 4. Користувачі

```bash
sudo useradd -m -s /bin/bash trainee      # створити користувача з домашнім каталогом
sudo passwd trainee                        # задати пароль
sudo usermod -aG sudo trainee              # додати в групу sudo
getent passwd trainee                      # перевірити, що користувач існує
```

Вивід `getent passwd trainee`:
```
trainee:x:1001:1001::/home/trainee:/bin/bash
```

Перевірка членства в sudo:
```bash
groups trainee
```
```
trainee : trainee sudo
```
