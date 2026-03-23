---
description: A reusable glossary with alphabetical index and backlinks
tags: [frontend, component, reference]
---
# Glossary Component

A pattern for building a glossary page with alphabetical navigation, term definitions, and automatic backlinks from content pages.

## Structure

```
src/
  components/
    Glossary.{tsx,vue,svelte}      # Main glossary list
    GlossaryEntry.{tsx,vue,svelte} # Individual term card
    GlossaryNav.{tsx,vue,svelte}   # A-Z letter navigation
  data/
    glossary.yaml                  # Term definitions (source of truth)
  utils/
    glossary.ts                    # Lookup helpers, slug generation
```

## Data Format

```yaml
# glossary.yaml
terms:
  - term: API Gateway
    slug: api-gateway
    definition: A server that acts as a single entry point for API requests.
    see_also: [reverse-proxy, load-balancer]
    tags: [networking, infrastructure]

  - term: Idempotency
    slug: idempotency
    definition: The property where applying an operation multiple times produces the same result as applying it once.
    see_also: [api-design]
    tags: [api, concepts]
```

## Key Implementation Details

1. **Alphabetical index**: Group terms by first letter, render a sticky A-Z nav bar that highlights the active section on scroll
2. **Slug-based anchors**: Each term gets a URL-friendly anchor (`#api-gateway`) for deep linking
3. **Backlinks**: Content pages reference glossary terms via `[API Gateway](/glossary#api-gateway)`. A build-time script scans content and injects "Referenced in:" links into each glossary entry
4. **Search**: Client-side fuzzy search over term names and definitions using a lightweight library (e.g., Fuse.js)
5. **See also**: Cross-reference links between related terms rendered as chips/tags below the definition

## Accessibility

- Letter nav uses `role="navigation"` with `aria-label="Alphabetical index"`
- Each letter section uses `aria-labelledby` pointing to its heading
- Search input has `role="searchbox"` with live region for result count
- Term cards are semantic `<dl>` / `<dt>` / `<dd>` elements

## Testing Checklist

- [ ] All terms render with correct definitions
- [ ] Letter nav scrolls to the right section
- [ ] Deep links (`#slug`) scroll to and highlight the term
- [ ] Search filters terms and shows "no results" state
- [ ] See-also links navigate to the referenced term
- [ ] Backlinks are generated correctly from content pages
- [ ] Keyboard navigation works through the letter nav
