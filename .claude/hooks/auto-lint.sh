#!/bin/bash
# Hook: Tự động lint sau khi edit/write file
# Chỉ lint file vừa thay đổi để nhanh hơn

CHANGED_FILE="$1"

if [ -f "package.json" ] && [ -n "$CHANGED_FILE" ]; then
  # Chỉ lint file .ts, .tsx, .js, .jsx
  if [[ "$CHANGED_FILE" =~ \.(ts|tsx|js|jsx)$ ]]; then
    npx eslint "$CHANGED_FILE" --fix --quiet 2>/dev/null
  fi
fi
