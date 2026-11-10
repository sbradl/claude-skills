# Kept so older instructions still work: same as install.ps1 -Update.
# Usage:  irm https://raw.githubusercontent.com/sbradl/claude-skills/main/update.ps1 | iex
#         & ([scriptblock]::Create((irm https://raw.githubusercontent.com/sbradl/claude-skills/main/update.ps1))) -Ref v2.1.4 tdd
& ([scriptblock]::Create((Invoke-RestMethod https://raw.githubusercontent.com/sbradl/claude-skills/main/install.ps1))) -Update @args
