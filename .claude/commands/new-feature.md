# Command: new-feature

## Mô tả
Bắt đầu một tính năng mới cho Tap Trading platform theo đúng PSB workflow.
Override file new-feature.md của claude-starter để thêm Tap Trading-specific context.

## Workflow

### Bước 1: Research & Plan (TRƯỚC KHI CODE)
```
1. Đọc lại CLAUDE.md section liên quan (business logic, module map)
2. Trả lời 3 câu hỏi:
   a. Feature này ảnh hưởng tới settlement flow không?
      → Nếu CÓ: review settlement-debug.md, thêm idempotency check
   b. Feature này thay đổi order lifecycle không?
      → Nếu CÓ: update risk module, thêm Kafka event mới
   c. Feature này cần contract change không?
      → Nếu CÓ: bắt đầu từ apps/contracts/, gen TypeChain mới trước
3. Tạo GitHub Issue trước khi code:
   gh issue create --title "feat: [tên feature]" --body "[mô tả + acceptance criteria]"
```

### Bước 2: Setup branch
```bash
git checkout develop
git pull origin develop
git checkout -b feat/issue-{NUMBER}-{feature-name}
```

### Bước 3: Implement theo thứ tự đúng

**Nếu có contract change:**
```
apps/contracts/ → test → typechain:gen → apps/backend/adapters/ → module → frontend
```

**Nếu chỉ có backend change:**
```
module entity → migration → service → controller → kafka events → tests
```

**Nếu chỉ có frontend change:**
```
hook → component → store → integration test
```

> ⚠ LUÔN implement backend trước, frontend sau.
> ⚠ LUÔN viết tests trước khi tạo PR.

### Bước 4: Tap Trading-specific checks trước khi commit
```
[ ] Nếu thêm field vào Order entity → chạy migration:generate
[ ] Nếu thêm Kafka topic mới → update onchain-events.md
[ ] Nếu thay đổi multiplier logic → update docs/architecture.md section Risk
[ ] Nếu thay đổi settlement condition → test với edge case: price touch EXACTLY at target
[ ] Nếu thêm asset mới → thêm Chainlink feed address vào price-feed-check.md
[ ] Nếu thay đổi contract ABI → chạy yarn typechain:gen và update adapter
```

### Bước 5: Commit & PR
```bash
# Dùng /commit command (từ claude-starter)
/commit

# Tạo PR
/pr

# PR description phải include:
# - Link GitHub Issue
# - Settlement impact (nếu có)
# - Contract change (nếu có) + Basescan link
# - Test coverage summary
```

### Bước 6: Update docs
```bash
# Dùng /update-docs command (từ claude-starter)
/update-docs
```

## Feature size guide

| Size | Ví dụ | Approach |
|------|-------|----------|
| Small | Thêm field vào API response | 1 branch, implement thẳng |
| Medium | Thêm asset mới (SOL/USD) | 1 branch, theo thứ tự contract → backend → frontend |
| Large | Thêm Early Close feature | Tách thành multiple issues, multi-agent worktree |

## Các feature hay gặp và note đặc biệt

### Thêm asset mới
```
1. Lấy Chainlink feed address từ docs.chain.link/data-feeds (BASE network)
2. Thêm vào price-feed-check.md
3. Thêm vào FEEDS config trong PriceWorker
4. Thêm STALE_THRESHOLDS cho asset mới
5. Test: chạy price-feed-check command để verify feed hoạt động
```

### Thêm duration mới (ví dụ: 30 phút)
```
1. Thêm vào DURATIONS constant trong packages/shared
2. Update multiplier pricing trong StrategyService (thời gian dài hơn → P(touch) cao hơn → multiplier thấp hơn)
3. Update frontend DurationPills component
4. Test: tạo order với duration mới, verify expiry đúng
```

### Thêm multiplier tier mới
```
1. Update StrategyService.calculateMultiplier()
2. Verify house edge vẫn dương sau khi thêm tier mới
3. Update frontend TargetBlockGrid để hiển thị tier mới
4. Chạy backtest với historical price data nếu có thể
```
