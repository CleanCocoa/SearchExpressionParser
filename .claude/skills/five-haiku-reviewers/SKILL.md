---
name: five-haiku-reviewers
description: Spawn five parallel Haiku subagents that each review a target (a document, a codebase, a directory, a single file, or a diff) through a different lens, then return an aggregated summary that surfaces issues multiple reviewers agreed on. Use this skill whenever the user asks for a "comprehensive review", "thorough review", "in-depth review", "deep review", "full review", "broad review", "wide review", "360 review", "multi-angle review", "multi-lens review", "multi-perspective review", "parallel review", "clarity review", "quality review" — or for "5 haiku subagents", "five haiku reviewers", "ask 5 haikus to review X", "five-reviewer pass", or any close variant — even if they don't explicitly name the skill. Also use it when the user wants a broad sweep over something they wrote or built (a doc, a PR, a directory, a feature) and is willing to spend tokens on parallel reviewers in exchange for breadth and cross-checking. Prefer this over a single-pass review whenever the user asks for breadth, multiple perspectives, or wants to be thorough.
---

# Five Haiku Reviewers

Spawn five Haiku subagents in parallel, each reviewing the same target from a different angle, then aggregate. The point is **breadth + agreement** — single reviewers miss things and have idiosyncratic tastes, but issues that surface across multiple lenses are almost always real.

## When to use

The user asks something like:
- "ask 5 haiku subagents: review X for Y"
- "five haiku reviewers on the codebase"
- "parallel clarity review of this doc"
- "give me a multi-lens review of …"

Or they want a broad first pass on something — a requirements doc, a piece of code, a directory, a diff — before deciding what to fix. The skill is cheap relative to a single deep review, since the five runs are parallel.

## Step 1: Identify the target

Look at the user's message and the conversation context:
- **Document** — a single markdown/text file (e.g. requirements, design doc, README).
- **Code** — Sources/, the whole repo, a directory, or a single source file.
- **Diff/PR** — uncommitted changes or a specific commit range.

If it's ambiguous, ask one short question. Otherwise pick the most plausible target and state it in one line before spawning ("Target: docs/foo.md.") so the user can correct course before five subagents run.

For a codebase target, glance at the layout first (one `ls` or `Glob`) so you can give each subagent a precise scope ("Sources/ only, skip tests/docs/.build").

## Step 2: Pick five lenses

Use the lens set matched to the target. These are defaults — adapt if the user named a specific focus ("review for security" → swap one lens for security; "review for performance" → swap one for performance).

**Document lenses:**
1. **Structure** — heading hierarchy, ordering, grouping, navigation.
2. **Language** — ambiguity, vague words, passive voice, inconsistent terminology.
3. **Requirements quality** *(only for spec/requirement docs; otherwise swap for "argument quality" or "accuracy")* — testability, atomicity, MUST/SHOULD usage, conflicts.
4. **Gaps & assumptions** — undefined terms, missing context, unstated scope/audience.
5. **Examples & formatting** — concreteness, code/example presence, list-vs-prose balance.

**Code lenses:**
1. **Naming** — types, functions, parameters; consistency, misleading names.
2. **Control flow** — long functions, deep nesting, unclear state, complex booleans.
3. **Public API** — discoverability, contract clarity, what should be internal.
4. **Tests** — names describe behavior?, A/A/A separation, magic values, tautological assertions.
5. **Structure** — file/dir layout, abstraction boundaries, where new features belong.

**Diff/PR lenses:**
1. **Scope discipline** — does the diff stay on-task or sprawl?
2. **Risk** — error handling, edge cases, breaking changes.
3. **Test coverage** — does new behavior have tests, are they meaningful?
4. **Naming/clarity** — names and comments in changed code.
5. **Consistency** — does the change match surrounding conventions?

## Step 3: Spawn all five in one message

This is non-negotiable for performance: **all five Agent calls go in a single message** so they run in parallel. Sequential spawning defeats the entire point of the skill.

For each subagent use the `general-purpose` agent type with `model: "haiku"`. The prompt for each must:
- State the absolute target path(s).
- Name the lens explicitly and describe what to evaluate under it.
- Demand concrete `file:line` (or section/line) references and short quoted snippets.
- Forbid preamble, praise, and summary; require a bulleted list of issues with concrete fixes.
- Cap length (~250–300 words).

Keep prompts self-contained — Haiku subagents have no conversation context and can't see prior messages or each other's output.

## Step 4: Aggregate

When all five return, synthesize:

1. **One short section per lens** — a few bullets of the highest-value issues from that reviewer. Don't paste their raw output verbatim; tighten it.
2. **A "Cross-reviewer agreement" section** — the issues that surfaced across multiple lenses. This is the most valuable part of the output; do not skip it. If two or more reviewers independently flagged the same thing, that's the strong signal — call it out explicitly with which lenses agreed.
3. **A short "act first" recommendation** — 2–4 items, ordered by how many reviewers agreed and how high-leverage the fix is.

Keep the aggregate scannable. The user already paid for five parallel runs; the synthesis should make the breadth feel useful, not overwhelming.

## What to avoid

- **Don't run reviewers serially.** Parallel is the whole point; serial wastes wall-clock time for no benefit.
- **Don't auto-fix.** This skill produces a review, not edits. If the user wants fixes, they'll ask in a follow-up.
- **Don't pad the aggregate with the reviewers' praise** — the prompts forbid praise from reviewers, but if any leaks through, drop it.
- **Don't merge near-duplicate items silently.** If three reviewers flagged the same line, say so — that overlap is signal, not noise to dedupe away.
- **Don't substitute your own opinion for a reviewer's.** If you disagree with a reviewer's flag, surface it under their lens anyway and note your disagreement in the cross-agreement section. The user can decide.

## Why this works

Five Haiku reviewers cost a fraction of one careful Opus review and catch a different distribution of issues. Each lens primes the model to notice things a generalist sweep misses (e.g. "tests" lens reliably surfaces tautological assertions that a "everything review" prompt glosses over). The agreement section is what turns five independent opinions into a confident recommendation — issues flagged by one reviewer are suggestive; issues flagged by three are almost always worth fixing.
