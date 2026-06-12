# AI Share Memory — Setup Script
# OpenClaw x Claude Code Shared Handoff Workflow

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  AI Share Memory — Setup" -ForegroundColor Cyan
Write-Host "  OpenClaw x Claude Code Handoff" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will:" -ForegroundColor White
Write-Host "  1. Create share files in your OpenClaw workspace" -ForegroundColor Gray
Write-Host "  2. Copy CLAUDE.md rules to your Claude Code project" -ForegroundColor Gray
Write-Host "  3. Configure Claude Code Stop hook (exit reminder)" -ForegroundColor Gray
Write-Host ""

# ============================================================
# Step 1: Detect / ask for OpenClaw workspace path
# ============================================================
Write-Host "---- Step 1/4: OpenClaw workspace path ----" -ForegroundColor Yellow
Write-Host ""

$defaultOpenclawWorkspace = "$env:USERPROFILE\.openclaw\workspace"
if (Test-Path $defaultOpenclawWorkspace) {
    Write-Host "  Detected: $defaultOpenclawWorkspace" -ForegroundColor Green
    $useDefault = Read-Host "  Use this path? (Y/n)"
    if ($useDefault -eq "" -or $useDefault -eq "Y" -or $useDefault -eq "y") {
        $openclawWorkspace = $defaultOpenclawWorkspace
    } else {
        $openclawWorkspace = Read-Host "  Enter full path to OpenClaw workspace"
    }
} else {
    Write-Host "  Default path not found" -ForegroundColor DarkYellow
    $openclawWorkspace = Read-Host "  Enter full path to OpenClaw workspace (e.g. C:\Users\you\.openclaw\workspace)"
}

if (-not (Test-Path $openclawWorkspace)) {
    Write-Host ""
    Write-Host "  Path does not exist. Create it? (y/N)" -ForegroundColor Yellow
    $create = Read-Host "  "
    if ($create -eq "Y" -or $create -eq "y") {
        New-Item -ItemType Directory -Force -Path $openclawWorkspace | Out-Null
        Write-Host "  Created" -ForegroundColor Green
    } else {
        Write-Host "  Canceled" -ForegroundColor Red
        exit 0
    }
}

# ============================================================
# Step 2: Detect / ask for Claude Code project path
# ============================================================
Write-Host ""
Write-Host "---- Step 2/4: Claude Code project path ----" -ForegroundColor Yellow
Write-Host ""
Write-Host "  This is the directory where you run Claude Code." -ForegroundColor Gray
Write-Host "  (the one that contains the .claude folder)" -ForegroundColor Gray
Write-Host ""

# Try to auto-detect projects with .claude/ directory
$foundProjects = @()
$searchPaths = @(
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Projects"
)
foreach ($searchPath in $searchPaths) {
    if (Test-Path $searchPath) {
        $subdirs = Get-ChildItem -Path $searchPath -Directory -ErrorAction SilentlyContinue | Select-Object -First 20
        foreach ($subdir in $subdirs) {
            if (Test-Path (Join-Path $subdir.FullName ".claude")) {
                $foundProjects += $subdir.FullName
            }
        }
    }
}

if ($foundProjects.Count -gt 0) {
    Write-Host "  Detected Claude Code projects:" -ForegroundColor Green
    for ($i = 0; $i -lt $foundProjects.Count; $i++) {
        Write-Host "    [$($i+1)] $($foundProjects[$i])" -ForegroundColor White
    }
    Write-Host "    [0] Enter path manually" -ForegroundColor Gray
    Write-Host ""
    $choice = Read-Host "  Select project number"
    $choiceNum = [int]$choice
    if ($choiceNum -ge 1 -and $choiceNum -le $foundProjects.Count) {
        $claudeProject = $foundProjects[$choiceNum - 1]
    } else {
        $claudeProject = Read-Host "  Enter full path to Claude Code project"
    }
} else {
    $claudeProject = Read-Host "  Enter full path to Claude Code project"
}

$claudeDir = Join-Path $claudeProject ".claude"
if (-not (Test-Path $claudeDir)) {
    Write-Host ""
    Write-Host "  .claude directory not found. Create it? (y/N)" -ForegroundColor Yellow
    $create = Read-Host "  "
    if ($create -eq "Y" -or $create -eq "y") {
        New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null
        Write-Host "  Created" -ForegroundColor Green
    } else {
        Write-Host "  Canceled" -ForegroundColor Red
        exit 0
    }
}

# ============================================================
# Step 3: Create share files + copy CLAUDE.md
# ============================================================
Write-Host ""
Write-Host "---- Step 3/4: Deploy files ----" -ForegroundColor Yellow
Write-Host ""

# Create share files from templates
$shareFiles = @("share_main.md", "share_vision.md", "share_yckz.md")
foreach ($file in $shareFiles) {
    $targetPath = Join-Path $openclawWorkspace $file
    if (Test-Path $targetPath) {
        Write-Host "  $file already exists, skipped" -ForegroundColor DarkYellow
    } else {
        $templatePath = Join-Path $scriptDir "templates\$file"
        if (Test-Path $templatePath) {
            Copy-Item $templatePath $targetPath
        } else {
            # Fallback: create from inline content (English only to avoid encoding issues)
            $agentName = ($file -replace "share_","" -replace "\.md","")
            $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
            $content = @"
# $file - OpenClaw ${agentName} agent x Claude Code shared memory
# Rules: append only, with timestamps. Use agent field to distinguish source.

---
agent: system
timestamp: $timestamp
status: init
---

## Current Status
Shared memory system initialized. ${agentName} agent ready.

## Changes Made
- Created $file - initialization

## Key Decisions
- Adopted OpenClaw x Claude Code shared memory handoff protocol
- ${agentName} agent has its own share file, isolated from other agents

## Pending / Blocked
- [ ] First real collaboration task

## Notes for Collaboration Partner
This is the ${agentName} agent shared memory. Append entries using this template for important operations.
"@
            $content | Out-File $targetPath -Encoding UTF8
        }
        Write-Host "  $file created" -ForegroundColor Green
    }
}

# Copy CLAUDE.md
$claudeMdSource = Join-Path $scriptDir "templates\CLAUDE.md"
$claudeMdTarget = Join-Path $claudeDir "CLAUDE.md"

if (Test-Path $claudeMdTarget) {
    Write-Host "  CLAUDE.md already exists" -ForegroundColor DarkYellow
    $backup = Read-Host "  Overwrite? Existing file will be backed up (y/N)"
    if ($backup -eq "Y" -or $backup -eq "y") {
        Copy-Item $claudeMdTarget "$claudeMdTarget.bak" -Force
        Copy-Item $claudeMdSource $claudeMdTarget -Force
        Write-Host "  CLAUDE.md updated (original backed up as .bak)" -ForegroundColor Green
    } else {
        Write-Host "  Kept existing CLAUDE.md" -ForegroundColor DarkYellow
    }
} else {
    Copy-Item $claudeMdSource $claudeMdTarget
    Write-Host "  CLAUDE.md copied" -ForegroundColor Green
}

# ============================================================
# Step 4: Configure Stop hook
# ============================================================
Write-Host ""
Write-Host "---- Step 4/4: Configure Stop Hook ----" -ForegroundColor Yellow
Write-Host ""

$settingsPath = Join-Path $claudeDir "settings.local.json"

# Read or initialize settings
$settings = $null
if (Test-Path $settingsPath) {
    try {
        $settings = Get-Content $settingsPath -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction Stop
    } catch {
        Write-Host "  Warning: Could not parse settings.local.json (encoding issue), treating as empty" -ForegroundColor DarkYellow
        $settings = $null
    }
}
if (-not $settings) {
    $settings = [PSCustomObject]@{}
}

# Check if Stop hook already exists
$hasStopHook = $false
if ($settings.PSObject.Properties.Name -contains "hooks") {
    if ($settings.hooks.PSObject.Properties.Name -contains "Stop") {
        $hasStopHook = $true
    }
}

if ($hasStopHook) {
    Write-Host "  Stop hook already exists, skipped" -ForegroundColor DarkYellow
} else {
    # Read hook JSON template
    $hookJsonPath = Join-Path $scriptDir "hooks\stop-hook.json"
    $hookConfig = Get-Content $hookJsonPath -Raw | ConvertFrom-Json

    # Merge into settings
    if (-not ($settings.PSObject.Properties.Name -contains "hooks")) {
        $settings | Add-Member -MemberType NoteProperty -Name "hooks" -Value ([PSCustomObject]@{})
    }
    $settings.hooks | Add-Member -MemberType NoteProperty -Name "Stop" -Value $hookConfig.Stop -Force

    # Write back
    $settings | ConvertTo-Json -Depth 10 | Out-File $settingsPath -Encoding UTF8
    Write-Host "  Stop hook configured" -ForegroundColor Green
}

# ============================================================
# Done
# ============================================================
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Files deployed:" -ForegroundColor White
Write-Host "    OpenClaw workspace: $openclawWorkspace" -ForegroundColor Gray
Write-Host "      share_main.md" -ForegroundColor Gray
Write-Host "      share_vision.md" -ForegroundColor Gray
Write-Host "      share_yckz.md" -ForegroundColor Gray
Write-Host "    Claude Code project: $claudeProject" -ForegroundColor Gray
Write-Host "      .claude\CLAUDE.md" -ForegroundColor Gray
Write-Host "      .claude\settings.local.json (Stop hook)" -ForegroundColor Gray
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Host "    1. In OpenClaw, write a test entry to share_main.md" -ForegroundColor Gray
Write-Host "    2. In Claude Code, type: read share_main" -ForegroundColor Gray
Write-Host "    3. Claude reads and appends a response" -ForegroundColor Gray
Write-Host "    4. Switch back to OpenClaw to confirm the loop" -ForegroundColor Gray
Write-Host ""
Write-Host "  See README.md for full documentation." -ForegroundColor DarkGray
Write-Host ""
