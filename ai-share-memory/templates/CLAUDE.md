# Claude Code × OpenClaw Handoff Rules / 协作规则

## 1. Read share on startup or keyword trigger / 启动时或关键词触发读取

When the user says **"read share", "check share", "catch up", "pickup", "continue", "handoff", "share"**
(or Chinese: **"看 share"、"接着做"、"继续"、"接力"、"share"**),
or when you need context from OpenClaw, read the relevant share file:

| Scenario / 场景 | File / 文件 |
|------|------|
| Research / vision agent / 科研课题 | `<OpenClaw workspace>\share_vision.md` |
| Main agent / general tasks / 主 agent、杂事 | `share_main.md` |
| yckz / standalone dev / 独立开发 | `share_yckz.md` |

If unsure, ask. After reading, briefly confirm current status before working.

## 2. Update share after important work / 完成重要操作后更新 share

After the following, **proactively** append an entry to the relevant share file:
- Refactoring, creating/deleting files, fixing critical bugs
- Completing a task milestone the user assigned
- Making a key decision that affects future work

**Format / 追加格式** (unified with OpenClaw):

```
---
agent: claude-code
timestamp: <ISO-8601 timestamp>
status: done | in-progress | blocked
---

## Current Status / 当前状态
[one-line summary]

## Changes Made / 本次变更
- file: `relative/path` — what and why

## Key Decisions / 关键决策
- decision + rationale

## Pending / Blocked / 待办
- [ ] items needing user or OpenClaw

## Notes for OpenClaw / 给 OpenClaw 的备注
[free-form context]
```

## 3. Append only / 追加不覆盖

- Append entries to the **end** of the file. Never overwrite.
- Old entries are project history — keep them.
- Use the `agent` field to distinguish source (`claude-code` vs `openclaw-main` etc.)
