# Simulation / Presentation Split

For games and simulations, keep the deterministic game logic strictly separate
from rendering and input. This makes the core unit-testable, replayable, and
drivable by headless bots — none of which is possible once logic is tangled into
the render layer.

## The Rule

- **Simulation layer** — pure logic classes with **no** rendering, input, or
  engine-display dependencies. In Godot, these are `RefCounted` classes (`City`,
  `Game`, `Pressure`, …); in other stacks, plain objects/structs. They take
  inputs and produce next-state + an event/summary describing what happened.
- **Presentation layer** — renderers, scene nodes, input handlers, audio. It
  *reads* simulation state and *calls* simulation methods; it never owns game
  rules. In Godot these are `Node2D` / `Control` subclasses.
- Dependency direction is one-way: presentation depends on simulation, never the
  reverse. The simulation must not `import`/reference the renderer.

## Why It Pays Off

- The simulation runs **headless** — unit tests and self-play bots exercise the
  real game rules with no window.
- Bugs are localized: a balance bug lives in the simulation, a visual bug in
  presentation. No hunting across the boundary.
- New features have an obvious home: persistent run state goes in the
  simulation; transient visual feedback ("juice") goes in presentation.

## Testing Consequence

- Simulation classes are unit-tested (TDD applies — failing test first).
- Pure-presentation code (renderers, particle/juice effects) is **TDD-exempt by
  convention** — it can't run headless, so it's verified by playing. Don't block
  on writing tests for it; do extract any non-trivial logic *out* of the renderer
  into a testable simulation/helper class.

## Smell to Watch For

If the simulation needs a screen size, a delta-time tied to frame rate, a node
reference, or an input event to compute game state — that logic has leaked
across the boundary. Pull it back into presentation and pass the simulation a
plain value (a turn tick, an explicit action) instead.
