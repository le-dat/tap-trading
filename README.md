# 🚀 Claude Code Setup — PSB System

> Complete setup for Claude Code following the **PSB (Plan → Setup → Build)** system
> Based on Avthar Sewrathan's workflow

---

## 📁 Directory Structure

```
your-project/
│
├── CLAUDE.md                          # 🧠 Claude's Memory — read at start of each session
├── .env.example                       # 📋 Environment variable template
│
├── .claude/
│   ├── settings.json                  # ⚙️ Permissions + Hooks config
│   │
│   ├── commands/                      # ⚡ Custom slash commands
│   │   ├── update-docs.md             # /update-docs
│   │   ├── commit.md                  # /commit
│   │   ├── pr.md                      # /pr
│   │   ├── new-feature.md             # /new-feature
│   │   └── retro.md                   # /retro
│   │
│   ├── agents/                        # 🤖 Subagents running independently
│   │   ├── changelog-agent.md         # Update changelog
│   │   ├── frontend-test-agent.md     # Run Playwright tests
│   │   └── research-agent.md          # Research tech stack
│   │
│   └── hooks/                         # 🪝 Automation hooks
│       ├── on-stop.sh                 # Run after task completes
│       ├── auto-lint.sh               # Lint after file edit
│       └── pre-bash-check.sh          # Check dangerous commands
│
└── docs/
    ├── spec-doc.md                    # 📐 Project specification (Phase 1)
    ├── architecture.md                # 🏗️  System architecture
    ├── changelog.md                   # 📝 Change history
    └── project-status.md              # 📊 Session tracking
```

---

## ⚡ Quick Start

Choose your preferred setup method:

### 🤖 Option A: Master Prompt for AI Agents (Recommended)

Copy and paste the prompt below into your AI assistant. This prompt is optimized for CLI agents like **Claude Code**, **Cursor**, or **Windsurf** to automatically architect and initialize your project files.

---

I want to build a fullstack project named **[PROJECT NAME]**.

**Reference Context:**

- Concept/Demo: [link/description]
- Tech Stack Ideas: [e.g., Next.js, FastAPI, PostgreSQL, Tailwind]
- Existing Repo (if any): [link]

**Phase 1: Deep Brainstorming**

Analyze the requirements and provide a step-by-step breakdown of:

1. **Core Mechanics:** How the primary user flows and logic will function.
2. **Universal Tech Stack:** Recommend the most suitable tools (Backend, Frontend, Database, Infra, and Smart Contracts if applicable).
3. **Information Architecture:** How data flows between system layers and external services.
4. **Implementation Roadmap:** Estimated timeline and milestones.

**Phase 2: Project Initialization**

Based on the analysis, **use your file-writing tools** to create the following directory structure and files in the current root. If you cannot write files, output them as separate code blocks.

1. **CLAUDE.md (Core Memory):**

   - Project overview, core mechanics, and tech stack.
   - Repository structure & architectural principles.
   - Coding patterns, naming conventions, and testing strategy.
   - Environment variables (all necessary keys with placeholders).
   - Known issues & decisions log.

2. **.claude/commands/ (Workflow Automation):**

   - `new-feature.md`: Standard workflow for feature development.
   - `backend-module.md` / `frontend-component.md`: Boilerplate generators.
   - `deploy.md`: Deployment flow + rollback instructions.
   - `debug-flow.md`: Diagnostic steps for the most complex modules.

3. **docs/ (Living Documentation):**

   - `spec-doc.md`: Milestones, acceptance criteria, and scope.
   - `architecture.md`: System design, DB schema, and data flow diagrams.
   - `project-status.md`: Current phase, progress tracker, and next steps.

**Phase 3: Execution Plan**

Generate a prioritized, step-by-step implementation guide:

- Define the build order (e.g., Base Schema -> Backend APIs -> Frontend Core -> Integration).
- Identify blocking steps and verification checkpoints for each phase.

---

---

### 🛠️ Option B: Manual Setup

Use this method if you already have a project or want to set up the structure manually from this template.

#### Step 1: Copy this structure to your project

```bash
# Clone or copy this directory to your project root
cp -r claude-setup/. your-project/
cd your-project/
```

#### Step 2: Give hooks execute permission

```bash
chmod +x .claude/hooks/*.sh
```

#### Step 3: Setup environment variables

```bash
cp .env.example .env.local
# Fill in actual values in .env.local
```

#### Step 4: Fill in CLAUDE.md

Open `CLAUDE.md` and fill in:

- [ ] Project goals
- [ ] Specific tech stack
- [ ] Design style guide
- [ ] Milestones

#### Step 5: Complete spec-doc.md

Open `docs/spec-doc.md` and fill it in completely before coding.

#### Step 6: Start Claude Code

```bash
claude
```

---

## 🎯 PSB System

### Phase 1: PLAN

Before opening terminal, answer 2 questions:

**Question 1:** What is the project goal?

- Learning → build fast, no need for production-ready
- Validate idea → minimal MVP in 1-2 weeks
- Real product → need full scalability, security

**Question 2:** What are the project milestones?

- Milestone 1 = MVP: [3-5 core features]
- Milestone 2 = Beta: [additional features after feedback]

**Deliverable:** Complete `docs/spec-doc.md`

---

### Phase 2: SETUP (7 steps)

| #   | Step           | File                    | Description                            |
| --- | -------------- | ----------------------- | -------------------------------------- |
| 1   | GitHub Repo    | —                       | Create repo, setup branches            |
| 2   | Env Variables  | `.env.local`            | Copy from `.env.example`, fill in keys |
| 3   | CLAUDE.md      | `CLAUDE.md`             | Fill in project memory                 |
| 4   | Auto Docs      | `docs/`                 | Create architecture, changelog, status |
| 5   | Plugins        | —                       | Install Anthropic plugins              |
| 6   | MCPs           | `.claude/settings.json` | Config based on tech stack             |
| 7   | Slash Commands | `.claude/commands/`     | Already included in this setup         |

**Bonus:** Pre-configured permissions + Hooks (configured in `settings.json`)

---

### Phase 3: BUILD

**3 Workflows:**

#### Workflow 1 — Single Feature

```text
Research → Plan → Implement → Test
```

Use for: Single features, bug fixes

#### Workflow 2 — Issue-Based

```
GitHub Issues → Branch → Build → PR → Merge
```

Use for: Multi-feature projects, organized work

```bash
# Create issues from spec doc
gh issue create --title "feat: [feature name]" --body "[description]"

# Work on issue
git checkout -b feat/issue-42-feature-name
# ... code ...
/commit
/pr
```

#### Workflow 3 — Multi-Agent (advanced)

```
Git Worktrees → Multiple Claude instances in parallel → Merge
```

Use for: Large projects, speed needed

```bash
# Create worktrees for parallel development
git worktree add ../project-feat-a feat/feature-a
git worktree add ../project-feat-b feat/feature-b

# Open 2 terminals, run claude in each worktree
cd ../project-feat-a && claude
cd ../project-feat-b && claude
```

---

## ⚡ Slash Commands

| Command               | Purpose                                       |
| --------------------- | --------------------------------------------- |
| `/new-feature [name]` | Start new feature following standard workflow |
| `/commit`             | Create git commit with standard message       |
| `/pr`                 | Create Pull Request to GitHub                 |
| `/update-docs`        | Update changelog, status, architecture        |
| `/retro`              | Summarize session, prepare for next time      |

---

## 🤖 Subagents

| Agent                 | Trigger            | Purpose                      |
| --------------------- | ------------------ | ---------------------------- |
| `changelog-agent`     | "update changelog" | Record changes after feature |
| `frontend-test-agent` | "test UI"          | Run Playwright tests         |
| `research-agent`      | "research X"       | Compare and recommend tech   |

---

## 🪝 Hooks

| Hook                | When                 | What                     |
| ------------------- | -------------------- | ------------------------ |
| `on-stop.sh`        | After task completes | Run lint + type check    |
| `auto-lint.sh`      | After file edit      | Auto-fix lint errors     |
| `pre-bash-check.sh` | Before bash command  | Block dangerous commands |

---

## 🛠️ Maintenance Guide (Keep vs. Update)

When starting a new project or migrating this setup, follow this guide to know what to keep as a "Base" and what requires customization.

| Component                   | Status        | Action                                                                                                              |
| :-------------------------- | :------------ | :------------------------------------------------------------------------------------------------------------------ |
| **`.claude/hooks/`**        | 🟢 **Keep**   | Standard scripts for linting and safety. No change needed unless using a different language (e.g., Python vs Node). |
| **`.claude/commands/`**     | 🟢 **Keep**   | Standard workflows like `/commit` or `/pr`. These are universal.                                                    |
| **`.claude/agents/`**       | 🟢 **Keep**   | Specialized sub-agents. They work the same across projects.                                                         |
| **`.claude/settings.json`** | 🟡 **Review** | Update `Write()` permissions if your folder structure changes (e.g., from `app/` to `src/`).                        |
| **`CLAUDE.md`**             | 🔴 **UPDATE** | **Critical.** This is the project's brain. Update goals, tech stack, and rules for every new repo.                  |
| **`docs/architecture.md`**  | 🔴 **UPDATE** | **Specific.** Update with your actual system design, DB schema, and data flows.                                     |
| **`.env.example`**          | 🔴 **UPDATE** | Update based on the services (Stripe, Clerk, Supabase, etc.) your project uses.                                     |
| **`docs/spec-doc.md`**      | 🔴 **UPDATE** | Unique to your product's requirements.                                                                              |

### Specific Cases for Update

1. **Change of Framework:** If moving from Next.js to Python/FastAPI, update `.claude/hooks/auto-lint.sh` to use `ruff` or `flake8` instead of `npm run lint`.
2. **Folder Structure:** If you put code in `src/`, update `.claude/settings.json` permissions to allow writing to `src/**`.
3. **Database:** If switching from SQL to NoSQL, update the `Database Schema` section in `docs/architecture.md` to reflect your collections/documents.

---

## 📌 Tips

1. **Use Opus 4 for important tasks** — costs more but avoids time-consuming bugs
2. **Keep CLAUDE.md updated** — add patterns, encountered bugs, decisions
3. **When encountering a bug, don't just fix** — record it in CLAUDE.md to avoid repetition
4. **Code is cheaper than time** — don't hesitate to delete and rebuild if direction is wrong
5. **Use plan mode before coding** — `/new-feature` always plans before implementing
6. **Commit frequently** — each small feature = 1 clear commit

---

## 🔌 Suggested MCPs by Tech Stack

```json
// Add to .claude/settings.json > mcpServers

// Database
"supabase": { "command": "npx", "args": ["@supabase/mcp-server-supabase"] }
"mongodb": { "command": "npx", "args": ["@mongodb-js/mcp-server-mongodb"] }

// Testing
"playwright": { "command": "npx", "args": ["@playwright/mcp"] }

// Version Control
"github": { "command": "npx", "args": ["@modelcontextprotocol/server-github"] }

// Files
"filesystem": { "command": "npx", "args": ["@modelcontextprotocol/server-filesystem", "."] }
```

---

_This setup is based on the video "How I Start EVERY Claude Code Project" — PSB System_
