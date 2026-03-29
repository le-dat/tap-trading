# Tap Trading — Project Status

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

**Phase:** 0 — Setup  
**Week:** 1  
**Overall progress:** 5% (scaffold + docs done, no code yet)

---

## Last Session

**Date:** —  
**Duration:** —  
**Completed:**
- Cloned claude-starter
- Added 5 domain-specific commands to .claude/commands/
- Populated CLAUDE.md with full domain knowledge
- Created docs/ (spec-doc, architecture, changelog, project-status)

**Decisions made:**
- Fixed multiplier tiers for MVP (not dynamic)
- BASE Sepolia for testnet (Chainlink feeds available)
- Privy for wallet auth (best web2→web3 UX)

**Bugs / blockers encountered:**
- None yet

---

## Next Session — Start Here

**Goal:** Scaffold monorepo + initialize Hardhat contracts project

**First command to run:**
```
/new-feature monorepo-scaffold
```

**Exact prompt to give Claude:**
```
Read CLAUDE.md and docs/spec-doc.md.
Set up the monorepo structure with yarn workspaces:
- apps/contracts (Hardhat + TypeScript)
- apps/backend (NestJS)
- apps/frontend (Next.js)
- packages/shared (types + utils)

Follow the structure in docs/architecture.md exactly.
```

**Files to touch next:**
- `package.json` (root workspaces config)
- `apps/contracts/hardhat.config.ts`
- `apps/contracts/contracts/TapOrder.sol` (stub)

---

## Milestone 1 Progress

| Feature | Status | Notes |
|---|---|---|
| Monorepo scaffold | ⬜ not started | |
| TapOrder.sol | ⬜ not started | |
| PriceFeedAdapter.sol | ⬜ not started | |
| PayoutPool.sol | ⬜ not started | |
| Contract tests | ⬜ not started | |
| BASE Sepolia deploy | ⬜ not started | |
| Backend: auth | ⬜ not started | |
| Backend: price | ⬜ not started | |
| Backend: order | ⬜ not started | |
| Backend: settlement | ⬜ not started | |
| Backend: socket | ⬜ not started | |
| Frontend: asset selector | ⬜ not started | |
| Frontend: target blocks | ⬜ not started | |
| Frontend: tap + trade | ⬜ not started | |
| Frontend: win/lose UI | ⬜ not started | |
| E2E trade flow test | ⬜ not started | |
| Security review | ⬜ not started | |
| Mainnet deploy | ⬜ not started | |

Status key: ⬜ not started · 🔄 in progress · ✅ done · ❌ blocked

---

## Known Issues & Decisions Log

| # | Issue / Decision | Resolution | Date |
|---|---|---|---|
| 1 | Fixed vs dynamic multiplier for MVP | Fixed tiers — simpler to audit house edge | — |
| 2 | Which testnet? | BASE Sepolia — has Chainlink feeds + low gas | — |
| 3 | Auth approach | Privy embedded wallet — best web2 UX | — |

---

## Useful Context for Claude

- Admin wallet (ADMIN_PRIVATE_KEY) is used by backend to submit txs on behalf of users. Never expose to frontend.
- Settlement worker must be restarted if it crashes — add to docker compose restart: always.
- Chainlink feeds on BASE Sepolia update every ~20s. Don't assume more frequent.
- When testing settlement: use MockV3Aggregator to control price manually, don't wait for real market movements.
- PayoutPool needs to be funded BEFORE any orders can win. Test with: `scripts/fund-pool.ts`.
