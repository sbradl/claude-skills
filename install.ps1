# Install the claude-skills into .\.claude\skills\ in the current directory.
# Usage:  irm https://raw.githubusercontent.com/sbradl/claude-skills/main/install.ps1 | iex
$ErrorActionPreference = 'Stop'

$repo   = 'sbradl/claude-skills'
$branch = 'main'
$dest   = Join-Path (Get-Location) '.claude\skills'

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("claude-skills-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
    $zip = Join-Path $tmp 'archive.zip'
    Write-Host "Downloading $repo@$branch ..."
    Invoke-WebRequest -Uri "https://github.com/$repo/archive/refs/heads/$branch.zip" -OutFile $zip

    Expand-Archive -Path $zip -DestinationPath $tmp -Force

    $src = Join-Path $tmp "claude-skills-$branch\.claude\skills"
    if (-not (Test-Path $src)) { throw "skills directory not found in archive" }

    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    Copy-Item -Path (Join-Path $src '*') -Destination $dest -Recurse -Force

    Write-Host "Installed skills into $dest:"
    Get-ChildItem -Name $dest
}
finally {
    Remove-Item -Recurse -Force $tmp
}
