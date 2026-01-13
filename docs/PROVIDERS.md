# Provider Setup Guide

Complete guide to setting up messaging providers with ClawdBot.

## Table of Contents

- [Provider Overview](#provider-overview)
- [WebChat (Built-in)](#webchat-built-in)
- [Telegram](#telegram)
- [Discord](#discord)
- [WhatsApp](#whatsapp)
- [Signal](#signal)
- [iMessage](#imessage)
- [Provider Security](#provider-security)

## Provider Overview

ClawdBot supports multiple messaging platforms, each with different setup complexity:

| Provider | Difficulty | Requirements | Best For |
|----------|-----------|--------------|----------|
| **WebChat** | ⭐ Easy | None | Testing, direct access |
| **Telegram** | ⭐ Easy | Bot token | Personal, groups |
| **Discord** | ⭐⭐ Medium | Bot token | Communities, servers |
| **WhatsApp** | ⭐⭐⭐ Hard | Business API | Business, customers |
| **Signal** | ⭐⭐⭐ Hard | signal-cli | Privacy-focused |
| **iMessage** | ⭐⭐⭐ Hard | macOS, imsg | Apple ecosystem |

**Recommendation**: Start with WebChat and Telegram.

## WebChat (Built-in)

The easiest way to use ClawdBot - no external setup needed!

### Setup

1. **Enable** (enabled by default):
   - In Unraid Docker settings: `WEBCHAT_ENABLED=true`

2. **Access**:
   - Open browser
   - Navigate to: `http://[UNRAID-IP]:18789`
   - Start chatting immediately!

### Features

- ✅ No external accounts needed
- ✅ Works immediately after installation
- ✅ Full Claude capabilities
- ✅ File upload support
- ✅ Conversation history
- ✅ Multiple simultaneous chats

### Use Cases

- Testing ClawdBot
- Direct Claude access
- Admin/management tasks
- When other providers are unavailable

**No additional configuration required!**

## Telegram

Easy to set up, great for personal use and groups.

### Prerequisites

- Telegram account
- Access to @BotFather

### Step 1: Create Bot

1. Open Telegram
2. Search for [@BotFather](https://t.me/botfather)
3. Start a chat
4. Send command: `/newbot`
5. Follow prompts:
   - Choose a name (display name)
   - Choose a username (must end in `bot`)
   - Example: `MyClawd Bot` / `myclawd_bot`

6. **Copy the token** (format: `123456:ABC-DEF...`)

### Step 2: Enable in Unraid

1. Edit ClawdBot container settings
2. Find: `Enable Telegram`
3. Set to: `true`
4. Apply changes

### Step 3: Configure in WebUI

1. Access ClawdBot WebUI: `http://[UNRAID-IP]:18789`
2. Navigate to: **Providers** → **Telegram**
3. Paste your bot token
4. Save

### Step 4: Test

1. In Telegram, search for your bot username
2. Start a chat
3. Send: `/start`
4. Send a message: "Hello!"
5. Claude should respond

### Group Setup

To use in Telegram groups:

1. **Add bot to group**:
   - Open group
   - Add members → Search for your bot
   - Add bot

2. **Configure privacy**:
   - Talk to @BotFather
   - Send: `/mybots`
   - Select your bot
   - Bot Settings → Group Privacy
   - **Disable** (allows bot to see all messages)

3. **Configure permissions** (in WebUI):
   - Set `mentionGating: true` (requires @mentions)
   - Configure `groupAllowFrom` (allowlist)

### Advanced Configuration

In WebUI → Providers → Telegram:

```yaml
telegram:
  enabled: true
  botToken: "your-token"
  groups:
    mentionGating: true        # Require @bot mention
    groupPolicy: "allowlist"   # or "denylist"
    groupAllowFrom:
      - "@groupusername"
      - "-1001234567890"       # Group chat ID
```

**Finding group ID**:
1. Add bot to group
2. Check ClawdBot logs
3. Look for group ID in connection messages

### Troubleshooting

**Bot not responding**:
- Check token in WebUI
- Verify bot is enabled
- Check group privacy settings
- Review ClawdBot logs

**"Bot is not a member" error**:
- Re-add bot to group
- Check bot wasn't removed
- Verify permissions

## Discord

Great for communities and gaming servers.

### Prerequisites

- Discord account
- Server admin access (to add bot)

### Step 1: Create Application

1. Visit [Discord Developer Portal](https://discord.com/developers/applications)
2. Click **New Application**
3. Name your application (e.g., "ClawdBot")
4. Click **Create**

### Step 2: Create Bot

1. In your application, go to **Bot** tab
2. Click **Add Bot** → **Yes, do it!**
3. Under **Token**, click **Reset Token**
4. **Copy the token** (format: `MTk4NjIy...`)
5. **Important**: Save this token securely

### Step 3: Configure Bot

Still in Bot settings:

1. **Privileged Gateway Intents**:
   - Enable: **SERVER MEMBERS INTENT**
   - Enable: **MESSAGE CONTENT INTENT**

2. **Bot Permissions** (for URL generation):
   - Text Permissions:
     - Send Messages
     - Send Messages in Threads
     - Read Message History
     - Add Reactions
   - Note the permissions integer

### Step 4: Invite Bot to Server

1. Go to **OAuth2** → **URL Generator**
2. Select scopes:
   - ✅ `bot`
   - ✅ `applications.commands`
3. Select permissions (from Step 3)
4. Copy generated URL
5. Open URL in browser
6. Select server
7. Authorize

### Step 5: Enable in Unraid

1. Edit ClawdBot container settings
2. Find: `Enable Discord`
3. Set to: `true`
4. Apply changes

### Step 6: Configure in WebUI

1. Access ClawdBot WebUI
2. Navigate to: **Providers** → **Discord**
3. Paste bot token
4. Save

### Step 7: Test

1. In Discord server, find a channel
2. Mention your bot: `@ClawdBot hello!`
3. Bot should respond

### Guild (Server) Configuration

Configure which servers bot can respond in:

```yaml
discord:
  enabled: true
  accounts:
    - botToken: "your-token"
      guilds:
        mentionGating: true      # Require @mention
        guildPolicy: "allowlist" # Whitelist servers
        guildAllowFrom:
          - "guild-id-1"
          - "guild-id-2"
```

**Finding guild ID**:
1. Enable Developer Mode: Settings → Advanced → Developer Mode
2. Right-click server icon → Copy ID

### Advanced Features

**Thread Support**:
- Bot can respond in threads
- Automatically joins threads when mentioned

**Role-based Permissions**:
- Configure in WebUI
- Restrict bot usage by role

### Troubleshooting

**Bot offline**:
- Check token in WebUI
- Verify bot is enabled in container
- Check Discord Developer Portal for API issues

**Bot not responding to mentions**:
- Verify MESSAGE CONTENT INTENT enabled
- Check bot has permissions in channel
- Review ClawdBot logs

**"Missing Permissions" error**:
- Re-invite bot with correct permissions
- Check channel-specific permission overrides

## WhatsApp

Advanced setup, requires Business API access.

### Prerequisites

- WhatsApp Business API account
- Phone number for verification
- Or: Use compatible WhatsApp Web solution

### Official Business API Method

1. **Get Business API Access**:
   - Apply at [business.whatsapp.com](https://business.whatsapp.com)
   - Requires business verification
   - May incur costs

2. **Configure**:
   - Obtain API credentials
   - Enable in ClawdBot container
   - Configure in WebUI with credentials

### Alternative: WhatsApp Web (Advanced)

Uses unofficial WhatsApp Web protocol:

**Warning**: Against WhatsApp ToS, use at own risk.

1. Enable in container: `WHATSAPP_ENABLED=true`
2. In WebUI → Providers → WhatsApp
3. Select mode: "web"
4. Scan QR code with WhatsApp mobile app
5. Connection established

**Limitations**:
- Requires keeping connection alive
- Phone must stay connected to internet
- Less stable than Business API

### Configuration

```yaml
whatsapp:
  enabled: true
  mode: "business-api"  # or "web"
  credentials:
    apiToken: "your-token"
    phoneNumberId: "your-phone-number-id"
  groups:
    mentionGating: true
    groupPolicy: "allowlist"
```

**Note**: WhatsApp setup is complex. Refer to [ClawdBot WhatsApp docs](https://docs.clawd.bot/providers/whatsapp) for full details.

## Signal

Privacy-focused, requires signal-cli.

### Prerequisites

- Signal account
- signal-cli installed (on host or separate container)
- Phone number for Signal account

### Setup Overview

**Note**: Signal setup is advanced and requires technical knowledge.

1. **Install signal-cli**:
   - [signal-cli GitHub](https://github.com/AsamK/signal-cli)
   - Or use signal-cli Docker container

2. **Register/Link Account**:
   ```bash
   signal-cli -u +1234567890 register
   signal-cli -u +1234567890 verify CODE
   ```

3. **Run signal-cli daemon**:
   ```bash
   signal-cli -u +1234567890 daemon --json
   ```

4. **Configure ClawdBot**:
   - Enable: `SIGNAL_ENABLED=true`
   - In WebUI, configure socket path to signal-cli

### Configuration

```yaml
signal:
  enabled: true
  mode: "signal-cli-json-rpc"
  socketPath: "/config/signal-cli/socket"
  phoneNumber: "+1234567890"
```

**Recommendation**: See [ClawdBot Signal docs](https://docs.clawd.bot/providers/signal) for complete guide.

## iMessage

macOS only, requires imsg tool.

### Prerequisites

- **macOS host** (Unraid won't work directly)
- imsg tool installed
- Apple ID with iMessage enabled

### Setup Overview

**Note**: iMessage requires macOS. This is not compatible with Unraid Docker containers directly.

### Workaround Options

1. **Mac Mini/macOS VM**:
   - Run macOS in VM or dedicated Mac
   - Install imsg and ClawdBot
   - Connect to Unraid services

2. **Remote Bridge**:
   - Run imsg on Mac
   - Expose JSON-RPC socket
   - Mount socket into ClawdBot container (network mount)

### Configuration

```yaml
imessage:
  enabled: true
  mode: "imsg-json-rpc"
  socketPath: "/config/imsg/socket"
```

**Limitation**: This provider is effectively unusable in standard Unraid Docker deployments.

## Provider Security

### Best Practices

1. **Use Allowlists**:
   - Configure `groupAllowFrom` for Telegram
   - Configure `guildAllowFrom` for Discord
   - Prevents unauthorized access

2. **Enable Mention Gating**:
   - Requires @mention to trigger bot
   - Prevents spam and unintended responses
   - Recommended for all group/server usage

3. **Restrict Permissions**:
   - Give bots minimal required permissions
   - Review permission grants regularly
   - Remove bots from unused groups/servers

4. **Monitor Logs**:
   - Check ClawdBot logs regularly
   - Look for suspicious activity
   - Review API usage

5. **Rotate Tokens**:
   - Regenerate bot tokens periodically
   - Update in ClawdBot WebUI
   - Revoke compromised tokens immediately

### Example Secure Configuration

```yaml
telegram:
  enabled: true
  botToken: "masked-in-logs"
  groups:
    mentionGating: true           # Requires @mention
    groupPolicy: "allowlist"      # Whitelist only
    groupAllowFrom:
      - "@trustedgroup"
      - "-1001234567890"
    commands:
      allowFrom:
        - "@trustedadmin"         # Admin commands restricted
```

---

**Need Help?** See [Troubleshooting Guide](TROUBLESHOOTING.md) or [Configuration Guide](CONFIGURATION.md).
