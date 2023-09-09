# -----------------------------------------------------------
# Benachrichtung bei der Installation von automatischen Updates
# /home/erik/skripte/unattended-upgrades-notify.sh
# -----------------------------------------------------------

#!/bin/bash

# Gotify Server URL und API-Token
GOTIFY_URL="https://gotify.erikslevin.de"
API_TOKEN="your-api-token"

# Hostname speichern
HOSTNAME=$(hostname)

# Nachricht an Gotify senden
curl -X POST "$GOTIFY_URL/message" \
  -F "token=$API_TOKEN" \
  -F "title=Update auf $HOSTNAME durchgeführt" \
  -F "message=Unattended-Upgrades hat ein Update installiert."