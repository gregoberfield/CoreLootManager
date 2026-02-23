<#
.SYNOPSIS
    Fetches external library dependencies for local CLM development.

.DESCRIPTION
    Mirrors what the BigWigs packager does with .pkgmeta when building a release.
    GitHub-hosted libs are downloaded as zip archives (no extra tools needed).
    WoWAce/CurseForge SVN libs require 'svn.exe' on the PATH (see below).

.NOTES
    Run from the repo root:
        .\scripts\fetch_externals.ps1

    SVN requirement:
        Install standalone SVN from https://www.visualsvn.com/downloads/#commandline
        (the "Apache Subversion command line tools") or via Chocolatey:
            choco install svn
        TortoiseSVN also installs svn.exe if you enable "command line tools" during setup.

    The BigWigs packager (used in CI) is the authoritative fetcher. You can also run
    it locally in WSL or Git Bash:
        bash scripts/release.sh -d -o -u -m .pkgmeta -S
#>

$ErrorActionPreference = "Stop"

$repoRoot  = Split-Path -Parent $PSScriptRoot
$libsDir   = Join-Path $repoRoot "ClassicLootManager\Libs"

function Get-GitHubLib {
    param(
        [string]$DestName,       # folder name inside Libs/
        [string]$ZipUrl,         # GitHub archive zip URL
        [string]$InnerFolder     # top-level folder name inside the zip
    )
    $dest = Join-Path $libsDir $DestName
    if (Test-Path $dest) {
        Write-Host "  [skip] $DestName already present." -ForegroundColor Gray
        return
    }
    $tmp = [System.IO.Path]::GetTempFileName() + ".zip"
    Write-Host "  [fetch] $DestName <- $ZipUrl" -ForegroundColor Cyan
    try {
        Invoke-WebRequest -Uri $ZipUrl -OutFile $tmp -UseBasicParsing
        $expandDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        Expand-Archive -LiteralPath $tmp -DestinationPath $expandDir -Force
        # The zip contains a single top-level folder (repo-name-tag); move it to dest.
        $inner = Join-Path $expandDir $InnerFolder
        if (-not (Test-Path $inner)) {
            # Fall back: pick whatever single subdirectory was extracted
            $inner = (Get-ChildItem $expandDir -Directory | Select-Object -First 1).FullName
        }
        Move-Item -LiteralPath $inner -Destination $dest
        Write-Host "  [ok]    $DestName" -ForegroundColor Green
    } finally {
        Remove-Item $tmp -ErrorAction SilentlyContinue
    }
}

function Get-SvnLib {
    param(
        [string]$DestName,   # folder name inside Libs/
        [string]$SvnUrl      # SVN URL to export (trunk or tag path)
    )
    $dest = Join-Path $libsDir $DestName
    if (Test-Path $dest) {
        Write-Host "  [skip] $DestName already present." -ForegroundColor Gray
        return
    }
    if (-not (Get-Command svn -ErrorAction SilentlyContinue)) {
        Write-Warning "svn not found — skipping $DestName. Install SVN and re-run."
        return
    }
    Write-Host "  [svn]  $DestName <- $SvnUrl" -ForegroundColor Cyan
    svn export --non-interactive $SvnUrl $dest
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [ok]   $DestName" -ForegroundColor Green
    } else {
        Write-Warning "svn export failed for $DestName (exit $LASTEXITCODE)"
    }
}

Write-Host "`nFetching CLM external libraries into: $libsDir`n" -ForegroundColor Yellow

# ---------------------------------------------------------------------------
# GitHub-hosted libs  (Invoke-WebRequest, no extra tools required)
# ---------------------------------------------------------------------------
# InnerFolder must match the folder name GitHub creates inside the zip archive.
# Pattern: <RepoName>-<TagName>  (slashes and dots become dashes in some cases)

Get-GitHubLib `
    -DestName    "LibDeflate" `
    -ZipUrl      "https://github.com/SafeteeWoW/LibDeflate/archive/refs/tags/1.0.2-release.zip" `
    -InnerFolder "LibDeflate-1.0.2-release"

Get-GitHubLib `
    -DestName    "LibSerialize" `
    -ZipUrl      "https://github.com/rossnichols/LibSerialize/archive/refs/tags/v1.1.3.zip" `
    -InnerFolder "LibSerialize-1.1.3"

Get-GitHubLib `
    -DestName    "LibLogger" `
    -ZipUrl      "https://github.com/lantisnt/LibLogger/archive/refs/tags/v1.2.1.zip" `
    -InnerFolder "LibLogger-1.2.1"

Get-GitHubLib `
    -DestName    "lib-st" `
    -ZipUrl      "https://github.com/ddumont/lib-st/archive/refs/tags/v4.1.3.zip" `
    -InnerFolder "lib-st-4.1.3"

# ---------------------------------------------------------------------------
# WoWAce SVN libs  (requires svn.exe on PATH)
# ---------------------------------------------------------------------------
# These are the same SVN URLs listed in .pkgmeta.
# Anonymous read access to repos.wowace.com / repos.curseforge.com is public.

Get-SvnLib `
    -DestName "LibStub" `
    -SvnUrl   "https://repos.wowace.com/wow/libstub/trunk"

Get-SvnLib `
    -DestName "CallbackHandler-1.0" `
    -SvnUrl   "https://repos.wowace.com/wow/callbackhandler/trunk/CallbackHandler-1.0"

Get-SvnLib `
    -DestName "Ace3" `
    -SvnUrl   "https://repos.wowace.com/wow/ace3/trunk"

Get-SvnLib `
    -DestName "LibCandyBar-3.0" `
    -SvnUrl   "https://repos.wowace.com/wow/libcandybar-3-0/trunk"

Get-SvnLib `
    -DestName "LibDBIcon-1.0" `
    -SvnUrl   "https://repos.wowace.com/wow/libdbicon-1-0/trunk"

Get-SvnLib `
    -DestName "LibUIDropDownMenu" `
    -SvnUrl   "https://repos.wowace.com/wow/libuidropdownmenu/trunk"

Get-SvnLib `
    -DestName "LibSharedMedia-3.0" `
    -SvnUrl   "https://repos.curseforge.com/wow/libsharedmedia-3-0/trunk/LibSharedMedia-3.0"

Get-SvnLib `
    -DestName "AceGUI-3.0-SharedMediaWidgets" `
    -SvnUrl   "https://repos.curseforge.com/wow/ace-gui-3-0-shared-media-widgets/trunk/AceGUI-3.0-SharedMediaWidgets"

Write-Host "`nDone. Re-deploy to your WoW AddOns folder and reload UI.`n" -ForegroundColor Yellow
