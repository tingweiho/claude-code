# Claude Code Playbook

An interactive course on how I actually use Claude Code — not the basics, but the full system: skill libraries, automation hooks, memory, and real use cases.

Built with the [`codebase-to-course`](https://github.com/anthropics/claude-code) skill. Runs entirely in the browser with no setup required.

## View it

**[→ Open the playbook](https://tingweiho.github.io/claude-code)**

Or clone and open `index.html` locally.

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

## Run locally

```bash
git clone https://github.com/tingweiho/claude-code.git
open claude-code/index.html
```

To rebuild from source after editing modules:

```bash
cd claude-code && bash build.sh
```
