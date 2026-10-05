<#
.SYNOPSIS
    Deploys website updates from 'dev' branch to the live GitHub repository ('live' remote / main branch).
.DESCRIPTION
    Ensures 'RGBDRIVE-V2-OVERVIEW.md' and local development files are excluded from the public GitHub repository.
    Syncs website files to 'main', commits, pushes to GitHub ('live') and Gitea ('origin'), then returns to 'dev'.
#>
param(
    [string]$Message = "Publish website update"
)

$ErrorActionPreference = "Stop"

# 1. Ensure we are currently on the 'dev' branch
$currentBranch = (git branch --show-current).Trim()
if ($currentBranch -ne "dev") {
    Write-Host "[ERROR] Please switch to the 'dev' branch before deploying." -ForegroundColor Red
    exit 1
}

# 2. Check for uncommitted working tree changes
$dirty = (git status --porcelain)
if ($dirty) {
    Write-Host "[WARNING] You have uncommitted changes on 'dev'." -ForegroundColor Yellow
    Write-Host "Please commit your changes to 'dev' (and push to Gitea) before deploying." -ForegroundColor Yellow
    exit 1
}

Write-Host "`n>>> Starting Deployment: dev -> main (GitHub live) <<<" -ForegroundColor Cyan

# 3. Switch to main
git checkout main

# 4. Copy all website files from dev into main
git checkout dev -- .

# 5. Remove internal development overview so it NEVER exists on main/GitHub
if (Test-Path "RGBDRIVE-V2-OVERVIEW.md") {
    git reset HEAD "RGBDRIVE-V2-OVERVIEW.md" 2>$null | Out-Null
    Remove-Item "RGBDRIVE-V2-OVERVIEW.md" -Force
}

# 6. Check if there are changes to deploy
$diff = (git status --porcelain)
if ($diff) {
    git add -A
    git commit -m "$Message"
    Write-Host "`n>>> Pushing to GitHub Pages ('live' remote)..." -ForegroundColor Cyan
    git push live main
    Write-Host ">>> Updating 'main' on local Gitea ('origin' remote)..." -ForegroundColor Cyan
    git push origin main
    Write-Host "`n[SUCCESS] Deployed successfully to rgbdrive.com via GitHub Pages!" -ForegroundColor Green
} else {
    Write-Host "`n[INFO] No changes detected between 'dev' and 'main'. Live site is already up to date." -ForegroundColor Yellow
}

# 7. Switch back to dev branch
git checkout dev
Write-Host ">>> Returned to 'dev' branch for everyday editing.`n" -ForegroundColor Cyan
