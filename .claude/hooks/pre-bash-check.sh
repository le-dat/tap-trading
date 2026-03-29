#!/bin/bash
# Hook: Kiểm tra trước khi chạy Bash command nguy hiểm
# Ngăn các lệnh có thể gây hại

COMMAND="$1"

# Kiểm tra các pattern nguy hiểm
DANGEROUS_PATTERNS=(
  "rm -rf /"
  "git push --force origin main"
  "DROP TABLE"
  "DELETE FROM.*WHERE 1=1"
  "truncate"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qi "$pattern"; then
    echo "🚫 BLOCKED: Lệnh nguy hiểm được phát hiện: '$pattern'"
    echo "Vui lòng xác nhận thủ công nếu bạn thực sự muốn chạy lệnh này."
    exit 1
  fi
done

exit 0
