# Module 5: Memory & Self-Improvement — the feedback loop

Module bg: ODD module → `style="background: var(--color-bg-warm)"`. id = `module-5`, number `05`.
**NO QUIZZES.**

### Teaching Arc
- **Metaphor:** A new colleague who actually remembers. Tell a good hire once — "we always merge, never rebase" — and you never repeat it. Memory is how Claude becomes that hire instead of the one you re-train every Monday.
- **Opening hook:** "The first time I corrected Claude, it forgot by the next session. Now it doesn't."
- **Key insight:** Corrections become *durable* by being written to small, single-fact files in `memory/`. Each file has a one-line description Claude scans for relevance — so the right past correction resurfaces at the right moment, without bloating every session.
- **Why care:** This is what turns Claude Code from a clever stranger into a teammate that compounds. The setup gets better the more you use it.

### Screens (5)

**Screen 1 — The memory folder.** 2 sentences + a `.file-tree` of `memory/` showing the three categories (use anonymized example filenames):
- `MEMORY.md` — the index: one line per memory, loaded every session
- `feedback-*.md` — how I like to work (corrections, confirmed approaches)
- `project-*.md` — ongoing context that the code can't tell you
- `reference-*.md` — pointers to IDs, docs, dashboards
`.caption`: "~20 single-fact files. One fact per file — easy to add, easy to retire."

**Screen 2 — How a correction becomes permanent (hero: code↔English).** LEFT — a real memory file (anonymized, use as given):
```
---
name: feedback-viz-no-gridlines
description: No gridlines + centered titles by default
metadata:
  type: feedback
---
No gridlines + centered titles by default; applies
to every plotting library. Why: cleaner, less ink.
```
RIGHT: "A name, so I can link to it." / "A description — the line Claude scans to decide if this memory is relevant *right now*." / "The fact itself, plus the *why*, so it is applied with judgment, not blindly." `.callout callout-accent`: I said "drop the gridlines" *once*. Now every chart starts that way — across Matplotlib, Plotly, anything.

**Screen 3 — The compounding loop.** Use `.flow-steps` (horizontal flow, rotates vertical on mobile):
1. I correct Claude in conversation →
2. It writes a one-line memory file →
3. Next session, the index loads and the description matches my task →
4. The behavior changes — no reminder needed.
2 sentences framing this as a loop that tightens over time. `.callout callout-info`: three layers reinforce each other — `CLAUDE.md` (who I am), **skills** (how to do a procedure), **memory** (corrections to both).

**Screen 4 — Where should a fact live?** Not everything belongs in memory. `.pattern-cards` (3) as decision guidance:
- **`CLAUDE.md`** — stable identity & global preferences ("be concise", "snake_case SQL").
- **A skill** — a *procedure* you repeat ("how to QA a dbt model", "how to format a leadership update").
- **`memory/`** — a *specific correction or fact* that surprised you once and shouldn't again.
Plus `known_issues.md` — a running fixes log (~16 entries) for "this broke, here's why, here's the fix." And `regression-guard`, a skill that enforces *baseline → change → re-verify* so a new feature doesn't silently break the old path.

**Screen 5 — Real standing orders (the system working).** Showcase actual saved learnings as `.callout` cards / `.icon-rows` (anonymized, all real):
- *Merge, never rebase + force-push* — avoids false conflicts and rewritten history.
- *No gridlines, centered titles* — every chart, every library.
- *Always self-assign my merge requests and resolve conflicts before reporting done.*
- *The project canvas is full-replace only* — section-level edits corrupt it.
- *Headless runs can't use connectors* — design around it (the Module 4 lesson, now a memory).
`.callout callout-accent`: none of these are in the code. They're the texture of *how I work* — and they survive across every session because they're written down.

### Interactive Elements
- [x] **Code↔English** — memory file (screen 2, hero)
- [x] **File tree** — `memory/` (screen 1)
- [x] **Flow steps** — the compounding loop (screen 3)
- [x] **Pattern cards** — where a fact lives (screen 4)
- [x] **Callout / icon-row cards** — real learnings (screen 5)
- [x] **Callouts** — accent (2, 5), info (3); caption (1)
- [ ] NO quiz

### Reference sections to read
- `interactive-elements.md` → Code↔English, Visual File Tree, Flow Diagrams, Pattern/Feature Cards, Callout Boxes, Icon-Label Rows, Glossary Tooltips
- `content-philosophy.md` (all) · `gotchas.md` (all) · `design-system.md` → Color Palette, Code Block Globals

### Tooltips to define
memory (persistent), frontmatter, slug, index, regression, baseline, rebase, force-push, dbt, canvas, connector.

### Connections
- **Previous:** Module 4 ended on a lesson ("headless can't connect") that itself became a memory — a perfect handoff.
- **Next:** Module 6 distills everything into a short list of best practices anyone can copy.
- **Tone:** terracotta accent; identifiers in `<code>`; first-person, reflective.
