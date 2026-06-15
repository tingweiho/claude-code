# Module 2: The Skill Library — load-on-demand expertise

Module bg: EVEN module → `style="background: var(--color-bg)"`. id = `module-2`, number `02`.
**NO QUIZZES.** This module owns the course's mandatory **group-chat animation**.

### Teaching Arc
- **Metaphor:** A team of on-call specialists. You describe a problem in plain words; the right specialist walks in already briefed, does the work, and leaves. You never page them by name.
- **Opening hook:** "I never type 'use the SQL skill.' I describe what I want, and the right expertise loads itself."
- **Key insight:** A skill is a folder with a `SKILL.md` file. Only its one-line *description* sits in context; the full instructions load *only* when your request matches. That keeps Claude's attention budget lean while giving it deep, specific know-how on demand.
- **Why care:** This is the highest-leverage habit in the whole setup — you teach Claude a procedure once, and it reappears exactly when relevant, forever.

### Screens (5)

**Screen 1 — What a skill is.** 2-3 sentences + a `.callout callout-accent`. A skill = a folder containing `SKILL.md` (the instructions) and a `description` (the trigger). Claude reads only the descriptions at startup; matching one pulls the full file into context. Metaphor grounded: "the specialist's business card is always on the desk; you only call them in when the job fits."

**Screen 2 — The library at a glance.** Use `.pattern-cards` (3 cards = 3 clusters). Exemplify 2-3 skills per cluster (don't list all 16 at equal depth):
- **Aircall ops** (border `--color-actor-1`): the domain skills — `aircall-data-stack` (warehouse + BI), `canvas-tracker` (the Slack project tracker), `scheduled-triggers`, `internal-comms`, plus `aircall-slack`, `aircall-confluence`, `gitlab-cli`.
- **Output & analysis** (border `--color-actor-2`): `data-analysis`, `data-viz`, `aircall-slides`, `codebase-to-course` (the one that built *this* page), `pdf`, `hex`.
- **Meta** (border `--color-actor-3`): `prompt-authoring`, `skill-creator` (the skill that makes skills), `regression-guard`.
One `.caption` under the cards: "16 skills, grouped by job — not alphabetised."

**Screen 3 — How matching works (hero: group-chat animation).** Frame the trigger mechanic as a conversation. `.chat-window id="chat-skills"`. Actors & colors: **Me** (`--color-actor-5`), **Dispatcher** = Claude's router (`--color-text-secondary` or `--color-actor-4`), **data-analysis** (`--color-actor-2`), **aircall-data-stack** (`--color-actor-1`). Messages (each `data-msg` index, `display:none`, first `.chat-avatar` letter):
0. Me: "Why did weekly signups drop last week?"
1. Dispatcher: "That's a diagnostic question that needs the warehouse — paging two specialists."
2. data-analysis: "On it. Loading diagnostic mode: confirm the drop is real before explaining it."
3. aircall-data-stack: "I'll pull the numbers from Redshift and check the dbt models feeding that metric."
4. Dispatcher: "Neither was named in the request — both matched on what it *meant*."
Include `.chat-typing` block and `.chat-controls` (`.chat-next-btn`, `.chat-all-btn`, `.chat-reset-btn`, `.chat-progress`). Follow with one sentence: the skills weren't summoned by name — they matched the *intent*.

**Screen 4 — The description IS the trigger.** Code↔English block. LEFT (real, anonymized `SKILL.md` frontmatter — use as given):
```
---
name: data-viz
description: Use whenever making a chart, plot, or
  visualization in a notebook. Trigger on "plot this",
  "visualize", "show the distribution", "compare segments".
---
```
RIGHT: "Every skill starts with a name and a description." / "Only this description sits in Claude's memory until needed." / "Those example phrases are the trip-wires — say something close and the full skill loads." 
`.callout callout-info`: writing a *good* description is its own craft — too vague and it fires constantly; too narrow and it never fires. (There's even a `prompt-authoring` skill for exactly this.)

**Screen 5 — Where the skills came from.** Three `.pattern-cards`:
- **Built from scratch** (🛠️): the Aircall-specific skills encode internal know-how no download could have — warehouse conventions, the canvas rules, the doc style.
- **Forked & rebranded** (🍴): `codebase-to-course` and the `frontend-slides` engine behind `aircall-slides` come from the open-source builder **Zara Zhang** (`github.com/zarazhangrui`). I forked them and swapped in my own branding and conventions.
- **Straight from Anthropic** (📦): `skill-creator` and `pdf` are Anthropic's own skills; the `ralph-loop` plugin installs from the official `anthropics/claude-plugins-official` marketplace.
End with a `.callout callout-accent`: **"Don't build from zero."** Fork a good skill, rebrand it, and bend it to your conventions — then use `skill-creator` to grow your own. (This is one of the best-practice threads we pull together at the end.)

### Interactive Elements
- [x] **Group-chat animation** (hero, screen 3) — the matching mechanic
- [x] **Code↔English** — `SKILL.md` frontmatter (screen 4)
- [x] **Pattern cards** — clusters (screen 2), provenance (screen 5)
- [x] **Callouts** — accent (1, 5), info (4); **caption** (2)
- [ ] NO quiz

### Reference sections to read
- `interactive-elements.md` → Group Chat Animation, Code↔English Translation Blocks, Pattern/Feature Cards, Callout Boxes, Glossary Tooltips
- `content-philosophy.md` (all) · `gotchas.md` (all) · `design-system.md` → Color Palette (actor colors), Module Structure

### Tooltips to define
skill, `SKILL.md`, frontmatter, description (as trigger), context / context window, router, notebook, fork, plugin, marketplace, repo, open source.

### Connections
- **Previous:** Module 1 mapped the whole `~/.claude/` folder and named the `skills/` directory.
- **Next:** Module 3 shows these skills *in action* across a real day's work.
- **Tone:** terracotta accent; assign each skill-character a consistent actor color; identifiers in `<code>`.
