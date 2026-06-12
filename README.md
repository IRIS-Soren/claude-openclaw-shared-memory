# Stop Being the Clipboard Between Your AIs

A lightweight markdown-based handoff workflow for Claude Code and OpenClaw.

---

## Why This Exists

I use two AI tools daily. One for planning, one for coding.

Every time I switch between them, I retype the same context: what was discussed, what changed, what's next.

Eventually I realized:

> **I wasn't using AI anymore. I was acting as a clipboard between AIs.**

This project is the fix — compressed to its simplest form.

---

## The Problem

- **OpenClaw** — planning, research, architecture, orchestration
- **Claude Code** — implementation, refactoring, deep engineering

They don't share context. The user carries all of it.

Each handoff means re-explaining: what happened, why, and where things stand.

---

## The Solution

Three shared markdown files. A fixed handoff protocol.

Each AI writes a structured entry when work is done. The next AI reads it before starting. Context passes through the filesystem — no server, no API, no framework.

---

## Demo

<video src="demo.mp4" width="800" controls autoplay loop muted></video>

The full loop:

```
OpenClaw                    Claude Code
   │                             │
   ├─ writes share.md ──────────►│
   │                             ├─ reads share.md
   │                             ├─ does the work
   │                             ├─ updates share.md
   │◄────────────────────────────┘
   │
   ├─ reads Claude's update
   ├─ continues working
```

---

## Quick Start

After running `setup.bat` (30 seconds):

1. In OpenClaw, write a test entry to `share_main.md`
2. In Claude Code, type: `看 share_main`
3. Claude reads the file and appends a response
4. Switch back to OpenClaw — the response is there

The user's only input at each handoff: **a single sentence.**

---

## Architecture

```
         Human
           │
    decision + dispatch
           │
     ┌─────┴─────┐
     ▼           ▼
 OpenClaw    Claude Code
     │           │
     │  writes   │  reads
     ▼           ▼
 ┌─────────────────────┐
 │   share_main.md     │
 │   share_vision.md   │
 │   share_yckz.md     │
 └─────────────────────┘
     ▲           ▲
     │  reads    │  writes
     │           │
 OpenClaw    Claude Code
```

Files live in the OpenClaw workspace. Claude Code reads and writes them via tool calls. No server. No sync. Just a filesystem.

---

## Workflow

```
OpenClaw → Claude Code:
  1. OpenClaw finishes work, writes to share file
  2. Open Claude Code, type: "看 share_vision"
  3. Claude reads context, confirms status, starts working

Claude Code → OpenClaw:
  1. Claude finishes work, updates share file
  2. Switch to OpenClaw, type: "看 share"
  3. OpenClaw reads Claude's update, continues
```

---

## Handoff Protocol

Both sides use the same format:

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

Append-only. Old entries become project history.

---

## Installation

### Windows

1. Download and extract this folder
2. Double-click `setup.bat`
3. Enter your OpenClaw workspace path and Claude Code project path
4. Done

### macOS / Linux

1. Copy `templates/share_*.md` to your OpenClaw workspace
2. Copy `templates/CLAUDE.md` to `.claude/` in your project
3. Merge `hooks/stop-hook.json` into `.claude/settings.local.json`

---

## Token Cost

Typically a few hundred tokens per handoff.

Share files are read via tool call, not injected into the system prompt. If you don't read the file, you don't pay for it.

---

## What This Is Not

- **Not** a new agent framework
- **Not** a shared memory system
- **Not** an MCP server
- **Not** an API integration layer

Shared memory is not a new idea (Blackboard architecture, 1985). Markdown-based memory has prior art (e.g., TICK.md). Agent handoff protocols exist in research and industry.

The only value here: compressing the Claude Code + OpenClaw handoff problem to its simplest working form.

---

## Design Principles

- **Filesystem as message bus** — the OS already gives you IPC for free
- **Append-only log** — every entry is preserved; the file is the audit trail
- **Human-in-the-loop** — the user decides when to hand off; AI handles the content
- **On-demand reading** — share files are not injected into system prompts; read only when needed
- **Zero moving parts** — no servers, no databases, no background processes

---

## Why Not MCP / Agent Frameworks?

| Approach | Setup Cost | Maintenance | Token Overhead |
|----------|-----------|-------------|----------------|
| MCP server | Write server + deploy | Ongoing | Low |
| Agent framework | Learn framework + code | Ongoing | Medium |
| ACP adapter | Write adapter | Ongoing | Medium |
| Clipboard (manual) | Zero | Zero | Very high |
| **Shared markdown files** | **Zero** | **Zero** | **Minimal** |

For a solo developer shipping real projects, the most expensive resource is not tokens — it's time spent maintaining infrastructure.

---

## Limitations

- **Asynchronous only** — both AIs cannot work on the same file simultaneously
- **Human-initiated** — the user must switch tools and say "看 share"
- **No conflict resolution** — don't let both AIs modify the same source file at once
- **Discipline required** — remember to update share (the Stop hook helps)

---

## Related Work

- [TICK.md](https://github.com/niccokunzmann/tickmd) — markdown-based task tracking
- Blackboard architecture (Hayes-Roth, 1985) — the original shared-memory AI pattern
- [Claude Code Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) — used for the exit reminder

---

## License

MIT
