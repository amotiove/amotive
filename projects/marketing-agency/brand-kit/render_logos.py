"""Render Amotive logo variants using Playwright for proper font rendering."""
import asyncio, os

def make_html(bg, text_color, weight, size, spacing, w, h, tag_color="", tag_size=0, tagline="", icon_only=False):
    if icon_only:
        return f"""<!DOCTYPE html>
<html><head>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@900&display=swap" rel="stylesheet">
<style>
* {{ margin: 0; padding: 0; }}
body {{ background: {bg}; display: flex; align-items: center; justify-content: center; height: {h}px; width: {w}px; }}
.icon {{ font-family: 'Playfair Display', Georgia, serif; font-weight: 900; font-size: {size}px; color: #C9A84C; }}
</style></head>
<body><div class="icon">a</div></body></html>"""
    
    tag_html = f'<div style="font-family: sans-serif; font-size: {tag_size}px; color: {tag_color}; letter-spacing: 3px; text-transform: uppercase; margin-top: 12px; text-align: center;">{tagline}</div>' if tagline else ""
    
    return f"""<!DOCTYPE html>
<html><head>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;800;900&display=swap" rel="stylesheet">
<style>
* {{ margin: 0; padding: 0; }}
body {{ background: {bg}; display: flex; align-items: center; justify-content: center; height: {h}px; width: {w}px; }}
.logo {{ font-family: 'Playfair Display', Georgia, serif; font-weight: {weight}; font-size: {size}px; letter-spacing: {spacing}px; }}
</style></head>
<body>
<div style="text-align:center;">
<div class="logo"><span style="color:#C9A84C;">am</span><span style="color:{text_color};">otive</span></div>
{tag_html}
</div></body></html>"""

VARIANTS = [
    {"name": "logo-dark-primary", "w": 1200, "h": 400, "bg": "#050A12", "text_color": "#FFFFFF", "weight": 800, "size": 120, "spacing": 6},
    {"name": "logo-dark-tagline", "w": 1200, "h": 480, "bg": "#050A12", "text_color": "#FFFFFF", "weight": 800, "size": 120, "spacing": 6, "tagline": "Revenue Engineering", "tag_color": "#A8B2C4", "tag_size": 18},
    {"name": "logo-light-primary", "w": 1200, "h": 400, "bg": "#FFFFFF", "text_color": "#050A12", "weight": 800, "size": 120, "spacing": 6},
    {"name": "logo-light-tagline", "w": 1200, "h": 480, "bg": "#FFFFFF", "text_color": "#050A12", "weight": 800, "size": 120, "spacing": 6, "tagline": "Revenue Engineering", "tag_color": "#555555", "tag_size": 18},
    {"name": "logo-transparent", "w": 1200, "h": 400, "bg": "transparent", "text_color": "#C9A84C", "weight": 800, "size": 120, "spacing": 6},
    {"name": "icon-square-dark", "w": 500, "h": 500, "bg": "#050A12", "text_color": "#C9A84C", "weight": 900, "size": 220, "spacing": 0, "icon_only": True},
    {"name": "social-banner", "w": 1500, "h": 500, "bg": "#050A12", "text_color": "#FFFFFF", "weight": 800, "size": 100, "spacing": 6, "tagline": "Digital Growth Agency \u2014 Lisbon", "tag_color": "#A8B2C4", "tag_size": 20},
    {"name": "icon-favicon", "w": 200, "h": 200, "bg": "#050A12", "text_color": "#C9A84C", "weight": 900, "size": 120, "spacing": 0, "icon_only": True},
]

async def main():
    from playwright.async_api import async_playwright
    outdir = os.path.dirname(os.path.abspath(__file__))
    
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        
        for v in VARIANTS:
            page = await browser.new_page(viewport={"width": v["w"], "height": v["h"]})
            html = make_html(**{k: v[k] for k in v if k != "name"})
            await page.set_content(html)
            await page.wait_for_timeout(2000)
            
            path = os.path.join(outdir, f"{v['name']}.png")
            transparent = v["bg"] == "transparent"
            await page.screenshot(path=path, omit_background=transparent)
            print(f"✅ {v['name']}.png ({v['w']}x{v['h']})")
            await page.close()
        
        await browser.close()
    print(f"\n🎨 All {len(VARIANTS)} logo variants rendered!")

asyncio.run(main())
