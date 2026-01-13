# ClawdBot Troubleshooting Guide

Solutions to common issues with ClawdBot on Unraid.

## Table of Contents

- [Container Issues](#container-issues)
- [WebUI Issues](#webui-issues)
- [Provider Issues](#provider-issues)
- [Performance Issues](#performance-issues)
- [Permission Issues](#permission-issues)
- [API and Authentication](#api-and-authentication)
- [Logs and Diagnostics](#logs-and-diagnostics)
- [Getting Help](#getting-help)

## Container Issues

### Container Won't Start

**Symptoms**: Container immediately stops after starting

**Common Causes**:
1. Missing or invalid ANTHROPIC_API_KEY
2. Port conflicts (18789 or 18790 in use)
3. AppData path issues

**Solutions**:

1. **Check API Key**:
   ```bash
   # View container environment variables
   docker inspect clawdbot | grep ANTHROPIC_API_KEY
   ```
   - Must be present and start with `sk-ant-`
   - Edit container settings to add/fix

2. **Check Port Conflicts**:
   ```bash
   # Check if ports are in use
   netstat -tulpn | grep 18789
   netstat -tulpn | grep 18790
   ```
   - If in use, stop conflicting service or change ClawdBot ports

3. **Check AppData Path**:
   ```bash
   ls -la /mnt/user/appdata/clawdbot
   ```
   - Directory should exist and be writable
   - Create if missing: `mkdir -p /mnt/user/appdata/clawdbot`

4. **Check Logs**:
   ```bash
   docker logs clawdbot
   ```
   - Look for specific error messages

### Container Keeps Restarting

**Symptoms**: Container starts but crashes repeatedly

**Solutions**:

1. **Check onboarding status**:
   ```bash
   ls /mnt/user/appdata/clawdbot/.initialized
   ```
   - If missing, onboarding may be failing
   - Check logs for onboarding errors

2. **Remove initialization marker** (force re-onboarding):
   ```bash
   rm /mnt/user/appdata/clawdbot/.initialized
   docker restart clawdbot
   ```

3. **Verify API key is valid**:
   - Test at [console.anthropic.com](https://console.anthropic.com/)
   - Generate new key if needed

### Container Health Check Failing

**Symptoms**: Docker shows container as "unhealthy"

**Solutions**:

1. **Check gateway is running**:
   ```bash
   docker exec clawdbot wget -O- http://localhost:18789/
   ```
   - Should return HTML response

2. **Review logs for errors**:
   ```bash
   docker logs clawdbot --tail 50
   ```

3. **Restart container**:
   ```bash
   docker restart clawdbot
   ```

## WebUI Issues

### Can't Access WebUI

**Symptoms**: `http://[UNRAID-IP]:18789` doesn't load

**Solutions**:

1. **Verify container is running**:
   ```bash
   docker ps | grep clawdbot
   ```
   - Should show "Up" status

2. **Check correct IP address**:
   - Use Unraid server's IP, not `localhost`
   - Find in Unraid WebUI (top right corner)

3. **Test port connectivity**:
   ```bash
   # From another device on network
   telnet [UNRAID-IP] 18789
   ```
   - Should connect (Ctrl+C to exit)

4. **Check firewall**:
   - Unraid firewall may block port
   - Add exception for port 18789

5. **Verify port mapping**:
   - Edit container settings
   - Port Mappings should show: `18789:18789`

### WebUI Loads But Won't Respond

**Symptoms**: Page loads but interactions don't work

**Solutions**:

1. **Clear browser cache**:
   - Hard refresh: Ctrl+Shift+R (Cmd+Shift+R on Mac)
   - Or clear browser cache completely

2. **Try different browser**:
   - Test in incognito/private mode
   - Try different browser (Chrome, Firefox, Safari)

3. **Check browser console**:
   - F12 → Console tab
   - Look for JavaScript errors
   - Report errors if found

4. **Verify gateway is responding**:
   ```bash
   curl -I http://[UNRAID-IP]:18789
   ```
   - Should return HTTP 200 OK

## Provider Issues

### Telegram Bot Not Responding

**Symptoms**: Bot doesn't reply to messages

**Checklist**:
- [ ] `TELEGRAM_ENABLED=true` in container settings
- [ ] Bot token entered correctly in WebUI
- [ ] Bot added to group (if testing in group)
- [ ] Privacy mode disabled (for group usage)
- [ ] Container restarted after configuration

**Solutions**:

1. **Verify token**:
   - Test token with Telegram API:
   ```bash
   curl https://api.telegram.org/bot[YOUR-TOKEN]/getMe
   ```
   - Should return bot info

2. **Check logs**:
   ```bash
   docker logs clawdbot | grep telegram
   ```
   - Look for connection errors

3. **For groups**, ensure:
   - Bot added to group
   - Group privacy disabled (@BotFather)
   - Bot mentioned: `@YourBot hello`

### Discord Bot Offline

**Symptoms**: Bot shows as offline in Discord

**Solutions**:

1. **Verify token**:
   - Check token in WebUI matches Discord Developer Portal
   - Regenerate token if needed

2. **Check intents**:
   - Discord Developer Portal → Bot
   - Enable: **MESSAGE CONTENT INTENT**
   - Enable: **SERVER MEMBERS INTENT**

3. **Verify bot is enabled**:
   - Container settings: `DISCORD_ENABLED=true`
   - WebUI: Discord provider configured

4. **Check logs**:
   ```bash
   docker logs clawdbot | grep discord
   ```

5. **Re-invite bot**:
   - Generate new OAuth2 URL
   - Re-invite with correct permissions

### WhatsApp Connection Failed

**Symptoms**: WhatsApp won't connect

**Note**: WhatsApp is the most complex provider to set up.

**Solutions**:

1. **For WhatsApp Web mode**:
   - QR code expires quickly - scan immediately
   - Phone must stay connected to internet
   - WhatsApp app must stay active

2. **For Business API**:
   - Verify credentials are correct
   - Check API quota/limits
   - Review Business API documentation

3. **Check logs**:
   ```bash
   docker logs clawdbot | grep whatsapp
   ```

4. **Consider using different provider**:
   - Telegram or Discord are more reliable

## Performance Issues

### High CPU Usage

**Symptoms**: Container using excessive CPU

**Solutions**:

1. **Check for conversation loops**:
   - Bot responding to itself
   - Misconfigured provider triggers

2. **Reduce log level**:
   - Change from `debug` to `info`
   - Edit container settings: `LOG_LEVEL=info`

3. **Limit active providers**:
   - Disable unused providers
   - Reduces background polling

4. **Monitor resource usage**:
   ```bash
   docker stats clawdbot
   ```

### High Memory Usage

**Symptoms**: Container memory continuously grows

**Solutions**:

1. **Check log file size**:
   ```bash
   du -sh /mnt/user/appdata/clawdbot/logs/
   ```
   - Large logs can cause memory issues

2. **Enable log rotation**:
   - Edit `/mnt/user/appdata/clawdbot/config.yaml`
   - Add log rotation settings

3. **Restart container periodically**:
   - Schedule weekly restart via User Scripts

4. **Clear workspace temp files**:
   ```bash
   rm -rf /mnt/user/appdata/clawdbot/workspace/temp/*
   ```

### Slow Response Times

**Symptoms**: Claude takes long time to respond

**Possible Causes**:
1. Anthropic API latency
2. Network issues
3. Large message history

**Solutions**:

1. **Check internet connection**:
   ```bash
   ping api.anthropic.com
   ```

2. **Test API directly**:
   ```bash
   curl -I https://api.anthropic.com
   ```

3. **Clear conversation history**:
   - Long histories can slow processing
   - Start new conversation

4. **Monitor Anthropic status**:
   - Check [status.anthropic.com](https://status.anthropic.com)

## Permission Issues

### Permission Denied Errors

**Symptoms**: Logs show "EACCES" or "Permission denied"

**Solutions**:

1. **Fix AppData ownership**:
   ```bash
   chown -R 99:100 /mnt/user/appdata/clawdbot
   chmod -R 755 /mnt/user/appdata/clawdbot
   ```

2. **Verify PUID/PGID**:
   - Edit container settings
   - Set: `PUID=99`, `PGID=100`
   - Apply and restart

3. **Check directory permissions**:
   ```bash
   ls -la /mnt/user/appdata/clawdbot
   ```
   - Should be: `drwxr-xr-x 99 100`

### Can't Write to Config

**Symptoms**: Changes in WebUI don't save

**Solutions**:

1. **Check config directory is writable**:
   ```bash
   touch /mnt/user/appdata/clawdbot/test
   rm /mnt/user/appdata/clawdbot/test
   ```
   - If fails, fix permissions (see above)

2. **Verify mount is read-write**:
   - Edit container settings
   - Config mount should show Mode: `rw`

3. **Check disk space**:
   ```bash
   df -h /mnt/user/appdata
   ```
   - Ensure sufficient free space

## API and Authentication

### API Key Errors

**Symptoms**: "Invalid API key" or "Authentication failed"

**Solutions**:

1. **Verify key format**:
   - Must start with `sk-ant-api03-`
   - No extra spaces or newlines

2. **Test key directly**:
   ```bash
   curl https://api.anthropic.com/v1/messages \
     -H "x-api-key: YOUR-KEY" \
     -H "anthropic-version: 2023-06-01" \
     -H "content-type: application/json" \
     -d '{"model":"claude-sonnet-4","max_tokens":10,"messages":[{"role":"user","content":"Hi"}]}'
   ```

3. **Generate new key**:
   - Visit [console.anthropic.com](https://console.anthropic.com/)
   - Settings → API Keys → Create Key
   - Update in container settings

### Rate Limit Errors

**Symptoms**: "Rate limit exceeded" errors

**Solutions**:

1. **Check Anthropic usage limits**:
   - Visit console.anthropic.com
   - Review usage and limits

2. **Reduce request frequency**:
   - Limit number of active conversations
   - Disable auto-responses in groups

3. **Upgrade Anthropic plan**:
   - Higher tiers have increased limits

## Logs and Diagnostics

### Accessing Logs

**Container logs**:
```bash
# Recent logs
docker logs clawdbot --tail 100

# Follow logs in real-time
docker logs clawdbot --follow

# All logs
docker logs clawdbot > clawdbot-logs.txt
```

**Application logs**:
```bash
# Gateway logs
cat /mnt/user/appdata/clawdbot/logs/gateway.log

# Provider logs
cat /mnt/user/appdata/clawdbot/logs/providers.log

# Error logs
cat /mnt/user/appdata/clawdbot/logs/errors.log
```

### Enable Debug Logging

1. Edit container settings
2. Set: `LOG_LEVEL=debug`
3. Apply and restart
4. Check logs for detailed information

**Warning**: Debug logs are verbose and can fill disk quickly.

### Diagnostic Commands

**Container status**:
```bash
docker ps -a | grep clawdbot
docker inspect clawdbot
```

**Network connectivity**:
```bash
docker exec clawdbot ping -c 3 api.anthropic.com
docker exec clawdbot wget -O- http://localhost:18789
```

**Resource usage**:
```bash
docker stats clawdbot --no-stream
```

**Configuration check**:
```bash
cat /mnt/user/appdata/clawdbot/config.yaml
```

## Getting Help

### Before Asking for Help

1. **Check this guide** - Most issues covered here
2. **Search existing issues** - Someone may have had same problem
3. **Collect information**:
   - Unraid version
   - ClawdBot container version
   - Full logs (sanitize API keys!)
   - Steps to reproduce
   - Configuration (sanitized)

### Where to Get Help

1. **GitHub Issues**:
   - [clawdbot-unraid Issues](https://github.com/eYdr1en/clawdbot-unraid/issues)
   - Search first, create new if needed

2. **GitHub Discussions**:
   - [clawdbot-unraid Discussions](https://github.com/eYdr1en/clawdbot-unraid/discussions)
   - For questions and general help

3. **Official ClawdBot**:
   - [ClawdBot Repository](https://github.com/clawdbot/clawdbot)
   - [ClawdBot Docs](https://docs.clawd.bot)

### Creating a Good Issue Report

Include:

1. **Description**: Clear description of the problem
2. **Steps to Reproduce**: Exact steps that cause the issue
3. **Expected Behavior**: What should happen
4. **Actual Behavior**: What actually happens
5. **Environment**:
   - Unraid version
   - ClawdBot version
   - Browser (for WebUI issues)
6. **Logs**: Relevant logs (sanitized!)
7. **Screenshots**: If applicable

**Example**:
```markdown
## Issue: Container won't start

### Description
ClawdBot container immediately stops after starting.

### Steps to Reproduce
1. Install ClawdBot from CA
2. Set ANTHROPIC_API_KEY
3. Start container
4. Container stops within 5 seconds

### Expected Behavior
Container should start and remain running.

### Actual Behavior
Container starts then immediately stops.

### Environment
- Unraid: 6.12.6
- ClawdBot: ghcr.io/eydr1en/clawdbot-unraid:latest
- Docker: 24.0.7

### Logs
```
ERROR: Onboarding failed!
Error: Invalid API key format
```

### Configuration
- ANTHROPIC_API_KEY: sk-ant-... (verified correct format)
- Ports: 18789:18789, 18790:18790
- AppData: /mnt/user/appdata/clawdbot (exists, 777 permissions)
```

---

**Still having issues?** Create an issue on [GitHub](https://github.com/eYdr1en/clawdbot-unraid/issues) with details!
