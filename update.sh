#!/usr/bin/env sh
# Kept so older instructions still work: same as install.sh --update.
# Usage:  curl -fsSL https://raw.githubusercontent.com/sbradl/claude-skills/main/update.sh | sh
#         curl -fsSL https://raw.githubusercontent.com/sbradl/claude-skills/main/update.sh | sh -s -- --ref v2.1.4 tdd
set -eu
curl -fsSL https://raw.githubusercontent.com/sbradl/claude-skills/main/install.sh | sh -s -- --update "$@"
