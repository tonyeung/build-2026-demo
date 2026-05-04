# Manual verification

`verify.sh` covers the headless checks. These need a human eye on VS Code.

## 1. Extensions installed

Open the Extensions panel (Ctrl/Cmd+Shift+X) and filter to "Installed". Confirm all six:

- [ ] GitHub Copilot
- [ ] GitHub Copilot Chat
- [ ] GitHub Pull Requests
- [ ] GitHub Actions
- [ ] CodeQL
- [ ] Docker

## 2. Copilot Chat reaches the model

Open Copilot Chat (Ctrl/Cmd+Alt+I). Send: `what files are in this repo?`

Pass = it lists files from the workspace within ~5s. If it errors with "not signed in", run `gh auth login` in the terminal first.

## 3. MCP server connected

In Copilot Chat, click the tools/agent picker (varies by VS Code version — usually a tool icon near the input). Look for a `github` MCP provider with tools like `search_repositories`, `get_pull_request`, etc.

Pass = github MCP tools appear in the picker.

If they don't: open the Output panel → "GitHub Copilot Chat" channel. Look for MCP startup logs. The most common failure is the `customizations.vscode.mcp` block being misread; verify devcontainer.json wasn't reformatted on save.

## 4. Path A end-to-end (Copilot SDK)

In the integrated terminal:

```
gh auth login          # one-time, choose GitHub.com → HTTPS → Login with web browser
python3 examples/copilot_sdk.py
```

Pass = the script prints a streaming response from the local Copilot CLI within ~10s.

## 5. Cross-platform parity

Compare what you saw on Windows vs macOS:

- [ ] Container build wall-clock within 30% of each other
- [ ] All six VS Code extensions show "Installed" on both
- [ ] `verify.sh` output identical (modulo version-string whitespace)
- [ ] Path B example printed a full response on both
- [ ] MCP tools list identical on both
- [ ] No Windows line-ending complaints in `setup.sh` output (look for `\r: command not found`)

If any of these diverge, that's the bug to fix before handoff.
