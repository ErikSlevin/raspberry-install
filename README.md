# Raspberry Installation

| Datum | Beschreibung |
|:----------:|--------------|
| 13.01.2023 | Anleitung erstellt |
| 09.09.2023 | Komplette Überarbeitung der Anleitung |

## Vorbereitungen
1. Raspberry Pi Imager runterladen & installieren
   - Download: https://www.raspberrypi.com/software/

2. Windows Terminal herrunterladen
   - Download: [https://apps.microsoft.com/store/detail/windows-terminal/](https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701?hl=de-de&gl=de)

3. Raspberry Pi OS auf Medium schreiben
   - Raspberry Pi OS (other)
   - Raspberry Pi OS Lite (64-bit) (with no desktop enviroment)
   - SD-Karte: Externes Medium auswählen
   - Einstellungen:
       - SSH aktivieren
       - Passwort und Benutzername setzen
       - Spracheinstellungen festlegen
   - schreiben

4. SSH Verbindung herstellen
    - Windows Terminal öffnen
    - `ssh username@[DYNAMISCHE IP vom Raspberry]`

## Grundkonfiguration
``` shell
# Paketquellen aktualisieren und updaten
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y

# Raspberry Hardwarekonfiguration ändern
# Hier wird u.A. WLAN, BT, Audio sowie die HDMI Schnittstelle deaktiviert
sudo nano /boot/config.txt

# Statische IP-Adresse konfigurieren
sudo nano /etc/dhcpcd.conf

# IPv6 deaktivieren
sudo nano /etc/sysctl.conf

# SysCtl Konfig übernehmen
sudo sysctl -p

# DCHP Dienst neustarten und Status überprüfen
sudo systemctl restart dhcpcd.service
sudo service dhcpcd status

# Hostname ändern
sudo nano /etc/hostname

# Hosts ändern
sudo nano /etc/hosts

# Locale einstellen
sudo raspi-config nonint do_change_locale de_DE.UTF-8 UTF-8
sudo raspi-config nonint do_change_locale de_DE.UTF-8

# Timezone einstellen
sudo raspi-config nonint do_change_timezone Europe/Berlin
```
> [`config.txt`](files/Grundkonfiguration/config.txt)
> [`dhcpcd.conf`](files/Grundkonfiguration/dhcpcd.conf)
> [`sysctl.conf`](files/Grundkonfiguration/sysctl.conf)
> [`hostname`](files/Grundkonfiguration/hostname)
> [`hosts`](files/Grundkonfiguration/hosts)

## Automatische Updates einrichten
``` shell
# unattended-upgrades installieren und konfigurieren
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure --priority=low unattended-upgrades

# Konfigurationsdateien anpassen inkl. Push-Notification via Gotify
# Der Notify-Container Gotify wird später noch eingerichtet
sudo nano /etc/apt/apt.conf.d/20auto-upgrades
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades

# Push-Benachrichtigung, wenn automatische Updates installiert wurden
sudo mkdir ~/skripte -v
sudo nano /home/erik/skripte/unattended-upgrades-notify.sh
sudo chmod +x /home/erik/skripte/unattended-upgrades-notify.sh

# Neustart (zwingend erforderlich wegen SSH Konfiguration)
sudo reboot
```
> [`20auto-upgrades`](files/unattended-upgrades/20auto-upgrades)
> [`50unattended-upgrades`](files/unattended-upgrades/50unattended-upgrades)
> [`unattended-upgrades-notify.sh`](files/unattended-upgrades/unattended-upgrades-notify.sh)

## SSH einrichten

``` shell
# SSH Backup erstellen 
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak -v

# zum root-User wechseln
sudo su

# SSH Schlüssel löschen und neu generieren
rm /etc/ssh/ssh_host_*
ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ""
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""

# entfernt kleine Diffie-Hellman-Module
awk '$5 >= 3071' /etc/ssh/moduli > /etc/ssh/moduli.safe
mv /etc/ssh/moduli.safe /etc/ssh/moduli

# Beschränkt den Schlüsselaustausch auf (key exchange), Chiffrier- (cipher) und MAC-Algorithmen.
nano /etc/ssh/sshd_config.d/ssh-audit_hardening.conf

# wechselt zum normalen Benutzer zurück.
exit

# Generiert einen sicheren SSH-Key (ed25519) - mit y Bestätigen.
sudo ssh-keygen -o -a 100 -t ed25519 -N "" -f /etc/ssh/ssh_host_ed25519_key -C "$(date '+%Y%m%d')-$(hostname -s)-ed25519_key"

# .ssh Ordner und authorized_keys erstellen
mkdir ~/.ssh
touch ~/.ssh/authorized_keys

# Verschiebt den ssh_host_ed25519_key.pub nach authorized_keys.
sudo cat /etc/ssh/ssh_host_ed25519_key.pub >> ~/.ssh/authorized_keys

# Das .ssh-Verzeichnis für andere Benutzer und Gruppen das leserecht entziehen.
chmod 700 ~/.ssh

# Legt fest, dass die SSH-Schlüsselpaare nur gelesen werden können.
sudo chmod 400 /etc/ssh/ssh_host_ed25519_key*

# Setzt den lokalen Benutzer als Besitzer des Public-Keys.
chown $USER:$USER ~/.ssh/authorized_keys

# zeigt den ssh_host_ed25519_key an.
sudo cat /etc/ssh/ssh_host_ed25519_key >> $(date '+%Y%m%d')-$(hostname -s)-ed25519_key
   # --> Windows -> in Datei speichern ODER scp pi-docker-1:~/*key C:\Users\erikw\.ssh\
   # --> !! ACHTUNG ZEILENENDESEQUENZ LF, NICHT CRLF !!!
   # --> Am besten in VSC öffnen und speichern 
   # --> Dateiname: echo $(hostname)-$(date -I)

# startet den SSH-Dienst neu
service ssh restart

# sshd_conf übernehmen 
sudo nano /etc/ssh/sshd_config

# issue.net anpassen
sudo nano /etc/issue.net

# MOTD löschen
sudo rm /etc/motd
sudo rm /etc/update-motd.d/10-uname

# Gotify Benachrichtigung via SSH 
sudo nano /opt/shell-login.sh
sudo chmod 755 /opt/shell-login.sh
echo "/opt/shell-login.sh > /dev/null 2>&1" | sudo tee -a /etc/profile

```
> [`ssh-audit_hardening.conf`](files/ssh/ssh-audit_hardening.conf)
> [`sshd_config`](files/ssh/sshd_config)
> [`issue.net`](files/ssh/issue.net)
> [`motd`](files/ssh/motd)
> [`shell-login.sh`](files/ssh/shell-login.sh)

## Firewall unf Fail2Bann einrichten
``` shell
# UFW installieren
sudo apt install ufw -y && sudo apt autoclean -y && sudo apt autoremove -y

# eingehende Verbindungen werden abgelehnt und ausgehende Verbindungen zugelassen.
sudo ufw default deny incoming
sudo ufw default allow outgoing

# SSH Verbindungen zulassen
# ACHTUNG: bitte SSH-Port-Nummer anpassen
sudo ufw allow 62253

# UFW aktivieren - mit y bestätigen
sudo ufw enable

# installiert die neueste Fail2ban Version
sudo apt install fail2ban -y -y && sudo apt autoclean -y && sudo apt autoremove -y

# erstellt eine Kopie der Konfigurationsdatei.
sudo cp /etc/fail2ban/jail.{conf,local} -v

# [sshd] Jail konfigurieren
# Zeilennummer vom sshd-Jail in Variable speichern
i=$(grep -n '\[sshd\]' /etc/fail2ban/jail.local | awk 'NR==2 {print}' | cut -d ':' -f 1 | awk '{print $1 + 1}')

# Grundeinstellungen vom Jail entfernen
sed -i "${i},$((i+7))d" /etc/fail2ban/jail.local

# Neue Einstellungen für den Jail hinzufügen
# Folgende Einstellungen werden mit dem echo-Befehl hinzugefügt:
# Wenn Änderungen gewünscht (z.B. SSH-Port) dann bitte den echo befehl anpassen,
# nicht die untenstehenden Kommentarzeilen!
# enabled = true		port = 62253	logpath = %(sshd_log)s	bantime = 2h	
# backend = %(sshd_backend)s	maxretry = 3	ignoreip = 127.0.0.1/8	findtime = 1d
echo -e "enabled = true\nport = 62253\nlogpath = %(sshd_log)s\nbackend = %(sshd_backend)s" \
	"\nmaxretry = 3\nfindtime = 1d\nbantime = 2h\nignoreip = 127.0.0.1/8" | \
	 sed -i "${i}r /dev/stdin" /etc/fail2ban/jail.local

# Fail2ban neu starten.
sudo service fail2ban restart

# Fail2ban nach Reboot automatisch starten
sudo systemctl enable fail2ban
```
> [`20auto-upgrades`](files/unattended-upgrades/20auto-upgrades)
> [`50unattended-upgrades`](files/unattended-upgrades/50unattended-upgrades)
> [`unattended-upgrades-notify.sh`](files/unattended-upgrades/unattended-upgrades-notify.sh)

## Docker und Portainer
``` shell
# Docker installieren
sudo mkdir ~/docker_files -v
sudo curl -fsSL https://get.docker.com -o get-docker.sh &&  sudo sh get-docker.sh 
sudo rm get-docker.sh
sudo groupadd docker
sudo usermod -aG docker $USER

# Neustart zwingend durch führen!
sudo reboot

# Docker Netzwerke erstellen
docker network create --subnet=10.0.10.0/24 --gateway=10.0.10.1 intern
docker network create --subnet=10.0.20.0/24 --gateway=10.0.20.1 extern

# Portainer deployen
docker run -d -p 9000:9443 --name portainer \
	--restart=always \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v portainer:/data \
	--label "com.centurylinklabs.watchtower.enable=true" \
	--network intern \
	portainer/portainer-ce:latest
```

## Quellen
- [*How to Configure Static IP Address on Raspberry Pi*](https://sleeplessbeastie.eu/2022/05/23/how-to-configure-static-ip-address-on-raspberry-pi/)
- [*Raspberry Pi: Internes WLAN und Bluetooth deaktivieren*](https://www.xgadget.de/anleitung/raspberry-pi-internes-wlan-und-bluetooth-deaktivieren/)
- [*YouTube: How to protect Linux from Hackers // My server security strategy!*](https://www.youtube.com/watch?v=Bx_HkLVBz9M&t=393s)
- [*How To Harden OpenSSH on Ubuntu 18.04*](https://www.digitalocean.com/community/tutorials/how-to-harden-openssh-on-ubuntu-18-04-de)
- [*OpenSSH Server härten und absichern unter Linux*](https://sakis.tech/openssh-server-abhaerten-und-absichern-unter-linux/)
- [*SSH Audit Hardening Guides*](https://www.sshaudit.com/hardening_guides.html)
- [*Absicherung eines Debian Servers*](https://www.thomas-krenn.com/de/wiki/Absicherung_eines_Debian_Servers)

