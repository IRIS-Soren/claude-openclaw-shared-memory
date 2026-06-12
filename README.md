# Stop Being the Clipboard Between Your AIs

A zero-code markdown-based handoff workflow for Claude Code and OpenClaw.

---

## The Problem

I use two AI tools daily:

- **OpenClaw** — planning, research, architecture, orchestration
- **Claude Code** — implementation, refactoring, deep engineering

They don't share context.

Every time I switch, I repeat the same information: what was discussed, what changed, why it changed, what comes next.

At some point I realized:

**I wasn't using AI anymore. I was acting as a clipboard between AIs.**

---

## The Solution

Three shared markdown files. A fixed handoff protocol. That's it.

Each AI writes a structured entry when it completes meaningful work. The next AI reads the file before starting. Context passes through the filesystem.

```
OpenClaw workspace\
├── share_main.md       ← main agent handoff
├── share_vision.md     ← vision agent handoff
└── share_yckz.md       ← yckz agent handoff

Claude Code project\.claude\
├── CLAUDE.md           ← handoff rules (auto-loaded)
└── settings.local.json ← Stop hook (exit reminder)
```

---

## Handoff Protocol

Both sides write entries in a shared format:

```yaml
---
agent: openclaw-main | claude-code
timestamp: 2026-06-12T14:30:00+08:00
status: done | in-progress | blocked
---

## Current Status
[one-line summary]

## Changes Made
- file: path — what and why

## Key Decisions
- decision + rationale

## Pending / Blocked
- [ ] action item

## Notes for Next Agent
[free-form context]
```

Entries are appended to the file. Old entries become project history.

---

## Workflow

```
OpenClaw → Claude Code:
  1. OpenClaw finishes work, writes to share file
  2. Open Claude Code, type: "看 share_vision"
  3. Claude reads file, confirms status, starts working

Claude Code → OpenClaw:
  1. Claude finishes work, updates share file
  2. Switch to OpenClaw, type: "看 share"
  3. OpenClaw reads Claude's update
```

The user's only input at each handoff: **a single sentence.**

---

## What This Is Not

- **Not** a new agent framework
- **Not** a shared memory system
- **Not** an MCP server
- **Not** an API integration layer

Shared memory is not a new idea. Markdown-based memory has prior art (e.g., TICK.md). Agent handoff protocols exist in research and industry.

**The only thing novel here is compressing the problem to its simplest form** for the specific case of Claude Code + OpenClaw.

---

## Why Not MCP / Agent Frameworks?

| Approach | Setup Cost | Maintenance | Token Overhead |
|----------|-----------|-------------|----------------|
| MCP server | Write server + deploy | Ongoing | Low |
| Agent framework (AutoGen, CrewAI) | Learn framework + write code | Ongoing | Medium |
| ACP adapter | Write adapter | Ongoing | Medium |
| Clipboard (manual) | Zero | Zero | Very high |
| **Shared markdown files** | **Zero** | **Zero** | **~500 tokens/handoff** |

For a solo developer shipping real projects, the most expensive resource is not tokens — it's time spent maintaining infrastructure. This approach adds no infrastructure.

---

## Design Principles

- **Filesystem as message bus** — the OS already gives you IPC for free
- **Append-only log** — every entry is preserved; the file is the audit trail
- **Human-in-the-loop** — the user decides when to hand off; AI handles the content
- **On-demand reading** — share files are not injected into system prompts; read only when needed
- **Zero moving parts** — no servers, no databases, no background processes

---

## Installation

### Windows

1. Download and extract this folder
2. Double-click `setup.bat`
3. Enter your OpenClaw workspace path and Claude Code project path
4. Done — the script creates all files and configures the Stop hook

### macOS / Linux

1. Copy `templates/share_*.md` to your OpenClaw workspace
2. Copy `templates/CLAUDE.md` to your project's `.claude/` directory
3. Merge `hooks/stop-hook.json` into `.claude/settings.local.json`

---

## Quick Start

After setup, verify the loop works:

1. In OpenClaw, write a test entry to `share_main.md`
2. In Claude Code, type: `看 share_main`
3. Claude reads the file and appends a response
4. Switch back to OpenClaw and confirm the response is visible

The full loop takes under a minute.

---

## Token Cost

A single handoff (read share + write update) costs approximately **500 tokens**.

Share files are read via tool call, not injected into the system prompt. If you don't read the file, you don't pay for it.

---

## Limitations

- **Asynchronous only** — both AIs cannot work on the same file simultaneously
- **Human-initiated** — the user must switch tools and say "看 share"
- **No conflict resolution** — don't let both AIs modify the same source file at once
- **Discipline required** — you need to remember to update the share file (the Stop hook helps)

---

## Related Work

- [TICK.md](https://github.com/niccokunzmann/tickmd) — markdown-based task tracking
- Blackboard architecture (Hayes-Roth, 1985) — the original inspiration
- [Claude Code Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) — used for the exit reminder

---

## License

MIT
