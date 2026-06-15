# Module 6: Best Practices & Hard-Won Lessons

Module bg: EVEN module → `style="background: var(--color-bg)"`. id = `module-6`, number `06`.
**NO QUIZZES.** This is the closer — distilled, copyable, confident. End on the one-diagram architecture.

### Teaching Arc
- **Metaphor:** Day-one field notes — the things I wish someone had told me before I started, written for the next person.
- **Opening hook:** "If you copy one thing from my setup, copy the habits — not the files."
- **Key insight:** The setup works because of a few principles, not because of any one clever script. Lean config, on-demand skills, ruthless redaction, and keeping your failures around as lessons.
- **Why care:** These transfer to *any* Claude Code setup, on any team.

### Screens (5)

**Screen 1 — `CLAUDE.md` is a directory, not a manual.** The headline lesson, callback to Module 1. 2 sentences + a code↔English showing the *shape* of a good lean config (real structure, anonymized):
```
## Who I am          (1-2 lines)
## Communication     (how to talk to me)
## Coding            (my conventions)
## Skills            (index — one line each, points outward)
## Reference files   (pointers, not content)
```
RIGHT: "Identity and preferences up top — stable, rarely changes." / "Then an *index* of skills: one line each, no detail." / "The detail lives in the skill folders and memory — `CLAUDE.md` just routes to it." `.callout callout-accent`: **Mine is 48 lines.** Every line read before each session is attention spent — a bloated `CLAUDE.md` makes Claude *worse*, not better. Keep it a table of contents.

**Screen 2 — The transferable habits.** `.pattern-cards` (3-4):
- 🎯 **Load on demand** — put procedures in skills, not in `CLAUDE.md`. Context is a budget; spend it only when relevant.
- 🍴 **Fork, don't build from zero** — start from a good open-source skill (e.g. Zara Zhang's), rebrand, then grow your own with `skill-creator`.
- 🧠 **Write down corrections** — one-line memory files turn "I had to say it twice" into "I never say it again".
- 🤖 **Automate the boring, keep humans in the loop** — default-approve flows (like my EOD → canvas loop) keep things moving without going rogue.

**Screen 3 — Security & redaction discipline.** 2 sentences + `.badge-list` of guardrails (real, safe):
- `Bash(rm -rf*)` — denied globally
- `Bash(git push --force*)` — denied globally
- `Bash(sudo*)` — denied globally
`.callout callout-warning`: a *shareable* setup must never leak live secrets — connection strings, account numbers, client secrets, tokens. **This very course was redaction-audited before it left my machine.** Treat anything you share like a screenshot that lives forever.

**Screen 4 — Keep your failures.** The most reusable part of a setup is the list of what *didn't* work. `.icon-rows` / `.callout` cards (all real):
- *Two cron scripts retired* — they tried to DM from a headless run, which can't connect. The wall taught the rule.
- *Trigger prompts got wiped by a UI bug* — recovered from a backup file + the API. Now every prompt is backed up.
- *Rebase → merge* — auto-rebasing replayed commits and invented conflicts; switching to merge ended them.
`.callout callout-info`: a `known_issues.md` log is cheap insurance — future-you (and future-Claude) reads it before repeating a mistake.

**Screen 5 — The whole system, one picture (hero).** Use `.icon-rows` or `.flow-steps` as a layered stack, top to bottom:
1. **Config** (`CLAUDE.md` + settings) — who I am, what's allowed.
2. **Skills** — on-demand expertise, forked and homegrown.
3. **Automation** — hooks, cron, cloud triggers running the recurring work.
4. **Memory** — corrections that make all three smarter over time.
Closing `.callout callout-accent`: **Start small.** A lean `CLAUDE.md`, one skill, one hook. Add a skill each time you repeat yourself, automate what's boring, and let memory catch the corrections. The system compounds — that's the whole point. End with one warm `.caption` line signing off (e.g. *"Built with the very setup it describes."*).

### Interactive Elements
- [x] **Code↔English** — lean `CLAUDE.md` shape (screen 1)
- [x] **Pattern cards** — transferable habits (screen 2)
- [x] **Badge list** — guardrails (screen 3)
- [x] **Icon rows / flow steps** — failures (4), the architecture stack (5, hero)
- [x] **Callouts** — accent (1, 2, 5), warning (3), info (4); caption (5)
- [ ] NO quiz

### Reference sections to read
- `interactive-elements.md` → Code↔English, Pattern/Feature Cards, Permission/Config Badges, Icon-Label Rows, Flow Diagrams, Callout Boxes, Glossary Tooltips
- `content-philosophy.md` (all) · `gotchas.md` (all) · `design-system.md` → Color Palette, Module Structure

### Tooltips to define
context budget / context window, skill, `skill-creator`, hook, cron, cloud trigger, secret / credential, connection string, token, rebase vs merge, `known_issues.md`.

### Connections
- **Previous:** Module 5 showed the memory system; this module turns the whole tour into principles.
- **Next:** none — this is the finale. Land it with confidence and a clear "start small" call to action.
- **Tone:** terracotta accent; identifiers in `<code>`; generous whitespace; this is the takeaway slide — make it quotable.
