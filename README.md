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
- **Удобство администрирования:** Благодаря Portainer управление Docker-контейнерами становится простым и интуитивно понятным, что облегчает мониторинг и конфигурацию системы.
- **Документированная установка:** Подробные инструкции и примеры команд помогут даже новичкам настроить окружение без особых трудностей.

## Предварительные требования

- **Windows 11 версии 22H2** (минимум) с поддержкой WSL2, включающей функцию [Зеркальное отображение сети (Mirrored Mode Networking)](https://learn.microsoft.com/ru-ru/windows/wsl/networking#mirrored-mode-networking) и [systemd](https://learn.microsoft.com/ru-ru/windows/wsl/systemd).
- **Debian**, установленный в WSL2.
- **Docker Engine**, установленный непосредственно внутри WSL2 (без использования Docker Desktop).
- Действительные учетные данные VPN, совместимые с используемым Docker-образом.
- **Portainer** для графического администрирования Docker.

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

Чтобы службы внутри WSL слушали на реальном IP-адресе (режим зеркального отображения сети), необходимо включить режим mirrored. Для этого нужно создать или отредактировать файл  
`C:\Users\Username\.wslconfig`  
(где `Username` — имя учетной записи, в которой будет запускаться WSL) и добавить в него следующий раздел:

```ini
[wsl2]
networkingMode=mirrored
```
#### Как это сделать через PowerShell

1. Откройте PowerShell от имени администратора и выполните следующую команду, чтобы открыть файл `.wslconfig` в блокноте:
   ```powershell
   notepad $env:USERPROFILE\.wslconfig
   ```
2. Если файл не существует, Notepad предложит создать его. Вставьте в открывшийся файл следующий контент:
   ```ini
   [wsl2]
   networkingMode=mirrored
   ```
3. Сохраните файл и закройте Notepad. При сохранении убедитесь, что файл сохраняется строго как .wslconfig (без дополнительных расширений).
4. Перезапустите WSL, выполнив в PowerShell:
   ```powershell
   wsl --shutdown
   ```
5. Запустите WSL заново – теперь службы будут доступны на реальном IP-адресе вашей Windows-хост машины, а не только через `localhost`.
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
   **Примечание:** Полученный IP-адрес должен совпадать с IP-адресом вашей Windows-хост машины, что подтверждает корректную работу в режиме `mirrored`
### Шаг 2: Установка Docker Engine и Portainer
#### 2.1. Установка Docker Engine

1. Обновите список пакетов и установите необходимые зависимости:
   ```bash
   sudo apt update
   sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release -y
   ```
2. Добавьте официальный ключ GPG Docker:
   ```bash
   curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   ```
3. Добавьте репозиторий Docker в список источников APT:
   ```bash
   echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```
4. Обновите список пакетов и установите Docker Engine:
   ```bash
   sudo apt update
   sudo apt install docker-ce docker-ce-cli containerd.io -y
   ```
5. Проверьте установку Docker, запустив тестовый контейнер:
   ```bash
   sudo docker run hello-world
   ```
6. Чтобы запускать Docker без sudo, добавьте своего пользователя в группу docker:
   ```bash
   sudo usermod -aG docker $USER
   ```
   После этого выйдите из системы и войдите снова, чтобы изменения вступили в силу.
#### 2.2. Установка и запуск Portainer

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
    Здесь:
    **9443** — порт для доступа к веб-интерфейсу по HTTPS.
    **8000** — порт для работы с агентом Portainer (при необходимости).
3. Создайте правило firewall для портов Portainer на Windows-хосте, выполнив в PowerShell:
    ```powershell
    New-NetFirewallRule -DisplayName "Allow Portainer Ports" -Direction Inbound -LocalPort 8000,9443 -Protocol TCP -Action Allow
    ```
4. Доступ к Portainer:
   Откройте браузер и перейдите по адресу:
   
   `https://<IP-адрес_вашего_Windows-хоста>:9443`

   При первом запуске вам будет предложено создать учетную запись администратора.   

   
