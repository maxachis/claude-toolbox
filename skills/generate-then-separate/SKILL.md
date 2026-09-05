---
name: generate-then-separate
description: Two-phase workflow for AI-assisted code creation: generate the working whole first, then separate it into its final module boundaries. Load when creating a substantial new feature or module from scratch and deciding how to structure it, or when generated code has grown into one file that needs splitting.
---

# Generate-Then-Separate Workflow

A two-phase approach for AI-assisted code creation that balances fast generation with maintainable output.

## The Problem

Agents optimizing for *generation* and agents optimizing for *maintenance* want opposite things:

- **Generation**: single file, everything inline, no abstractions → fastest path to working code
- **Maintenance**: separated concerns, small files, clear boundaries → easiest to modify surgically

Code that's easy to generate in one shot is hard to iterate on, and vice versa.

## The Workflow

### Phase 1: Generate
- Let the agent produce a working prototype in whatever structure is natural
- Don't fight the monolith — it's the fastest path to "does it work?"
- Focus feedback on correctness and behavior, not structure

### Phase 2: Separate
- Once the prototype works, immediately request a separation pass
- This is cheap now (the agent just wrote the code and has full context)
- Split along natural concern boundaries (e.g., HTML / CSS / JS, or config / logic / presentation)

### Phase 3: Iterate
- All further changes happen against the separated structure
- Each change touches fewer files, reads less context, and has a smaller blast radius

## When to Apply

- Any new feature or page that an agent generates from scratch
- Especially when the generated output exceeds ~300 lines in a single file
- Especially for vanilla (non-bundled) projects where there's no framework enforcing structure

## When NOT to Apply

- Small utilities or scripts under ~200 lines — the overhead of splitting isn't worth it
- Generated code that won't be iterated on (one-shot scripts, throwaway prototypes)
- Projects with a framework that already enforces file structure (React components, Django apps)

## Key Heuristic

If you'll modify the code more than once, separate it. If you'll generate it and move on, don't bother.
