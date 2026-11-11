<#
.SYNOPSIS
    Deploys website updates from 'dev' branch to the live GitHub repository ('live' remote / main branch).
.DESCRIPTION
    Syncs website files in 'docs/' and 'README.md' from 'dev' to 'main',
    strictly excluding internal operational documentation ('DEV-DOCS.md').
    GitHub Pages serves directly from the '/docs' folder on 'main'.
    Pushes 'main' to GitHub ('live') and Gitea ('origin'), then returns to 'dev'.
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

Write-Host "`n>>> Starting Deployment: dev -> main (GitHub Pages /docs) <<<" -ForegroundColor Cyan

# 3. Switch to main
git checkout main

# 4. Clean root on main and mirror exact state from dev
Get-ChildItem -Path . -Exclude ".git" | Remove-Item -Recurse -Force
git checkout dev -- .

# 5. Remove internal operational documentation so it NEVER exists on main/GitHub
$internalDocs = @("DEV-DOCS.md", "RGBDRIVE-V2-OVERVIEW.md", "PROJECT-OPERATIONS-LOG.md")
foreach ($doc in $internalDocs) {
    if (Test-Path $doc) {
        git reset HEAD $doc 2>$null | Out-Null
        Remove-Item $doc -Force
    }
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
    Write-Host "`n[SUCCESS] Deployed successfully to rgbdrive.com via GitHub Pages (/docs)!" -ForegroundColor Green
} else {
    Write-Host "`n[INFO] No changes detected between 'dev' and 'main'. Live site is already up to date." -ForegroundColor Yellow
}

# 7. Switch back to dev branch
git checkout dev
Write-Host ">>> Returned to 'dev' branch for everyday editing.`n" -ForegroundColor Cyan
