#!/usr/bin/env bash
# security-scan.sh — pre-commit secret scanner
# Run from repo root. Exits 1 if any potential secret is found.

set -euo pipefail

PATTERNS=(
  'sk-[A-Za-z0-9]{20,}'              # OpenAI
  'sk-ant-[A-Za-z0-9-]{20,}'         # Anthropic
  'eyJ[A-Za-z0-9_-]{20,}\.eyJ'       # JWT (Supabase service role)
  'ghp_[A-Za-z0-9]{30,}'             # GitHub PAT
  'AKIA[0-9A-Z]{16}'                 # AWS access key
  'xoxb-[0-9]+-[0-9]+'               # Slack bot
  'ya29\.[A-Za-z0-9_-]{30,}'         # Google OAuth access token
  '1//[A-Za-z0-9_-]{30,}'            # Google OAuth refresh token
)

FOUND=0
STAGED=$(git diff --cached --name-only --diff-filter=ACM | grep -v -E '(\.env\.example|\.gitignore|security-scan\.sh|\.lock$)' || true)

if [ -z "$STAGED" ]; then
  exit 0
fi

for f in $STAGED; do
  [ -f "$f" ] || continue
  for p in "${PATTERNS[@]}"; do
    if grep -E -n "$p" "$f" >/dev/null 2>&1; then
      echo "🚨 Potential secret in $f matching pattern: $p"
      grep -E -n "$p" "$f"
      FOUND=1
    fi
  done
done

if [ $FOUND -eq 1 ]; then
  echo ""
  echo "❌ Commit blocked. Remove secrets and try again."
  echo "   If false positive, add an exclusion to .claude/hooks/security-scan.sh"
  exit 1
fi

exit 0
