#!/bin/bash
# Setup VS Code profiles for demo and development workflows.
# Profiles created via this script can be switched with:
#   Cmd/Ctrl+Shift+P → Profiles: Open Profile → Demo or Default

set -e

# Determine VS Code config directory based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  VSCODE_DIR="$HOME/Library/Application Support/Code"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  VSCODE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/Code"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
  # Windows (Git Bash)
  VSCODE_DIR="$APPDATA/Code"
else
  echo "❌ Unsupported OS: $OSTYPE"
  exit 1
fi

PROFILES_DIR="$VSCODE_DIR/User/profiles"
DEMO_PROFILE="$PROFILES_DIR/Demo"
DEFAULT_PROFILE="$PROFILES_DIR/Default"

# Create profiles directory if it doesn't exist
mkdir -p "$PROFILES_DIR"

echo "📦 Setting up VS Code profiles..."

# Copy Demo profile
if [[ -d "$DEMO_PROFILE" ]]; then
  echo "   ℹ️  Demo profile already exists (skipping)"
else
  mkdir -p "$DEMO_PROFILE"
  # Extract settings from the JSON and write to settings.json
  jq '.settings' "$(dirname "$0")/../.vscode/profiles/demo.json" > "$DEMO_PROFILE/settings.json"
  echo "   ✅ Demo profile created"
fi

# Copy Default profile
if [[ -d "$DEFAULT_PROFILE" ]]; then
  echo "   ℹ️  Default profile already exists (skipping)"
else
  mkdir -p "$DEFAULT_PROFILE"
  # Extract settings from the JSON and write to settings.json
  jq '.settings' "$(dirname "$0")/../.vscode/profiles/default.json" > "$DEFAULT_PROFILE/settings.json"
  echo "   ✅ Default profile created"
fi

echo ""
echo "✨ Profiles ready! Switch between them:"
echo ""
echo "   🎬 For demos:      Cmd/Ctrl+Shift+P → Profiles: Open Profile → Demo"
echo "   🛠️  For development: Cmd/Ctrl+Shift+P → Profiles: Open Profile → Default"
echo ""
