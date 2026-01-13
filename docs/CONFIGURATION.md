# ClawdBot Configuration Guide

Complete guide to configuring ClawdBot on Unraid.

## Table of Contents

- [Configuration Overview](#configuration-overview)
- [Environment Variables](#environment-variables)
- [Port Configuration](#port-configuration)
- [Volume Mounts](#volume-mounts)
- [Provider Configuration](#provider-configuration)
- [Advanced Settings](#advanced-settings)
- [Configuration Files](#configuration-files)

## Configuration Overview

ClawdBot can be configured through three methods:

1. **Unraid Docker Settings** - Primary method for most settings
2. **WebUI** - For provider-specific settings and runtime configuration
3. **Config Files** - Advanced users, direct file editing

## Environment Variables

### Required

#### ANTHROPIC_API_KEY

- **Purpose**: Authentication with Anthropic Claude API
- **Format**: `sk-ant-api03-...`
- **Where to get**: [console.anthropic.com](https://console.anthropic.com/) → Settings → API Keys
- **Security**: Masked in logs and WebUI
- **Example**: `sk-ant-api03-1234567890abcdef...`

**Important**: Container will not start without a valid API key.

### Ports

#### CLAWDBOT_GATEWAY_PORT

- **Default**: `18789`
- **Purpose**: Gateway WebUI and API endpoint
- **Must match**: Port mapping in Docker settings
- **Access**: `http://[UNRAID-IP]:[PORT]`

#### CLAWDBOT_BRIDGE_PORT

- **Default**: `18790`
- **Purpose**: Bridge communication between services
- **Must match**: Port mapping in Docker settings
- **Usually**: No direct access needed

### Provider Toggles

Enable/disable messaging providers:

| Variable | Default | Description |
|----------|---------|-------------|
| `WHATSAPP_ENABLED` | false | Enable WhatsApp integration |
| `TELEGRAM_ENABLED` | false | Enable Telegram bot |
| `DISCORD_ENABLED` | false | Enable Discord bot |
| `SIGNAL_ENABLED` | false | Enable Signal integration (advanced) |
| `IMESSAGE_ENABLED` | false | Enable iMessage (macOS only) |
| `WEBCHAT_ENABLED` | true | Enable built-in WebChat |

**Note**: Enabling a provider only activates it. You still need to configure credentials in the WebUI.

### System Configuration

#### PUID and PGID

- **PUID** (Process User ID): Default `99`
- **PGID** (Process Group ID): Default `100`
- **Purpose**: File ownership for AppData directory
- **Unraid Defaults**: `99:100` (nobody:users)

**When to change**:
- Custom user needs access to files
- Sharing AppData with other containers
- Specific permission requirements

**Finding your user ID**:
```bash
id yourusername
```

#### LOG_LEVEL

- **Default**: `info`
- **Options**: `debug`, `info`, `warn`, `error`
- **Purpose**: Controls logging verbosity

**Use cases**:
- `debug`: Troubleshooting, detailed logs
- `info`: Normal operation (recommended)
- `warn`: Only warnings and errors
- `error`: Only errors

**Performance**: `debug` level can generate large logs and slow down the system.

#### TZ (Timezone)

- **Default**: `UTC`
- **Format**: `Region/City`
- **Examples**:
  - `America/New_York`
  - `Europe/London`
  - `Asia/Tokyo`
  - `Australia/Sydney`

**Purpose**: Correct timestamps in logs and WebUI.

**Finding your timezone**:
```bash
timedatectl list-timezones | grep -i your_city
```

## Port Configuration

### Gateway Port (18789)

**What it does**:
- Hosts the WebUI
- Provides REST API
- Handles provider webhooks
- WebChat interface

**Changing the port**:
1. Edit container settings
2. Change **both**:
   - Port Mapping: `[new-port]:18789`
   - Environment Variable: `CLAWDBOT_GATEWAY_PORT=[new-port]`
3. Apply changes
4. Access WebUI at `http://[UNRAID-IP]:[new-port]`

**Common reasons to change**:
- Port 18789 already in use
- Security through obscurity
- Reverse proxy configuration

### Bridge Port (18790)

**What it does**:
- Internal service communication
- Provider bridge connections
- Generally not accessed directly

**Changing the port**:
1. Edit container settings
2. Change **both**:
   - Port Mapping: `[new-port]:18790`
   - Environment Variable: `CLAWDBOT_BRIDGE_PORT=[new-port]`
3. Apply changes

**Note**: Usually no need to change unless there's a port conflict.

### Port Conflicts

**Check for conflicts**:
```bash
# From Unraid terminal
netstat -tulpn | grep 18789
netstat -tulpn | grep 18790
```

**Resolve conflicts**:
1. Identify conflicting service
2. Change ClawdBot ports, or
3. Change conflicting service's ports

## Volume Mounts

### Config Directory

**Container Path**: `/config`
**Default Host Path**: `/mnt/user/appdata/clawdbot`
**Mode**: `rw` (read-write)

**Contents**:
```
/mnt/user/appdata/clawdbot/
├── .initialized           # First-run marker
├── config.yaml            # Main configuration
├── sessions/              # Session data
├── providers/             # Provider configurations
│   ├── whatsapp.yaml
│   ├── telegram.yaml
│   └── discord.yaml
├── credentials/           # Encrypted credentials
│   └── anthropic.key
└── logs/                  # Application logs
    ├── gateway.log
    └── providers.log
```

**Important**:
- Contains all persistent data
- **Must be backed up regularly**
- Survives container updates
- Permissions: `99:100` (PUID:PGID)

### Workspace Directory

**Container Path**: `/workspace`
**Default Host Path**: `/mnt/user/appdata/clawdbot/workspace`
**Mode**: `rw` (read-write)
**Optional**: Yes

**Purpose**:
- Claude Code execution environment
- File operations and tool usage
- Temporary file storage

**Contents**:
```
/mnt/user/appdata/clawdbot/workspace/
├── projects/              # User projects
├── temp/                  # Temporary files
└── outputs/               # Execution outputs
```

### Changing Volume Paths

**Why change**:
- Custom AppData location
- Different disk/share preference
- Organizational needs

**How to change**:
1. Stop container
2. Edit container settings
3. Change host path for `/config` or `/workspace`
4. Apply changes
5. **Important**: Move existing data:
   ```bash
   mv /mnt/user/appdata/clawdbot /your/new/path/
   ```
6. Start container

## Provider Configuration

### Configuration Workflow

1. **Enable in Docker Settings**:
   - Set `[PROVIDER]_ENABLED=true`
   - Apply and restart container

2. **Configure in WebUI**:
   - Access WebUI: `http://[UNRAID-IP]:18789`
   - Navigate to **Providers** section
   - Select provider
   - Enter credentials/tokens
   - Configure permissions

3. **Test**:
   - Send test message from provider
   - Verify Claude responds

### Provider-Specific Settings

See [Provider Setup Guide](PROVIDERS.md) for detailed configuration of each provider.

## Advanced Settings

### NODE_ENV

- **Default**: `production`
- **Options**: `production`, `development`
- **Purpose**: Node.js environment mode

**When to change**:
- Development/debugging: Use `development`
- Production use: Keep as `production`

**Impact**:
- `development`: Verbose logs, source maps, hot reload
- `production`: Optimized, minimal logs

### Custom Configuration Files

Advanced users can directly edit configuration files in:
```
/mnt/user/appdata/clawdbot/config.yaml
```

**Structure**:
```yaml
gateway:
  port: 18789
  bind: loopback
  auth:
    enabled: true
    token: "auto-generated"

agents:
  defaults:
    model: claude-sonnet-4
    sandbox:
      mode: none

providers:
  telegram:
    enabled: true
    botToken: "your-token"
  discord:
    enabled: true
    botToken: "your-token"
  # ... other providers
```

**Editing**:
1. Stop container
2. Edit file with text editor
3. Validate YAML syntax
4. Start container

**Caution**: Invalid YAML will prevent container from starting.

### Log Rotation

Configure log rotation in `config.yaml`:

```yaml
logging:
  level: info
  rotation:
    enabled: true
    maxSize: 50M
    maxFiles: 5
    compress: true
```

**Options**:
- `maxSize`: Max size per log file
- `maxFiles`: Number of rotated files to keep
- `compress`: Gzip old log files

## Configuration Best Practices

### Security

1. **Never commit API keys**: Keep them in Docker settings only
2. **Use masked variables**: Anthropic API key should be masked
3. **Regular backups**: Backup config directory regularly
4. **Restrict WebUI access**: Use firewall rules if needed
5. **Provider allowlists**: Configure group/guild allowlists

### Performance

1. **Log level**: Use `info` for normal operation
2. **Log rotation**: Enable to prevent disk fill
3. **Workspace cleanup**: Periodically clean `/workspace/temp`
4. **Monitor resources**: Check CPU/RAM usage

### Maintenance

1. **Document changes**: Keep notes on customizations
2. **Test updates**: Verify configuration after container updates
3. **Monitor logs**: Check for errors or warnings
4. **Review providers**: Disable unused providers

## Troubleshooting Configuration

### Configuration Not Applying

**Issue**: Changes in Docker settings don't take effect

**Solution**:
1. Stop container
2. Make changes
3. Apply
4. Start container
5. Verify in logs

### Provider Credentials Not Saving

**Issue**: Provider tokens don't persist

**Solution**:
1. Check `/config` directory permissions:
   ```bash
   ls -la /mnt/user/appdata/clawdbot
   ```
2. Should be owned by `99:100`
3. Fix if needed:
   ```bash
   chown -R 99:100 /mnt/user/appdata/clawdbot
   ```

### Invalid Configuration Error

**Issue**: Container fails to start with config error

**Solution**:
1. Check logs for specific error
2. Validate `config.yaml` syntax
3. Restore from backup if needed
4. Or delete `.initialized` and let container re-initialize

---

For provider-specific configuration, see [Provider Setup Guide](PROVIDERS.md).

For troubleshooting, see [Troubleshooting Guide](TROUBLESHOOTING.md).
