#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

sudo chown "$(id -u):$(id -g)" frontend/node_modules backend/.venv

# Hide the committed node_modules so git doesn't report them as changed
git config --global --add safe.directory "$PWD"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "==> Hiding the committed node_modules from git"
  git ls-files -z frontend/node_modules | git update-index --skip-worktree -z --stdin
  exclude_file="$(git rev-parse --git-path info/exclude)"
  mkdir -p "$(dirname "$exclude_file")"
  for pattern in 'node_modules/' '.venv/' '__pycache__/' '.env'; do
    grep -qxF "$pattern" "$exclude_file" 2>/dev/null || echo "$pattern" >> "$exclude_file"
  done
fi

echo "==> Installing backend dependencies"
uv venv --allow-existing --python "$(command -v python)" backend/.venv
uv pip install --python backend/.venv/bin/python -r backend/requirements.txt

echo "==> Installing frontend dependencies"
npm ci --prefix frontend

echo "==> Done. Frontend: http://localhost:5173  API docs: http://localhost:8000/docs"