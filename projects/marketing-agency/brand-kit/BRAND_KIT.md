# Amotive — Brand Kit

## Logo
**Wordmark:** `amotive` — all lowercase, Playfair Display 800 weight
- `am` = Gold (#C9A84C)
- `otive` = White (dark bg) or Navy (light bg)

**Icon:** Lowercase `a` in gold, Playfair Display 900 weight

### Logo Files
| File | Use Case | Size |
|------|----------|------|
| `logo-dark-primary.png` | Website, dark backgrounds | 1200×400 |
| `logo-dark-tagline.png` | With "Revenue Engineering" | 1200×480 |
| `logo-light-primary.png` | Print, light backgrounds | 1200×400 |
| `logo-light-tagline.png` | With tagline, light bg | 1200×480 |
| `logo-transparent.png` | Overlays, watermarks | 1200×400 |
| `icon-square-dark.png` | Profile pictures | 500×500 |
| `social-banner.png` | Social media covers | 1500×500 |
| `icon-favicon.png` | Browser favicon | 200×200 |
| `logo-dark.svg` | Vector (scalable) | SVG |
| `logo-light.svg` | Vector (scalable) | SVG |

### Logo Rules
- Minimum clear space: height of the `a` on all sides
- Never rotate, distort, or add effects
- Never change the gold/text color split
- Never put on busy/patterned backgrounds without overlay

---

## Colors

### Primary Palette
| Name | Hex | RGB | Use |
|------|-----|-----|-----|
| **Amotive Gold** | `#C9A84C` | 201, 168, 76 | Logo, CTAs, premium accents |
| **Deep Navy** | `#050A12` | 5, 10, 18 | Primary background |
| **Rich Navy** | `#0A1628` | 10, 22, 40 | Secondary background |
| **Pure White** | `#FFFFFF` | 255, 255, 255 | Text on dark, light bg |

### Secondary Palette
| Name | Hex | Use |
|------|-----|-----|
| **Action Orange** | `#E87A2F` | CTAs, buttons, urgency |
| **Growth Emerald** | `#2ECC71` | Success, growth metrics |
| **Alert Crimson** | `#C0392B` | Pain points, warnings |
| **Silver** | `#A8B2C4` | Subtitles, secondary text |
| **Muted Gold** | `#8B7A3D` | Hover states, borders |

### Color Psychology (per section)
- **Threat/Problem** → Crimson (#C0392B)
- **Opportunity/Growth** → Emerald (#2ECC71)
- **Premium/Trust** → Gold (#C9A84C)
- **Action/CTA** → Orange (#E87A2F)
- **Authority** → Navy (#050A12)

---

## Typography

### Primary Fonts
| Font | Weight | Use |
|------|--------|-----|
| **Playfair Display** | 700-900 | Headlines, logo, hero text |
| **DM Sans** | 400-700 | Body text, UI, descriptions |

### Hierarchy
- **H1:** Playfair Display 800, 48-72px
- **H2:** Playfair Display 700, 32-40px
- **H3:** DM Sans 700, 24-28px
- **Body:** DM Sans 400, 16-18px
- **Small/Caption:** DM Sans 400, 13-14px

### Rules
- White text on dark backgrounds must be **bold/heavy weight** (min 600)
- Never use light/thin weights on dark backgrounds
- Letter spacing: +2-4px on headings, normal on body
- Line height: 1.4-1.6 for body text

---

## Voice & Tone

### Brand Voice
- **Confident, not arrogant** — We know our worth, we don't brag
- **Direct, not blunt** — Say what matters, skip the fluff
- **Premium, not pretentious** — Luxury is in the quality, not the language
- **Persuasive, not pushy** — Inception over pressure (Klaff framework)

### Writing Rules
1. Never use "we'd be happy to" or "don't hesitate to"
2. Never use exclamation marks in headlines
3. Use numbers and specifics over vague claims ("3-5x ROAS" not "great results")
4. Pain → Solution → Proof → CTA flow in all copy
5. End with takeaway closes, not desperate CTAs

### Taglines
- **Primary:** "We build the digital presence that makes your competitors nervous."
- **Service:** "Websites. Marketing. Growth. No fluff."
- **Authority:** "Revenue engineering for ambitious businesses."
- **Portuguese:** "A sua presença digital. Finalmente profissional."

---

## Imagery Style

### Photography
- Dark, moody, high-contrast
- Tech/digital aesthetic — screens, code, analytics dashboards
- Luxury textures — marble, dark wood, gold accents
- Never use obvious stock photos
- People: confident, professional, diverse

### Graphics
- 3D wireframe geometric shapes (cubes, spheres)
- Floating particles on dark backgrounds
- Art deco corner details
- Gradient overlays (navy to transparent)
- Grid patterns, subtle

---

## Social Media Templates

### Profile Picture
Use `icon-square-dark.png` — gold `a` on navy

### Cover/Banner
Use `social-banner.png` — full wordmark with location

### Post Colors
- Regular posts: Navy background + gold/white text
- Case studies: Include emerald accent (growth)
- Promotions: Orange CTA buttons
- Testimonials: Dark background + large quote in gold

---

## File Organization
```
brand-kit/
├── BRAND_KIT.md          ← This file
├── logo-dark-primary.png  ← Main logo (dark bg)
├── logo-dark-tagline.png  ← With tagline
├── logo-light-primary.png ← Main logo (light bg)
├── logo-light-tagline.png ← With tagline
├── logo-transparent.png   ← For overlays
├── icon-square-dark.png   ← Profile picture
├── icon-favicon.png       ← Browser icon
├── social-banner.png      ← Social covers
├── logo-dark.svg          ← Vector
├── logo-light.svg         ← Vector
└── render_logos.py        ← Regenerate script
```
