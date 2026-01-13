#!/bin/sh
set -e

# ClawdBot Docker Entrypoint Script
# Handles first-run initialization, permissions, and container startup

echo "==================================="
echo "ClawdBot for Unraid"
echo "==================================="

# Configuration
CONFIG_DIR="${CLAWDBOT_CONFIG_DIR:-/config}"
MARKER_FILE="$CONFIG_DIR/.initialized"
PUID="${PUID:-1000}"
PGID="${PGID:-1000}"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"
mkdir -p /workspace

# Display configuration
echo "Configuration:"
echo "  Config Directory: $CONFIG_DIR"
echo "  Workspace Directory: /workspace"
echo "  Gateway Port: ${CLAWDBOT_GATEWAY_PORT:-18789}"
echo "  Bridge Port: ${CLAWDBOT_BRIDGE_PORT:-18790}"
echo "  PUID: $PUID"
echo "  PGID: $PGID"
echo "  Log Level: ${LOG_LEVEL:-info}"

# Check for ANTHROPIC_API_KEY
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo ""
    echo "ERROR: ANTHROPIC_API_KEY environment variable is required!"
    echo ""
    echo "To get your API key:"
    echo "  1. Visit https://console.anthropic.com/"
    echo "  2. Navigate to 'Settings' → 'API Keys'"
    echo "  3. Create a new API key"
    echo "  4. Add it to your Unraid Docker container settings"
    echo ""
    exit 1
fi

# Mask API key in logs (show first 10 and last 4 characters)
API_KEY_MASKED="${ANTHROPIC_API_KEY:0:10}...${ANTHROPIC_API_KEY: -4}"
echo "  API Key: $API_KEY_MASKED"

# Handle PUID/PGID permissions
if [ "$PUID" != "1000" ] || [ "$PGID" != "1000" ]; then
    echo ""
    echo "Adjusting user and group IDs to PUID=$PUID, PGID=$PGID..."

    # Modify existing clawdbot user/group
    groupmod -o -g "$PGID" clawdbot 2>/dev/null || true
    usermod -o -u "$PUID" clawdbot 2>/dev/null || true

    # Update ownership of directories
    chown -R "$PUID:$PGID" /config 2>/dev/null || true
    chown -R "$PUID:$PGID" /workspace 2>/dev/null || true
    chown -R "$PUID:$PGID" /home/clawdbot 2>/dev/null || true
fi

# Ensure config directory exists
mkdir -p "$CONFIG_DIR/.clawdbot/agents/main"

# Always create/recreate config file to ensure correct structure
echo ""
echo "==================================="
echo "Configuring ClawdBot..."
echo "==================================="
cat > "$CONFIG_DIR/.clawdbot/clawdbot.json" <<EOF
{
  "gateway": {
    "mode": "local",
    "port": ${CLAWDBOT_GATEWAY_PORT:-18789},
    "bind": "0.0.0.0"
  },
  "workspace": "/workspace"
}
EOF

# Set ownership
chown -R "$PUID:$PGID" "$CONFIG_DIR/.clawdbot"

# Create marker file if it doesn't exist
if [ ! -f "$MARKER_FILE" ]; then
    touch "$MARKER_FILE"
    chown "$PUID:$PGID" "$MARKER_FILE"
    echo "First run - configuration created!"
else
    echo "Configuration updated!"
fi

echo "WebUI will be available at http://[YOUR-IP]:${CLAWDBOT_GATEWAY_PORT:-18789}"

# Display provider status
echo ""
echo "==================================="
echo "Provider Status"
echo "==================================="
echo "  WhatsApp: ${WHATSAPP_ENABLED:-false}"
echo "  Telegram: ${TELEGRAM_ENABLED:-false}"
echo "  Discord: ${DISCORD_ENABLED:-false}"
echo "  Signal: ${SIGNAL_ENABLED:-false}"
echo "  iMessage: ${IMESSAGE_ENABLED:-false}"
echo "  WebChat: ${WEBCHAT_ENABLED:-true}"
echo ""
echo "To configure providers, access the WebUI at:"
echo "  http://[YOUR-IP]:${CLAWDBOT_GATEWAY_PORT:-18789}"
echo ""

echo "==================================="
echo "Starting ClawdBot Gateway..."
echo "==================================="
echo ""
echo "Command: $@"
echo "Config: $CONFIG_DIR/.clawdbot/clawdbot.json"
echo ""

# Export environment variables for clawdbot to use
export ANTHROPIC_API_KEY
export CLAWDBOT_CONFIG_PATH="$CONFIG_DIR/.clawdbot/clawdbot.json"
export CLAWDBOT_STATE_DIR="$CONFIG_DIR/.clawdbot"

# Execute main command as clawdbot user
exec su-exec clawdbot:clawdbot "$@"
