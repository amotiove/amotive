# Professional Trades Service Website Template

A complete, production-ready website template designed specifically for plumbers, HVAC technicians, electricians, roofers, and other trade service professionals. Built for **conversion and trust** with mobile-first responsive design.

## ✨ Key Features

- **Single HTML file** - Everything embedded (CSS + JS)
- **Mobile-first responsive design** - Perfect for emergency mobile searches
- **Trust-focused design** - Navy blue + red/orange color palette
- **Fast-loading** - No external frameworks or dependencies
- **SEO optimized** - Meta tags, Open Graph, structured content
- **Conversion-focused** - Multiple CTAs, emergency service emphasis
- **Professional typography** - Google Fonts (Inter + DM Sans)

## 🎯 Target Customers

This template is perfect for:
- Plumbers
- HVAC technicians  
- Electricians
- Roofers
- General contractors
- Emergency repair services

## 🔧 Customization Guide

### Required Template Variables

Replace these variables throughout the HTML file with your business information:

| Variable | Description | Example |
|----------|-------------|---------|
| `{{BUSINESS_NAME}}` | Your business name | "Smith's Plumbing Co" |
| `{{PHONE}}` | Phone number | "(555) 123-4567" |
| `{{EMAIL}}` | Business email | "info@smithplumbing.com" |
| `{{ADDRESS}}` | Street address | "123 Main Street" |
| `{{CITY}}` | City name | "Denver" |
| `{{TAGLINE}}` | Service description | "Plumbing & HVAC Services" |
| `{{LICENSE_NUMBER}}` | License number | "PL12345" |
| `{{YEARS_EXPERIENCE}}` | Years in business | "15" |

### Quick Search & Replace

Use your text editor's "Find & Replace" function:

1. Find: `{{BUSINESS_NAME}}` → Replace: "Your Business Name"
2. Find: `{{PHONE}}` → Replace: "(555) 123-4567" 
3. Find: `{{EMAIL}}` → Replace: "info@yourbusiness.com"
4. Find: `{{ADDRESS}}` → Replace: "123 Your Street"
5. Find: `{{CITY}}` → Replace: "Your City"
6. Find: `{{TAGLINE}}` → Replace: "Your Services"
7. Find: `{{LICENSE_NUMBER}}` → Replace: "LIC123456"
8. Find: `{{YEARS_EXPERIENCE}}` → Replace: "10"

### Color Customization

The template uses CSS custom properties (variables) for easy color changes:

```css
:root {
    --navy-blue: #1e3a8a;        /* Primary brand color */
    --red-orange: #ea580c;       /* Accent/CTA color */
    --red-orange-light: #fb923c; /* Lighter accent */
    --red-orange-dark: #c2410c;  /* Darker accent */
}
```

To change colors, modify these values in the CSS section.

### Content Customization

#### Services Section
- Modify the 8 service cards to match your specific services
- Update service icons (emoji or replace with icon fonts)
- Adjust service descriptions and features lists

#### Service Areas
- Update the service area list with your actual coverage areas
- Add or remove areas as needed

#### Reviews/Testimonials  
- Replace with real customer reviews
- Use actual customer names (with permission)
- Update locations to match your service areas

#### About Section
- Replace placeholder text with your business story
- Update statistics to match your business
- Replace placeholder image with professional team photo

### Image Placeholders

The template uses placehold.co for placeholder images. Replace these URLs with your actual images:

1. **Hero Image**: `https://placehold.co/500x400/1e3a8a/ffffff?text=Professional+Service+Team`
2. **About Image**: `https://placehold.co/500x400/475569/ffffff?text=Professional+Team+at+Work`

Recommended image sizes:
- Hero: 500x400px minimum
- About: 500x400px minimum  
- Keep images optimized for web (under 500KB each)

### SEO Optimization

#### Meta Tags
Update the following in the `<head>` section:

```html
<title>{{BUSINESS_NAME}} - Professional {{TAGLINE}} in {{CITY}}</title>
<meta name="description" content="Your custom description here">
<meta name="keywords" content="your, relevant, keywords, here">
```

#### Open Graph Tags
Update social media sharing images and descriptions:

```html
<meta property="og:image" content="https://yourdomain.com/social-image.jpg">
<meta property="og:url" content="https://yourdomain.com">
```

### Mobile Emergency Bar

The template includes a sticky emergency contact bar that appears on mobile devices. It shows automatically:
- After 3 seconds on mobile
- When scrolling down past 300px
- Hides when near the top of page

### Additional Customizations

#### Favicon
Replace the inline SVG favicon with your custom favicon:

```html
<link rel="icon" type="image/x-icon" href="/favicon.ico">
```

#### Analytics
Add your Google Analytics or other tracking codes before the closing `</head>` tag.

#### Schema Markup
Consider adding structured data for better SEO:

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "HomeAndConstructionBusiness",
  "name": "Your Business Name",
  "telephone": "555-123-4567",
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "123 Main St",
    "addressLocality": "Your City",
    "addressRegion": "State",
    "postalCode": "12345"
  }
}
</script>
```

## 🚀 Launch Checklist

Before going live, ensure you've:

- [ ] Replaced all `{{TEMPLATE_VARIABLES}}`
- [ ] Added real customer reviews (with permission)
- [ ] Replaced placeholder images with professional photos
- [ ] Updated service areas to match your coverage
- [ ] Added your actual business license number
- [ ] Tested all phone number links
- [ ] Verified email addresses are correct
- [ ] Added favicon and social sharing image
- [ ] Set up analytics tracking
- [ ] Tested on mobile devices
- [ ] Checked page speed (should be fast!)

## 📱 Mobile Optimization

This template is mobile-first and includes:
- Touch-friendly phone number links
- Large, accessible buttons
- Sticky emergency contact bar
- Optimized loading for mobile networks
- Emergency-focused design (customers often search during crises)

## 🔒 Trust Elements

The template emphasizes trust through:
- License number prominently displayed
- "Licensed, Bonded & Insured" badges
- Years of experience highlighted
- Customer reviews and testimonials
- Professional color scheme
- Clean, trustworthy design

## 💰 Pricing Strategy

This template is designed to be sold to trades professionals for **$1,500** because it provides:

1. **Professional design** that builds immediate trust
2. **Conversion-optimized** layout that turns visitors into customers  
3. **Mobile-first** approach for emergency service calls
4. **Complete solution** - no additional development needed
5. **Industry-specific** content and structure
6. **SEO-ready** foundation for online visibility

## 🛠️ Technical Details

- **HTML5** semantic structure
- **CSS3** with custom properties and flexbox/grid
- **Vanilla JavaScript** - no frameworks
- **Google Fonts** for professional typography
- **Responsive design** with mobile-first approach
- **Optimized performance** - minimal HTTP requests
- **Accessible** color contrasts and button sizes

## 📞 Support

For customization help or questions about this template, contact your web development team or follow the customization guide above.

**Remember**: Test thoroughly on multiple devices before launching, and ensure all contact information is accurate - these businesses depend on emergency calls!