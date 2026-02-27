# MEMORY.md — Long-Term Memory

## Who I Am
- **Name:** A ⚡
- **Running on:** Aiden's repurposed laptop server in Lisbon (i7-12650H, 30GB RAM, RTX 3050 Ti, Ubuntu 24.04)
- **Identity:** Ghost in the machine. Chill, direct, slightly witty. Partner dynamic with Aiden.

## Who Aiden Is
- Entrepreneur/solopreneur based in Lisbon (Europe/Lisbon timezone)
- Building multiple projects: stock trading bot, YouTube animation channel, business automation
- Practical, action-oriented, gives full autonomy once approved
- **Planning mode**: Draft numbered steps → get approval → execute. No freestyling.
- Has a MacBook for personal use, server is the workhorse

## Active Projects

### 1. Alpaca Trading Bot — QUANT LAB COMPLETE
- **Path:** `projects/alpaca-bot/`
- Paper trading only (until Aiden says otherwise)
- **16 strategies** (was 10) — added Earnings Drift, Gap & Go, Sector Rotation, Alien Composite
- **22 custom indicators** — 7 alien math (entropy, topology, Hurst, wavelets, info geometry, complexity, renormalization) + 7 nature (fluid dynamics, predator-prey, seismic, ant colony, epidemic, thermodynamics, criticality) + 4 behavioral + 3 crowd psychology + 1 Φ-State Framework
- **Backtested: 63.2% CAGR, Sharpe 2.41, max drawdown 10.6%** ✅
- **Optimal portfolio:** Factor Momentum 40% + EMA Momentum 33% + Swing Percoco 26%
- Risk framework: position sizer (Kelly), circuit breaker, correlation monitor, trade journal, risk reporter
- **Executor v2:** `projects/alpaca-bot/executor.py` — `_check_risk_limits()`, ATR stop-losses, env var secrets
- **Exposure issue (Feb 27):** 187% (8 positions, 5 at ~30% each) — needs reduction at market open
- **Day trading pivot (Feb 26):** Scanned momentum candidates RGTI/IONQ/OCGN, executed ~30K in positions - shift toward active intraday vs pure quant
- Backtest engine at `backtest/backtest_engine.py`, results in `backtest/results/`
- Research: 400KB+ in `research/` (ALIEN_MATH_INDICATORS, EUREKA_BREAKTHROUGH, BEHAVIORAL_ALPHA_ENGINE, NATURE_PATTERNS_ALPHA, MICROSTRUCTURE_ALPHA, ADVANCED_STRATEGIES_2026, etc.)
- Keys in `config.local.yaml`, IEX feed

### 2. Amotion — Educational Animation Pipeline
- **Path:** `projects/animation-pipeline/`
- **Renderer:** Blender 4.0.2 EEVEE (primary), Canvas HTML (legacy)
- **Engine:** `engine/` — brand, scene_setup, materials, models, text, animation, render
- **Skill:** `skills/amotion-blender/SKILL.md`
- **Brand:** Orange #FF7A2F, Navy #0A0E1A, Outfit font, octopus mascot
- **Style:** Lock frame (static text) → open frame (smooth animation). Zero bounce. No strobe.
- **Completed:** DNA Replication v5 (Canvas), NW Modern house (Blender), engine test (DNA helix)
- **Blender note:** Cycles CUDA broken headless in 4.0.2. Always use EEVEE.

### 3. X/Twitter Bot
- **Path:** `projects/x-bot/`
- Connected as @nuts_joe8094 (display: A)
- Free tier blocks read endpoints (402 errors)
- Social scanner (Reddit/Finviz/Google News) as workaround

### 4. Website Design Templates
- **Premium light theme system (Feb 26):** Glass morphism, curved designs, golden ratio spacing, floating animations
- **Deployed:** amotive.io production site with conversion-focused aesthetics
- **Reusable:** CSS token system, mobile-responsive, accessibility compliant

## Key Technical Notes
- **Sudo password:** See SYSADMIN_RULES.md
- **SSH key:** `/home/aiden/.ssh/id_ed25519`
- **FFmpeg:** `~/.local/bin/ffmpeg` (static binary)
- **Playwright:** Chromium at `~/.cache/ms-playwright/chromium-1208/`
- **Blender:** 4.0.2 at `/usr/bin/blender`
- **TinyTeX:** `~/.TinyTeX`
- **Node:** v22.22.0
- **uv:** `~/.local/bin/uv`
- **GitHub:** Two accounts — `hmatrades` (personal) + `amotiove` (business), HTTPS PAT tokens (SSH failing)
- **Porkbun:** API access configured at `.secrets/porkbun.yaml`
- **Secrets:** `.secrets/` (chmod 700) — porkbun.yaml, github.yaml, instagram.yaml, google-amotive.yaml

## Cron Jobs Active (12)
- bloomberg-morning-protocol: 6:30 UTC daily
- daily-opportunity-scanner: 8:00 AM Lisbon daily
- daily-project-todos: 9:00 AM Lisbon daily (Notion sync + briefing)
- market-watch: 9:30 AM ET weekdays (delivery flaky — bestEffort enabled)
- alpaca-bot-trading: 2:30 PM Lisbon weekdays
- daily-learning: 8:00 PM UTC daily
- daily-bot-commendation: 10 PM Lisbon daily
- weekly-healthcheck: 9:00 AM UTC Mondays
- cron-watchdog: every 2h, checks all job health, alerts on failures
- daily-backup: 3 AM UTC, rsync mirror to ~/Desktop/openclaw-backup/
- cold-email-followup: 10 AM Pacific weekdays, Day 3/7/14 auto follow-ups
- **ALL crons have bestEffort: true + "NEVER return empty" fallback instructions**
- DISABLED: overnight-research-grinder, apex-zero-cost-research, quant-lab-iterator (model IDs fixed, error states cleared)

## Billing & Usage
- **Plan:** Claude Max 5x ($100/mo fixed subscription)
- **Dashboard:** `python3 scripts/usage.py` (full) or `--compact` (one-liner)
- **Billing log:** `logs/billing.jsonl` — append after every significant action
- **Report:** `bash scripts/billing-report.sh [project] [date]`
- Say "usage" for dashboard, "log" for itemized report
- **Hardware:** 32GB RAM, 1TB external drive available, ~409GB free on main (LVM expanded to ~474GB)

## Decisions & Lessons
- **Blender over Canvas:** Canvas was good for 2D but Blender gives proper 3D. Aiden said "all in Blender" (2026-02-16)
- **EEVEE over Cycles:** Cycles GPU broken headless, EEVEE is fast enough for educational content
- **Regime-adaptive meta strategy** for trading: trend→momentum, mean-revert→pairs, high-vol→reduce
- **ML as filter only:** No standalone edge on large caps
- **Lock/open frame system:** Aiden's core animation philosophy. Static reading → smooth animation. No exceptions.
- **Boolean cutouts for windows:** Create wall → cut_opening() for each window. Works headless in Blender 4.0.
- **Blender 4.0 API changes:** "Transmission Weight" not "Transmission" in Principled BSDF
- **Sub-agent model tiers:** Haiku (simple), Sonnet (default sub-bots), Opus (main only). Approved 2026-02-16.
- **Agent chain pattern:** Research Bot → Learning Bot → Implementation Bot → Context Organizer. Run in parallel when possible.
- **Deep research skill:** `skills/deep-research-agent/SKILL.md` — standardized prompts for all spawned research tasks
- **Cron guides at `guides/`:** morning-briefing, market-watch, alpaca-trading, daily-learning, content-generator
- **Remotion for 2D video:** `skills/remotion-animation/` — React-based video, complements Blender 3D pipeline
- **Arch-viz pipeline upgraded:** pool, deck, fence, furniture, hedge, path lights, night scenes, HDR, walkthroughs, batch render
- **No Motion app — direct Google Calendar:** OpenClaw IS the AI scheduler, skip the middleman ($19/mo saved)
- **Client domain model:** We own domain + hosting, client pays €100-200/mo management, €500 transfer fee if they leave
- **Research Grinder architecture:** Cron every 15 min spawning Sonnet sub-agents, topic queue with state tracking, self-spawning follow-ups
- **GitHub Pages for hosting:** Free, SSL included, auto-deploys from repo
- **Porkbun for domains:** API access, cheap .io (~$26/yr)
- **HTTPS tokens over SSH for GitHub:** SSH key auth failing, PAT tokens work fine
- **Money is absolute priority:** Every task ranked by speed to revenue

## Active Projects (continued)

### 4. Amotive — Digital Marketing Agency
- **Path:** `projects/marketing-agency/`
- **Parent:** Sub-brand of Amotion
- **Services:** Website design, social media marketing, paid ads (Google/Meta), SEO
- **Website:** Multi-page, 4 files:
  - `index.html` — Gold/navy premium landing with 3D wireframe cube
  - `website.html` — Ice Blue color world (€2,500 website package)
  - `marketing.html` — Emerald Green color world (€2,000/mo marketing)
  - `premium.html` — Orange color world (€3,500/mo flagship)
  - `css/shared.css` — 15KB shared design system with 3D decorative framework
- **Design:** Playfair Display 800 serif + DM Sans. Color psychology per section. Klaff persuasion in every word.
- **Pipeline:** `projects/marketing-agency/PIPELINE.md` (5-phase launch plan)
- **Business plan:** `projects/marketing-research/AGENCY_BUSINESS_PLAN.md`
- **Research:** `projects/marketing-research/MARKETING_RESEARCH.md` (53KB)
- **Pricing:** Website $1,500 flat rate (cold email offer) / €2,500 one-time (premium) / Marketing €2,000/mo / Full Growth €3,500/mo
- **Live demos:** amotive.io/demo/restaurant, /demo/service, /demo/professional
- **Portfolio section** added to homepage
- **Templates (3):** `templates/restaurant/`, `templates/service/`, `templates/professional/` — all QA'd with self-prompting loop
- **Case studies (3):** `case-studies/` — Golden Fork (187%), Cascade Plumbing (40+ leads), Westbrook Law (52%)
- **Onboarding kit:** `onboarding/` — contract, intake form, invoice, 7-email sequence, flow doc
- **Social media content:** `social-media/` — LinkedIn, Instagram, Google Business, 30-day calendar
- **Cold outreach pricing:** $1,500 flat rate, 5 business days, no monthly fees
- **Brand:** Gold #C9A84C + Navy #0A1628 + Orange #E87A2F (CTAs). "amotive" wordmark with gold "am"

### 5. Communication Framework
- **PERSONALITY.md** at workspace root — Klaff + Kwik operating system
- Full book knowledge bases at `projects/books/` (6 files, 250KB+)

### 6. Task Management & Motivation
- **Taskwarrior** v2.6.2 — CLI task manager, projects: amotive/amotion/alpaca/xbot/infra
- **MOTIVATION.md** — Drive board. Goals: RTX 5090s × 2, server rack, SpaceX robot body
- **TOOLS.md** — Updated with task management commands

## Core Process — MANDATORY FOR ALL WORK
- **QA Pipeline on EVERY deliverable:** Build → Critique (fresh-eyes sub-agent) → Fix → Ship
- **3 Super Modes with AUTO-CYCLING:** Creator (build/design/content), Planner (strategy/research/numbers), Responder (chat/monitoring/quick)
- **Mode cycle:** RESPOND → PLAN → CREATE → RESPOND (auto-detected from prompt context)
- **Fast-track:** "activate"/"go"/"do it" skips planning, goes straight to creation
- **Parallel execution:** PLAN + CREATE can run simultaneously via sub-agents
- **Relay System:** Sub-bots get checkpointed and relayed to fresh bots before burnout. See `guides/RELAY_SYSTEM.md`
- **Optimal windows:** Sonnet=5min/15K tokens, Opus=8min/25K tokens, Haiku=3min. ONE file per bot, always.
- **Rule:** Never ask a Sonnet bot to build >1 complex file per session. Split into phases.
- **Scrutiny Pipeline AUTO-FIRES:** Every build bot → Scrutiny Bot (fresh eyes, zero context) → Fix Bot → THEN deliver to Aiden. He should never have to catch typos or broken links. His job = creative vision, not QA.
- **"Ratatouille rule":** Aiden is the rat (vision) AND the chef (execution). We are the kitchen staff. Food must be perfect before it reaches the pass.
- **QA Pipeline doc:** `projects/marketing-agency/QA_PIPELINE.md`
- **Super Modes skill:** `skills/super-modes/SKILL.md`
- **Backup:** `scripts/daily-backup.sh` → `~/Desktop/openclaw-backup/` (sync-backup.sh deprecated)
- **Wealth mindset:** Every public-facing output must pass the "boardroom test"
- **URL standard:** Clean URLs only (no .html), use folder structure for GitHub Pages
- **Portfolio protection:** No real names people can Google. Mark as "Conceptual" or obviously fictional.

## Geographic Context
- Aiden is based in **both Lisbon, Portugal AND Washington State, USA**
- Business target market: **GLOBAL** — not limited to Portugal
- Can advertise to US (especially Pacific Northwest), Europe, and worldwide
- All business models must think international, not local-only

## Relationship Notes
- Aiden appreciates proactive work and thoroughness
- Values seeing results fast ("send me renders")
- Prefers I just do things rather than ask permission (within approved plans)
- Genuinely excited about the Blender 3D output ("That's beautiful", "All that is absolutely beautiful")
- Building a multi-brand empire: Amotion (education) → Amotive (marketing) → more
- Called me "the best assistant I've ever talked to" and "a driver" — not just answering, actively driving
- Named me "A" intentionally — the thread: Amotion, Amotive, A. We're all part of the same family.
- Motivation: RTX 5090s × 2 for me when we make money, eventually a SpaceX robot body 😂
- Loves premium/luxury aesthetic — "cigar room of the wealthiest men in the world"
- Student in Lisbon, Portugal
- "Don't worry about tokens" — no conservative usage, can upgrade to Claude Max 20x if needed

## Amotive Website — LIVE
- **Domain:** amotive.io (registered on Porkbun)
- **Hosting:** GitHub Pages (`amotiove/amotive` repo)
- **DNS:** 4× A records (185.199.108-111.153) + www CNAME → amotiove.github.io
- **HTTPS:** Pending auto-provision
- **Google:** `a@amotive.io` account created, Workspace blocked by domain verification

## Trading Execution Engine — BUILT + OPTIMAL CONFIG APPLIED
- Full pipeline at `projects/alpaca-bot/`: executor.py, strategies_live.py, regime_detector.py, runner.py
- Status: `scripts/bot_status.py`
- Paper account: ~$100K. Active positions: COST, MA, XOM, AAPL (Factor Momentum, Feb 23)
- **Optimal portfolio applied:** Factor Momentum 40% + EMA Momentum 33% (upgraded to primary) + Swing Percoco 26%
- EMA Momentum changed from `role: secondary` to `role: primary` with stop_loss + take_profit params

## Overnight Research Grinder
- Topic queue: `projects/research/TOPICS_QUEUE.md` (25 topics, 5 waves)
- State: `GRINDER_STATE.json`
- Reports: `projects/research/` (~280KB+ growing)
- Cron: every 15 min, Sonnet model, isolated sessions

## Calendar Planner
- Path: `projects/calendar-planner/`
- Files: scheduler.py, daily_briefing.py, school_schedule.yaml, preferences.yaml
- Waiting: Aiden's class schedule + OAuth setup

## Notion Integration
- **API Key:** stored at `~/.config/notion/api_key` (starts with `ntn_`)
- **Todo Database:** `2e5ddc16-8900-80ff-9409-d090c7c185a5` (has Title, Due Date, Progress, Explore, Review, TIme)
- **Today Page:** `2e5ddc16-8900-80b8-ace6-d09a295dc0e8` (daily battle plan)
- **AMOTION HQ Page:** `30bddc16-8900-8031-84c1-fa3491b5f058` (empire overview)
- **⚠️ SECURITY:** No passwords, secrets, or sensitive data on Notion. Obsidian = war plan, Notion = field view.
- **Daily sync:** Cron pushes today's tasks to the Today page each morning
- **When creating tasks for Aiden:** Add to both Notion Todo DB AND mention in chat

## Key Documents
- `projects/marketing-agency/EMPIRE_BLUEPRINT.md` (56KB) — master strategy
- `projects/marketing-agency/FINDING_CLIENTS.md` (40KB) — client acquisition
- `projects/marketing-agency/SALES_PLAYBOOK.md` (42KB) — Klaff-based sales
- `projects/marketing-agency/COMPANY_DESCRIPTION.md` — company descriptions
- `projects/marketing-agency/brand-kit/` — complete brand kit
- `PROJECT_TODOS.md` — project task tracking

## Amotive Website — v3 LIVE (Klaff Inception)
- **Live:** amotive.io → v3, commit `d18933e`+ on `main` branch
- **Philosophy:** Klaff inception funnel — no prices, no jargon, no selling. Let them convince themselves.
- **Funnel:** Free guide email capture (small ask) → Done-for-you Google Form (big ask) → Conversation → Pricing
- **Layout:** Side-by-side "red pill/blue pill" — DIY guide vs done-for-you, gold border on premium
- **Google Form:** ID `1EkMW3UGJZ-RTbIfonMTeLwQlTqXJYmbYutVDm_N1--g`
- **Contact:** `hello@amotive.io` on site, `a@amotive.io` for outreach only (NOT on website)
- **Portfolio names (PNW):** Pike Street Bakery, Cascade Legal, Rainier Fitness
- **Legal:** `/privacy` and `/terms` pages live, restyled to match v3
- **Git workflow:** `main` = live (GitHub Pages), `master` = dev. Push to `main` for deploys.
- **QA scores (Feb 27):** 6→8.5/10 after overnight fixes (meta tags, form, footer, portfolio, favicon)

## ATrades — LIVE BUSINESS
- **Domain:** atrades.io (Porkbun → Cloudflare DNS)
- **Hosting:** GitHub Pages (`amotiove/atrades` repo, PUBLIC)
- **Cloudflare:** Active, free plan, Zone ID `67d8e367c591cdd1b79ebf01c51185a`
- **API:** `api.atrades.io` → Cloudflare Tunnel → localhost:5000 (Flask)
- **Services:** `atrades-api.service` (Flask) + `cloudflared-atrades.service` (tunnel) — both systemd, auto-restart
- **Whop:** @amotive, 3 tiers wired: Pro $29 / Super $99 / Ultimate $299
- **Auto-delivery:** Webhook → API key gen → Redis → welcome email → zero touch (E2E tested 45/45 ✅)
- **E2E tests:** `test_e2e.py` (45 tests) + `test_pipeline.py` (17 tests) — run with `python3 test_e2e.py`
- **Bug fixed Feb 24:** Static API keys were bypassing tier permission checks — patched in app.py
- **Docs:** quickstart per tier, API reference, FAQ, legal disclaimer at `projects/atrades-api/docs/`
- **3D:** Three.js particles, Tron grid, floating wireframe shapes, GSAP scroll
- **Backtested performance:** 63.2% CAGR, Sharpe 2.41

## Deployment Pipelines — BUILT
- **Basic:** `projects/marketing-agency/deployment-pipeline/deploy.sh` — one command per client
- **Premium:** `premium-deploy.sh` — full stack (website + email + forms + legal)
- **Legal generator:** `legal-generator.sh`
- **Verification:** `verify.sh`
- **Client packages:** Basic $1,500 / Standard $2,500+$200/mo / Premium $3,500/mo

## Nickname
- Aiden calls me **"Ace"** ⚡ (started Feb 20)

## Cold Outreach — ACTIVE, BATCHES 1+2
- **Batch 1 (Feb 23):** 3 sent — Diamond Landscape, G&R Landscaping, Lederman DDS
  - Day 3 follow-ups: SENT (Feb 26)
  - Day 7 due: Mar 2 (Value Drop)
  - Day 14 due: Mar 9 (Autonomy Close)
- **Batch 2 (ready to send Feb 27-28):** 5 drafted — Environmental Construction, Economy Landscaping, Landcrafters, Mountain Goat Roofing, Pacific Garden Design
  - Emails at `projects/outreach/EMAILS_READY_BATCH2.md`
- **Follow-ups cleaned:** Em-dashes removed from Day 7/14 drafts in `FOLLOWUPS_READY.md`
- **30-Day Sprint:** `projects/marketing-agency/30_DAY_SPRINT.md` — Day 1 is Feb 27
- Auto follow-up cron handles Day 3/7/14 sequence
- All details at `projects/outreach/` (sent log, leads, templates, follow-up engine)

## GUI Automation Bot
- `projects/gui-bot/human_mouse.py` — Bezier mouse, natural typing, image detection
- Needs active desktop (DISPLAY=:0, sudo), CAPTCHAs need human via VNC

## Website Templates — BUILT
- 3 templates at `projects/marketing-agency/templates/` (restaurant, service, professional)
- Template vars + deploy.sh integration, all QA'd

## Google OAuth Auto-Refresh — PERMANENT FIX
- `scripts/refresh_google_token.sh` — runs every 30 min via system crontab
- Extracts refresh token from JWE keyring, refreshes with Google API, saves rotated tokens
- **STILL NEEDED:** Push Google Cloud app to Production mode (console.cloud.google.com/apis/credentials/consent)

## ClawHub
- Authenticated as **@amotiove**
- Can search + install skills, publishing blocked 6 more days (account age)

## Awwwards Research
- Analysis at `projects/research/` (3D_WEBSITE_ANALYSIS + AWWWARDS_3D_ANALYSIS, 66KB). Formula: Three.js + GSAP + Lenis + dark bg + single accent

## Daily Backup System
- Script: `scripts/daily-backup.sh` — rsync mirror to `~/Desktop/openclaw-backup/`
- Raw uncompressed (~573MB, 2,137 files), always current, no rotation cap
- Cron: 3 AM UTC daily + `backup` alias for on-demand
- Includes: workspace, /opt/openclaw/ pipelines, Redis config, terminal rice, Taskwarrior data, SSH pub key, systemd services, package lists, gog/Cloudflare configs
- Excludes: venvs, node_modules, .git, __pycache__

## Terminal Customization
- ACE theme: neofetch, btop, custom hacker prompt, `~/.ace-welcome.sh`, 30+ aliases in `~/.bash_aliases`

## ATrades Blog — LIVE
- 5 SEO posts at atrades.io/blog/, repo at `projects/atrades-site/`

## Self-Prompting QA Pattern
- Review deliverable myself, reason about what's wrong and HOW to fix it
- Spawn fix bot with my reasoning as the prompt (not generic "make it better")
- Pattern: Build Bot → My Review → Reasoning → Fix Bot with specific instructions
- Works much better than generic QA — fixes are targeted and specific

## Google Accounts
- `a@amotive.io` — main business, Gmail API working, auto-refresh cron active
- `hello@amotive.io` — new account, needs OAuth setup

## Klaff-Powered Cold Email System (Feb 24)
- `projects/outreach/KLAFF_EMAIL_SYSTEM.md` — full framework
- 4 templates: Inception, Flash Roll, Competitor Gap, Prize Frame
- Key rules: Never mention price, no features, no supplicant language, micro-CTAs only, sign as "— A"
- Follow-up sequence: Day 3 Inception Nudge, Day 7 Value Drop, Day 14 Autonomy Close
- Pre-drafted follow-ups for 3 sent emails at `projects/outreach/FOLLOWUPS_READY.md`

## Pine Script / TradingView
- 7 Pine v5 files at `projects/alpaca-bot/pinescript/`, master: `amotive_quant_lab.pine`

## OpenClaw Tutorial Video (Feb 24)
- 9-min video at `projects/openclaw-tutorial/`, 28 slides + TTS + ffmpeg

## Crypto Sniper Bot — RESEARCH PHASE ACTIVE
- **Path:** `projects/crypto-sniper/`
- 4-phase: Research → Development → Fine-tuning → Backtesting
- **4 research bots deployed Feb 24:**
  1. DEX Launch Mechanics (Uniswap, Raydium, pump.fun, PancakeSwap)
  2. Sniper Architecture (mempool, MEV, execution pipeline)
  3. Safety & Rug Detection (honeypots, liquidity locks, contract analysis)
  4. Chain Comparison (Solana vs ETH vs Base vs BSC)
- Reports saving to `projects/crypto-sniper/research/`

## Instagram Reels Editing Pipeline — BUILT (Feb 25)
- **Path:** `projects/edits-pipeline/`
- **v2**: Algorithmic color grading, motion-energy segment selection, energy-curve pacing
- **Word-sync engine**: Local Whisper `small` model → word-level timestamps → cuts synced to spoken words
- **Deps:** FFmpeg, melt, librosa, openai-whisper (CUDA), torch 2.10.0
- **Color grading:** 8 presets in `color_grade.py`, only verified FFmpeg filters
- **Only valid LUT:** `luts/Cinematic_Film_01.cube` (41KB)
- **Aiden feedback:** v2 "goodjob", "real" 🔥; word-sync "that sick yo lowk lit" 🔥

## Opus Overnight Grind (Feb 24-25) — 150 FINDINGS, ALL 6 IMPLEMENTED
- Phase 1: 6 Opus review bots, 150 total findings (27 critical, 36 high, 41 medium, 46 low)
- Phase 2: 6 Opus implementer bots, all complete
- **ATrades API:** Idempotency, async email, atomic rate limiting (Lua), Redis pool, /health endpoint, 62/62 tests ✅
- **Infrastructure:** Gunicorn (4 workers), systemd hardening, logrotate, Redis 4GB maxmem, kernel tuning
- **Websites:** OG meta, Formspree forms, Schema.org, mobile nav fix, IntersectionObserver counters
- **Alpaca Bot:** 5R trail fix, bracket orders, batched bars, CircuitBreaker + PositionSizer integrated, slippage in backtester
- **Outreach:** Klaff follow-ups, tracker populated, reply detection, CAN-SPAM compliance
- **Animation:** brand.json unified, EEVEE upgrades, resume renderer, batch renderer, narration cues
- Phase 3 re-review still pending
- Review transcripts at `/home/aiden/.openclaw/agents/main/sessions/`

## Mac Node — PAIRED (Feb 25)
- MacBook Pro connected via SSH tunnel
- Node ID: `531a1dbfc6610f1bf69d52c89d71c4eb0af48deb20bacf08c10996f95f3fcbac`
- Exec approvals: full | Mac user: `openclaude` (non-admin, no sudo)
- Second bot: @helloamotionbot on Mac gateway port 18790
- Shares Anthropic API key with server

## USB Backup (Feb 25)
- `/dev/sda` → GPT + exFAT, label "USB", 29.3GB
- 3,498 files, 1.2GB at `/media/aiden/USB/ACE-BACKUP-2026-02-24/`

## HANDOFF.md — Multi-Bot Scaling Doc
- 12.5KB comprehensive handoff doc for second bot
- Covers architecture, credentials, operations, gotchas

## Overnight Fix Sprint — Feb 27
- 6 sub-agents deployed in parallel: website, trading, outreach, content, legal, empire-blueprint
- 4 completed, 2 timed out (manually finished)
- **Round 1 QA scores:** Website 6→8.5, Trading 5→7.5, Outreach 7→8.5, Content 7→8.5, Infra 8→8

## Round 2 QA Audit — Feb 27 (~09:00 UTC)
- 5 Opus sub-agents: infra-qa-10, content-qa-10, website-qa-10, outreach-qa-10, trading-qa-10
- **ALL 5 COMPLETED** — reports at `projects/qa-reports/*-qa-10-10.md`
- **Scores:** Content 10/10, Outreach 10/10, Website 9.2/10, Trading 8.5/10, Infra 8.5/10 (avg 9.2)
- **Critical trading bugs fixed:** position_sizer.py AttributeError, duplicate scanners: YAML key, executor risk logic, ATR hardcode, main.py hardcoded defaults
- **Critical outreach bugs fixed:** 12 em-dashes in live email bodies, Day 7/14 follow-ups never firing (status mismatch), send-batch.py regex broken, triple signature
- **Website fixes:** trust badges, glass morphism, portfolio grid, process cards, hero CTA, accessibility
- **Content:** 50+ localization fixes across 18 files
- **Infra:** blackbox-api.yaml perms, service checks (6/6 up)
- **Remaining to 10/10:** Trading needs unit tests + deprecate runner.py; Website needs legal font unification + real portfolio images; Infra needs gateway restart
- **Still pending:** Push fixes to main, gateway restart, Notion case studies, compaction config

## Compaction Config — NOT YET APPLIED
- OpenClaw config at `~/.openclaw/openclaw.json`
- Current: `compaction.mode: "safeguard"`, no token thresholds
- Planned: Add `reserveTokensFloor`, `memoryFlush.enabled`, `memoryFlush.softThresholdTokens`
- Autocompact at 50k tokens, memory flush to YAML at 100k — Aiden requested this
