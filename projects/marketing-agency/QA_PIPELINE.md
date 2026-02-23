# QA PIPELINE — Detail Bot System

## Architecture: Build → Critique → Fix → Ship

Every deliverable goes through 3 phases before it's considered done:

### Phase 1: BUILD BOT
- Creates the work (website, content, design, etc.)
- Follows brand guidelines and brief
- Delivers first draft

### Phase 2: CRITIQUE BOT (separate agent, fresh eyes)
- Receives the output with NO context about how it was built
- Reviews with a ruthless eye for detail
- Checks against this checklist:

#### Universal QA Checklist
- [ ] **URL structure** — Clean paths (e.g., `amotive.io/marketing` not `marketing.html`)
- [ ] **Fake names/businesses** — Can someone Google this and find nothing? If so, change it or make it obviously fictional
- [ ] **Placeholder text** — Zero "Lorem ipsum", "placeholder", "TODO", "TBD" anywhere
- [ ] **Contact info** — Correct email, phone, no test data
- [ ] **Links** — Every link goes somewhere real (no `#`, no `javascript:void(0)` except anchors)
- [ ] **Spelling/grammar** — Zero typos, professional copy
- [ ] **Mobile responsive** — Works on 375px, 768px, 1024px, 1440px, 1920px
- [ ] **Performance** — No layout shift, smooth animations, fast load
- [ ] **Brand consistency** — Colors, fonts, spacing match brand guidelines
- [ ] **Legal** — Copyright year correct, no stolen images, proper attribution
- [ ] **Social proof** — If using testimonials/case studies, they must be clearly marked as examples OR use real data
- [ ] **Forms** — All fields work, validation present, submit goes somewhere
- [ ] **Images** — All load, proper alt text, optimized file size
- [ ] **Console errors** — Zero JS errors in browser console
- [ ] **Accessibility** — Proper contrast, keyboard nav, screen reader basics
- [ ] **SEO** — Title, meta description, OG tags, structured data where relevant

#### Website-Specific QA
- [ ] **Nav links all work** — Every menu item goes to correct page
- [ ] **Cross-page consistency** — Same header/footer on all pages
- [ ] **CTA clarity** — Every CTA tells user exactly what happens next
- [ ] **Pricing accuracy** — Numbers match across all pages
- [ ] **3D effects** — Smooth, not laggy, don't block content on mobile
- [ ] **Form pre-selection** — Service pages pre-select their service in dropdown

#### Portfolio/Case Study QA
- [ ] **Names are FICTIONAL** — No real business names that could be Googled
- [ ] **Use disclaimers** — "Representative example" or "Conceptual project"
- [ ] **Screenshots are our work** — No stolen portfolio pieces
- [ ] **Results are realistic** — Don't claim 10,000% ROI

### Phase 3: FIX BOT (separate agent)
- Receives the critique report
- Fixes every issue found
- Re-runs the QA checklist
- Delivers final version

### Phase 4: SIGN-OFF
- Final output sent to Aiden with:
  - Summary of what was built
  - What the critique bot found
  - What was fixed
  - Any remaining notes/decisions needed

## URL Structure Standard
All Amotive pages use clean URLs via GitHub Pages directory structure:
```
amotive.io/              → index.html
amotive.io/marketing     → marketing/index.html
amotive.io/websites      → websites/index.html  
amotive.io/growth        → growth/index.html
amotive.io/portfolio     → portfolio/index.html
amotive.io/contact       → contact/index.html
```

NOT: `amotive.io/marketing.html` ❌
NOT: `amotive.io/website-3d.html` ❌

## Wealth Mindset Standard
Every public-facing output must pass the "boardroom test":
> Would this look professional on a screen in a boardroom of a Fortune 500 company?
If no → fix it before shipping.
