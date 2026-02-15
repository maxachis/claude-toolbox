# File Organization for AI-Assisted Development

## Core Principle

**Splitting by concern optimizes for partial access; combining optimizes for full access.**

When files are split, an AI assistant can read only what it needs. When files are combined, the AI reads everything regardless of the task. This affects both context usage and the assistant's ability to reason about focused changes.

## When to Split Files

Split when:
- **Low coupling** between concerns (one section can be understood without the other)
- **Large secondary sections** (a concern grows beyond ~100 lines)
- **Typical tasks are partial** (most changes touch one concern, not all)

Examples:
- Separating configuration from implementation
- Extracting types/interfaces into dedicated files
- Splitting tests from source code
- Isolating presentation from business logic

## When to Keep Combined

Keep combined when:
- **High coupling** exists (concerns reference each other extensively)
- **Typical tasks are holistic** (most changes require understanding all concerns)
- **Sections are small** (splitting adds navigation overhead without meaningful savings)

Examples:
- Small utility functions with their tests (if tests are brief)
- Tightly coupled class definitions with their type declarations
- Configuration that directly mirrors code structure

## Evaluating Coupling

**High coupling indicators:**
- Shared constants, magic values, or identifiers across concerns
- One concern generates or templates content for another
- Changes to one concern frequently require changes to the other
- Understanding one concern requires context from the other

**Low coupling indicators:**
- Concerns communicate through well-defined interfaces
- Each concern is self-contained and independently testable
- Historical changes typically touch one concern at a time
- Team members can work on concerns independently

## Directory Organization

The same splitting principles apply at the directory level. When a concern represents a distinct integration or trust boundary, isolate it in its own directory rather than scattering it across the codebase.

Isolate when:
- **The concern crosses a trust boundary** (authentication, authorization, credential management)
- **The concern wraps an external dependency** (third-party APIs, vendor SDKs, external services)
- **Changes require specialized review** (security-sensitive logic, payment processing, data exports)
- **The implementation could be swapped independently** (switching auth providers, replacing an API vendor)

This isolation serves two purposes. First, it gives an AI assistant (or any developer) a clear target — working on auth means reading the auth directory, not hunting through the full codebase. Second, it creates a natural audit surface: security-sensitive or integration-heavy code lives in known locations and can be reviewed with appropriate scrutiny.

Name directories after the concern they represent (`auth/`, `integrations/`, `payments/`), not after implementation details (`middleware/`, `wrappers/`). The name should answer "what boundary does this protect?" rather than "what pattern does this use?"

Avoid isolating prematurely. If a concern is a single file with no signs of growth, a dedicated directory adds navigation overhead for no benefit. Let complexity justify the structure.

## General Guidance

| Pattern | Recommendation |
|---------|----------------|
| Large monolithic modules | Split by responsibility - easier partial reads |
| Tightly integrated features | Keep combined - context is essential |
| Shared utilities/types | Split into dedicated files - high reuse value |
| Configuration + implementation | Split - config changes independently |
| Small cohesive units | Keep combined - overhead not worth it |
