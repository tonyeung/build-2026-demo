#!/usr/bin/env bash
# run-first-mac.sh
# Run once before the demo on macOS to ensure all prerequisites are installed.

set -euo pipefail

step() { echo -e "\n==> $1"; }

command_exists() { command -v "$1" &>/dev/null; }

# ── Homebrew ─────────────────────────────────────────────────────────────────
step "Checking Homebrew"
if ! command_exists brew; then
    step "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for the rest of this script (Apple Silicon default path)
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true
else
    echo "Homebrew already installed."
fi

# ── Git ───────────────────────────────────────────────────────────────────────
step "Checking Git"
if ! command_exists git; then
    brew install git
else
    echo "Git already installed."
fi

# ── GitHub CLI ────────────────────────────────────────────────────────────────
step "Checking GitHub CLI"
if ! command_exists gh; then
    brew install gh
else
    echo "GitHub CLI already installed."
fi

# ── VS Code ───────────────────────────────────────────────────────────────────
step "Checking VS Code"
# Check both the CLI command and the .app bundle (CLI may not be on PATH yet)
if ! command_exists code && [[ ! -d "/Applications/Visual Studio Code.app" ]]; then
    brew install --cask visual-studio-code
else
    echo "VS Code already installed."
fi

# ── Dev Containers extension ──────────────────────────────────────────────────
step "Checking Dev Containers extension"
# If `code` isn't on PATH but VS Code is installed, add the CLI shim to PATH
if ! command_exists code && [[ -f "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
    export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    echo "Added VS Code CLI to PATH for this session."
fi

if command_exists code; then
    code --install-extension ms-vscode-remote.remote-containers
    echo "Dev Containers extension installed/ensured."
else
    echo "WARNING: VS Code not on PATH; install the Dev Containers extension manually."
fi

# ── Docker Desktop ────────────────────────────────────────────────────────────
step "Checking Docker Desktop"
if ! command_exists docker; then
    step "Installing Docker Desktop..."
    brew install --cask docker
    echo "Docker Desktop installed. Opening it now..."
    open -a Docker
else
    echo "Docker already installed."
    # Ensure Docker Desktop is running
    if ! docker info &>/dev/null 2>&1; then
        echo "Docker daemon not running. Starting Docker Desktop..."
        open -a Docker
    fi
fi

step "Waiting for Docker daemon (up to 2 minutes)"
ready=false
for i in $(seq 1 24); do
    if docker info &>/dev/null 2>&1; then
        ready=true
        break
    fi
    echo "  ...waiting (${i}/24)"
    sleep 5
done

if $ready; then
    echo "Docker daemon is ready."
    docker version --format "Server: {{.Server.Version}}"
else
    echo "WARNING: Docker daemon not ready after 2 minutes. Start Docker Desktop manually and run 'docker info'."
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo -e "\nSetup complete."
echo "IMPORTANT: If VS Code is already open, fully restart it to pick up Git/GitHub CLI and the code CLI in PATH."
