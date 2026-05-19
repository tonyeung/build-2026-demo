# run-first-windows.ps1
# Run in elevated PowerShell (Run as Administrator)

$ErrorActionPreference = "Stop"

function Write-Step($msg) {
    Write-Host "`n==> $msg" -ForegroundColor Cyan
}

function Test-IsAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($id)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Ensure-WindowsFeature {
    param(
        [Parameter(Mandatory = $true)][string]$FeatureName
    )

    $output = & dism.exe /Online /Get-FeatureInfo /FeatureName:$FeatureName 2>&1
    if ($output -like "*State : Enabled*") {
        Write-Host "Feature already enabled: $FeatureName"
        return $false
    }

    Write-Step "Enabling Windows feature: $FeatureName"
    & dism.exe /Online /Enable-Feature /FeatureName:$FeatureName /NoRestart | Out-Null
    return $true
}

function Test-CommandExists {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

if (-not (Test-IsAdmin)) {
    throw "Please run this script as Administrator."
}

$needsRestart = $false

Write-Step "Checking required virtualization features for WSL2"
$needsRestart = (Ensure-WindowsFeature -FeatureName "Microsoft-Windows-Subsystem-Linux") -or $needsRestart
$needsRestart = (Ensure-WindowsFeature -FeatureName "VirtualMachinePlatform") -or $needsRestart

Write-Step "Checking WSL installation"
if (-not (Test-CommandExists "wsl.exe")) {
    Write-Step "WSL command not found. Installing WSL core..."
    # --no-distribution installs WSL components without pulling Linux distro immediately
    wsl --install --no-distribution
    $needsRestart = $true
} else {
    Write-Host "WSL command found."
}

Write-Step "Configuring WSL defaults"
# This can fail if restart is pending; we'll handle that with guidance below
try {
    wsl --set-default-version 2
    Write-Host "Set WSL default version to 2."
} catch {
    Write-Warning "Could not set default WSL version yet (often due to pending restart)."
}

Write-Step "Ensuring at least one Linux distro is installed (Ubuntu)"
$distroList = @()
try {
    $distroList = (wsl --list --quiet) | Where-Object { $_ -and $_.Trim() -ne "" }
} catch {
    Write-Warning "Could not query distro list yet."
}

if ($distroList.Count -eq 0) {
    try {
        Write-Step "Installing Ubuntu (first run may take 2-3 minutes)..."
        wsl --install -d Ubuntu --no-launch
        
        Write-Step "Configuring default user non-interactively..."
        # Create user account and configure sudoers without interactive prompt
        $username = $Env:USERNAME
        wsl -d Ubuntu -u root -- bash -c @"
useradd -m -s /bin/bash $username 2>/dev/null || true
echo '$username ALL=(ALL) NOPASSWD:ALL' | tee -a /etc/sudoers > /dev/null 2>&1 || true
"@
        Write-Host "Ubuntu installed and configured."
    } catch {
        Write-Warning "Ubuntu install could not complete now. You may need to rerun after restart."
    }
} else {
    Write-Host "Existing WSL distro(s): $($distroList -join ', ')"
}

Write-Step "Checking Docker Desktop installation"
$dockerCli = Get-Command docker -ErrorAction SilentlyContinue
$dockerDesktopExe = "$Env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
$dockerCliExe = "$Env:ProgramFiles\Docker\Docker\DockerCli.exe"

if (-not $dockerCli -and -not (Test-Path $dockerDesktopExe)) {
    Write-Step "Docker not found. Installing Docker Desktop via winget..."
    if (-not (Test-CommandExists "winget.exe")) {
        throw "winget is not available. Install App Installer from Microsoft Store, then rerun."
    }

    winget install -e --id Docker.DockerDesktop --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "Docker appears installed."
}

Write-Step "Adding current user to docker-users group (if needed)"
try {
    $result = & net localgroup docker-users $Env:USERNAME /add 2>&1
    if ($result -match "already a member") {
        Write-Host "User already in docker-users group."
    } else {
        Write-Host "User ensured in docker-users group."
    }
} catch {
    Write-Warning "Could not add user to docker-users group (may already exist or require logoff)."
}

Write-Step "Starting Docker Desktop"
if (Test-Path $dockerDesktopExe) {
    Start-Process -FilePath $dockerDesktopExe | Out-Null
    Write-Host "Docker Desktop started."
} else {
    Write-Warning "Docker Desktop executable not found yet."
}

Write-Step "Waiting for Docker daemon (up to 2 minutes)"
$ready = $false
$timeout = 120
$elapsed = 0
while ($elapsed -lt $timeout) {
    docker info 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $ready = $true
        break
    }
    Start-Sleep -Seconds 5
    $elapsed += 5
}

if ($ready) {
    Write-Host "Docker daemon is ready." -ForegroundColor Green
    docker version --format "Server: {{.Server.Version}}"
} else {
    Write-Warning @"
Docker daemon not ready after 2 minutes. This usually means one of:

  1. First-run wizard not completed
     -> Open Docker Desktop from the Start menu, accept the EULA,
        and wait for the whale icon to stop animating.

  2. WSL2 backend not provisioned (Windows features were just enabled)
     -> Restart Windows.

  3. Your user is not yet in the 'docker-users' group
     -> Sign out of Windows and sign back in.

After resolving, rerun this script in an elevated PowerShell.
"@
}

Write-Step "Checking Git for Windows installation"
if (-not (Test-CommandExists "git.exe")) {
    Write-Step "Installing Git for Windows..."
    winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "Git already installed."
}

Write-Step "Checking GitHub CLI installation"
if (-not (Test-CommandExists "gh.exe")) {
    Write-Step "Installing GitHub CLI..."
    winget install -e --id GitHub.cli --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "GitHub CLI already installed."
}

Write-Step "Checking VS Code installation"
if (-not (Test-CommandExists "code.exe")) {
    Write-Step "Installing VS Code..."
    winget install -e --id Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "VS Code already installed."
}

Write-Step "Checking Dev Containers extension"
if (Test-CommandExists "code.exe") {
    # Install the extension if not already present
    code --install-extension ms-vscode-remote.remote-containers | Out-Null
    Write-Host "Dev Containers extension installed/ensured."
} else {
    Write-Warning "VS Code not available yet; Dev Containers extension will need to be installed manually or after restart."
}

if ($needsRestart) {
    Write-Warning "A restart is required to finish setup. Restart Windows, then rerun this script once."
} else {
    Write-Host "`nSetup completed. If Docker commands fail, sign out/in or restart once." -ForegroundColor Green
}

Write-Host "`nIMPORTANT: If VS Code is open, fully restart it to pick up Git/GitHub CLI in PATH." -ForegroundColor Yellow