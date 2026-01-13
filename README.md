# ClawdBot for Unraid

> Your personal AI assistant powered by Claude, packaged for Unraid Community Applications

[![Docker Image](https://img.shields.io/badge/docker-ghcr.io-blue)](https://github.com/eYdr1en/clawdbot-unraid/pkgs/container/clawdbot-unraid)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Unraid](https://img.shields.io/badge/platform-Unraid-orange)](https://unraid.net/)

## Overview

ClawdBot is an open-source personal AI assistant that brings Anthropic's Claude AI to your favorite messaging platforms. This Docker container makes it easy to run ClawdBot on your Unraid server with full support for WhatsApp, Telegram, Discord, Signal, iMessage, and a built-in WebChat interface.

## Features

- 🤖 **Powered by Claude AI** - Uses Anthropic's Claude models for intelligent conversations
- 💬 **Multi-Platform Support** - WhatsApp, Telegram, Discord, Signal, iMessage, WebChat
- 🌐 **Built-in WebUI** - Easy configuration and management interface
- 🔧 **Automated Setup** - Non-interactive onboarding on first run
- 🔒 **Secure** - Non-root execution, encrypted credentials, masked API keys
- 📦 **Multi-Architecture** - Supports both amd64 and arm64 platforms
- 🔄 **Always-On** - Run your personal AI assistant 24/7 on your Unraid server
- 🛠️ **Tool Execution** - Browser automation, canvas rendering, and plugin support

## Quick Start

### Prerequisites

- **Unraid 6.10 or later**
- **Anthropic API Key** - Get one at [console.anthropic.com](https://console.anthropic.com/)

### Installation via Community Applications

1. Open your Unraid WebUI
2. Navigate to the **Apps** tab
3. Search for **ClawdBot**
4. Click **Install**
5. Enter your **Anthropic API Key**
6. Adjust ports if needed (defaults: 18789, 18790)
7. Set AppData path (default: `/mnt/user/appdata/clawdbot`)
8. Click **Apply**

The container will automatically run onboarding on first start (takes about 30-60 seconds).

### Manual Installation

If you prefer to add the template manually:

1. In Unraid, go to **Docker** tab
2. Click **Add Container**
3. At the bottom, click **Template repositories**
4. Add this URL:
   ```
   https://github.com/eYdr1en/clawdbot-unraid
   ```
5. Or directly add the template URL:
   ```
   https://raw.githubusercontent.com/eYdr1en/clawdbot-unraid/main/templates/clawdbot.xml
   ```

## Configuration

### Required Settings

- **Anthropic API Key** - Your API key from [Anthropic Console](https://console.anthropic.com/)
  - Navigate to Settings → API Keys
  - Create a new API key
  - Copy and paste into the container settings

### Port Configuration

| Port | Purpose | Default |
|------|---------|---------|
| 18789 | Gateway WebUI/API | Required |
| 18790 | Bridge communication | Required |

### Volume Mounts

| Container Path | Host Path | Purpose |
|----------------|-----------|---------|
| `/config` | `/mnt/user/appdata/clawdbot` | Configuration, sessions, provider data |
| `/workspace` | `/mnt/user/appdata/clawdbot/workspace` | Claude Code workspace (optional) |

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ANTHROPIC_API_KEY` | - | **Required**: Your Anthropic API key |
| `PUID` | 99 | User ID for file permissions |
| `PGID` | 100 | Group ID for file permissions |
| `LOG_LEVEL` | info | Logging verbosity (debug, info, warn, error) |
| `TZ` | UTC | Timezone (e.g., America/New_York) |

#### Provider Toggles

| Variable | Default | Description |
|----------|---------|-------------|
| `WHATSAPP_ENABLED` | false | Enable WhatsApp provider |
| `TELEGRAM_ENABLED` | false | Enable Telegram provider |
| `DISCORD_ENABLED` | false | Enable Discord provider |
| `SIGNAL_ENABLED` | false | Enable Signal provider |
| `IMESSAGE_ENABLED` | false | Enable iMessage provider (macOS only) |
| `WEBCHAT_ENABLED` | true | Enable WebChat interface |

## Accessing the WebUI

After installation, access ClawdBot at:

```
http://[UNRAID-IP]:18789
```

For example: `http://192.168.1.100:18789`

The WebUI allows you to:
- Configure messaging providers
- View conversation history
- Manage settings
- Monitor ClawdBot status

## Provider Setup

ClawdBot supports multiple messaging platforms. Each requires specific setup:

### WebChat (Built-in) ✅

- **Difficulty**: Easy
- **Setup**: Enabled by default
- **Access**: http://[UNRAID-IP]:18789
- **No additional configuration required**

### Telegram ⚡

- **Difficulty**: Easy
- **Requirements**: Telegram bot token

**Setup Steps**:
1. Open Telegram and search for [@BotFather](https://t.me/botfather)
2. Send `/newbot` and follow the prompts
3. Copy the bot token
4. In Unraid container settings, set `TELEGRAM_ENABLED=true`
5. Access ClawdBot WebUI → Providers → Telegram
6. Paste your bot token
7. Configure group permissions if needed

### Discord 🎮

- **Difficulty**: Medium
- **Requirements**: Discord bot token

**Setup Steps**:
1. Visit [Discord Developer Portal](https://discord.com/developers/applications)
2. Create a new application
3. Go to "Bot" section and create a bot
4. Copy the bot token
5. In Unraid container settings, set `DISCORD_ENABLED=true`
6. Access ClawdBot WebUI → Providers → Discord
7. Paste your bot token
8. Invite the bot to your server with proper permissions

### WhatsApp / Signal / iMessage

These providers require more complex setup. See detailed guides:
- [Full Provider Setup Guide](docs/PROVIDERS.md)

## Documentation

Comprehensive documentation is available in the `docs/` directory:

- **[Installation Guide](docs/INSTALLATION.md)** - Detailed installation instructions
- **[Configuration Guide](docs/CONFIGURATION.md)** - In-depth configuration options
- **[Provider Setup](docs/PROVIDERS.md)** - Step-by-step provider configuration
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions

## Local Development

### Building the Image

```bash
cd clawdbot-unraid
docker build -t clawdbot-unraid:local .
```

### Testing with Docker Compose

1. Create a `.env` file:
   ```bash
   cp .env.example .env
   # Edit .env and add your ANTHROPIC_API_KEY
   ```

2. Start the container:
   ```bash
   docker compose up
   ```

3. Access WebUI at http://localhost:18789

4. View logs:
   ```bash
   docker compose logs -f
   ```

5. Stop the container:
   ```bash
   docker compose down
   ```

## Architecture

```
User → Unraid WebUI → Docker Engine → ClawdBot Container
                                           ↓
                                    Gateway (18789)
                                           ↓
                                    Provider Handlers
                                           ↓
                            [WhatsApp|Telegram|Discord|...]
                                           ↓
                                    Anthropic API
```

## Security

This container implements several security best practices:

- ✅ **Non-root execution** - Runs as user `clawdbot:1000`
- ✅ **Masked secrets** - API keys masked in logs and UI
- ✅ **Encrypted credentials** - Provider credentials encrypted at rest
- ✅ **Network isolation** - Bridge network, only necessary ports exposed
- ✅ **Minimal base image** - Alpine Linux for smaller attack surface

### Security Recommendations

1. **Keep your API key secure** - Never commit it to version control
2. **Use allowlists** - Configure group/guild allowlists for providers
3. **Regular updates** - Keep the container updated for security patches
4. **Backup your config** - Regular backups of `/mnt/user/appdata/clawdbot`
5. **Monitor access** - Review WebUI access logs periodically

## Backup and Restore

### Backing Up

Back up the entire AppData directory:

```bash
tar -czf clawdbot-backup-$(date +%Y%m%d).tar.gz /mnt/user/appdata/clawdbot/
```

**Important files**:
- `/mnt/user/appdata/clawdbot/config.yaml` - Main configuration
- `/mnt/user/appdata/clawdbot/sessions/` - Session data
- `/mnt/user/appdata/clawdbot/providers/` - Provider configurations
- `/mnt/user/appdata/clawdbot/credentials/` - Encrypted credentials

### Restoring

1. Stop the ClawdBot container
2. Extract backup to AppData location:
   ```bash
   tar -xzf clawdbot-backup-YYYYMMDD.tar.gz -C /
   ```
3. Start the container

## Troubleshooting

### Container won't start

**Check**:
- ANTHROPIC_API_KEY is set in container settings
- Ports 18789 and 18790 are not in use by other containers
- AppData path exists and is writable

**Solution**:
```bash
# Check container logs
docker logs clawdbot

# Verify API key is set
docker inspect clawdbot | grep ANTHROPIC_API_KEY
```

### WebUI not accessible

**Check**:
- Container is running: `docker ps | grep clawdbot`
- Port mapping is correct: `18789:18789`
- Firewall isn't blocking the port
- Using correct Unraid server IP

### Provider not responding

**Check**:
- Provider is enabled in container settings
- Provider token/credentials entered correctly in WebUI
- Bot invited to group/server (for group/guild usage)
- Proper permissions granted to bot

See [Troubleshooting Guide](docs/TROUBLESHOOTING.md) for more detailed solutions.

## Updating

### Automatic Updates (Recommended)

If using Community Applications with Auto-Update plugin:
1. Updates will be detected automatically
2. Container will be updated when new version is available
3. Your configuration is preserved (stored in AppData)

### Manual Update

1. Stop the container
2. Pull the latest image:
   ```bash
   docker pull ghcr.io/eydr1en/clawdbot-unraid:latest
   ```
3. Start the container

Your configuration in `/mnt/user/appdata/clawdbot` is preserved during updates.

## Performance

**Expected Resource Usage**:
- CPU: Low (< 5% idle, 10-20% during conversations)
- RAM: ~200-500 MB
- Disk: ~500 MB - 2 GB (depends on message history and logs)
- Network: Variable (depends on usage and providers)

**Recommended Hardware**:
- CPU: Any modern x86_64 or ARM64 processor
- RAM: Minimum 1 GB available
- Disk: Minimum 2 GB available for AppData

## Support

- **Issues**: [GitHub Issues](https://github.com/eYdr1en/clawdbot-unraid/issues)
- **Discussions**: [GitHub Discussions](https://github.com/eYdr1en/clawdbot-unraid/discussions)
- **Official ClawdBot**: [clawdbot/clawdbot](https://github.com/clawdbot/clawdbot)
- **ClawdBot Documentation**: [docs.clawd.bot](https://docs.clawd.bot)

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit your changes: `git commit -am 'Add feature'`
4. Push to the branch: `git push origin feature-name`
5. Create a Pull Request

## Changelog

### v1.0.0 (2026-01-13)
- Initial release for Unraid Community Applications
- Support for all messaging providers
- Automated onboarding with Anthropic API key
- WebUI for configuration and management
- Multi-architecture support (amd64, arm64)
- Comprehensive documentation

See [CHANGELOG.md](CHANGELOG.md) for full version history.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

This is an **unofficial community packaging** of ClawdBot for Unraid. For official ClawdBot support, please visit the [official ClawdBot repository](https://github.com/clawdbot/clawdbot).

**ClawdBot** itself is developed by the ClawdBot team and is subject to its own license terms.

## Acknowledgments

- **ClawdBot Team** - For creating the amazing ClawdBot project
- **Anthropic** - For providing the Claude AI API
- **Unraid Community** - For the fantastic NAS operating system
- **Contributors** - Everyone who has contributed to this project

## Related Projects

- [ClawdBot](https://github.com/clawdbot/clawdbot) - Official ClawdBot repository
- [Unraid](https://unraid.net/) - The Unraid operating system
- [Community Applications](https://forums.unraid.net/topic/38582-plug-in-community-applications/) - Unraid app store

---

Made with ❤️ for the Unraid community
