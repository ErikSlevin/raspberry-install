# -----------------------------------------------------------
# Benachrichtung bei der Installation von automatischen Updates
# /home/erik/skripte/unattended-upgrades-notify.sh
# -----------------------------------------------------------

#!/bin/bash

# Gotify Server URL und API-Token
GOTIFY_URL="https://gotify.yourdomain.de"
API_TOKEN="yourtoken"

# Hostname speichern
HOSTNAME=$(hostname)

TITLE="Unattended-Upgrades"
MESSAGE="Automatische Aktualisierung durch Unattended-Upgrades auf $HOSTNAME"
PRIORITY=5

# Nachricht an Gotify senden
curl -X POST "$GOTIFY_URL/message?token=$API_TOKEN" \
  -F "title=$TITLE" \
  -F "message=$MESSAGE" \
  -F "priority=5"