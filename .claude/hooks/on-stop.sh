#!/bin/bash
# Hook: Chạy sau khi Claude kết thúc task
# Kiểm tra tests có pass không trước khi kết thúc

echo "🔍 Chạy kiểm tra sau task..."

# Chạy lint nếu có package.json
if [ -f "package.json" ]; then
  if npm run lint --silent 2>/dev/null; then
    echo "✅ Lint passed"
  else
    echo "⚠️  Lint có lỗi — hãy review trước khi commit"
  fi
fi

# Chạy type check nếu có tsconfig
if [ -f "tsconfig.json" ]; then
  if npx tsc --noEmit --quiet 2>/dev/null; then
    echo "✅ TypeScript OK"
  else
    echo "⚠️  TypeScript errors — cần fix trước khi deploy"
  fi
fi

echo "✅ Hook on-stop hoàn thành"
