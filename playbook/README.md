# Claude Code Playbook

An interactive course on how I actually use Claude Code — not the basics, but the full system: skill libraries, automation hooks, memory, and real use cases.

## → [View the playbook](https://tingweiho.github.io/claude-code/playbook/)

Or clone and open `index.html` locally — no setup required.

## What's inside

| Module | Topic |
|---|---|
| 1 | The System — `~/.claude/` as an operating layer |
| 2 | Skill Library — reusable capabilities on demand |
| 3 | Use Cases — what I actually use it for |
| 4 | Automation — hooks, cron, and background agents |
| 5 | Memory — persistent context across sessions |
| 6 | Best Practices — what works, what doesn't |
| 7 | Resources |

## Repo structure

```
index.html      ← the course (open this)
styles.css      ← stylesheet
main.js         ← interactivity
assets/         ← logo SVGs
src/            ← source files
  _base.html    ← shell (title, nav dots)
  modules/      ← one HTML file per module
  build.sh      ← rebuild: bash src/build.sh
```
