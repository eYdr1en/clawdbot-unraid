# ClawdBot Installation Guide

This guide will walk you through installing ClawdBot on your Unraid server.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Method 1: Community Applications (Recommended)](#method-1-community-applications-recommended)
- [Method 2: Manual Template Installation](#method-2-manual-template-installation)
- [Initial Configuration](#initial-configuration)
- [First Start](#first-start)
- [Verification](#verification)
- [Next Steps](#next-steps)
- [Troubleshooting Installation](#troubleshooting-installation)

## Prerequisites

Before installing ClawdBot, ensure you have:

### Required

1. **Unraid Server**
   - Version 6.10 or later
   - Docker service enabled

2. **Anthropic API Key**
   - Sign up at [console.anthropic.com](https://console.anthropic.com/)
   - Navigate to **Settings** → **API Keys**
   - Click **Create Key**
   - Copy the key (format: `sk-ant-api03-...`)
   - **Important**: Save this key securely - you won't be able to see it again

### Recommended

- **Minimum Hardware**:
  - CPU: Any modern x86_64 or ARM64 processor
  - RAM: 1 GB available
  - Disk Space: 2 GB available in AppData

- **Network**:
  - Ports 18789 and 18790 available (or choose different ports)
  - Internet connection for API access

## Method 1: Community Applications (Recommended)

### Step 1: Open Community Applications

1. Log in to your Unraid WebUI
2. Click on the **Apps** tab in the top menu
3. If you don't see the Apps tab, install the Community Applications plugin first:
   - Go to **Plugins** tab
   - Click **Install Plugin**
   - Search for "Community Applications"
   - Install it

### Step 2: Search for ClawdBot

1. In the Apps tab, use the search bar
2. Type **ClawdBot**
3. Look for "ClawdBot" by eYdr1en

### Step 3: Install

1. Click on the **ClawdBot** entry
2. Click **Install** or **Get More Info** → **Install**
3. You'll be presented with the configuration screen

### Step 4: Configure

Fill in the required settings (see [Initial Configuration](#initial-configuration) below)

### Step 5: Apply

1. Review your settings
2. Click **Apply**
3. The container will download and start automatically

## Method 2: Manual Template Installation

If ClawdBot isn't yet in Community Applications, or you prefer manual installation:

### Step 1: Add Template Repository

1. Open Unraid WebUI
2. Go to **Docker** tab
3. Scroll to the bottom
4. Click **Add Container**
5. In the template dropdown, select **Template repositories**
6. Add this URL:
   ```
   https://github.com/eYdr1en/clawdbot-unraid
   ```
7. Click **Save**

### Step 2: Add Container from Template

1. Still in the **Docker** tab
2. Click **Add Container**
3. In the **Template** dropdown, look for **ClawdBot**
4. Select it

### Alternative: Direct Template URL

If the repository method doesn't work:

1. Click **Add Container**
2. Switch to **Advanced View** (toggle at top)
3. At the bottom, find **Template URL**
4. Enter:
   ```
   https://raw.githubusercontent.com/eYdr1en/clawdbot-unraid/main/templates/clawdbot.xml
   ```
5. Click **Apply Template**

## Initial Configuration

When you install ClawdBot, you'll need to configure these settings:

### Required Settings

#### 1. Anthropic API Key

- **Field**: `ANTHROPIC_API_KEY`
- **Value**: Your API key from Anthropic Console
- **Format**: `sk-ant-api03-...`
- **Important**: This field is masked for security

#### 2. Ports

- **Gateway Port**:
  - Default: `18789`
  - Change if port is already in use
  - This is where you'll access the WebUI

- **Bridge Port**:
  - Default: `18790`
  - Change if port is already in use
  - Used for internal communication

#### 3. Config Directory

- **Field**: Config Directory
- **Default**: `/mnt/user/appdata/clawdbot`
- **Purpose**: Stores all persistent data
- **Recommendation**: Keep default unless you have specific needs

### Optional Settings

#### User/Group IDs (PUID/PGID)

- **PUID**: Default `99` (nobody user on Unraid)
- **PGID**: Default `100` (users group on Unraid)
- **When to change**: If you need specific file ownership

To find your user ID:
```bash
id your_username
```

#### Workspace Directory

- **Default**: `/mnt/user/appdata/clawdbot/workspace`
- **Purpose**: Working directory for Claude Code execution
- **Optional**: Can leave as default

#### Provider Toggles

Enable only the providers you plan to use:

- **Enable WebChat**: `true` (recommended to keep enabled)
- **Enable WhatsApp**: `false` (enable if you'll configure WhatsApp)
- **Enable Telegram**: `false` (enable if you'll configure Telegram)
- **Enable Discord**: `false` (enable if you'll configure Discord)
- **Enable Signal**: `false` (advanced, enable if needed)
- **Enable iMessage**: `false` (macOS only, enable if needed)

**Note**: You can enable providers later via WebUI.

#### Advanced Settings

- **Log Level**: `info` (use `debug` for troubleshooting)
- **Timezone**: `UTC` (or your timezone, e.g., `America/New_York`)

## First Start

### What Happens on First Start

When you start ClawdBot for the first time:

1. **Automated Onboarding** (30-60 seconds)
   - ClawdBot validates your API key
   - Initializes the gateway daemon
   - Creates configuration files
   - Sets up the WebUI

2. **Status Indicators**
   - Container status changes to "Started"
   - Health check will show "healthy" after ~60 seconds

### Monitoring First Start

To watch the initialization process:

1. In Unraid Docker tab, find **ClawdBot**
2. Click the container icon
3. Select **Logs**
4. Watch for these messages:
   ```
   ===================================
   First Run Detected
   ===================================
   Running automated onboarding...

   ===================================
   Onboarding Complete!
   ===================================
   ClawdBot has been initialized successfully.
   ```

### Expected Startup Time

- **First start**: 60-90 seconds (includes onboarding)
- **Subsequent starts**: 10-20 seconds

## Verification

### 1. Check Container Status

In Unraid Docker tab:
- Container should show status: **Started**
- Health should show: **healthy** (after ~60 seconds)

### 2. Check Logs

Look for these success indicators in the logs:
```
Onboarding Complete!
Starting ClawdBot Gateway...
Gateway daemon started on port 18789
```

### 3. Access WebUI

1. Open your web browser
2. Navigate to: `http://[UNRAID-IP]:18789`
   - Replace `[UNRAID-IP]` with your Unraid server IP
   - Example: `http://192.168.1.100:18789`

3. You should see the ClawdBot WebUI

### 4. Test WebChat

1. In the WebUI, look for the WebChat interface
2. Send a test message: "Hello!"
3. Claude should respond

**Success!** ClawdBot is installed and working.

## Next Steps

Now that ClawdBot is installed:

1. **Configure Providers** (optional)
   - [Provider Setup Guide](PROVIDERS.md)
   - Start with Telegram (easiest)

2. **Explore the WebUI**
   - Familiarize yourself with the interface
   - Review provider settings
   - Check system status

3. **Set Up Backup**
   - See [Backup Guide](#backup-and-restore) in main README
   - Schedule regular backups of `/mnt/user/appdata/clawdbot`

4. **Review Security**
   - Configure provider allowlists
   - Enable mention gating for group chats
   - Review access logs

5. **Read Documentation**
   - [Configuration Guide](CONFIGURATION.md) - Detailed configuration options
   - [Provider Setup](PROVIDERS.md) - Configure messaging platforms
   - [Troubleshooting](TROUBLESHOOTING.md) - Common issues and solutions

## Troubleshooting Installation

### Container Won't Start

**Problem**: Container immediately stops after starting

**Possible Causes**:
1. Missing or invalid ANTHROPIC_API_KEY
2. Port conflict (18789 or 18790 in use)
3. AppData path doesn't exist or isn't writable

**Solutions**:

1. **Check API Key**:
   - Edit container settings
   - Verify ANTHROPIC_API_KEY is filled in
   - Ensure no extra spaces or characters
   - Key should start with `sk-ant-`

2. **Check Port Conflicts**:
   ```bash
   # From Unraid terminal
   netstat -tulpn | grep 18789
   netstat -tulpn | grep 18790
   ```
   - If ports are in use, change them in container settings

3. **Check AppData Path**:
   ```bash
   ls -la /mnt/user/appdata/
   mkdir -p /mnt/user/appdata/clawdbot
   chmod 777 /mnt/user/appdata/clawdbot
   ```

### Onboarding Fails

**Problem**: Logs show "ERROR: Onboarding failed!"

**Possible Causes**:
1. Invalid API key
2. Network connectivity issues
3. Anthropic API temporarily unavailable

**Solutions**:

1. **Verify API Key**:
   - Test your key at [console.anthropic.com](https://console.anthropic.com/)
   - Generate a new key if needed
   - Update container with new key

2. **Check Network**:
   ```bash
   # From container console
   curl -I https://api.anthropic.com
   ```
   - Should return HTTP 200 or 400 (not timeout)

3. **Retry**:
   - Stop container
   - Remove marker file: `rm /mnt/user/appdata/clawdbot/.initialized`
   - Start container (will re-run onboarding)

### Can't Access WebUI

**Problem**: `http://[UNRAID-IP]:18789` doesn't load

**Possible Causes**:
1. Container not running
2. Wrong IP address
3. Firewall blocking port
4. Port mapping incorrect

**Solutions**:

1. **Verify Container Running**:
   ```bash
   docker ps | grep clawdbot
   ```
   - Should show "Up" status

2. **Check IP Address**:
   - Use Unraid server's IP address, not `localhost` or `127.0.0.1`
   - Find IP in Unraid WebUI (top right corner)

3. **Check Port Mapping**:
   - Edit container
   - Verify Port Mappings section shows `18789:18789`

4. **Test Port Access**:
   ```bash
   # From another machine on your network
   telnet [UNRAID-IP] 18789
   ```
   - Should connect (Ctrl+C to exit)

### Permission Errors

**Problem**: Logs show "EACCES" or permission denied errors

**Solutions**:

1. **Fix AppData Permissions**:
   ```bash
   chown -R 99:100 /mnt/user/appdata/clawdbot
   chmod -R 755 /mnt/user/appdata/clawdbot
   ```

2. **Adjust PUID/PGID**:
   - Edit container settings
   - Set PUID to `99` and PGID to `100` (Unraid defaults)
   - Apply and restart

### Need More Help?

If you're still having issues:

1. **Check Full Logs**:
   - Docker tab → ClawdBot → Logs
   - Copy the full log output

2. **Search Existing Issues**:
   - [GitHub Issues](https://github.com/eYdr1en/clawdbot-unraid/issues)

3. **Create New Issue**:
   - Include:
     - Unraid version
     - Container version
     - Full logs (sanitize API keys!)
     - Steps to reproduce

4. **See Troubleshooting Guide**:
   - [Full Troubleshooting Guide](TROUBLESHOOTING.md)

---

**Congratulations!** You've successfully installed ClawdBot on Unraid. Enjoy your personal AI assistant!
