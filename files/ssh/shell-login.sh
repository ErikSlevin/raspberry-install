# -----------------------------------------------------------
# Benachrichtigung wenn SSH-Login
# /opt/shell-login.sh
# -----------------------------------------------------------

#!/bin/bash

# Gotify Server URL und API-Token
GOTIFY_URL="https://gotify.yourdomain.de"
API_TOKEN="your-api-token"

# Hostname speichern
HOSTNAME=$(hostname)

TITLE="SSH-Login $USER"
MESSAGE="Login auf $(hostname) am $(date +%Y-%m-%d) um $(date +%H:%M)"
PRIORITY=5

# Nachricht an Gotify senden
curl -X POST "$GOTIFY_URL/message?token=$API_TOKEN" \
  -F "title=$TITLE" \
  -F "message=$MESSAGE" \
  -F "priority=10"