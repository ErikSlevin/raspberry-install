# raspberry-config
 This is my Raspyberry installation and configuration with raspbian and docker

## Vorbereitungen
1. Raspberry Pi Imager runterladen & installieren
   - Download: https://www.raspberrypi.com/software/

2. Windows Terminal herrunterladen
   - Download: [https://apps.microsoft.com/store/detail/windows-terminal/](https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701?hl=de-de&gl=de)

3. Raspberry Pi OS auf Medium schreiben
   - Raspberry Pi OS (other)
   - Raspberry Pi OS Lite (32-bit)
   - SD-Karte: Externes Medium auswählen
   - schreiben

4. SSH Dienst aktivieren
   - Medium trennen und neu verbinden
   - Explorer öffnen
   - neue (leere) Textdatei erstellen
   - Dateiname: ssh (ohne .txt Endung)

5. SSH Verbindung herstellen
    - Windows Terminal öffnen
    - `ssh pi@[DYNAMISCHE IP vom Raspberry]`
    - Passwort: `raspberry`

## Grundkonfiguration

### System aktualisieren
```console
# Paketlisten aktualisieren
sudo apt update -y
 
# Pakete aktualisieren
sudo apt upgrade -y
```

### User
```console
# Neuen Benutzer anlegen
sudo useradd -m erik -G sudo

# Passwort vergeben
sudo passwd erik

# Standardbenutzer alle Rechte
sudo usermod --lock --expiredate 1 pi

# Benutzerwechsel
su erik

# Root Passwort festlegen
sudo passwd root

# SSH Verzeichnis erstellen
mkdir ~/.ssh -v && touch ~/.ssh/authorized_keys

# Neustarten
sudo reboot

# Neuverbinden
ssh erik@[DYNAMISCHE IP vom Raspberry]
```

### Netzwerk
* Konfigurationsdateien:
  * [NetworkManager.conf](files/NetworkManager.conf)
  * [interfaces](files/interfaces)
  * [sysctl.conf](files/sysctl.conf
  )

```console
# Network-Manager installieren
sudo apt install network-manager -y

# dhcpcd stoppen
sudo systemctl stop dhcpcd.service

# dhcpcd deaktivieren
sudo systemctl disable dhcpcd.service

# Network-Manager konfigurieren
sudo nano /etc/NetworkManager/NetworkManager.conf

# Statische IP vergeben
sudo nano /etc/network/interfaces

# IPv6 deaktivieren
sudo nano /etc/sysctl.conf

# SysCtl Konfig übernehmen
sudo sysctl -p

# Network-Manager neustarten
sudo service NetworkManager restart

# Neustarten
sudo reboot

# Neuverbinden
ssh erik@[STATISCHE IP vom Raspberry]
```

### Automatische Updates
* Konfigurationsdateien:
  * [50unattended-upgrades](files/50unattended-upgrades)
  * [10periodic](files/10periodic)

```console
# Automatische Updates aktivieren
sudo apt install unattended-upgrades apt-config-auto-update -y
sudo dpkg-reconfigure -plow unattended-upgrades

# Automatische Updates Konfig Backup
sudo mv /etc/apt/apt.conf.d/{50unattended-upgrades,50unattended-upgrades.orig} -v
sudo mv /etc/apt/apt.conf.d/{10periodic,10periodic.orig} -v

# Grundkonfiguration von unattend-upgrade
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades

# Automatische Updates Wöchentlich
sudo nano /etc/apt/apt.conf.d/10periodic
```

### Raspi-Config
```console
# Raspi-Konfig aufrufen und Änderungen vornehmen
# System Options -> S4 Hostname -> [Neuer Host Name}
# Localisation Options -> Locale -> de_DE.UTF-8 UTF-8 ->  de_DE.UTF-8
# Localisation Options -> Timezone -> Europe -> Berlin
# Advanced Options -> Expand Filesystem 
sudo raspi-config

# Neustarten
sudo reboot

# Neuverbinden
ssh erik@[STATISCHE IP vom Raspberry]
```

### Hardware-Config
* Konfigurationsdateien:
  * [config.txt](files/config.txt)

```console
# Boot Konfiguration sichern
sudo mv /boot/{config.txt,config.txt.orig} -v

# GPU Memory verringern,WLAN und Blutooth deaktivieren  
sudo nano /boot/config.txt

```

### SSH-Config

* Konfigurationsdateien:
  * [config](files/config)
  * [sshd_config](files/sshd_config)

```console
# SSH Schlüssel löschen
sudo rm /etc/ssh/ssh_host_*

# SSH Schlüssel neu generieren
sudo dpkg-reconfigure openssh-server

# Windows Terminal SSH Schlüssel erstellen und übertragen
ssh-keygen -t ed25519 -C pi-docker-1 -> C:\Users\erik\.ssh\docker-pi-1-id_ed25519
scp C:\Users\erik\.ssh\docker-pi-1-id_ed25519.pub erik@10.0.0.20:~/.ssh/authorized_keys

# Windows .ssh Konfigurationsdatei erstellen zum schnellen verbinden
# neue Datei erstellen: C:\Users\erik\.ssh\config

# SSH-Gruppe erstellen und Benutzer der SSH-Gruppe hinzufügen
sudo groupadd ssh-users && sudo usermod -a -G ssh-users erik

# SSH Konfig sichern
sudo mv /etc/ssh/{sshd_config,sshd_config.orig} -v

# SSH Konfig anpassen 
sudo nano /etc/ssh/sshd_config

# SSH neustarten
sudo systemctl restart ssh
```
### 2-Faktor Authentifizierung einrichten

* Konfigurationsdateien:
  * [config](files/config)
  * [sshd_config](files/sshd_config)

```console
# Zwei-Faktor Authentifizierung installieren
sudo apt install libpam-google-authenticator -y

# Zwei-Faktor konfigurieren
# 1. Frage: Yes (Secret Key EPCJ3HSQXXXXXXXXXXT472MNTE)
# 2. Frage: Yes
# 3. Frage: Yes
# 4. Frage: No
# 5. Frage: Yes
google-authenticator
		
# PAM sichern
sudo mv /etc/pam.d/{sshd,sshd.orig} -v

# PAM Konfig anpassen
sudo nano /etc/pam.d/sshd
```

### MOTD einrichten

* Konfigurationsdateien:
  * [issue.net](files/issue.net)
  * [motd.sh](files/motd.sh)

```console
# Banner vor SSH Login anpassen
sudo nano /etc/issue.net

# MOTD entfernen
sudo rm /etc/motd  -v

# MOTD erstellen
sudo nano /etc/profile.d/motd.sh

# Berechtigung und Besitzer ändern
sudo chown root:root /etc/profile.d/motd.sh -v && sudo chmod +x /etc/profile.d/motd.sh -v

# SSH neustarten
sudo systemctl restart ssh

# Windows Terminal NEUER Tab - neue SSH Verbindung testen - je nach dem was in der config eingestellt wurde
Bsp.: ssh pi-docker-1
ssh pi-docker-1
```

### Firewall einrichten

* Konfigurationsdateien:
  * [issue.net](files/jail.local)

```console
# Firewall installieren
sudo apt update -y && sudo apt install fail2ban -y

# Firewall Konfig erstellen
sudo nano /etc/fail2ban/jail.local

# Firewall neustarten
sudo service fail2ban restart
```

### Docker Installation
```console
# Docker herrunterladen
curl -fsSL https://get.docker.com -o ~/get-docker.sh

# Docker installieren
sudo sh ~/get-docker.sh

# Docker in Benutzergruppe aufnehmen
sudo usermod -aG docker erik

# Docker beim Systemstart ausführen
sudo systemctl enable docker.service && sudo systemctl enable containerd.service
```

### Docker-Compose Installation
```console
# Docker-Compose Abhängigkeiten Installieren
sudo apt install libffi-dev libssl-dev python3-dev python3 python3-pip -y

# Docker-Compose installieren
sudo pip3 install docker-compose
```

### Portainer Container bereitstellen
```console
# Portainer als Container bereitstellen (GUI für Docker)
sudo docker run -d -p 8000:8000 -p 9000:9443 --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    cr.portainer.io/portainer/portainer-ce:latest

# Portainer Oberfläche
# https:// [STATISCHE IP vom Raspberry]:9000
```

