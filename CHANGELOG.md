# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-01-13

### Added
- Initial release of ClawdBot for Unraid
- Multi-stage Docker build with Node.js 22 Alpine
- Automated onboarding on first run
- Support for all messaging providers:
  - WebChat (built-in)
  - Telegram
  - Discord
  - WhatsApp
  - Signal
  - iMessage
- WebUI for configuration and management (port 18789)
- Multi-architecture support (amd64, arm64)
- GitHub Actions CI/CD pipeline with automated builds
- Automated publishing to GitHub Container Registry (ghcr.io)
- Comprehensive documentation:
  - Installation guide
  - Configuration guide
  - Provider setup guide
  - Troubleshooting guide
- Security features:
  - Non-root user execution
  - Masked API keys in logs
  - Encrypted credentials at rest
- Health check monitoring
- Log rotation support
- Unraid XML template for Community Applications
- Environment variable configuration
- PUID/PGID support for Unraid permissions
- Persistent data storage in AppData
- Workspace directory for Claude Code execution
- Provider enable/disable toggles
- Configurable log levels
- Timezone configuration

### Security
- Non-root container execution (clawdbot:1000)
- API key masking in logs and UI
- Encrypted credential storage
- Minimal Alpine Linux base image
- Security scanning via GitHub Actions

### Documentation
- Complete README with quick start guide
- Detailed installation instructions
- Configuration reference
- Provider setup guides for all platforms
- Comprehensive troubleshooting guide
- Architecture documentation
- Security best practices
- Backup and restore procedures

[Unreleased]: https://github.com/eYdr1en/clawdbot-unraid/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/eYdr1en/clawdbot-unraid/releases/tag/v1.0.0
