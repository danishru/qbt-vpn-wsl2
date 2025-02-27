# Запуск qBittorrent с VPN в Docker на Debian внутри WSL2
Этот проект документирует процесс запуска qBittorrent с интегрированным VPN в контейнере Docker, работающем на Debian внутри WSL2 на Windows. Данный подход позволяет обеспечить безопасное и анонимное использование BitTorrent-клиента с помощью VPN, при этом окружение Docker гарантирует повторяемость и изоляцию.

> [!CAUTION]
> **qBittorrent** — это программа для обмена файлами. При работе торрента его данные становятся доступны другим пользователям посредством раздачи. Вы несёте персональную ответственность за все данные, которыми делитесь.
>
> **VPN (Virtual Private Network)** — это технология, позволяющая создать зашифрованное соединение между вашим устройством и сервером VPN, что обеспечивает дополнительную защиту и приватность при передаче данных. Однако использование VPN не гарантирует абсолютной > анонимности и безопасности. Вы несёте персональную ответственность за все действия, проводимые через VPN, и обязаны соблюдать все применимые законы и нормативные акты.
> 
> **Отказ от ответственности:** Авторы проекта не несут ответственности за возможные юридические или иные последствия, возникающие при использовании проекта.
>
> **Юридическая консультация:** Данный проект не является юридической консультацией, и в случае сомнений рекомендуется обратиться к квалифицированному юристу.

> [!IMPORTANT]
> Этот проект создан с использованием редакции ChatGPT. Если вы придерживаетесь иной этической точки зрения, приношу извинения. Однако, я считаю, что данное применение является морально приемлемым, поскольку проект является некоммерческим, бесплатным и свободным, а его цель — способствовать открытости и взаимодействию.

## Описание

В современных условиях приватность и безопасность при использовании BitTorrent-клиентов становятся критически важными. Данный проект описывает, как:
- Установить и настроить WSL2 на Windows, используя Debian в качестве Linux-дистрибутива.
- Запустить Docker в WSL2, чтобы работать с контейнерами напрямую в Linux-среде.
- Развернуть готовый Docker-образ, включающий qBittorrent с поддержкой VPN (например, на базе образа [binhex/arch-qbittorrentvpn](https://hub.docker.com/r/binhex/arch-qbittorrentvpn)), который позволяет объединить работу BitTorrent-клиента с VPN для повышения конфиденциальности и обхода ограничений.
- Обеспечить доступ к веб-интерфейсу qBittorrent с хоста и других устройств в локальной сети.
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
- **Службы, запущенные в WSL2, не будут доступны через NAT (например, при подключении через публикацию портов на роутере или VPN).**
- **Диски, подключенные в хостовой системе как папки, будут недоступны внутри WSL2.**
- **USB-устройства, подключенные к хосту, недоступны из WSL.**

> [!NOTE]  
> Подробные и расширенные инструкции, а также обход ограничений и решение возможных проблем доступны на [Wiki проекта](https://github.com/danishru/qbt-vpn-wsl2/wiki).
# Быстрый старт

> [!IMPORTANT]
> Быстрый старт предназначен для уверенного пользователя, знакомого с WSL2, Debian и Docker.  
> Здесь приведены минимальные шаги для быстрого и базового развёртывания qBittorrent с VPN в Docker на Debian внутри WSL2.

---

### Шаг 1: Настройка WSL2 и Debian

1. **Обновите Windows**  
   Убедитесь, что у вас установлена Windows 11 версии **22H2** (минимум) и установлены все обновления через Центр обновления Windows.

2. **Обновите WSL до версии не ниже 2.4.10.0**  
   Откройте Windows Terminal или PowerShell от имени администратора и выполните:
   ```powershell
   wsl --version
   wsl --update
   ```
3. **Включение Mirrored Mode Networking**  
   Откройте PowerShell от имени администратора и выполните:
      ```powershell
      if (!(Test-Path $env:USERPROFILE\.wslconfig)) { New-Item -Path $env:USERPROFILE\.wslconfig -ItemType File -Force }; notepad $env:USERPROFILE\.wslconfig
      ```
   В открытом файле добавьте:
      ```ini
      [wsl2]
      networkingMode=mirrored
      [experimental]
      hostAddressLoopback=true
      ```
   Затем сохраните файл и закройте Notepad, после чего выполните:
      ```powershell
      wsl --shutdown
      ```

4. **Установите Debian**  
   Выполните команду:
   ```powershell
   wsl --install -d Debian
   ```  
   После установки запустите Debian для первоначальной настройки.

5. **Обновите систему в Debian**  
   В терминале Debian выполните:
   ```bash
   sudo apt update && sudo apt upgrade -y
   sudo apt full-upgrade -y
   ```
   
---

### Шаг 2: Установка Docker Engine

1. **Установите зависимости и добавьте репозиторий Docker:**
   ```bash
   sudo apt update
   sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release -y
   curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```

2. **Установите Docker Engine:**
   ```bash
   sudo apt update
   sudo apt install docker-ce docker-ce-cli containerd.io -y
   ```

3. **Проверьте установку:**
   ```bash
   sudo docker run hello-world
   ```

4. **Удалите тестовый контейнер и образ hello-world:**
   ```bash
   sudo docker rm $(sudo docker ps -a --filter "ancestor=hello-world" -q)
   sudo docker rmi hello-world
   ```
---

### Шаг 3: Развёртывание qBittorrentVPN с Docker Compose
1. **Создайте папку для тома конфигурации**
   
   Используем bind mount, чтобы данные тома находились внутри WSL, но были доступны напрямую из Windows.  
   Создайте папку, например, по пути:
   ```bash
   sudo mkdir -p /srv/docker/volumes/qbittorrentvpn_config/_data
   ```

3. **Создайте файл docker-compose.yml**
   
   Перейдите в нужный каталог и запустите nano для создания файла:
   ```bash
   sudo nano docker-compose.yml
   ```
   Вставьте в открывшийся редактор следующий контент:
   ```yaml
   services:
     qbittorrentvpn:
       image: binhex/arch-qbittorrentvpn:latest
       container_name: qbittorrentvpn
       cap_add:
         - NET_ADMIN
       healthcheck:
         test: ["CMD-SHELL", "curl -fsSL http://localhost:$${WEBUI_PORT}/api/v2/app/version"]
         interval: 30s
         timeout: 10s
         retries: 3
         start_period: 10s
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
         - PUID=1000
         - PGID=1000
         - TZ=Europe/Moscow
       ports:
         - "8080:8080"
       volumes:
         - config:/config
         - /etc/localtime:/etc/localtime:ro
       restart: always
   volumes:
     config:
       driver: local
       driver_opts:
         type: none
         o: bind
         device: /srv/docker/volumes/qbittorrentvpn_config/_data
   ```
   Сохраните изменения (CTRL+O, затем Enter) и выйдите из nano (CTRL+X).

4. **Запустите Docker Compose:**  
   В том же каталоге выполните:
   ```bash
   sudo docker compose -p qbittorrentvpn up -d
   ```
---

### Шаг 4: Создание правила Windows Firewall через PowerShell и доступ к qBittorrent с VPN

1. Чтобы обеспечить доступ к веб-интерфейсу qBittorrent (порт 8080) с других устройств, выполните в PowerShell (от имени администратора):
   ```powershell
   if (-not (Get-NetFirewallRule -DisplayName "Allow qBittorrent WebUI" -ErrorAction SilentlyContinue)) { New-NetFirewallRule -DisplayName "Allow qBittorrent WebUI" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow }
   ```
2. Если переменная `VPN_ENABLED=yes`, убедитесь, что файл с настройками OpenVPN (.ovpn) размещён в папке `/openvpn` внутри volume `config`.
3. Откройте браузер и перейдите по адресу:
   ```plaintext
   http://<IP-адрес_вашего_сервера>:${WEBUI_PORT}
   ```
4. Для входа в веб-интерфейс qBittorrent используйте учетные данные, указанные в файле `supervisord.log` внутри volume `config`.
>[!IMPORTANT]  
> По умолчанию qBittorrent настроен на скачивание файлов в директорию `/config/qBittorrent/downloads` внутри volume `config`.

---

Этот быстрый старт поможет вам развернуть qBittorrent с VPN в Docker на Debian внутри WSL2 минимальными усилиями. Более тонкая настройка и дополнительные функции описаны в [Wiki проекта](https://github.com/danishru/qbt-vpn-wsl2/wiki).

---
