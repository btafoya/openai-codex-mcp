# Dockerfile for OpenAI Codex MCP Server
FROM python:3.12-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies including Node.js and npm
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    nodejs \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Verify installations
RUN python --version && node --version && npm --version

# Set working directory
WORKDIR /app

# Copy project files
COPY pyproject.toml ./
COPY codex_server.py ./
COPY openai_codex_mcp.json ./

# Install Python dependencies with SSL trust workarounds for build environments
RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org -e .

# Create app user for security
RUN useradd --create-home --shell /bin/bash app && \
    chown -R app:app /app

# Create startup script that will install Codex CLI and start the server
COPY <<EOF /usr/local/bin/entrypoint.sh
#!/bin/bash
set -e

echo "=== OpenAI Codex MCP Server Docker Container ==="

# Function to install Codex CLI
install_codex_cli() {
    echo "Installing OpenAI Codex CLI..."
    
    # Multiple installation strategies for different environments
    if npm install -g @openai/codex; then
        echo "✓ Codex CLI installed successfully"
        return 0
    fi
    
    echo "Trying with relaxed SSL settings..."
    npm config set strict-ssl false
    if npm install -g @openai/codex; then
        echo "✓ Codex CLI installed successfully (with relaxed SSL)"
        npm config set strict-ssl true
        return 0
    fi
    npm config set strict-ssl true
    
    echo "❌ Failed to install Codex CLI automatically"
    echo "This may be due to network restrictions or proxy settings."
    echo ""
    echo "MANUAL INSTALLATION REQUIRED:"
    echo "1. Access the container: docker exec -it <container_name> /bin/bash"
    echo "2. Install manually: npm install -g @openai/codex"
    echo "3. Or install from host: docker exec -u root <container_name> npm install -g @openai/codex"
    echo ""
    echo "The server will start but may not function until Codex CLI is installed."
    return 1
}

# Check if we're running as root and try to install Codex CLI
if [ "\$EUID" -eq 0 ]; then
    install_codex_cli || echo "Continuing without Codex CLI..."
    echo "Switching to app user..."
    chown -R app:app /app
    exec gosu app "\$0" "\$@"
fi

# Running as app user - check if Codex CLI is available
if command -v codex &> /dev/null; then
    echo "✓ Codex CLI found"
else
    echo "⚠️  Codex CLI not found - server may not function properly"
fi

echo "Starting MCP server on port \${PORT:-8000}..."
exec codex_server
EOF

RUN chmod +x /usr/local/bin/entrypoint.sh

# Install gosu for user switching
RUN apt-get update && apt-get install -y gosu && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]