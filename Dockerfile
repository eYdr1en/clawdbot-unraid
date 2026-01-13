# ClawdBot Unraid Docker Image
# Multi-stage build for optimal size and security

# Stage 1: Runtime (ClawdBot is distributed as npm package)
FROM node:22-alpine

LABEL org.opencontainers.image.title="ClawdBot for Unraid"
LABEL org.opencontainers.image.description="Personal AI assistant powered by Claude for Unraid"
LABEL org.opencontainers.image.source="https://github.com/clawdbot/clawdbot"
LABEL org.opencontainers.image.vendor="ClawdBot Community"

# Install dependencies
RUN apk add --no-cache \
    su-exec \
    shadow \
    tini \
    curl

# Create non-root user and group
RUN addgroup -g 1000 clawdbot && \
    adduser -D -u 1000 -G clawdbot -s /bin/sh clawdbot

# Set working directory
WORKDIR /app

# Install clawdbot globally
# Using --legacy-peer-deps to avoid potential peer dependency issues
RUN npm install -g clawdbot@latest --legacy-peer-deps && \
    npm cache clean --force

# Create necessary directories with proper permissions
RUN mkdir -p /config /workspace /home/clawdbot/.clawdbot && \
    chown -R clawdbot:clawdbot /config /workspace /home/clawdbot

# Copy entrypoint script
COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose ports
# 18789: Gateway WebUI and API
# 18790: Bridge communication port
EXPOSE 18789 18790

# Environment defaults
ENV NODE_ENV=production \
    CLAWDBOT_CONFIG_DIR=/config \
    CLAWDBOT_GATEWAY_PORT=18789 \
    CLAWDBOT_BRIDGE_PORT=18790 \
    PUID=1000 \
    PGID=1000 \
    LOG_LEVEL=info \
    TZ=UTC

# Health check
# Checks if the gateway is responding on port 18789
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:18789/ || exit 1

# Use tini for proper signal handling
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]

# Default command (can be overridden)
CMD ["clawdbot", "gateway", "daemon"]
