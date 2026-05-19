# BUILD 2026 demo scaffold

Drop-in devcontainer + repo scaffold for BUILD 2026 demo presenters. Designed
for **Windows + macOS local Docker Desktop** and **GitHub Codespaces** with
identical behavior on all three.

## What's Already In The Devcontainer

This starter is meant to answer the first demo question quickly: "does it
already have the stack I need?" The container includes these runtimes and demo
tooling out of the box:

- **Languages / runtimes**: Node.js, Python, Go, .NET, Java, Ruby, PHP, and C/C++
- **Package / version managers**: npm, pip, SDKMAN, nvm, rvm, and rbenv
- **GitHub demo tooling**: GitHub CLI, Copilot CLI, `@github/copilot-sdk` (npm), `github-copilot-sdk` (pip), and the `gh-codeql` extension
- **Container / repo tooling**: Docker-in-Docker, Git LFS, and VS Code Dev Containers support
- **VS Code extensions preconfigured in-container**: GitHub Copilot, Copilot Chat, GitHub Pull Requests, GitHub Actions, CodeQL, and Docker

If your demo depends on one of those stacks, you should be able to open the repo
in the container and start from a working baseline instead of provisioning tools
live on stage.

## Prerequisites

**Windows users**: Run this first in PowerShell as Administrator (sudo not supported):

```powershell
.\run-first-windows.ps1
```

This script automates the entire Windows prerequisite setup: WSL2 enablement, Docker Desktop installation and startup, Git, GitHub CLI, VS Code, and the Dev Containers extension. It handles retries for Windows features and Docker daemon readiness. If a restart is required, the script will tell you — restart and run it again.

**macOS users**: Run this first in Terminal:

```bash
bash run-first-mac.sh
```

This script automates the entire macOS prerequisite setup: Homebrew, Docker Desktop installation and startup, Git, GitHub CLI, VS Code, and the Dev Containers extension. It handles retries for Docker daemon readiness.

---

Your company-issued laptop image almost certainly already has these.

You need three components on the host machine:

- **VS Code** — verify from `Help → About`. If missing: https://code.visualstudio.com/
- **Dev Containers extension** — verify in the Extensions panel; install from
  the VS Code Marketplace if missing.
- **A container runtime**:
  - **macOS**: Docker Desktop. Verify with `docker --version` in Terminal. If
    missing: https://www.docker.com/products/docker-desktop/
  - **Windows**: WSL2 + Docker Desktop with the WSL2 backend enabled. 
    Verify with `wsl --status` and `docker --version` in PowerShell. 
    (The script above handles this automatically.)

**Zero-install path**: skip all of the above and use GitHub Codespaces from a
browser. Only needs a GitHub account with Codespaces access.

If your laptop is locked-down and the install requires admin, file a ticket
with IT — most companies have a standard "developer tooling" approval flow
that covers Docker Desktop and VS Code together.

## First-time setup

Same four steps on Windows and macOS:

1. **Generate a fine-grained PAT** at https://github.com/settings/personal-access-tokens/new
   — under *Account permissions*, set **Models → Read**. Pick an expiration past
   your demo date. Click *Generate token* and copy it.
2. **Create your `.env`**: `cp .devcontainer/.env.example .devcontainer/.env`
3. **Paste the token** after `GITHUB_TOKEN=` in `.devcontainer/.env` and save.
4. **Open the folder in VS Code** and click *Reopen in Container*. Then run
   `gh auth login` in the container terminal (one-time, for Path A).

That's it — `scripts/verify.sh` confirms everything is wired, `scripts/doctor.sh`
is the day-of pre-stage check.

**On Codespaces**: skip steps 2–3. Configure `GITHUB_TOKEN` as a Codespaces
user or repo secret instead (Settings → Codespaces → Codespaces secrets) — the
`secrets` block in `devcontainer.json` will prompt you.

## What's in here

```
.devcontainer/
  devcontainer.json      # base image + features + MCP + secrets layering
  setup.sh               # heavy installs (runs once during prebuild)
  .env.example           # template for GITHUB_TOKEN — copy to .env
.github/
  copilot-instructions.md      # repo-scoped Copilot behavior
  workflows/
    codeql.yml                 # GHAS / Autofix demos
    copilot-setup-steps.yml    # coding agent sandbox setup
.vscode/
  settings.json          # dev defaults (line numbers on, activity bar visible)
  profiles/
    demo.json            # profile config for live presentations and recordings
    default.json         # profile config for development work
examples/
  models_api.py          # Path B: GitHub Models direct REST (with offline mode)
  models_api_fixture.json # canned response for MODELS_OFFLINE=1
  copilot_sdk.py         # Path A: Copilot CLI SDK via JSON-RPC
scripts/
  setup-vscode-profiles.sh # initialize VS Code profiles (Demo and Default)
  verify.sh              # tooling smoke test (post-build)
  verify-manual.md       # human-only checks (VS Code, MCP, Path A)
  doctor.sh              # day-of pre-stage health check
  reset-demo.sh          # restore tracked files between demos
run-first-windows.ps1    # Windows setup automation: WSL2, Docker Desktop, Git, GitHub CLI, VS Code
run-first-mac.sh         # macOS setup automation: Homebrew, Docker Desktop, Git, GitHub CLI, VS Code
.gitignore               # ignores .env and other local-only files
.gitattributes           # line-ending normalization (Windows safety)
AGENTS.md                # custom agent definitions (Plan Mode)
```

## VS Code profiles: dev & demo modes

This repo includes two VS Code **profiles** that users switch between: one optimized for
development work, one for live presentations and recordings. This eliminates confusion about
why certain settings differ from standard VS Code when working on the demo itself.

### Setup (one-time)

From inside the dev container, run:

```bash
bash scripts/setup-vscode-profiles.sh
```

This creates two profiles in your local VS Code:
- **Demo** — optimized for projection screens and clean recordings
- **Default** — optimized for development work (line numbers on, activity bar visible)

### Switching profiles

From VS Code, open the Command Palette and run:

```
Profiles: Open Profile
```

Pick **Demo** before presenting, **Default** for development. Settings, colors, and font sizes
switch instantly.

### Demo profile settings

Optimized for on-stage visibility, recordings, and minimal distraction:

**Visual consistency:**
- **Editor font**: 16px Courier New (readable on projection screens and video)
- **Theme**: GitHub Light (high-contrast, records cleanly)
- **Line height**: 1.6 (breathing room for audience readability)
- **Word wrap**: 88 columns (Python PEP 8 alignment; prevents horizontal scrolling surprises)

**Distraction reduction** (less clutter on stage):
- **Hidden activity bar** — use Cmd/Ctrl+Shift+P for navigation instead
- **Hidden status bar** — suppresses environment info that might confuse audiences
- **No line numbers** — cleaner code view
- **No bracket colorization** — reduces syntax highlighting complexity for video encoding

**Recording optimization:**
- **Bracket pair guides active** (subtle hints without color)
- **Smooth scrolling enabled** (smoother video playback)
- **Preview tabs disabled** (no tab flickering during file opens)

**Extension defaults:**
- **Copilot Chat welcome notifications off** — no interruptions mid-demo
- **Copilot enable**: explicitly `true`

### Default profile settings

Optimized for productive development:

- **Font**: Standard size for comfortable long-term development
- **Theme**: Dark Modern (less eye strain during long work sessions)
- **UI**: Activity bar and status bar visible (full IDE functionality)
- **Editor**: Line numbers on, bracket colorization on, unwrapped lines, standard features enabled

## Two demo paths supported

1. **Copilot CLI / agent flows** — uses `@github/copilot-sdk` (npm, PyPI, Go,
   NuGet). The SDKs are JSON-RPC wrappers around the local `copilot` CLI; they
   are NOT generic model-API clients. Auth: `gh auth login` (browser OAuth).
2. **GitHub Models direct API** — `POST https://models.github.ai/inference/chat/completions`
   with `Authorization: Bearer $GITHUB_TOKEN`. Auth: the fine-grained PAT in
   `.devcontainer/.env`. No SDK; the call shape itself is the demo. Conference-
   WiFi fallback: `MODELS_OFFLINE=1 python examples/models_api.py` returns the
   checked-in fixture without an HTTP call.

## Cross-platform notes

- **Windows presenters**: Docker Desktop with WSL2 backend. **Clone the demo
  repo inside WSL2**, not on the Windows filesystem — bind-mount perf is ~10×
  worse otherwise.
- **macOS presenters**: enable VirtioFS in Docker Desktop → Settings → General.
  Works on Apple Silicon and Intel.
- **Codespaces**: works identically on both. Recommend enabling prebuilds
  (Settings → Codespaces → Prebuild configuration → trigger on push to default
  branch) so cold-start lands in 20–30s.

## Night-before runbook

Run through this the day before. Each item has caused a real demo failure.

- [ ] **Pre-pull the base image**: `docker pull mcr.microsoft.com/devcontainers/universal:6-noble`.
      A cold pull on venue WiFi is 5+ minutes of dead air.
- [ ] **Open the container once** to populate the build cache. Codespaces
      presenters: confirm a prebuild exists for the demo branch (badge in
      Settings → Codespaces).
- [ ] **Run `scripts/doctor.sh`** inside the container. Every line green.
- [ ] **Lock Docker Desktop's version** — do NOT update it within a week of
      stage. Updates have flipped VirtioFS settings off and made mounts 10×
      slower.
- [ ] **Disable VPN auto-start** on the demo laptop. VPN auto-reconnects mid-
      demo rewrite DNS and break Models endpoint resolution.
- [ ] **Backup laptop ready on the projector input**, already powered, signed
      in. Switching cables on stage is the single most common visible failure.
- [ ] **Rehearse with venue-WiFi off** at least once. Confirm `MODELS_OFFLINE=1`
      runs cleanly and your demo narrative still works on the fixture output.
- [ ] **Token check**: `scripts/doctor.sh` reports the token works. Note the
      PAT's expiration date — if it's within a week, regenerate now.

## Day-of stage moves

- **First slide**: run `scripts/doctor.sh` live. Audience sees green; you
  confirm the room's network reaches the endpoint.
- **Between demos**: `scripts/reset-demo.sh` restores tracked files (preserves
  `.devcontainer/.env` so you don't have to re-paste the token).
- **If a demo hangs mid-step**: switch to `MODELS_OFFLINE=1` and continue. Don't
  debug live — narrate "let's use the cached response" and move on.

## Troubleshooting

**`verify.sh` or `doctor.sh` reports 401.** Your PAT is the wrong *type*. GitHub
Models requires a **fine-grained** PAT, not a classic one. The page at
https://github.com/settings/tokens (classic) won't work. Use
https://github.com/settings/personal-access-tokens/new (fine-grained) and check
*Models → Read* under Account permissions.

**`verify.sh` or `doctor.sh` reports 403.** Your PAT is fine-grained (good) but
the Models:Read permission isn't checked. Regenerate it with that box ticked.

**Container won't start with "no such file: .env".** The `initializeCommand`
should auto-create `.devcontainer/.env` from the example, but if VS Code's pre-
start hook didn't run, do it manually: `cp .devcontainer/.env.example
.devcontainer/.env`, then *Reopen in Container*.

**Path B works but VS Code Copilot Chat says "not signed in".** That's
independent of `GITHUB_TOKEN`. Copilot Chat uses VS Code's own GitHub sign-in
— click the account icon in the bottom-left and sign in.

**`copilot_sdk.py` errors on import.** The Copilot SDK is in public preview;
class names may have shifted since the scaffold was written. The error message
will name the right symbol — adjust the import in `examples/copilot_sdk.py` and
re-run.

**On Windows, `setup.sh` errors with `\r: command not found`.** Your unzip tool
didn't honor `.gitattributes` line endings. Run `dos2unix .devcontainer/setup.sh
scripts/*.sh` from inside WSL2, then *Rebuild Container*.

**WSL2 clock drift after laptop sleep breaks token auth.** Symptom: tokens that
worked yesterday return 401 today on a freshly-resumed Windows laptop. Fix in
PowerShell: `wsl --shutdown`, then re-open the WSL2 shell. Mid-stage recovery is
the same one command.

**Codespaces cold-start is taking 5+ minutes.** Prebuilds aren't enabled yet on
the repo. Settings → Codespaces → Prebuild configuration → trigger on push to
default branch. After the first prebuild build completes, subsequent starts
land in 20–30 seconds.

## Things the presenter still owns

- Filling in `.github/copilot-instructions.md` with repo-specific guidance.
- Filling in `AGENTS.md` with any custom agents their demo needs.
- Adjusting the CodeQL `matrix.language` list to the demo's languages.
- Per-project Go (`go get github.com/github/copilot-sdk/go`) and .NET
  (`dotnet add package GitHub.Copilot.SDK`) installs — they're project-scoped,
  not global.
- Recording asciinema casts of each demo as a fallback. Suggested filenames:
  `demos/<demo-name>.cast`. Ship them in the demo repo so `MODELS_OFFLINE=1` is
  the second-line-of-defense and the cast is the last.
