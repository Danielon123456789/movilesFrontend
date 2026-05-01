# Build Screen From Figma

## Objective

Implement a Flutter screen from a Figma design in a structured, reusable, scalable and visually faithful way.

---

## Context

This project uses:

- Flutter
- Riverpod
- go_router
- centralized design tokens (`AppColors`, `AppTextStyles`, `AppSpacing`, etc.)
- feature-based architecture
- mobile-first approach
- Figma as the source of truth for visual specs

---

## Source of truth

Figma is the source of truth for UI decisions.

Always prioritize exact Figma specs for:

- spacing
- sizes
- typography
- colors
- radii
- layout proportions

Do not guess values when Figma specs are available.

---

## Phase 1. Analyze first (DO NOT CODE)

Before writing code, identify:

- overall layout structure
- reusable components
- exact Figma specs needed
- visual hierarchy
- interactive elements
- dynamic or stateful UI parts
- missing design tokens
- existing widgets/styles that can be reused in the project

Also detect:

- whether the design is a single continuous surface or separated sections
- whether shadows, borders, cards or background changes are actually present in the design
- risks of breaking existing behavior while implementing the UI

In this phase:

- do not write code
- do not modify files
- do not simulate implementation as completed

---

## Phase 2. Plan

Before implementation, provide:

1. files to create or modify
2. widget tree / screen structure
3. components to extract
4. tokens to reuse
5. tokens to add only if truly missing
6. assumptions or open questions
7. possible risks (UI regressions, state regressions, navigation impact)

---

## Phase 3. Implement step by step

Implement in this order:

1. base screen layout
2. reusable subwidgets
3. theme and design tokens
4. navigation hooks (if needed)
5. state integration (only if needed)
6. dynamic UI behavior

Do not implement everything in one large widget.

---

## Fidelity rules (CRITICAL)

- Do NOT reinterpret the design
- Do NOT “approximate” if Figma specs are available
- Replicate the layout as faithfully as possible
- Do NOT add visual elements that are not present in the design
- Do NOT remove functional visual indicators already required by the screen

Examples:

- do not add a `Card` if the design shows a continuous surface
- do not add shadows, borders or white backgrounds unless Figma explicitly shows them
- do not change spacing or proportions arbitrarily

---

## Design token rules

- Do NOT hardcode colors, spacing, radii or text styles if a token already exists
- Always use the existing design system first
- If a required value does not exist, propose adding a token instead of hardcoding it
- Reuse `AppColors`, `AppTextStyles`, `AppSpacing`, and any existing theme extensions

---

## Component rules

- Keep widgets small and focused
- Avoid large build methods
- Extract repeated or meaningful UI pieces
- Prefer composition over monolithic widgets
- Reuse existing shared widgets before creating new ones

---

## State rules

- Add state only if the screen truly needs it
- Avoid local widget state if the value already belongs in a provider
- Use Riverpod as the single source of truth for shared or persistent UI state
- Do not duplicate state between route params, local variables and providers

Examples:

- if selected date already exists in a provider, do not create `_selectedDate` locally
- if the screen receives a route value, sync it with the provider without duplicating ownership

---

## Behavior rules

When implementing UI from Figma:

- preserve required dynamic behavior
- do not sacrifice functionality for visual cleanup
- keep visual indicators working

Examples:

- current time indicator in a timeline must remain visible if required
- titles like `Hoy` vs formatted date must remain correct
- dynamic states must still render correctly

---

## Responsive rules

- Use Figma iPhone medium as the visual reference
- Do not lock the UI to rigid screen dimensions
- Preserve proportions and spacing while allowing responsive behavior
- Use constraints and layout composition instead of device-specific hacks

---

## Output format

Before coding, respond with:

1. screen analysis
2. files to create/modify
3. widget extraction plan
4. token usage / token gaps
5. implementation order

Then implement in small, controlled steps.

---

## Constraints

- Do not hardcode arbitrary values
- Do not create unnecessary files
- Do not introduce new UI patterns without justification
- Do not refactor unrelated code
- Do not break existing navigation, state or functionality

---

## Goal

The final screen should:

- match the Figma design as closely as possible
- reuse the project's design system
- remain maintainable and scalable
- preserve required behavior and state consistency
