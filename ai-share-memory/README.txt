AI Share Memory — OpenClaw × Claude Code 共享记忆协作系统

=== 简介 ===

本工具用于在 OpenClaw 和 Claude Code 之间建立共享记忆机制，
使两个 AI 工具能够通过 Markdown 文件交换上下文信息，
避免用户在切换工具时手动传递项目状态。


=== 解决的问题 ===

同时使用 OpenClaw 和 Claude Code 时，每次切换都需要手动复制粘贴上下文：
- 从 OpenClaw 切到 Claude Code：需要重新解释当前任务背景、修改了什么、下一步做什么
- 从 Claude Code 切回 OpenClaw：需要重新说明做了什么改动、有什么遗留问题

本方案通过在公共目录放置 share 文件，让两个 AI 工具自动读写上下文信息。
用户切换时只需说一句"看 share"，无需手动传递任何内容。


=== 工作原理 ===

OpenClaw 和 Claude Code 共享同一个文件目录。
每个 AI 完成重要操作后，在对应的 share 文件中追加一条标准化记录。
下一位 AI 接手时先读取文件，获取前一个 AI 的工作内容和当前状态。

文件结构：

  OpenClaw workspace\
  ├── share_main.md       ← main agent 共享记忆
  ├── share_vision.md     ← vision agent 共享记忆
  └── share_yckz.md       ← yckz agent 共享记忆

  Claude Code 项目\.claude\
  ├── CLAUDE.md           ← 协作规则（启动时自动加载）
  └── settings.local.json ← Stop hook（退出时提醒更新 share）


=== 配置方法 ===

Windows 用户：

  1. 双击 setup.bat
  2. 按提示输入 OpenClaw workspace 路径和 Claude Code 项目路径
  3. 脚本自动完成以下操作：
     - 在 workspace 创建 share_main.md / share_vision.md / share_yckz.md
     - 将 CLAUDE.md 复制到项目的 .claude 目录
     - 在 settings.local.json 中添加 Stop hook

Mac / Linux 用户（手动配置）：

  1. 将 templates/ 下的 share_*.md 复制到 OpenClaw workspace
  2. 将 templates/CLAUDE.md 复制到项目的 .claude/ 目录
  3. 将 hooks/stop-hook.json 的内容合并到 .claude/settings.local.json


=== 日常使用 ===

OpenClaw → Claude Code 切换：

  在 OpenClaw 完成讨论后，切换到 Claude Code，输入：
    "看 share_vision"（或其他 share 文件）
  Claude Code 将自动读取对应文件中的上下文，直接继续工作。

Claude Code → OpenClaw 切换：

  Claude Code 完成代码任务后，会按 CLAUDE.md 中的规则主动更新 share 文件。
  切回 OpenClaw 后，OpenClaw 读取 share 文件即可获知最新进展。

关键词：

  在 Claude Code 中输入以下任一关键词即可触发读取：
    "看 share" / "接着做" / "继续" / "接力" / "share"


=== Share 文件格式 ===

双方统一使用以下模板追加条目：

  ---
  agent: openclaw-main | claude-code
  timestamp: 2026-06-12T14:30:00+08:00
  status: done | in-progress | blocked
  ---

  ## 当前状态
  [一句话描述]

  ## 本次变更
  - 文件: 路径 — 做了什么

  ## 关键决策
  - 决策内容 + 原因

  ## 待办 / 阻塞
  - [ ] 待处理事项

  ## 给合作方的备注
  [自由文本]

规则：
  - 追加到文件末尾，不覆盖已有内容
  - 老信息保留作为项目历史
  - agent 字段区分来源


=== Token 消耗 ===

单次接力（读取 share + 写入更新）约消耗 500 tokens。
Share 文件不会注入 system prompt，仅在显式调用时按需读取。


=== 注意事项 ===

  - 不要让两个 AI 同时修改同一个源文件
  - Share 文件只追加不删除，老信息是项目历史的一部分
  - 退出 Claude Code 时 Stop hook 会弹窗提醒更新 share


=== 文件清单 ===

  setup.bat              Windows 一键配置入口
  setup.ps1              配置脚本
  templates/CLAUDE.md    Claude Code 协作规则模板
  templates/share_main.md     main agent 模板
  templates/share_vision.md   vision agent 模板
  templates/share_yckz.md     yckz agent 模板
  hooks/stop-hook.json   Stop hook 配置
