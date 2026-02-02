# Styling Helper

Help with CSS, styling issues, and design implementation.

## Arguments

- `$ARGUMENTS` - Styling task (e.g., "center this modal", "make responsive", "match this design")

## Instructions

1. **Detect the styling approach**:
   - Plain CSS/SCSS/Less
   - Tailwind CSS
   - CSS Modules
   - Styled-components/Emotion
   - CSS-in-JS variants
   - UI framework (MUI, Chakra, Radix, shadcn, etc.)

2. **For layout issues**:
   - Prefer modern CSS (Flexbox, Grid) over older techniques
   - Consider container queries for component-level responsiveness
   - Use logical properties (margin-inline vs margin-left)

3. **For responsive design**:
   - Mobile-first approach
   - Use relative units (rem, em, %) appropriately
   - Define sensible breakpoints
   - Test edge cases (very small, very large screens)

4. **For visual styling**:
   - Follow existing design tokens/variables
   - Maintain consistent spacing scale
   - Ensure sufficient color contrast
   - Consider dark mode if project supports it

5. **Best practices**:
   - Avoid !important unless overriding third-party
   - Minimize specificity
   - Use CSS custom properties for theming
   - Keep selectors simple and readable

## Output

- CSS/styling code in project's format
- Explanation of approach for complex layouts
- Browser compatibility notes if using newer features
- Responsive behavior description
