# Запуск qBittorrent с VPN в Docker на Debian внутри WSL2
Этот проект документирует процесс запуска qBittorrent с интегрированным VPN в контейнере Docker, работающем на Debian внутри WSL2 на Windows. Данный подход позволяет обеспечить безопасное и анонимное использование BitTorrent-клиента с помощью VPN, при этом окружение Docker гарантирует повторяемость и изоляцию.

## Описание

В современных условиях приватность и безопасность при использовании BitTorrent-клиентов становятся критически важными. Данный проект описывает, как:
- Установить и настроить WSL2 на Windows, используя Debian в качестве Linux-дистрибутива.
- Запустить Docker в WSL2, чтобы работать с контейнерами напрямую в Linux-среде.
- Развернуть готовый Docker-образ, включающий qBittorrent с поддержкой VPN (например, на базе образа [binhex/arch-qbittorrentvpn](https://hub.docker.com/r/binhex/arch-qbittorrentvpn)), который позволяет объединить работу BitTorrent-клиента с VPN для повышения конфиденциальности и обхода ограничений.
- Настроить проброс портов и обеспечить доступ к веб-интерфейсу qBittorrent с хоста и других устройств в сети.
- Дополнительно использовать [Portainer](https://www.portainer.io/) для удобства настройки и администрирования Docker-окружения через графический веб-интерфейс.

## Ключевые возможности

- **Интеграция VPN:** Запуск qBittorrent с VPN позволяет шифровать трафик и скрывать реальный IP-адрес.
- **Изоляция через Docker:** Использование контейнеров гарантирует чистоту и повторяемость окружения.
- **WSL2 на Windows:** Использование WSL2 предоставляет нативную Linux-среду, улучшая производительность и совместимость Docker-контейнеров.
- **Автоматический запуск WSL2:** WSL2 может быть запущен без необходимости входа пользователя в систему, например, через планировщик задач, что позволяет запускать сервисы и контейнеры в автоматическом режиме.
- **Удобство администрирования:** Благодаря Portainer управление Docker-контейнерами становится простым и интуитивно понятным, что облегчает мониторинг и конфигурацию системы.
- **Документированная установка:** Подробные инструкции и примеры команд помогут даже новичкам настроить окружение без особых трудностей.

## Предварительные требования

- **Windows 11 версии 22H2** (минимум) с поддержкой WSL2, включающей функцию [Зеркальное отображение сети (Mirrored Mode Networking)](https://learn.microsoft.com/ru-ru/windows/wsl/networking#mirrored-mode-networking) и [systemd](https://learn.microsoft.com/ru-ru/windows/wsl/systemd).
- **Debian**, установленный в WSL2.
- **Docker Engine**, установленный непосредственно внутри WSL2 (без использования Docker Desktop).
- Действительные учетные данные VPN, совместимые с используемым Docker-образом.
- **Portainer** для графического администрирования Docker.

## Ограничения
**Службы, запущенные в WSL2, не будут доступны через NAT (например, при подключении через публикацию портов на роутере или VPN).**
> [!TIP]
> Для обхода можно использовать:
> - KeenDNS на роутерах Keenetic ([пример настройки](https://help.keenetic.com/hc/ru/articles/360000563719-%D0%9F%D1%80%D0%B8%D0%BC%D0%B5%D1%80-%D1%83%D0%B4%D0%B0%D0%BB%D0%B5%D0%BD%D0%BD%D0%BE%D0%B3%D0%BE-%D0%B4%D0%BE%D1%81%D1%82%D1%83%D0%BF%D0%B0-%D0%BA-%D0%B2%D0%B5%D0%B1-%D0%BF%D1%80%D0%B8%D0%BB%D0%BE%D0%B6%D0%B5%D0%BD%D0%B8%D1%8F%D0%BC-%D0%B4%D0%BE%D0%BC%D0%B0%D1%88%D0%BD%D0%B5%D0%B9-%D1%81%D0%B5%D1%82%D0%B8-%D1%87%D0%B5%D1%80%D0%B5%D0%B7-KeenDNS)).
> - Другой хост с Docker где можно использовать NGINX Proxy Manager ([официальный сайт](https://nginxproxymanager.com/)).
> - Сервер Home Assistant где NGINX Proxy Manager доступен как дополнение ([репозиторий](https://github.com/hassio-addons/addon-nginx-proxy-manager)).
> - NGINX Reverse Proxy ([документация](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)).

**Диски, подключенные в хостовой системе как папки, будут недоступны внутри WSL.**
> [!NOTE]
> Дополнительную информацию о настройке точек монтирования и возможных ограничениях смотрите в [официальной документации](https://learn.microsoft.com/ru-ru/windows-server/storage/disk-management/assign-a-mount-point-folder-path-to-a-drive).

> [!TIP]
> Для обхода этой проблемы можно подключать диски как сетевые папки CIFS внутри Debian.
> > Пример такого обхода описан в [Шаге 3.](#шаг-3-опционально-подключение-дисков-из-хостовой-системы-в-wsl-2)

**USB-устройства, подключенные к хосту, недоступны из WSL.**
> [!TIP]
> Для обхода можно использовать проект USB/IP с открытым исходным кодом. Подробнее можно узнать в [документации](https://learn.microsoft.com/ru-ru/windows/wsl/connect-usb).

## Как запустить
## Шаг 1: Настройка WSL2 и Debian

Перед запуском qBittorrent с VPN в Docker на Debian внутри WSL2 необходимо правильно подготовить систему. В этом разделе подробно описаны все необходимые действия, начиная с обновления Windows и заканчивая обновлением всех пакетов в Debian.

### 1.1. Обновление Windows
- Убедитесь, что у вас установлена Windows 11 версии **22H2** (минимум).  
- Запустите **Центр обновления Windows** и установите все доступные обновления.

### 1.2. Обновление WSL до минимальной версии 2.4.10.0
1. Откройте [Windows Terminal](https://aka.ms/terminal) (или PowerShell) от имени администратора и проверьте текущую версию WSL:
   ```powershell
   wsl --version
2. Если версия ниже 2.4.10.0, выполните обновление:
   ```powershell
   wsl --update
3. Перезапустите WSL:
   ```powershell
   wsl --shutdown
### 1.3. Включение режима Mirrored Mode Networking

Чтобы службы внутри WSL слушали на реальном IP-адресе (режим зеркального отображения сети), необходимо включить режим `mirrored` и активировать функцию `hostAddressLoopback`. Для этого нужно создать или отредактировать файл  
`C:\Users\Username\.wslconfig`  
(где `Username` — имя учетной записи, в которой будет запускаться WSL) и добавить в него следующий раздел:

```ini
[wsl2]
networkingMode=mirrored
[experimental]
hostAddressLoopback=true
```
> [!NOTE]
> Подробнее можно узнать в [документации WSL](https://learn.microsoft.com/ru-ru/windows/wsl/wsl-config#configuration-settings-for-wslconfig).
#### Как это сделать через PowerShell

1. Откройте PowerShell от имени администратора и выполните следующую команду, чтобы открыть файл `.wslconfig` в блокноте:
   ```powershell
   notepad $env:USERPROFILE\.wslconfig
   ```
2. Если файл не существует, Notepad предложит создать его. Вставьте в открывшийся файл следующий контент:
   ```ini
   [wsl2]
   networkingMode=mirrored
   [experimental]
   hostAddressLoopback=true
   ```
3. Сохраните файл и закройте Notepad.
> [!WARNING]
> При сохранении убедитесь, что файл сохраняется строго как .wslconfig (без дополнительных расширений).
4. Если WSL был запущен, выполните в PowerShell:
   ```powershell
   wsl --shutdown
   ```
5. Теперь службы WSL будут доступны на реальном IP-адресе вашей Windows-хост машины, а не только через `localhost`.
### 1.4. Установка дистрибутива Debian через PowerShell

Для установки Debian через PowerShell выполните следующую команду:
```powershell
wsl --install -d Debian
```
Эта команда загрузит и установит Debian из Microsoft Store. После завершения установки запустите Debian для первоначальной настройки.
### 1.5. Смена пароля root
1. Откройте терминал Debian.
2. Выполните команду:
   ```bash
   sudo passwd root
   ```
3. Введите новый пароль и подтвердите его.
### 1.6. Обновление системы Debian
1. Обновите список пакетов и установите доступные обновления:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
2. Для полного обновления системы выполните:
   ```bash
   sudo apt full-upgrade -y
   ```
3. Проверьте, в каком режиме работает WSL (mirrored или NAT). В терминале Debian выполните:
      ```bash
   wslinfo --networking-mode
   ```
   Вы должны увидеть, что режим установлен как `mirrored`.
4. Узнайте IP-адрес, на котором WSL слушает:
   ```bash
   hostname -I
   ```
> [!NOTE]
> Полученный IP-адрес должен совпадать с IP-адресом вашей Windows-хост машины, что подтверждает корректную работу в режиме `mirrored`
### Шаг 2: Установка Docker Engine и Portainer
#### 2.1. Установка Docker Engine

1. Обновите пакеты и установите зависимости:
   ```bash
   sudo apt update
   sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release -y
   ```
2. Добавьте ключ и репозиторий Docker:
   ```bash
   curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```
3. Обновите пакеты и установите Docker Engine:
   ```bash
   sudo apt update
   sudo apt install docker-ce docker-ce-cli containerd.io -y
   ```
4. Проверьте установку, запустив:
   ```bash
   sudo docker run hello-world
   ```
5. Чтобы запускать Docker без sudo:
   ```bash
   sudo usermod -aG docker $USER
   ```
   После этого закройте текущую сессию терминала WSL и откройте новую, чтобы изменения вступили в силу.
#### 2.3. Установка и запуск Portainer

Portainer предоставляет удобный веб-интерфейс для управления Docker-контейнерами.

1. Создайте volume для хранения данных Portainer:
   ```bash
   sudo docker volume create portainer_data
   ```
2. Запустите контейнер Portainer:
    ```bash
    sudo docker run -d \
    -p 8000:8000 \
    -p 9443:9443 \
    --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest
    ```
> [!NOTE]
> - **9443** — порт для доступа к веб-интерфейсу по HTTPS.
> - **8000** — порт для работы с агентом Portainer (при необходимости).
3. Создайте правило firewall для портов Portainer на Windows-хосте, выполнив в PowerShell:
    ```powershell
    New-NetFirewallRule -DisplayName "Allow Portainer Ports" -Direction Inbound -LocalPort 8000,9443 -Protocol TCP -Action Allow
    ```
4. Доступ к Portainer:
   Откройте браузер и перейдите по адресу:
   
   `https://<IP-адрес_вашего_Windows-хоста>:9443`

   При первом запуске вам будет предложено создать учетную запись администратора.

### Шаг 3 (Опционально): Подключение дисков из хостовой системы в WSL 2

Если диски, подключённые на хостовой машине как папки, не доступны напрямую в WSL, их можно смонтировать как сетевые папки (CIFS) внутри Debian.

В данном примере используются общие административные папки Windows (Admin$, IPC$, C$) – в частности, папка C$ – и для подключения применяется учетная запись локального администратора "Администратор". Это упрощает настройку, поскольку эти папки создаются по умолчанию в Windows и не требуют дополнительной конфигурации.
> [!NOTE]
> Подробнее можно узнать в [документации](https://learn.microsoft.com/ru-ru/troubleshoot/windows-server/networking/remove-administrative-shares?source=recommendations).

#### 3.1. Установка пакетов для монтирования CIFS

Перед монтированием убедитесь, что в Debian установлены необходимые пакеты:

```bash
sudo apt update
sudo apt install cifs-utils -y
```

#### 3.2. Создание каталога для монтирования

Создайте каталог в Debian, куда будет монтироваться сетевая папка. Например:

```bash
sudo mkdir -p /share/lib
```

#### 3.3. #### Скрытие учетных данных с использованием файла /root/.smbcredentials

- Откройте терминал Debian в WSL2 и выполните следующую команду для редактирования файла с помощью nano:
```bash
sudo nano /root/.smbcredentials
```
- Вставьте в файл следующие строки:
 
```ini
username=YOUR_USERNAME
password=YOUR_PASSWORD
```

(Замените YOUR_USERNAME и YOUR_PASSWORD на ваши реальные данные учетной записи с правами на административные папки.)

- Сохраните файл и установите безопасные права доступа:
   
```bash
sudo chmod 600 /root/.smbcredentials
```

#### 3.4. Монтирование сетевой папки CIFS с использованием файла учетных данных

Смонтируйте сетевую папку CIFS. Например, для шары //127.0.0.1/C\$/lib с указанием кодировки UTF-8 выполните:

```bash
sudo mount -t cifs //127.0.0.1/C$/lib /share/lib  cifs  credentials=/root/.smbcredentials,iocharset=utf8,file_mode=0777,dir_mode=0777
```

#### 3.5. Постоянное монтирование при загрузке

Чтобы автоматически монтировать папку при загрузке, отредактируйте файл /etc/fstab:

```bash
sudo nano /etc/fstab
```

Добавьте следующую строку в конец файла:

```
//127.0.0.1/C$/lib /share/lib  cifs  credentials=/root/.smbcredentials,iocharset=utf8,file_mode=0777,dir_mode=0777  0  0
```
Сохраните изменения и выйдите из редактора.

### Шаг 4: Установка и настройка binhex/arch-qbittorrentvpn через Portainer Stacks и настройка Windows Firewall
#### 4.1. Создание папки для использования нового пути хранения данных qbittorrentvpn на хосте

> [!TIP]
> Папка **ProgramData** — это скрытая системная директория Windows, предназначенная для хранения общих данных приложений, доступных всем пользователям системы. Вот несколько ключевых моментов:
> - **Общее хранилище:** Данные, хранящиеся в ProgramData, не привязаны к конкретному пользователю. Это позволяет приложениям сохранять общие настройки, конфигурационные файлы и другую информацию, которая используется всеми пользователями.
> - **Расположение:** Обычно эта папка находится по адресу `C:\ProgramData`.
> - **Системный уровень:** В отличие от пользовательской папки AppData, которая находится в профиле каждого пользователя, ProgramData используется для хранения данных, общих для системы, что упрощает управление настройками и обеспечивает их сохранность при смене или удалении пользовательских профилей.
> - **Безопасность:** Доступ к этой папке ограничен, что помогает защитить важные системные и программные данные от несанкционированного доступа и изменений.
> 
> Использование папки ProgramData для хранения данных qbittorrentvpn (например, в `C:\ProgramData\wls_docker\volumes\qbittorrentvpn_config\_data`) повышает безопасность и удобство управления, так как данные будут храниться вне WSL, на уровне Windows-хоста, где к ним имеет доступ системный администратор.

> [!IMPORTANT]  
> Вы можете использовать любую папку для размещения данных qbittorrentvpn, главное – соблюдать нужные права доступа.

Чтобы создать такую папку через PowerShell (от имени администратора), выполните:
```powershell
New-Item -ItemType Directory -Path "C:\ProgramData\wls_docker\volumes\qbittorrentvpn_config\_data" -Force
```

#### 4.2. Создание Stack в Portainer
> [!TIP]
> Использование Stack в Portainer позволяет объединить все настройки контейнера в один файл YAML, что значительно упрощает развёртывание, обновление и управление конфигурацией, делая процесс более прозрачным и удобным.

> [!IMPORTANT]  
> Если вы хотите, чтобы qBittorrent был доступен в локальной сети, замените адрес в параметре LAN_NETWORK (по умолчанию 192.168.0.0/16) на вашу подсеть в формате CIDR.

> [!NOTE]  
> Более подробную информацию о параметрах можно найти на странице проекта: [@binhex/arch-qbittorrentvpn](https://github.com/binhex/arch-qbittorrentvpn).
>
> Наш пример предназначен для запуска qBittorrent в окружении WSL2 с использованием конфигурационного файла .ovpn для OpenVPN.


1. Войдите в Portainer и перейдите в раздел **Stacks**.
2. Нажмите **Add Stack**.
3. Введите имя Stack, например, `qbittorrentvpn`, и вставьте следующий YAML в редактор стека:

```yaml
version: '2.1'
services:
  qbittorrentvpn:
    image: binhex/arch-qbittorrentvpn:latest
    container_name: qbittorrentvpn
    cap_add:
      - NET_ADMIN
    environment:
      - VPN_ENABLED=yes
      - VPN_PROV=custom
      - VPN_CLIENT=openvpn
      - ENABLE_STARTUP_SCRIPTS=yes
      - NAME_SERVERS=1.1.1.1,1.0.0.1
      - WEBUI_PORT=8080
      - LAN_NETWORK=192.168.0.0/16,localhost,127.0.0.1,172.17.0.0/16
      - LANG=ru_RU.UTF-8
      - DEBUG=false
      - PUID=0
      - PGID=0
      - TZ=Europe/Moscow
    ports:
      - "8080:8080"
    volumes:
      - config:/config
      - /share/qBittorrent/downloads:/downloads:rw
      - /share:/share:rw
      - /etc/localtime:/etc/localtime:ro
    restart: always

volumes:
  config:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /mnt/c/ProgramData/wls_docker/volumes/qbittorrentvpn_config/_data
```

4. Нажмите **Deploy the stack** и дождитесь завершения развертывания.

#### 4.3. Создание правила Windows Firewall через PowerShell

Чтобы обеспечить доступ к веб-интерфейсу qBittorrent (порт 8080) с других устройств, создайте правило в Windows Firewall. Выполните в PowerShell (от имени администратора):

```powershell
New-NetFirewallRule -DisplayName "Allow qBittorrent WebUI" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
```

#### 4.4. Доступ к qBittorrent с VPN

После развертывания контейнера:
- Откройте браузер и перейдите по адресу:

```
http://<IP-адрес_вашего_сервера>:8080
```

- Используйте указанные учетные данные для входа в веб-интерфейс qBittorrent.
- При необходимости настройте проброс портов или обратный прокси для обеспечения доступа извне.

