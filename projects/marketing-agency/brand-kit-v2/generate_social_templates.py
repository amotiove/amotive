#!/usr/bin/env python3
"""
Amotive Brand Kit - Social Media Templates Generation
Creates SVG templates for various social media platforms
"""

import svgwrite
from svgwrite import mm, cm, px
import os
import cairosvg

# Brand Colors
GOLD = "#C9A84C"
NAVY = "#0A1628"
WHITE = "#FFFFFF"
LIGHT_BG = "#F7F8FC"
ORANGE = "#E87A2F"

class AmotiveSocialTemplates:
    def __init__(self, output_dir="social-templates"):
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)
    
    def create_instagram_post(self, width=1080, height=1080):
        """Instagram post template (1080x1080)"""
        dwg = svgwrite.Drawing(size=(width, height))
        
        # Background gradient
        gradient = dwg.defs.add(dwg.linearGradient(id="bg_gradient", x1="0%", y1="0%", x2="100%", y2="100%"))
        gradient.add_stop_color(offset="0%", color=NAVY)
        gradient.add_stop_color(offset="100%", color="#0D1B30")
        
        dwg.add(dwg.rect(insert=(0, 0), size=(width, height), fill="url(#bg_gradient)"))
        
        # Main content area
        content_y = 200
        
        # Logo
        logo_group = dwg.g()
        am_text = dwg.text("am", insert=(200, content_y),
                          fill=GOLD,
                          font_family="Playfair Display, serif",
                          font_size=64,
                          font_weight="600",
                          style="letter-spacing: -2px")
        logo_group.add(am_text)
        
        otive_text = dwg.text("otive", insert=(300, content_y),
                             fill=WHITE,
                             font_family="Playfair Display, serif",
                             font_size=64,
                             font_weight="600",
                             style="letter-spacing: -1px")
        logo_group.add(otive_text)
        
        dwg.add(logo_group)
        
        # Tagline
        tagline = dwg.text("Your growth. Engineered.", insert=(width/2, content_y + 100),
                          fill=WHITE,
                          font_family="Inter Tight, sans-serif",
                          font_size=24,
                          text_anchor="middle",
                          opacity="0.9",
                          style="letter-spacing: 0.5px")
        dwg.add(tagline)
        
        # Main message area
        message_rect = dwg.rect(insert=(80, content_y + 180), size=(width-160, 300),
                               fill=WHITE, fill_opacity="0.05",
                               stroke=GOLD, stroke_width=2,
                               rx=20)
        dwg.add(message_rect)
        
        # Sample content (placeholder)
        sample_title = dwg.text("Your headline goes here", insert=(width/2, content_y + 250),
                               fill=WHITE,
                               font_family="Playfair Display, serif",
                               font_size=36,
                               font_weight="600",
                               text_anchor="middle")
        dwg.add(sample_title)
        
        sample_desc = dwg.text("Supporting message that converts", insert=(width/2, content_y + 300),
                              fill=WHITE,
                              font_family="Inter Tight, sans-serif",
                              font_size=18,
                              text_anchor="middle",
                              opacity="0.8")
        dwg.add(sample_desc)
        
        # CTA Button
        cta_rect = dwg.rect(insert=(width/2 - 100, content_y + 350), size=(200, 50),
                           fill=ORANGE, rx=25)
        dwg.add(cta_rect)
        
        cta_text = dwg.text("Learn More", insert=(width/2, content_y + 380),
                           fill=WHITE,
                           font_family="Inter Tight, sans-serif",
                           font_size=16,
                           font_weight="600",
                           text_anchor="middle")
        dwg.add(cta_text)
        
        # Bottom branding
        bottom_text = dwg.text("Pacific Northwest Digital Agency", insert=(width/2, height - 80),
                              fill=WHITE,
                              font_family="Inter Tight, sans-serif",
                              font_size=14,
                              text_anchor="middle",
                              opacity="0.6")
        dwg.add(bottom_text)
        
        return dwg
    
    def create_linkedin_banner(self, width=1584, height=396):
        """LinkedIn banner template (1584x396)"""
        dwg = svgwrite.Drawing(size=(width, height))
        
        # Background
        dwg.add(dwg.rect(insert=(0, 0), size=(width, height), fill=NAVY))
        
        # Left side content
        left_margin = 80
        center_y = height/2
        
        # Logo
        am_text = dwg.text("am", insert=(left_margin, center_y - 20),
                          fill=GOLD,
                          font_family="Playfair Display, serif",
                          font_size=48,
                          font_weight="600",
                          style="letter-spacing: -2px")
        dwg.add(am_text)
        
        otive_text = dwg.text("otive", insert=(left_margin + 80, center_y - 20),
                             fill=WHITE,
                             font_family="Playfair Display, serif",
                             font_size=48,
                             font_weight="600",
                             style="letter-spacing: -1px")
        dwg.add(otive_text)
        
        # Tagline
        tagline = dwg.text("Your growth. Engineered.", insert=(left_margin, center_y + 30),
                          fill=WHITE,
                          font_family="Inter Tight, sans-serif",
                          font_size=20,
                          opacity="0.9")
        dwg.add(tagline)
        
        # Right side message
        right_text_x = width - 400
        main_msg = dwg.text("Strategic Digital Solutions", insert=(right_text_x, center_y - 30),
                           fill=WHITE,
                           font_family="Playfair Display, serif",
                           font_size=32,
                           font_weight="500")
        dwg.add(main_msg)
        
        sub_msg = dwg.text("for Pacific Northwest Businesses", insert=(right_text_x, center_y + 10),
                          fill=WHITE,
                          font_family="Inter Tight, sans-serif",
                          font_size=18,
                          opacity="0.8")
        dwg.add(sub_msg)
        
        # Accent line
        accent_line = dwg.line(start=(left_margin, center_y + 60), end=(left_margin + 200, center_y + 60),
                              stroke=GOLD, stroke_width=3)
        dwg.add(accent_line)
        
        return dwg
    
    def create_twitter_header(self, width=1500, height=500):
        """Twitter/X header template (1500x500)"""
        dwg = svgwrite.Drawing(size=(width, height))
        
        # Background with subtle texture
        dwg.add(dwg.rect(insert=(0, 0), size=(width, height), fill=LIGHT_BG))
        
        # Overlay pattern
        pattern_rect = dwg.rect(insert=(0, 0), size=(width, height), 
                               fill=NAVY, fill_opacity="0.95")
        dwg.add(pattern_rect)
        
        # Centered content
        center_x, center_y = width/2, height/2
        
        # Main logo
        am_text = dwg.text("am", insert=(center_x - 80, center_y - 40),
                          fill=GOLD,
                          font_family="Playfair Display, serif",
                          font_size=72,
                          font_weight="600",
                          style="letter-spacing: -3px")
        dwg.add(am_text)
        
        otive_text = dwg.text("otive", insert=(center_x + 20, center_y - 40),
                             fill=WHITE,
                             font_family="Playfair Display, serif",
                             font_size=72,
                             font_weight="600",
                             style="letter-spacing: -2px")
        dwg.add(otive_text)
        
        # Tagline
        tagline = dwg.text("Your growth. Engineered.", insert=(center_x, center_y + 30),
                          fill=WHITE,
                          font_family="Inter Tight, sans-serif",
                          font_size=24,
                          text_anchor="middle",
                          style="letter-spacing: 1px")
        dwg.add(tagline)
        
        # Subtitle
        subtitle = dwg.text("Digital presence, done right • Pacific Northwest", insert=(center_x, center_y + 70),
                           fill=WHITE,
                           font_family="Inter Tight, sans-serif",
                           font_size=16,
                           text_anchor="middle",
                           opacity="0.7")
        dwg.add(subtitle)
        
        # Decorative elements
        left_dot = dwg.circle(center=(center_x - 200, center_y + 70), r=3, fill=GOLD)
        right_dot = dwg.circle(center=(center_x + 200, center_y + 70), r=3, fill=GOLD)
        dwg.add(left_dot)
        dwg.add(right_dot)
        
        return dwg
    
    def create_facebook_cover(self, width=820, height=312):
        """Facebook cover template (820x312)"""
        dwg = svgwrite.Drawing(size=(width, height))
        
        # Gradient background
        gradient = dwg.defs.add(dwg.linearGradient(id="fb_gradient", x1="0%", y1="0%", x2="100%", y2="0%"))
        gradient.add_stop_color(offset="0%", color=NAVY)
        gradient.add_stop_color(offset="100%", color="#1A2B42")
        
        dwg.add(dwg.rect(insert=(0, 0), size=(width, height), fill="url(#fb_gradient)"))
        
        # Left aligned content
        left_margin = 60
        center_y = height/2
        
        # Logo
        am_text = dwg.text("am", insert=(left_margin, center_y - 20),
                          fill=GOLD,
                          font_family="Playfair Display, serif",
                          font_size=42,
                          font_weight="600",
                          style="letter-spacing: -2px")
        dwg.add(am_text)
        
        otive_text = dwg.text("otive", insert=(left_margin + 70, center_y - 20),
                             fill=WHITE,
                             font_family="Playfair Display, serif",
                             font_size=42,
                             font_weight="600",
                             style="letter-spacing: -1px")
        dwg.add(otive_text)
        
        # Main message
        main_msg = dwg.text("Strategic Digital Solutions for Local Businesses", 
                           insert=(left_margin + 250, center_y - 15),
                           fill=WHITE,
                           font_family="Inter Tight, sans-serif",
                           font_size=20,
                           font_weight="500")
        dwg.add(main_msg)
        
        # Contact info
        contact_text = dwg.text("Pacific Northwest • yourgrowtg.engineered@amotive.com",
                               insert=(left_margin + 250, center_y + 20),
                               fill=WHITE,
                               font_family="Inter Tight, sans-serif",
                               font_size=14,
                               opacity="0.8")
        dwg.add(contact_text)
        
        # Gold accent bar
        accent_bar = dwg.rect(insert=(left_margin, center_y + 35), size=(150, 4), fill=GOLD)
        dwg.add(accent_bar)
        
        return dwg
    
    def create_email_signature(self):
        """Create HTML email signature"""
        html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        .signature-table {{
            font-family: 'Inter Tight', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            border-collapse: collapse;
            max-width: 500px;
        }}
        .logo-cell {{
            vertical-align: middle;
            padding-right: 20px;
        }}
        .logo-text {{
            font-family: 'Playfair Display', Georgia, serif;
            font-size: 28px;
            font-weight: 600;
            text-decoration: none;
            letter-spacing: -1px;
        }}
        .logo-am {{ color: {GOLD}; }}
        .logo-otive {{ color: {NAVY}; }}
        .info-cell {{
            vertical-align: middle;
            border-left: 3px solid {GOLD};
            padding-left: 15px;
        }}
        .name {{
            font-size: 16px;
            font-weight: 600;
            color: {NAVY};
            margin: 0 0 2px 0;
        }}
        .title {{
            font-size: 14px;
            color: #6B7280;
            margin: 0 0 8px 0;
        }}
        .tagline {{
            font-size: 12px;
            color: {GOLD};
            font-weight: 500;
            margin: 0 0 8px 0;
            letter-spacing: 0.5px;
        }}
        .contact {{
            font-size: 12px;
            color: #6B7280;
            margin: 0;
        }}
        .contact a {{
            color: {NAVY};
            text-decoration: none;
        }}
        .contact a:hover {{
            color: {GOLD};
        }}
    </style>
</head>
<body>
    <table class="signature-table">
        <tr>
            <td class="logo-cell">
                <a href="https://amotive.com" style="text-decoration: none;" class="logo-text">
                    <span class="logo-am">am</span><span class="logo-otive">otive</span>
                </a>
            </td>
            <td class="info-cell">
                <p class="name">[Your Name]</p>
                <p class="title">[Your Title]</p>
                <p class="tagline">Your growth. Engineered.</p>
                <p class="contact">
                    <a href="mailto:hello@amotive.com">hello@amotive.com</a> • 
                    <a href="https://amotive.com">amotive.com</a><br>
                    Pacific Northwest Digital Agency
                </p>
            </td>
        </tr>
    </table>
</body>
</html>
        """
        return html_content
    
    def save_svg_and_png(self, dwg, filename):
        """Save both SVG and PNG versions"""
        # Save SVG
        svg_path = os.path.join(self.output_dir, f"{filename}.svg")
        dwg.saveas(svg_path)
        
        # Save PNG at 2x resolution
        png_path = os.path.join(self.output_dir, f"{filename}@2x.png")
        
        try:
            import cairosvg
            svg_content = dwg.tostring()
            cairosvg.svg2png(bytestring=svg_content.encode('utf-8'),
                           write_to=png_path,
                           output_width=dwg.attribs['width'] * 2,
                           output_height=dwg.attribs['height'] * 2)
            print(f"✓ Generated {svg_path} and {png_path}")
        except ImportError:
            print(f"✓ Generated {svg_path} (cairosvg not available for PNG)")
        except Exception as e:
            print(f"✓ Generated {svg_path} (PNG conversion failed: {e})")
    
    def generate_all_templates(self):
        """Generate all social media templates"""
        print("🎨 Generating Amotive social media templates...")
        
        # Instagram post
        instagram = self.create_instagram_post()
        self.save_svg_and_png(instagram, "amotive-instagram-post")
        
        # LinkedIn banner
        linkedin = self.create_linkedin_banner()
        self.save_svg_and_png(linkedin, "amotive-linkedin-banner")
        
        # Twitter header
        twitter = self.create_twitter_header()
        self.save_svg_and_png(twitter, "amotive-twitter-header")
        
        # Facebook cover
        facebook = self.create_facebook_cover()
        self.save_svg_and_png(facebook, "amotive-facebook-cover")
        
        # Email signature
        email_signature_html = self.create_email_signature()
        email_path = os.path.join(self.output_dir, "amotive-email-signature.html")
        with open(email_path, 'w', encoding='utf-8') as f:
            f.write(email_signature_html)
        print(f"✓ Generated {email_path}")
        
        print("✅ Social media templates complete!")

if __name__ == "__main__":
    template_generator = AmotiveSocialTemplates()
    template_generator.generate_all_templates()