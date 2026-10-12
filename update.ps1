# Update the claude-skills in .\.claude\skills\ to the latest release.
# Replaces the skill directories in place; leaves the rest of .\.claude alone.
# Usage:  irm https://raw.githubusercontent.com/sbradl/claude-skills/main/update.ps1 | iex
#         & ([scriptblock]::Create((irm https://raw.githubusercontent.com/sbradl/claude-skills/main/update.ps1))) -Ref v2.1.4 tdd craft-review
# -Ref takes a release tag, or a branch (main for the development version).
# Arguments name skill groups (directories under skills\); none means every
# group with at least one skill already installed.
[CmdletBinding(PositionalBinding = $false)]
param(
    [string]$Ref,
    [Parameter(ValueFromRemainingArguments)][string[]]$Group
)
$ErrorActionPreference = 'Stop'

$repo = 'sbradl/claude-skills'
$dest = Join-Path (Get-Location) '.claude\skills'

if (-not $Ref) {
    try { $Ref = (Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest").tag_name }
    catch { throw "no release found; pass -Ref main for the development version" }
}

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("claude-skills-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
    $zip = Join-Path $tmp 'archive.zip'
    Write-Host "Downloading $repo@$Ref ..."
    Invoke-WebRequest -Uri "https://github.com/$repo/archive/$Ref.zip" -OutFile $zip

    Expand-Archive -Path $zip -DestinationPath $tmp -Force

    # The archive holds one top-level directory, named after the repo and ref.
    $root = Get-ChildItem -Directory $tmp | Select-Object -First 1
    $src = Join-Path $root.FullName 'skills'
    if (-not (Test-Path $src)) { throw "skills directory not found in archive" }

    $available = Get-ChildItem -Directory -Name $src
    if (-not $Group) {
        $Group = @($available | Where-Object {
            @(Get-ChildItem -Directory -Name (Join-Path $src $_)) |
                Where-Object { Test-Path (Join-Path $dest $_) }
        })
        if (-not $Group) { throw "no installed skill groups in $dest; run install.ps1 first" }
    }
    foreach ($g in $Group) {
        if ($available -notcontains $g) { throw "no skill group '$g' (available: $($available -join ' '))" }
    }

    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    foreach ($g in $Group) {
        # Replace each skill directory wholesale so renamed or deleted files
        # inside it don't linger.
        foreach ($d in Get-ChildItem -Directory (Join-Path $src $g)) {
            $target = Join-Path $dest $d.Name
            if (Test-Path $target) { Remove-Item -Recurse -Force $target }
        }
        Copy-Item -Path (Join-Path $src "$g\*") -Destination $dest -Recurse -Force
    }

    Write-Host "Updated skills in $dest:"
    Get-ChildItem -Name $dest
}
finally {
    Remove-Item -Recurse -Force $tmp
}
