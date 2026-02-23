# Restaurant Website Template

**Professional, production-ready restaurant website template designed for premium clients ($1,500+ value)**

## 🎯 Overview

This template delivers a complete, single-file HTML restaurant website with embedded CSS and minimal JavaScript. No external frameworks required - just upload and customize!

### ✨ Features

- **Single HTML file** - Easy deployment and maintenance
- **Mobile-first responsive design** - Perfect on phones, tablets, and desktops
- **Warm amber/gold color palette** - Food-focused, appetite-inducing design
- **Professional typography** - Google Fonts: Playfair Display + DM Sans
- **Smooth animations** - Fade-in sections, smooth scrolling navigation
- **SEO optimized** - Meta tags, Open Graph, Twitter Cards
- **Fast loading** - No external dependencies, optimized images
- **Sticky mobile CTA** - "Order Now" button appears on mobile scroll

### 📱 Mobile Features

- Collapsible navigation menu
- Touch-friendly buttons and links
- Optimized font sizes and spacing
- Sticky "Order Now" button for easy access
- Fast loading on mobile networks

## 🛠 Customization Guide

### Required Template Variables

Replace these variables throughout the HTML file:

| Variable | Description | Example |
|----------|-------------|---------|
| `{{BUSINESS_NAME}}` | Restaurant name | "Bella Vista Ristorante" |
| `{{PHONE}}` | Phone number | "(555) 123-4567" |
| `{{EMAIL}}` | Contact email | "info@bellavista.com" |
| `{{ADDRESS}}` | Street address | "123 Main Street" |
| `{{CITY}}` | City, State ZIP | "San Francisco, CA 94102" |
| `{{TAGLINE}}` | Restaurant tagline | "Authentic Italian Cuisine" |
| `{{HOURS}}` | Weekday hours | "5:00 PM - 10:00 PM" |

### Quick Customization Steps

1. **Find & Replace Variables**
   ```bash
   # Use your text editor's find & replace function
   # Replace {{BUSINESS_NAME}} with actual restaurant name
   # Replace {{PHONE}} with actual phone number
   # Continue for all variables...
   ```

2. **Update Menu Items**
   - Located in the `<section id="menu">` section
   - Modify dish names, descriptions, and prices
   - Add/remove menu categories as needed
   - Keep the structure for consistent styling

3. **Customize About Section**
   - Update the restaurant story in `<section id="about">`
   - Replace placeholder text with actual restaurant history
   - Change the about image placeholder

4. **Update Contact Information**
   - Modify hours in the Hours & Location section
   - Update address and contact details
   - Add Google Maps embed (see Google Maps section)

## 🗺 Google Maps Integration

Replace the map placeholder with actual Google Maps embed:

1. Go to [Google Maps](https://maps.google.com)
2. Search for your restaurant address
3. Click "Share" → "Embed a map"
4. Copy the iframe code
5. Replace this section:
   ```html
   <div class="map-placeholder">
       Google Maps Embed Placeholder<br>
       <!-- Replace with actual Google Maps embed code -->
   </div>
   ```
   
   With your iframe:
   ```html
   <iframe src="https://www.google.com/maps/embed?pb=..." 
           width="100%" height="300" style="border:0;" 
           allowfullscreen="" loading="lazy">
   </iframe>
   ```

## 🖼 Image Customization

### Current Placeholder Images

The template uses placeholder images from placehold.co:

1. **Hero Background** - `1920x1080` food imagery
2. **About Section Image** - `500x400` restaurant interior
3. **Open Graph Image** - `1200x630` social media sharing

### Replacing Images

1. **Hero Background Image**
   ```css
   .hero {
       background: linear-gradient(rgba(44, 44, 44, 0.4), rgba(44, 44, 44, 0.4)), 
                   url('YOUR-HERO-IMAGE.jpg') center/cover;
   }
   ```

2. **About Section Image**
   ```html
   <img src="YOUR-INTERIOR-IMAGE.jpg" alt="{{BUSINESS_NAME}} Interior">
   ```

3. **Social Media Image**
   ```html
   <meta property="og:image" content="YOUR-SOCIAL-IMAGE.jpg">
   ```

### Image Specifications

| Location | Dimensions | Format | Notes |
|----------|------------|--------|-------|
| Hero | 1920×1080 | JPG | High quality food/restaurant exterior |
| About | 500×400 | JPG | Interior or chef photo |
| Social | 1200×630 | JPG/PNG | Logo + restaurant name |
| Favicon | 32×32 | ICO/PNG | Simple logo icon |

## 🎨 Color Customization

The template uses a warm amber/gold palette. To customize colors, modify the CSS variables:

```css
:root {
    --primary-gold: #d4af37;     /* Main gold color */
    --warm-amber: #f5b800;       /* Accent amber */
    --deep-gold: #b8860b;        /* Darker gold */
    --cream: #faf8f3;            /* Light background */
    --warm-white: #fefcf7;       /* Main background */
    --charcoal: #2c2c2c;         /* Text color */
    --dark-brown: #3e2723;       /* Dark accents */
    --light-gold: #f4e4bc;       /* Very light gold */
    --accent-orange: #cc8500;    /* Orange accent */
}
```

### Popular Restaurant Color Schemes

**Elegant Italian**
```css
--primary-gold: #c41e3a;    /* Rich red */
--warm-amber: #228b22;      /* Forest green */
--deep-gold: #8b0000;       /* Dark red */
```

**Modern Steakhouse**
```css
--primary-gold: #8b4513;    /* Saddle brown */
--warm-amber: #daa520;      /* Golden rod */
--deep-gold: #654321;       /* Dark brown */
```

## 📝 Menu Customization

### Adding Menu Items

```html
<div class="menu-item">
    <div class="menu-item-info">
        <h4>Dish Name</h4>
        <p>Dish description with key ingredients</p>
    </div>
    <span class="menu-item-price">$XX</span>
</div>
```

### Adding Menu Categories

```html
<div class="menu-category">
    <h3>Category Name</h3>
    <!-- Menu items go here -->
</div>
```

### Menu Best Practices

- Keep descriptions to 1-2 lines
- Highlight premium ingredients
- Use appetizing language
- Price consistently (whole numbers vs decimals)
- Group logically (apps, mains, desserts)

## 🔧 Technical Customization

### Favicon Setup

Add these files to your root directory:
- `favicon.ico` (32×32 px)
- `apple-touch-icon.png` (180×180 px)

### SEO Optimization

1. **Page Title**: Update the `<title>` tag
2. **Meta Description**: Modify the description meta tag
3. **Keywords**: Update relevant keywords for your location/cuisine
4. **Alt Text**: Add descriptive alt text to all images

### Performance Tips

- Optimize images (use WebP format if supported)
- Minify CSS for production (remove comments and whitespace)
- Consider lazy loading for images below the fold
- Test on Google PageSpeed Insights

## 📱 Mobile Optimization

The template is mobile-first, but consider these additional optimizations:

### Touch Targets
- All buttons and links are minimum 44px touch targets
- Adequate spacing between clickable elements
- Easy-to-tap phone numbers and email links

### Mobile Menu
- Hamburger menu automatically appears on screens < 768px
- Smooth slide animations
- Closes when navigation links are clicked

### Call-to-Action
- Sticky "Order Now" button appears when scrolling on mobile
- Direct phone link for immediate calling
- Prominent reservation button in hero and contact sections

## 🚀 Deployment

### Quick Upload
1. Upload `index.html` to your web server
2. Add favicon files to root directory
3. Upload optimized images
4. Test on mobile and desktop devices

### Domain Setup
1. Point domain to your web hosting
2. Ensure SSL certificate is installed
3. Set up 301 redirects if needed
4. Configure Google Analytics (optional)

## 🧪 Testing Checklist

### Functionality
- [ ] All navigation links work correctly
- [ ] Mobile menu opens and closes
- [ ] Phone links open dialer on mobile
- [ ] Email links open email client
- [ ] Smooth scrolling works
- [ ] Sticky button appears/disappears correctly

### Responsive Design
- [ ] Looks professional on mobile (320px+)
- [ ] Tablet view (768px-1024px) displays correctly
- [ ] Desktop view (1200px+) utilizes space well
- [ ] No horizontal scrolling on any device
- [ ] Text remains readable at all sizes

### Performance
- [ ] Page loads in under 3 seconds
- [ ] Images are appropriately sized
- [ ] No console errors in browser
- [ ] Works in major browsers (Chrome, Firefox, Safari, Edge)

### SEO
- [ ] Page title includes restaurant name and location
- [ ] Meta description is compelling and under 160 characters
- [ ] All images have descriptive alt text
- [ ] Heading hierarchy is logical (h1, h2, h3)

## 💡 Advanced Customization

### Adding Online Ordering

Replace the "Order Now" buttons with links to your ordering platform:

```html
<a href="https://your-ordering-platform.com" class="cta-button">Order Online</a>
```

### Reservation System Integration

Replace reservation buttons with your booking system:

```html
<a href="https://your-reservation-system.com" class="reservation-button">Make a Reservation</a>
```

### Social Media Links

Add social media icons to the footer:

```html
<div class="social-links">
    <a href="https://facebook.com/yourrestaurant">Facebook</a>
    <a href="https://instagram.com/yourrestaurant">Instagram</a>
    <a href="https://twitter.com/yourrestaurant">Twitter</a>
</div>
```

## 🛡 Security & Maintenance

### Regular Updates
- Review and update contact information quarterly
- Update menu items and prices as needed
- Refresh images annually
- Check for broken links monthly

### Security Best Practices
- Keep web server software updated
- Use HTTPS (SSL certificate)
- Regular backups of the website
- Monitor for suspicious activity

## 📞 Support

For technical issues or customization help:

1. Check browser console for JavaScript errors
2. Validate HTML at [W3C Validator](https://validator.w3.org/)
3. Test mobile responsiveness at [Mobile-Friendly Test](https://search.google.com/test/mobile-friendly)
4. Review Google PageSpeed Insights for performance tips

## 📄 License

This template is provided for commercial use. You may customize and deploy it for your restaurant clients without attribution required.

---

**Template Version**: 1.0  
**Created**: 2024  
**Optimized for**: Modern browsers, mobile devices, fast loading  
**Target Market**: Premium restaurant clients ($1,500+ budget)  