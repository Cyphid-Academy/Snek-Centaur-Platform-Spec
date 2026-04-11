#!/bin/bash
set -e

if [ -f "package.json" ]; then
  npm install --prefer-offline --no-audit 2>/dev/null || true
fi

echo "Post-merge setup complete."
