# Install or update the claude-skills in .\.claude\skills\ in the current directory.
# Usage:  irm https://raw.githubusercontent.com/sbradl/claude-skills/main/install.ps1 | iex
#         & ([scriptblock]::Create((irm https://raw.githubusercontent.com/sbradl/claude-skills/main/install.ps1))) -Ref v2.1.4 tdd craft-review
#         & ([scriptblock]::Create((irm https://raw.githubusercontent.com/sbradl/claude-skills/main/install.ps1))) -Update
# Installs the latest release; -Ref takes a release tag, or a branch (main for
# the development version). Arguments name skill groups (directories under
# skills\); none means pick from a checklist (or install all when input is
# redirected) — or, with -Update, every group already installed.
# Each group's skill directories are replaced wholesale, and skills a group
# no longer has are removed, so renamed or deleted files don't linger.
# Leaves the rest of .\.claude alone.
[CmdletBinding(PositionalBinding = $false)]
param(
    [string]$Ref,
    [switch]$Update,
    [Parameter(ValueFromRemainingArguments)][string[]]$Group
)
$ErrorActionPreference = 'Stop'

$repo = 'sbradl/claude-skills'
$dest = Join-Path (Get-Location) '.claude\skills'

if (-not $Ref) {
    try { $Ref = (Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest").tag_name }
    catch { throw "no release found (or GitHub API rate limit hit); pass -Ref main for the development version" }
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
    # Lists the skills a group installed, so a later run can remove those it dropped.
    function Get-Manifest($g) { Join-Path $dest ".claude-skills.$g" }
    if (-not $Group -and $Update) {
        # A manifest, or a skill installed before manifests existed.
        $Group = @($available | Where-Object {
            (Test-Path (Get-Manifest $_)) -or
            @(Get-ChildItem -Directory -Name (Join-Path $src $_) | Where-Object { Test-Path (Join-Path $dest $_) })
        })
        if (-not $Group) { throw "no installed skill groups in $dest; install first" }
    }
    elseif (-not $Group -and [Console]::IsInputRedirected) {
        $Group = $available
    }
    elseif (-not $Group) {
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
        $manifest = Get-Manifest $g
        $new = @(Get-ChildItem -Name (Join-Path $src $g))
        $old = @(if (Test-Path $manifest) { Get-Content $manifest })
        foreach ($name in $old + $new) {
            if ($name -in '', '.', '..' -or $name -match '[\\/]') { continue }
            $target = Join-Path $dest $name
            if (Test-Path $target) { Remove-Item -Recurse -Force $target }
        }
        Copy-Item -Path (Join-Path $src "$g\*") -Destination $dest -Recurse -Force
        Set-Content -Path $manifest -Value $new
    }

    Write-Host "Skills in ${dest}:"
    Get-ChildItem -Name $dest
}
finally {
    Remove-Item -Recurse -Force $tmp
}
