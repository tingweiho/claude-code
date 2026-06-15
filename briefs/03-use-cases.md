# Module 3: Use Cases by Domain — how the work actually gets done

Module bg: ODD module → `style="background: var(--color-bg-warm)"`. id = `module-3`, number `03`.
**NO QUIZZES.** This module owns a mandatory **data-flow animation** (the merge-request relay).

### Teaching Arc
- **Metaphor:** A relay race. The day's work isn't one job — it's a baton passed between four very different legs: crunching numbers, drawing charts, writing for humans, and shipping code. Same runner, different terrain.
- **Opening hook:** "A normal day spans four jobs that have almost nothing in common. The same tool handles all four — it just changes mode."
- **Key insight:** Skills aren't trivia; they're how Claude switches *register* — the rigor of analysis, the taste of visualization, the voice of internal comms, the discipline of shipping code.
- **Why care:** Seeing the four lanes side by side shows what's automatable and where judgment still has to live.

### Screens (5)

**Screen 1 — Four lanes.** Use `.icon-rows` (4 rows), each with the powering skills named in `<code>`:
- 📊 **Data analysis** — "why did this metric move?" → `data-analysis` + `aircall-data-stack`
- 📈 **Visualization** — turning a table into a chart someone *gets* → `data-viz`
- ✍️ **Communication** — status updates, docs, decks → `internal-comms`, `aircall-confluence`, `aircall-slides`, `aircall-slack`
- 🗂️ **Productivity / admin** — the daily grind, automated → `daily-digest`, `canvas-tracker` (deep-dived next module)

**Screen 2 — Lane 1: Data analysis.** 2-3 sentences: the `data-analysis` skill enforces rigor a rushed analyst skips. Use `.pattern-cards` for its 5 modes: Diagnostic, Exploratory, Descriptive, Experimental (A/B), Predictive. Then a short code↔English of a representative query in my house style (snake_case, clear aliases — illustrative, anonymized):
```
select
    signup_week,
    count(distinct user_id) as signups
from clean_signups
where signup_week >= date_trunc('week', current_date) - interval '8 weeks'
group by 1
order by 1
```
RIGHT: "Count distinct users per week..." / "...for the last 8 weeks..." / "...so I can see if last week's drop is real or just noise." `.callout callout-info`: the rule is *confirm the drop is real before explaining it* — half of diagnostics is resisting the first story.

**Screen 3 — Lane 2: Visualization.** 2 sentences + `.pattern-cards` of a few `data-viz` rules drawn from the Cleveland–McGill hierarchy: "Position beats angle beats area" (bars > pies), "No dual Y-axes", "Sequential data gets a sequential ramp, not a rainbow". Then a `.badge-list` of my standing chart defaults (real saved preferences):
- `no gridlines` — removed by default, every library
- `centered titles` — by default
`.callout callout-accent`: these live in Claude's *memory*, so every chart starts correct without me asking (we'll see the memory system in Module 5).

**Screen 4 — Lane 3 & 4: Communication + admin.** Keep tight. `.icon-rows` (3-4): `internal-comms` (status reports, leadership updates, FAQs in the company's house format), `aircall-confluence` (wiki docs that land in the right place), `aircall-slides` (16:9 branded decks), `aircall-slack` (post / read / search). One sentence linking to the next module: the admin lane is so repetitive I handed most of it to scheduled robots — that's Module 4.

**Screen 5 — Shipping code: the merge-request relay (hero: data-flow animation).** This is the richest workflow. `.flow-animation` with `data-steps` (⚠️ no apostrophes inside labels — use plain words). Actors `flow-actor-1..5`: **Me**, **GitLab Pipeline**, **ci-watch**, **Bugbot**, **Main branch**.
Steps JSON (use double-quote delimiters, no inner apostrophes):
```
[
 {"highlight":"flow-actor-1","label":"I push a branch and open a merge request"},
 {"highlight":"flow-actor-2","label":"GitLab fires up a CI pipeline to test it","packet":true,"from":"actor-1","to":"actor-2"},
 {"highlight":"flow-actor-3","label":"ci-watch.sh polls that pipeline in the background","packet":true,"from":"actor-2","to":"actor-3"},
 {"highlight":"flow-actor-4","label":"Bugbot leaves an automated code review","packet":true,"from":"actor-3","to":"actor-4"},
 {"highlight":"flow-actor-3","label":"ci-watch reports back: green, or here are the failures","packet":true,"from":"actor-4","to":"actor-3"},
 {"highlight":"flow-actor-5","label":"Threads resolved, pipeline green: merge into main","packet":true,"from":"actor-3","to":"actor-5"}
]
```
Then a code↔English of what `ci-watch.sh` collapses a noisy pipeline page into (real, safe):
```
# ci-watch exit codes
0   green — pipeline passed, no open threads
1   failed — prints the last 120 lines of the failing job
2   timeout — 40-minute cap hit
4   green, but review threads still open
```
RIGHT: "Instead of refreshing a web page, I get one number." / "`1` drops me straight onto the failing log." / "`4` means tests pass but a human or Bugbot still wants changes — not done yet." `.callout callout-accent`: the script encodes a *definition of done* — green is necessary but not sufficient; open threads still block.

### Interactive Elements
- [x] **Data-flow animation** (hero, screen 5) — MR relay
- [x] **Code↔English** ×3 — SQL (2), ci-watch codes (5)  [minimum one required; we have several]
- [x] **Pattern cards** — analysis modes (2), viz rules (3)
- [x] **Badge list** — chart defaults (3)
- [x] **Icon rows** — four lanes (1), comms/admin (4)
- [x] **Callouts** — info (2), accent (3, 5); caption optional
- [ ] NO quiz

### Reference sections to read
- `interactive-elements.md` → Message Flow / Data Flow Animation (read the single-quote warning), Code↔English, Pattern/Feature Cards, Permission/Config Badges, Icon-Label Rows, Callout Boxes, Glossary Tooltips
- `content-philosophy.md` (all) · `gotchas.md` (all) · `design-system.md` → Color Palette (actor colors), Code Block Globals, Syntax Highlighting

### Tooltips to define
metric, A/B test, Cleveland–McGill hierarchy, dual Y-axis, sequential / rainbow palette, CI/CD pipeline, merge request (MR), branch, Bugbot, merge, "green" (CI), review thread, snake_case.

### Connections
- **Previous:** Module 2 explained how skills load on demand.
- **Next:** Module 4 takes the repetitive admin lane and shows the always-on robots that run it without me.
- **Tone:** terracotta accent; keep actor colors consistent with Module 2 where the same characters reappear; identifiers in `<code>`.
