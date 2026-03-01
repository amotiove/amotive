#!/usr/bin/env python3
"""
Amotive Brand Kit - Favicon Generation
Creates favicon set from the monogram design
"""

import svgwrite
import os
from PIL import Image, ImageDraw, ImageFont
import cairosvg
import json
from io import BytesIO

# Brand Colors
GOLD = "#C9A84C"
NAVY = "#0A1628"
WHITE = "#FFFFFF"

class AmotiveFavicons:
    def __init__(self, output_dir="favicons"):
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)
    
    def create_monogram_svg(self, size=512):
        """Create high-resolution monogram SVG"""
        dwg = svgwrite.Drawing(size=(size, size))
        
        # Background circle in navy
        dwg.add(dwg.circle(center=(size/2, size/2), r=size/2, fill=NAVY))
        
        # Create geometric 'A' with gold accent
        center_x, center_y = size/2, size/2
        
        # Scale factor for larger size
        scale = size / 100
        
        # Main 'A' structure
        a_group = dwg.g()
        
        # Left leg of A
        left_line = dwg.line(start=(center_x-15*scale, center_y+20*scale), 
                            end=(center_x-5*scale, center_y-15*scale),
                            stroke=WHITE, stroke_width=int(4*scale))
        a_group.add(left_line)
        
        # Right leg of A  
        right_line = dwg.line(start=(center_x+15*scale, center_y+20*scale),
                             end=(center_x+5*scale, center_y-15*scale), 
                             stroke=WHITE, stroke_width=int(4*scale))
        a_group.add(right_line)
        
        # Crossbar in gold (the distinctive element)
        crossbar = dwg.line(start=(center_x-8*scale, center_y+2*scale),
                           end=(center_x+8*scale, center_y+2*scale),
                           stroke=GOLD, stroke_width=int(5*scale))
        a_group.add(crossbar)
        
        # Small gold accent triangle at top
        triangle_points = [(center_x-3*scale, center_y-15*scale), 
                          (center_x+3*scale, center_y-15*scale), 
                          (center_x, center_y-20*scale)]
        triangle = dwg.polygon(points=triangle_points, fill=GOLD)
        a_group.add(triangle)
        
        dwg.add(a_group)
        return dwg
    
    def svg_to_png(self, svg_content, width, height):
        """Convert SVG to PNG using cairosvg"""
        png_data = cairosvg.svg2png(bytestring=svg_content.encode('utf-8'),
                                   output_width=width,
                                   output_height=height)
        return Image.open(BytesIO(png_data))
    
    def create_ico_favicon(self, base_svg_content):
        """Create favicon.ico with multiple sizes"""
        sizes = [16, 32]
        images = []
        
        for size in sizes:
            png_img = self.svg_to_png(base_svg_content, size, size)
            images.append(png_img)
        
        # Save as ICO
        ico_path = os.path.join(self.output_dir, "favicon.ico")
        images[0].save(ico_path, format='ICO', sizes=[(16, 16), (32, 32)])
        print(f"✓ Generated {ico_path}")
    
    def create_png_favicon(self, base_svg_content, size, filename):
        """Create PNG favicon of specified size"""
        png_img = self.svg_to_png(base_svg_content, size, size)
        png_path = os.path.join(self.output_dir, filename)
        png_img.save(png_path, format='PNG', optimize=True)
        print(f"✓ Generated {png_path}")
    
    def create_webmanifest(self):
        """Create site.webmanifest file"""
        manifest = {
            "name": "Amotive - Digital Agency",
            "short_name": "Amotive",
            "icons": [
                {
                    "src": "android-chrome-192.png",
                    "sizes": "192x192",
                    "type": "image/png"
                },
                {
                    "src": "android-chrome-512.png",
                    "sizes": "512x512",
                    "type": "image/png"
                }
            ],
            "theme_color": NAVY,
            "background_color": NAVY,
            "display": "standalone",
            "start_url": "/",
            "orientation": "portrait"
        }
        
        manifest_path = os.path.join(self.output_dir, "site.webmanifest")
        with open(manifest_path, 'w', encoding='utf-8') as f:
            json.dump(manifest, f, indent=2)
        print(f"✓ Generated {manifest_path}")
    
    def create_favicon_html_snippet(self):
        """Create HTML snippet for favicon implementation"""
        html_snippet = """<!-- Amotive Favicons -->
<link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
<link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
<link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
<link rel="manifest" href="/site.webmanifest">
<meta name="theme-color" content="#0A1628">
<meta name="apple-mobile-web-app-title" content="Amotive">
<meta name="application-name" content="Amotive">"""
        
        snippet_path = os.path.join(self.output_dir, "favicon-html-snippet.html")
        with open(snippet_path, 'w', encoding='utf-8') as f:
            f.write(html_snippet)
        print(f"✓ Generated {snippet_path}")
    
    def generate_all_favicons(self):
        """Generate complete favicon set"""
        print("🎨 Generating Amotive favicon set...")
        
        # Create base monogram SVG
        monogram_svg = self.create_monogram_svg(512)
        svg_content = monogram_svg.tostring()
        
        # Save the source SVG
        svg_path = os.path.join(self.output_dir, "amotive-monogram-source.svg")
        monogram_svg.saveas(svg_path)
        print(f"✓ Generated {svg_path}")
        
        # Create favicon.ico (16x16, 32x32)
        self.create_ico_favicon(svg_content)
        
        # Create individual PNG favicons
        self.create_png_favicon(svg_content, 16, "favicon-16x16.png")
        self.create_png_favicon(svg_content, 32, "favicon-32x32.png")
        self.create_png_favicon(svg_content, 180, "apple-touch-icon.png")
        self.create_png_favicon(svg_content, 192, "android-chrome-192.png")
        self.create_png_favicon(svg_content, 512, "android-chrome-512.png")
        
        # Create webmanifest
        self.create_webmanifest()
        
        # Create HTML snippet
        self.create_favicon_html_snippet()
        
        print("✅ Favicon set complete!")
        print("\n📋 Implementation Instructions:")
        print("1. Upload all PNG files and favicon.ico to your website's root directory")
        print("2. Upload site.webmanifest to your website's root directory")  
        print("3. Add the HTML snippet from favicon-html-snippet.html to your <head> section")

if __name__ == "__main__":
    favicon_generator = AmotiveFavicons()
    favicon_generator.generate_all_favicons()