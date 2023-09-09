# -----------------------------------------------------------
# Benachrichtigung wenn SSH-Login
# /opt/shell-login.sh
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
  -F "title=SSH-Login $USER" \
  -F "message=Login auf $(hostname) am $(date +%Y-%m-%d) um $(date +%H:%M)"
