# Project Rules

## Overview

This is a vanilla HTML/CSS/JS frontend project with no bundler or framework. Follow these conventions when making changes.

## File Structure

Separate concerns into distinct files from the start:

```
index.html          # Markup and structure only
style.css           # All styles
app.js              # All behavior
data/               # Static data files (JSON, GeoJSON, etc.)
```

For larger projects, split further by responsibility:

```
index.html
css/
├── base.css        # Reset, variables, typography
├── components.css  # UI component styles
├── layout.css      # Page layout
js/
├── app.js          # Entry point, initialization
├── config.js       # Constants, configuration
├── utils.js        # Shared helper functions
data/
```

## HTML

- Keep `<style>` and `<script>` blocks out of HTML — use external files
- Use semantic elements (`<main>`, `<nav>`, `<section>`)
- Load CSS in `<head>`, scripts at end of `<body>` or with `defer`
- Use CDN links for libraries (no npm/bundler needed)

## CSS

- Use CSS custom properties (variables) for theming
- Mobile-first responsive design
- No CSS-in-JS — plain CSS or CSS files only
- Group styles by component/concern with section comments

## JavaScript

- No build step — code runs directly in the browser
- Use `const`/`let`, template literals, arrow functions (modern ES6+)
- Avoid deep module systems — use `<script type="module">` if imports are needed
- Keep global state minimal and explicit

## Dependencies

- Load libraries via CDN (`unpkg`, `cdnjs`, `jsdelivr`)
- Pin versions in URLs (e.g., `leaflet@1.9.4`, not `leaflet@latest`)
- No `package.json` or `node_modules` unless explicitly needed

## Deployment

- Static hosting (Netlify, GitHub Pages, Vercel)
- No build step required for the frontend itself
- If data needs processing, use a separate build script (Python, bash, etc.)
