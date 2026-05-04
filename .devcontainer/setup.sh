#!/usr/bin/env bash
set -euxo pipefail

# Globally install the Copilot SDKs that have a sensible global install path.
# These wrap the `copilot` CLI via JSON-RPC — they are NOT generic model SDKs.
# (Path A: programmatic agent flows around the Copilot CLI.)
npm install -g @github/copilot-sdk
pip install --user github-copilot-sdk

# Go and .NET Copilot SDKs are per-project (`go get` / `dotnet add package`) —
# add them in your demo project, not here.

# CodeQL extension for GHAS / Autofix demos.
gh extension install github/gh-codeql

# Path B (GitHub Models direct API) needs no installs — it's plain HTTP against
# https://models.github.ai/inference with $GITHUB_TOKEN. See examples/.
