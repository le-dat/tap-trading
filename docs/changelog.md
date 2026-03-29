# Tap Trading — Changelog

> Updated automatically by `/update-docs` command after each completed feature.
> Format: [version or date] — what changed — who / which session.

---

## How to update

After completing a feature, run:
```
/update-docs
```
Claude will add an entry to this file with: what was built, key decisions made, any bugs encountered and fixed.

---

## Unreleased — In Progress

### Added
- Project scaffolded from claude-starter template
- CLAUDE.md populated with full Tap Trading domain context
- 5 domain-specific commands added to .claude/commands/
- docs/ folder initialized with spec-doc, architecture, changelog, project-status

---

## [0.1.0] — Contracts (target: Week 2)

_To be filled after Phase 1 completion._

### Added
- TapOrder.sol: createOrder, settleOrder, batchSettle, pause/unpause
- PriceFeedAdapter.sol: Chainlink AggregatorV3 wrapper with stale check
- PayoutPool.sol: liquidity management, operator fee
- MockV3Aggregator.sol: for local testing
- Full test suite: settlement edge cases, reentrancy, stale price
- Deploy scripts: base-sepolia, base mainnet
- TypeChain bindings generated

### Decisions
- multiplierBps in basis points (500 = 5x) for integer math on-chain
- settleOrder is permissionless (anyone can call) → trustless settlement

---

## [0.2.0] — Backend Core (target: Week 5)

_To be filled after Phase 2 completion._

### Added
- NestJS monorepo setup: API (:3001) + Worker (:3002)
- auth module: Privy verify → JWT issue
- price module: Chainlink event listener → Redis cache → Kafka publish
- order module: create/query with risk validation
- settlement module: worker loop, price touch detection, on-chain settle
- socket module: Socket.io gateway, realtime order status push
- Docker Compose: postgres, redis, kafka, minio, zookeeper

---

## [0.3.0] — Frontend MVP (target: Week 8)

_To be filled after Phase 3 completion._

### Added
- Next.js 14 App Router setup
- Privy embedded wallet integration
- AssetSelector with live price ticker
- TargetBlockGrid: 6 blocks (±0.5%, ±1%, ±2%)
- TapButton with haptic feedback
- ActiveTradeCard: countdown ring + price proximity bar
- WinModal / LoseModal with Framer Motion animations
- Trade history page
- PWA manifest + service worker

---

## [0.4.0] — Pre-launch (target: Week 10)

_To be filled after Phase 4 completion._

### Added
- Security review: reentrancy, stale price, rate limiting
- Load test: 100 concurrent orders
- BASE Mainnet deploy
- Post-launch monitoring setup
