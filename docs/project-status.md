# Tap Trading — Project Status

> [ [CLAUDE.md](../CLAUDE.md) ] [ [Spec](spec-doc.md) ] [ [Architecture](architecture.md) ] [ [Plan](project-plan.md) ] [ [Status](project-status.md) ] [ [Changelog](changelog.md) ]

> Claude updates this file at the START and END of each session via `/retro`.
> Use this to resume context quickly after closing terminal.

---

## How to use

**Start of session:** Tell Claude:
```
Read docs/project-status.md and continue from where we left off.
```

**End of session:** Run:
```
/retro
```
Claude will update "Last session" and "Next session" sections below.

---

## Current Phase

**Phase:** 1 — Contracts (✅ COMPLETE)
**Week:** 2
**Overall progress:** 20% (See [Detailed Plan](project-plan.md) for steps)

---

## Last Session

**Date:** 2026-03-31
**Duration:** ~30 min
**Completed:**
- Phase 1 Smart Contracts COMPLETE: 23 Foundry tests passing, `forge build` clean, Hardhat compile + TypeChain (62 typings) ✅
- Added 2 missing tests: `test_settleOrder_isPermissionless`, `test_settleOrder_revertsWhenFeedIsStale`
- Fixed: stale feed test arithmetic underflow (needed `vm.warp` before `updateAnswerAndTimestamp`)
- Fixed: missing `@nomicfoundation/hardhat-toolbox` → switched to `@nomicfoundation/hardhat-ethers` only (avoids Hardhat 3 migration chain)
- Generated `docs/project-plan.md` (22 steps, 6 phases)

**Decisions made:**
- `batchSettle` uses `try this.settleOrder()` external call for per-order failure isolation
- settleOrder is permissionless (anyone can call) — trustless, no single point of failure
- multiplierBps in basis points (500 = 5x) for integer math

**Bugs / blockers encountered:**
- Stale feed test arithmetic underflow — fixed with `vm.warp(block.timestamp + 61 seconds)` before updating mock
- Hardhat toolbox dependency hell — fixed by using just `@nomicfoundation/hardhat-ethers`

---

## Next Session — Start Here

**Goal:** Phase 2 Infrastructure — Docker Compose + TypeORM migrations

**Plan:** [project-plan.md](project-plan.md) — Phase 1 ✅ complete, Phase 2 next

**First command to run:**
```
/dev-setup
```

**Exact prompt to give Claude:**
```
Read docs/project-plan.md and CLAUDE.md.
Start Phase 2: Infrastructure.
Run /dev-setup to set up Docker Compose for Postgres, Redis, Kafka, MinIO.
Then create TypeORM migrations for users, orders, settlements, payments tables.
```

**Files to touch next:**
- `docker-compose.yml` (create in root)
- `apps/backend/src/migrations/`

---

## Milestone 1 Progress

| Feature | Status | Notes |
|---|---|---|
| Monorepo scaffold | ✅ done | yarn workspaces, apps/contracts/backend/frontend exist |
| TapOrder.sol | ✅ done | createOrder, settleOrder, batchSettle, pause/unpause |
| PriceFeedAdapter.sol | ✅ done | 60s stale threshold, Chainlink wrapper |
| PayoutPool.sol | ✅ done | PAYOUT_ROLE access control |
| Contract tests | ✅ done | 23 Foundry tests passing |
| TypeChain bindings | ✅ done | 62 typings via `yarn typechain:gen` |
| Docker Compose infra | ⬜ not started | Phase 2 |
| TypeORM migrations | ⬜ not started | Phase 2 |
| BASE Sepolia deploy | ⬜ not started | |
| Backend: auth | ⬜ not started | Phase 3 |
| Backend: price | ⬜ not started | Phase 3 |
| Backend: order | ⬜ not started | Phase 3 |
| Backend: settlement | ⬜ not started | Phase 3 |
| Backend: socket | ⬜ not started | Phase 3 |
| Frontend: auth screen | ⬜ not started | Phase 4 |
| Frontend: trading screen | ⬜ not started | Phase 4 |
| Frontend: win/lose UI | ⬜ not started | Phase 4 |
| E2E trade flow test | ⬜ not started | Phase 4 |
| Security review | ⬜ not started | Phase 5 |
| Mainnet deploy | ⬜ not started | Phase 5 |

Status key: ⬜ not started · 🔄 in progress · ✅ done · ❌ blocked

---

## Known Issues & Decisions Log

| # | Issue / Decision | Resolution | Date |
|---|---|---|---|
| 1 | Fixed vs dynamic multiplier for MVP | Fixed tiers — simpler to audit house edge | — |
| 2 | Which testnet? | BASE Sepolia — has Chainlink feeds + low gas | — |
| 3 | Auth approach | Privy embedded wallet — best web2 UX | — |
| 4 | Hardhat toolbox dependency hell | Use only `@nomicfoundation/hardhat-ethers` (not full toolbox) to avoid Hardhat 3 Ignition chain | 2026-03-31 |
| 5 | batchSettle failure isolation | `try this.settleOrder()` external call pattern — one bad order doesn't revert batch | 2026-03-31 |
| 6 | settleOrder is permissionless | Anyone can call — trustless settlement, no single point of failure | 2026-03-31 |

---

## Useful Context for Claude

- Admin wallet (ADMIN_PRIVATE_KEY) is used by backend to submit txs on behalf of users. Never expose to frontend.
- Settlement worker must be restarted if it crashes — add to docker compose restart: always.
- Chainlink feeds on BASE Sepolia update every ~20s. Don't assume more frequent.
- When testing settlement: use MockV3Aggregator to control price manually, don't wait for real market movements.
- PayoutPool needs to be funded BEFORE any orders can win. Test with: `scripts/fund-pool.ts`.
