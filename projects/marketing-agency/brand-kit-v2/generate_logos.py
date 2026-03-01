#!/usr/bin/env python3
"""
Amotive Brand Kit - Logo Generation
Generates all logo variations in SVG and PNG formats
"""

import svgwrite
from svgwrite import mm, cm, px
import os
from io import StringIO
import subprocess
import sys

# Brand Colors
GOLD = "#C9A84C"
NAVY = "#0A1628" 
WHITE = "#FFFFFF"
LIGHT_BG = "#F7F8FC"

class AmotiveLogo:
    def __init__(self, output_dir="logos"):
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)
    
    def create_primary_wordmark(self, width=300, height=80):
        """Primary wordmark: gold 'am' + white 'otive' on navy bg"""
        dwg = svgwrite.Drawing(size=(width, height))
        
        # Navy background
        dwg.add(dwg.rect(insert=(0, 0), size=(width, height), fill=NAVY))
        
        # Text styling
        font_family = "Playfair Display, serif"
        font_size = 48
        font_weight = "600"
        
        # Position text centered
        text_y = height/2 + font_size/3
        
        # Create text group for better positioning
        text_group = dwg.g()
        
        # "am" in gold
        am_text = dwg.text("am", insert=(40, text_y), 
                          fill=GOLD, 
                          font_family=font_family,
                          font_size=font_size,
                          font_weight=font_weight,
                          style="letter-spacing: -2px")
        text_group.add(am_text)
        
        # "otive" in white
        otive_text = dwg.text("otive", insert=(110, text_y),
                             fill=WHITE,
                             font_family=font_family, 
                             font_size=font_size,
                             font_weight=font_weight,
                             style="letter-spacing: -1px")
        text_group.add(otive_text)
        
        dwg.add(text_group)
        return dwg
    
    def create_reversed_wordmark(self, width=300, height=80):
        """Reversed wordmark: gold 'am' + navy 'otive' on light bg"""
        dwg = svgwrite.Drawing(size=(width, height))
        
        # Light background
        dwg.add(dwg.rect(insert=(0, 0), size=(width, height), fill=WHITE))
        
        font_family = "Playfair Display, serif"
        font_size = 48
        font_weight = "600"
        text_y = height/2 + font_size/3
        
        text_group = dwg.g()
        
        # "am" stays gold
        am_text = dwg.text("am", insert=(40, text_y),
                          fill=GOLD,
                          font_family=font_family,
                          font_size=font_size,
                          font_weight=font_weight,
                          style="letter-spacing: -2px")
        text_group.add(am_text)
        
        # "otive" becomes navy
        otive_text = dwg.text("otive", insert=(110, text_y),
                             fill=NAVY,
                             font_family=font_family,
                             font_size=font_size, 
                             font_weight=font_weight,
                             style="letter-spacing: -1px")
        text_group.add(otive_text)
        
        dwg.add(text_group)
        return dwg
    
    def create_monogram(self, size=100):
        """Stylized 'A' monogram with geometric gold accent"""
        dwg = svgwrite.Drawing(size=(size, size))
        
        # Background circle in navy
        dwg.add(dwg.circle(center=(size/2, size/2), r=size/2, fill=NAVY))
        
        # Create geometric 'A' with gold accent
        center_x, center_y = size/2, size/2
        
        # Main 'A' structure
        a_group = dwg.g()
        
        # Left leg of A
        left_line = dwg.line(start=(center_x-15, center_y+20), 
                            end=(center_x-5, center_y-15),
                            stroke=WHITE, stroke_width=4)
        a_group.add(left_line)
        
        # Right leg of A  
        right_line = dwg.line(start=(center_x+15, center_y+20),
                             end=(center_x+5, center_y-15), 
                             stroke=WHITE, stroke_width=4)
        a_group.add(right_line)
        
        # Crossbar in gold (the distinctive element)
        crossbar = dwg.line(start=(center_x-8, center_y+2),
                           end=(center_x+8, center_y+2),
                           stroke=GOLD, stroke_width=5)
        a_group.add(crossbar)
        
        # Small gold accent triangle at top
        triangle_points = [(center_x-3, center_y-15), (center_x+3, center_y-15), (center_x, center_y-20)]
        triangle = dwg.polygon(points=triangle_points, fill=GOLD)
        a_group.add(triangle)
        
        dwg.add(a_group)
        return dwg
    
    def create_stacked_version(self, width=200, height=120):
        """Stacked version for narrow spaces"""
        dwg = svgwrite.Drawing(size=(width, height))
        
        # Navy background
        dwg.add(dwg.rect(insert=(0, 0), size=(width, height), fill=NAVY))
        
        font_family = "Playfair Display, serif"
        
        # "am" on top line
        am_text = dwg.text("am", insert=(width/2, 35),
                          fill=GOLD,
                          font_family=font_family,
                          font_size=32,
                          font_weight="600",
                          text_anchor="middle",
                          style="letter-spacing: -1px")
        dwg.add(am_text)
        
        # "otive" on bottom line  
        otive_text = dwg.text("otive", insert=(width/2, 75),
                             fill=WHITE,
                             font_family=font_family,
                             font_size=32,
                             font_weight="600", 
                             text_anchor="middle",
                             style="letter-spacing: -1px")
        dwg.add(otive_text)
        
        return dwg
    
    def create_with_tagline(self, width=400, height=120, tagline="Your growth. Engineered."):
        """Primary logo with tagline underneath"""
        dwg = svgwrite.Drawing(size=(width, height))
        
        # Navy background
        dwg.add(dwg.rect(insert=(0, 0), size=(width, height), fill=NAVY))
        
        # Main logo
        logo_font = "Playfair Display, serif"
        logo_size = 48
        logo_y = 50
        
        # Logo text
        am_text = dwg.text("am", insert=(60, logo_y),
                          fill=GOLD,
                          font_family=logo_font,
                          font_size=logo_size,
                          font_weight="600",
                          style="letter-spacing: -2px")
        dwg.add(am_text)
        
        otive_text = dwg.text("otive", insert=(130, logo_y),
                             fill=WHITE,
                             font_family=logo_font,
                             font_size=logo_size,
                             font_weight="600",
                             style="letter-spacing: -1px")
        dwg.add(otive_text)
        
        # Tagline
        tagline_text = dwg.text(tagline, insert=(width/2, 85),
                               fill=WHITE,
                               font_family="Inter Tight, sans-serif",
                               font_size=14,
                               text_anchor="middle",
                               opacity="0.9",
                               style="letter-spacing: 0.5px")
        dwg.add(tagline_text)
        
        return dwg
    
    def save_svg_and_png(self, dwg, filename):
        """Save both SVG and 2x PNG versions"""
        # Save SVG
        svg_path = os.path.join(self.output_dir, f"{filename}.svg")
        dwg.saveas(svg_path)
        
        # Save PNG at 2x resolution
        png_path = os.path.join(self.output_dir, f"{filename}@2x.png")
        
        # Use cairosvg to convert SVG to PNG
        try:
            import cairosvg
            # Get SVG content
            svg_content = dwg.tostring()
            
            # Convert to PNG at 2x scale
            cairosvg.svg2png(bytestring=svg_content.encode('utf-8'),
                           write_to=png_path,
                           output_width=dwg.attribs['width'] * 2,
                           output_height=dwg.attribs['height'] * 2)
            print(f"✓ Generated {svg_path} and {png_path}")
        except ImportError:
            print(f"✓ Generated {svg_path} (cairosvg not available for PNG)")
        except Exception as e:
            print(f"✓ Generated {svg_path} (PNG conversion failed: {e})")
    
    def generate_all_logos(self):
        """Generate complete logo system"""
        print("🎨 Generating Amotive logo system...")
        
        # Primary wordmark (dark bg)
        primary = self.create_primary_wordmark()
        self.save_svg_and_png(primary, "amotive-primary")
        
        # Reversed wordmark (light bg)
        reversed_logo = self.create_reversed_wordmark()
        self.save_svg_and_png(reversed_logo, "amotive-reversed")
        
        # Monogram/Icon
        monogram = self.create_monogram()
        self.save_svg_and_png(monogram, "amotive-monogram")
        
        # Stacked version
        stacked = self.create_stacked_version()
        self.save_svg_and_png(stacked, "amotive-stacked")
        
        # With tagline - try different taglines
        taglines = [
            "Your growth. Engineered.",
            "Digital presence, done right.", 
            "Built to convert."  # New Klaff-style option
        ]
        
        for i, tagline in enumerate(taglines):
            filename_suffix = ["engineered", "done-right", "built-convert"][i]
            with_tag = self.create_with_tagline(tagline=tagline)
            self.save_svg_and_png(with_tag, f"amotive-with-tagline-{filename_suffix}")
        
        print("✅ Logo system complete!")

if __name__ == "__main__":
    logo_generator = AmotiveLogo()
    logo_generator.generate_all_logos()