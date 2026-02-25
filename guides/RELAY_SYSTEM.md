# Bot Relay System — Replicant Memory Transfer

## The Problem
Sub-agents (especially Sonnet) burn out or time out on large tasks. Quality degrades as context fills up. 10-minute timeout means complex builds get cut halfway.

## Optimal Productive Windows (Research)

### Claude Sonnet 4
- **Context window:** 200K tokens
- **Sweet spot:** First 50-80K tokens of output (roughly 3-5 minutes of heavy generation)
- **Quality degrades after:** ~60-70% context utilization
- **Optimal relay point:** 4-5 minutes into a 10-min session, or when output hits ~15K tokens
- **Best for:** Research, code generation, content writing, analysis

### Claude Opus 4
- **Context window:** 200K tokens
- **Sweet spot:** Maintains quality much longer (designed for extended reasoning)
- **Quality degrades after:** ~80% context utilization
- **Optimal relay point:** 7-8 minutes, or ~25K output tokens
- **Best for:** Complex architecture, multi-step reasoning, orchestration

### Claude Haiku
- **Context window:** 200K tokens
- **Sweet spot:** First 20-30K tokens (very fast, 1-2 minutes)
- **Quality degrades after:** ~50% context utilization (smaller model = faster fatigue)
- **Optimal relay point:** 2-3 minutes
- **Best for:** Simple formatting, summaries, quick lookups, data extraction

## The Relay Pattern

### Architecture: Checkpoint + Spawn

```
Task arrives
    ↓
Bot A spawns (Phase 1)
    ↓ works for ~4-5 min
    ↓ saves CHECKPOINT file (what's done, what's left, intermediate state)
    ↓ completes or times out
    ↓
Commander (A/Opus) reads checkpoint
    ↓
Bot B spawns (Phase 2) with compressed context from checkpoint
    ↓ works for ~4-5 min
    ↓ saves updated CHECKPOINT
    ↓
... repeat until task complete
```

### Checkpoint File Format
```json
{
  "task": "Build amotive.io marketing page",
  "phase": 2,
  "totalPhases": 3,
  "completed": [
    "index-v2.html built and saved",
    "website-v2.html built and saved"
  ],
  "inProgress": "marketing-v2.html",
  "remaining": ["premium-v2.html"],
  "keyContext": "Use emerald green #2ECC71 accent, match index-v2.html style exactly, intake form pre-selects Marketing",
  "filesCreated": [
    "/path/to/index-v2.html",
    "/path/to/website-v2.html"
  ],
  "timestamp": "2026-02-19T00:15:00Z",
  "model": "claude-sonnet-4",
  "tokensUsed": 45000
}
```

### Key Rules
1. **Every multi-file task gets pre-split into phases** (1 file per phase max)
2. **Each phase bot builds ONE thing and saves a checkpoint**
3. **Checkpoint = compressed memory** — only what the next bot needs to continue
4. **Commander reads checkpoint and spawns next bot with minimal context**
5. **Fresh bot = fresh quality** — no context fatigue

## Implementation: Relay Spawn Function

### Commander Pattern (used by A/Opus)
For any task that might take >5 minutes or produce >1 file:

1. Split task into atomic phases (1 deliverable each)
2. Write phase instructions to a task file
3. Spawn Bot A for Phase 1 with timeout 300s (5 min)
4. When Bot A completes/times out → read checkpoint
5. Spawn Bot B for Phase 2 with checkpoint context
6. Repeat until all phases done
7. Run QA critique on final output

### Prompt Compression for Relay
When passing context to the next bot:
- Strip all intermediate reasoning/thinking
- Keep only: what was built, file paths, remaining tasks, key design decisions
- Target: <2000 tokens of context passed to next bot
- Include "Read [file] for reference" instead of pasting file contents

## Anti-Burnout Strategies

### 1. Task Decomposition
BAD: "Build 4 HTML pages with full CSS and JS"
GOOD: "Build index-v2.html" → checkpoint → "Build website-v2.html" → checkpoint → etc.

### 2. Reference Files Instead of Context
BAD: "Here's the full 2000-line CSS file, now build a page matching it"
GOOD: "Read /path/to/index-v2.html and match its style exactly"

### 3. Shorter Timeouts
- Sonnet: 300s (5 min) instead of 600s (10 min)
- Better to get 90% quality in 5 min than 70% quality in 10 min
- The relay bot picks up fresh

### 4. One File Per Bot
Never ask a Sonnet bot to build more than 1 complex file per session.
1 bot = 1 file = 1 checkpoint. Always.
