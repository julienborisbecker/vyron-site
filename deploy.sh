#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/julienborisbecker/vyron-site.git"
BRANCH="main"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if ! command -v git >/dev/null 2>&1; then
  echo "git n'est pas installe."
  exit 1
fi

if [ ! -d ".git" ]; then
  echo "Initialisation du repo git..."
  git init
fi

git branch -M "$BRANCH"

if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REPO_URL"
else
  git remote add origin "$REPO_URL"
fi

git add .

if git diff --cached --quiet; then
  echo "Aucun changement a publier."
  exit 0
fi

if [ "${1:-}" != "" ]; then
  COMMIT_MSG="$1"
else
  COMMIT_MSG="site: update $(date '+%Y-%m-%d %H:%M')"
fi

echo "Commit: $COMMIT_MSG"
git commit -m "$COMMIT_MSG"

if git rev-parse --abbrev-ref --symbolic-full-name "@{u}" >/dev/null 2>&1; then
  git push
else
  git push -u origin "$BRANCH"
fi

echo "Deploiement termine."
