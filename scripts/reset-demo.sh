#!/usr/bin/env bash
# Reset to a known-good state between demos. Safe to run repeatedly.
# Does NOT touch untracked files (so .devcontainer/.env survives).

set -euo pipefail

echo "Resetting tracked files to last commit..."
git restore .

echo
echo "Done. Untracked files (including .devcontainer/.env) are preserved."
echo "If your demo modified untracked state too, clean it up manually."
echo
echo "Pre-flight check: scripts/doctor.sh"
