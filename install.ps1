# Install the claude-skills into .\.claude\skills\ in the current directory.
# Usage:  irm https://raw.githubusercontent.com/sbradl/claude-skills/main/install.ps1 | iex
#         & ([scriptblock]::Create((irm https://raw.githubusercontent.com/sbradl/claude-skills/main/install.ps1))) -Ref v2.1.4 tdd craft-review
# Installs the latest release; -Ref takes a release tag, or a branch (main for
# the development version). Arguments name skill groups (directories under
# skills\); none means pick from a checklist.
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

    $available = @(Get-ChildItem -Directory -Name $src)
    if (-not $Group) {
        # Checklist: up/down (or k/j) move, space toggles, enter confirms.
        $n = $available.Count
        $on = @($false) * $n
        $cur = 0
        Write-Host 'Select skill groups (up/down move, space toggles, enter confirms):'
        $top = [Console]::CursorTop
        [Console]::CursorVisible = $false
        try {
            :pick while ($true) {
                [Console]::SetCursorPosition(0, $top)
                for ($i = 0; $i -lt $n; $i++) {
                    $mark = if ($i -eq $cur) { '>' } else { ' ' }
                    $box = if ($on[$i]) { '[x]' } else { '[ ]' }
                    $skills = (Get-ChildItem -Directory -Name (Join-Path $src $available[$i])) -join ' '
                    Write-Host "$mark $box $($available[$i]) ($skills)"
                }
                # Writing past the bottom scrolls the console; re-anchor.
                $top = [Console]::CursorTop - $n
                switch ([Console]::ReadKey($true).Key) {
                    { $_ -in 'UpArrow', 'K' }   { if ($cur -gt 0) { $cur-- } }
                    { $_ -in 'DownArrow', 'J' } { if ($cur -lt $n - 1) { $cur++ } }
                    'Spacebar'                  { $on[$cur] = -not $on[$cur] }
                    'Enter'                     { break pick }
                }
            }
        }
        finally {
            [Console]::CursorVisible = $true
        }
        $Group = for ($i = 0; $i -lt $n; $i++) { if ($on[$i]) { $available[$i] } }
        if (-not $Group) { Write-Host 'Nothing selected.'; return }
    }
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
