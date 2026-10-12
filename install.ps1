# Install the claude-skills into .\.claude\skills\ in the current directory.
# Usage:  irm https://raw.githubusercontent.com/sbradl/claude-skills/main/install.ps1 | iex
#         & ([scriptblock]::Create((irm https://raw.githubusercontent.com/sbradl/claude-skills/main/install.ps1))) tdd craft-review
# Arguments name skill groups (directories under skills\); none means all.
param([Parameter(ValueFromRemainingArguments)][string[]]$Group)
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

    $src = Join-Path $tmp "claude-skills-$branch\skills"
    if (-not (Test-Path $src)) { throw "skills directory not found in archive" }

    $available = Get-ChildItem -Directory -Name $src
    if (-not $Group) { $Group = $available }
    foreach ($g in $Group) {
        if ($available -notcontains $g) { throw "no skill group '$g' (available: $($available -join ' '))" }
    }

    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    foreach ($g in $Group) {
        Copy-Item -Path (Join-Path $src "$g\*") -Destination $dest -Recurse -Force
    }

    Write-Host "Installed skills into $dest:"
    Get-ChildItem -Name $dest
}
finally {
    Remove-Item -Recurse -Force $tmp
}
