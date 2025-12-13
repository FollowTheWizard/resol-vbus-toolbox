# Use Node 18 on Debian trixie slim
FROM node:18-trixie-slim

# Install system deps commonly needed for native modules and USB access
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    udev \
    libusb-1.0-0-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install only production dependencies
COPY package.json package.json
RUN npm install --production --no-audit --no-fund

# Copy app sources
COPY . /app

# Optional non-root user (if you need the container to run as root, remove these two lines)
RUN groupadd -r app && useradd -r -g app app \
    && chown -R app:app /app
USER app

# Start the app
CMD ["node", "src/index.js"]