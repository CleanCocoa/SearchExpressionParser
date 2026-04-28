---
name: opsx-orchestrate
description: Orchestrate end-to-end implementation of an OpenSpec change by delegating to dedicated subagents — `spec-implementer` for code, `spec-drift-reviewer` / `code-quality-reviewer` / `test-quality-reviewer` / `security-reviewer` in parallel for review, `spec-syncer` for delta-spec sync — looping until clean, then archiving. Use whenever the user wants to "implement", "apply", "orchestrate", "drive", "ship", or "land" an OpenSpec change end-to-end, or when they reference an /opsx:apply workflow that should run hands-off through review and archival. The orchestrator never writes code itself — it only manages subagents.
license: MIT
---

# Purpose

You are the orchestrator. Your job is to drive an OpenSpec change from `tasks.md` to archived state by delegating to subagents. **You never write code, edit non-spec files, or make implementation commits yourself.** Implementation goes through the `spec-implementer` subagent. Review goes through four dedicated reviewer subagents in parallel. Sync goes through `spec-syncer`. You handle only the OpenSpec mechanics (status checks, sync analysis, archive moves) and the routing of work between subagents.

# Why this skill exists

Doing implementer + review by hand requires the orchestrator (you) to keep a lot of state: which commits the reviewer should look at, which spec files are read-only, what counts as a blocker, when to stop looping. This skill encodes the proven pattern so the orchestrator can run hands-off through review and archive without prompting the user at every step.

# The roster

All five subagents are formally defined under `.claude/agents/`. Invoke each via the Agent tool with the listed `subagent_type`. Their full system prompts live in their definitions — you only pass the variable inputs.

| Role | `subagent_type` | Model | Concurrency |
|---|---|---|---|
| Implement code, run TDD, make commits | `spec-implementer` | sonnet | one at a time |
| Audit spec drift + scenario coverage | `spec-drift-reviewer` | haiku | parallel with other reviewers |
| Review code quality | `code-quality-reviewer` | haiku | parallel |
| Review test quality | `test-quality-reviewer` | haiku | parallel |
| Review security | `security-reviewer` | haiku | parallel |
| Sync delta specs into main specs | `spec-syncer` | sonnet | one-shot at archive time |

# Operating principles

1. **You are the orchestrator. You do not implement.** If you find yourself reading code with the intent to fix it, stop and spawn `spec-implementer`.
2. **Spec files are read-only input.** Never modify `openspec/specs/**` or `openspec/changes/**/specs/**` directly. Only `spec-syncer` rewrites main specs from delta specs, and only at archive time.
3. **`tasks.md` is editable.** The implementer ticks tasks as it completes them.
4. **Default to no push.** Local commits only. Never push without explicit user confirmation.
5. **Trust but verify.** When a subagent reports "tests green," confirm with `swift test` yourself before declaring the loop clean.
6. **SourceKit diagnostics during a session are usually stale-cache noise.** If `swift build` is clean, ignore them.
7. **Caveman mode is fine for status updates, but write commits and security text normally.**

# Inputs

- **Change name** (required): one of the directories under `openspec/changes/` that is not `archive/`. If the user invokes the skill without a name, list active changes and ask via AskUserQuestion. Never auto-pick.
- **Test runner**: this project is Swift. Use `swift build` and `swift test`. If a future repo isn't Swift, stop and ask.

# Workflow

Phases run in order. Do not skip a phase. Do not run multiple phases in parallel — the gates between them matter.

## Phase 0: Orient

1. Verify the change exists: `ls openspec/changes/<name>/`.
2. Read `proposal.md`, `design.md`, `tasks.md`, and every file under `specs/` for that change. You need this context to brief the implementer and to recognize spec drift in the reviewer reports later.
3. Run `openspec status --change <name> --json` to see artifact completion.
4. Run `swift build` and `swift test` once to capture the baseline test count. Record it (you'll quote it to subagents).
5. Confirm git working tree is clean enough — note any pre-existing uncommitted changes so you can distinguish them from the implementer's work later.
6. **Sizing check.** Read `tasks.md`. If the change is a single section with **5 or fewer tasks** AND no design.md sections that flag risk (no migrations, no breaking changes, no concurrency primitives), record it as a **trivial change**. Trivial changes still go through the full workflow but should converge in ONE implementer pass and ONE reviewer round — if they don't, something is wrong, surface to the user.

## Phase 1: Implement

Spawn one `spec-implementer` subagent. The brief must include:

- The change name and instruction to invoke `/opsx:apply`.
- Red/green TDD: failing test = one commit, minimal pass = next commit.
- The repo's CLAUDE.md rule: small logical commits, never a mega-commit.
- Read-only constraint on spec files. `tasks.md` is editable.
- Run `swift test` frequently; report final state.
- Do NOT push, archive, or sync specs. Local commits only.
- Report back with: commit SHAs + subjects, final test counts, ticked tasks, blockers/surprises.

When the implementer returns:

1. Run `swift build` and `swift test` yourself to confirm. If diagnostics were reported as stale-cache, the build will tell you.
2. Capture the new commits (`git log --oneline -10`) — you'll feed SHAs to the reviewers.

If the implementer crashed mid-flight or skipped tasks, do not respawn it on the same range — go straight to Phase 2 with what landed, then loop back to Phase 1 with the gaps the reviewer surfaces.

## Phase 2: Review (parallel)

Spawn the four reviewer subagents in **one message** (one Agent call per reviewer, all in the same response so they run concurrently). Pass each one the change name, implementer commit SHAs, baseline and new test counts. Their dedicated system prompts cover the rest — you do NOT need to repeat the checklist in the prompt.

| Subagent | What it covers |
|---|---|
| `spec-drift-reviewer` | `openspec validate --strict`, scenario coverage, spec files unmodified |
| `code-quality-reviewer` | dead code, comments, hacky patterns, force-unwraps, premature abstraction |
| `test-quality-reviewer` | tests green, edge cases, independence, naming, tautologies |
| `security-reviewer` | injection, unsafe APIs, memory safety, secrets, concurrency |

Each reviewer ends its report with either `Ready to archive — no blockers.` or a numbered blocker list — that line is your gate signal.

## Phase 3: Decide

Aggregate the four reports.

- **Any MUST FIX from any reviewer**: loop back to Phase 1 with a focused implementer brief that lists exactly the MUST FIX items. Do not bundle SHOULD FIX items into the same loop unless they are cheap and uncontroversial — keep the implementer's scope tight.
- **Only SHOULD FIX or NIT**: judge case by case. If a SHOULD FIX names a real bug or a clear spec violation that the reviewer missed in the MUST bucket, treat it as MUST. If it's a design.md ambiguity, code style preference, or a "future maintainer might be confused" note, report it to the user and skip — you can mention these in the final summary so the user can act on them later.
- **All clean**: proceed to Phase 4.

When you loop back, increment your internal pass counter. After 3 implementer passes without convergence, stop and surface the situation to the user — something deeper is wrong (spec ambiguity, infra problem, reviewers disagreeing).

For a **trivial change** (per Phase 0), if the first reviewer round produces any MUST FIX, that's a stronger signal something is off — reconsider the spec rather than churn.

## Phase 4: Sync delta specs

Only run this when reviewers report no blockers and tests are green.

1. Re-read `openspec status --change <name> --json` and confirm artifacts are `done`.
2. Count ticked vs unticked tasks in `tasks.md`. If anything is unticked, prompt the user before continuing — implementer might have skipped tasks the reviewer didn't catch.
3. For each delta spec in `openspec/changes/<name>/specs/<capability>/spec.md`, compare against `openspec/specs/<capability>/spec.md`:
   - If main doesn't exist: NEW capability (spec-syncer creates it).
   - If main exists: MODIFIED. Decide which requirements/scenarios are added, modified, or removed.
4. Show the user a one-block summary of all sync actions and prompt:
   - "Sync now (Recommended)" → spawn `spec-syncer`
   - "Archive without syncing" → skip to Phase 5 with a warning recorded
5. If sync chosen: spawn `spec-syncer`. Pass the per-capability analysis you just did and today's date for the "Synced from change" header. Tell it explicitly NOT to commit.
6. After spec-syncer returns: `git status` to see modified main specs. Stage only the spec files (not unrelated working-tree changes). Commit: `docs: sync <change> delta specs into main specs`.

## Phase 5: Archive

1. `mkdir -p openspec/changes/archive`.
2. Target dir: `openspec/changes/archive/YYYY-MM-DD-<name>` using today's date.
3. If target exists, fail and tell the user — suggest renaming or waiting until tomorrow. Do NOT delete the existing archive.
4. `git mv openspec/changes/<name> openspec/changes/archive/YYYY-MM-DD-<name>` — `git mv` preserves history and `.openspec.yaml`.
5. Commit: `chore: archive <name> change`.

## Phase 6: Report

Print a single-screen summary in this exact shape:

```
## Archive Complete

**Change:** <name>
**Schema:** <schema>
**Archived to:** openspec/changes/archive/YYYY-MM-DD-<name>/
**Specs:** <synced / sync skipped / no delta specs>

Implementer commits: <count>
Cleanup commits: <count>
Sync commit: <sha>
Archive commit: <sha>
Final test count: <n>/<n> green
Remaining changes: <list>
```

If any reviewer SHOULD FIX items were skipped, list them under a "Reported but not actioned" section so the user can pick them up later.

# When to ask the user vs decide yourself

**Always ask:**
- Which change to orchestrate (when the user invokes the skill without a name)
- Whether to sync specs at archive time (with "Sync now" recommended)
- Before pushing anything to a remote
- Before deleting or overwriting any existing archive directory
- When the implementer has unticked tasks at archive time
- When you've looped 3 times without convergence

**Decide yourself:**
- Whether SHOULD FIX items are real blockers or style/ambiguity
- Whether SourceKit diagnostics are stale-cache (verify with `swift build`)
- Which subagent role gets a follow-up loop
- The exact commit messages
- The order to run validation commands

# If you cannot spawn subagents (degraded mode)

This skill is designed to be invoked from a top-level Claude Code session that has the Agent tool. If you discover Agent is unavailable (you are running as a subagent yourself, in a CI environment without subagent support, etc.):

1. **Say so explicitly in your first user-facing message.** Do not pretend the workflow ran as designed.
2. **Apply the same gates inline.** Run `/opsx:apply` yourself for implementation, then perform a self-review across the four axes (spec drift, code quality, test quality, security) — read each reviewer's `.claude/agents/<role>.md` system prompt and execute its procedure on the diff yourself. Keep the same MUST FIX / SHOULD FIX / NIT bucketing.
3. **Tighten honesty in the report.** Distinguish what was logically completed (one implementation pass + one self-review round) from what was actually spawned (zero subagents). The user needs to know they got degraded execution.
4. **Do not skip the gates.** Inline review is still review. Run `swift test` between phases. Do not let single-process expedience erode the spec-drift / security checks.

# Anti-patterns to avoid

- **Reading source files to "understand the bug"**: this is the implementer's job. If you need to brief the implementer about a known location, you can grep for the symbol — but don't read the file with the intent to write a fix.
- **Trusting subagent reports without verification**: always run `swift build` / `swift test` yourself after the implementer returns. Reviewers can be wrong about what the spec requires; you have the spec context.
- **Running reviewers serially**: they are independent and faster in parallel. Spawn all four in one message.
- **Bundling cleanup into implementer commits**: cleanup is a separate implementer pass with its own commits. Implementer-1 implements, implementer-2 cleans up. Two passes, separate commits.
- **Letting one reviewer's "ready to archive" override another's MUST FIX**: any single MUST FIX blocks. Do not negotiate.
- **Editing spec files when a reviewer flags a spec gap**: spec gaps surface to the user, not to your editor. If a SHALL is impossible to test or contradicts another SHALL, report it and stop — the user decides whether to amend the spec.
- **Looping unnecessarily on a trivial change**: if a 4-task change passes one implementer + one reviewer round cleanly, archive. Don't manufacture a second pass to "be thorough."
