# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy source code
COPY . .

# Runtime stage
FROM node:20-alpine

WORKDIR /app

# Install tini for proper signal handling
RUN apk add --no-cache tini

# Copy built app from builder
COPY --from=builder /app /app

# Create a non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

USER nodejs

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "require('fs').accessSync('/tmp/healthy')" || exit 1

# Use tini to handle signals properly
ENTRYPOINT ["/sbin/tini", "--"]

# Default command - runs mqtt-publisher script with host, port, and credentials from env vars
CMD ["node", "bin/resol-vbus-toolbox", \
     "--host", "${VBUS_HOST:-192.168.178.200}", \
     "--port", "${VBUS_PORT:-7053}", \
     "--password", "${VBUS_PASSWORD:-vbus}", \
     "--script", "scripts/mqtt-publisher.js"]
