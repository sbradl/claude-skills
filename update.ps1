# Update the claude-skills in .\.claude\skills\ to the latest version.
# Replaces the skill directories in place; leaves the rest of .\.claude alone.
# Usage:  irm https://raw.githubusercontent.com/sbradl/claude-skills/main/update.ps1 | iex
#         & ([scriptblock]::Create((irm https://raw.githubusercontent.com/sbradl/claude-skills/main/update.ps1))) tdd craft-review
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
