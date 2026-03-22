# Token-Efficient Playwright MCP Usage

## Tool Selection Hierarchy

Always use the cheapest tool that gets the job done:

1. **`browser_wait_for`** — Near-zero tokens. Confirm state changes (text appeared/disappeared) before acting.
2. **`browser_evaluate`** — Low tokens. Extract data, check element state, run DOM queries. Returns only what you ask for.
3. **`browser_snapshot`** — High tokens (5-15k). Full accessibility tree. Use sparingly for orientation and finding refs.
4. **`browser_take_screenshot`** — Highest tokens. Only for visual verification when accessibility tree is insufficient.

## Core Patterns

### Extract with evaluate, not snapshots
```javascript
// Good: targeted extraction
browser_evaluate({ function: "() => document.querySelector('h1').textContent" })

// Bad: snapshot the whole page just to read a heading
browser_snapshot()
```

### Confirm state with wait_for
```javascript
// Good: wait for result before proceeding
browser_wait_for({ text: "Results loaded" })

// Bad: snapshot to check if text appeared
browser_snapshot()
```

### One snapshot, many actions
- Take one snapshot to get element refs
- Perform multiple clicks/fills using those refs
- Only re-snapshot if the page structure changes significantly

### Batch extractions
```javascript
// Good: single evaluate returning all data
browser_evaluate({
  function: "() => [...document.querySelectorAll('.item')].map(el => ({ title: el.querySelector('h3').textContent, price: el.querySelector('.price').textContent }))"
})

// Bad: one evaluate per item
```

### Intercept network requests
- For data-heavy pages, use `browser_network_requests` to find API endpoints
- Fetch the API directly via `browser_evaluate` with `fetch()` instead of scraping DOM

## Anti-Patterns

- **Snapshot after every click** — Use `browser_wait_for` to confirm, only snapshot when you need new refs
- **Screenshots for text content** — Use `browser_evaluate` or `browser_snapshot` instead
- **Debug-level console messages** — Use `browser_console_messages({ level: "error" })` unless you need more
- **Unbatched extractions** — One evaluate returning an array beats N evaluates returning one item each
- **Re-snapshotting for data** — If you already see the data in a snapshot, extract it with evaluate next time
- **Full-page screenshots** — Avoid `fullPage: true` unless specifically needed for visual review

## Multi-Page Scraping

1. Use `browser_evaluate` to determine pagination (page count, next button existence)
2. Loop: navigate/click next → `browser_wait_for` (content loaded) → `browser_evaluate` (extract data)
3. Avoid snapshots inside the loop — only snapshot once to understand page structure
4. Aggregate results in a single evaluate if possible

## Form Filling

- Use `browser_fill_form` to fill multiple fields in one call instead of individual `browser_type` calls
- Only snapshot once to get field refs, then fill all fields at once
