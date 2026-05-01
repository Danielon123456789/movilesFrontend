---
name: create-feature
description: >-
  Creates new app features under lib/features with minimal layers (presentation,
  domain, data as needed), Riverpod state, go_router navigation, and design tokens.
  Use when scaffolding a feature, adding a new module, or the user invokes
  create-feature.
disable-model-invocation: true
---
# Create Feature

## Objective

Create a new feature following the project architecture in a clean, scalable and minimal way, without adding unnecessary layers or files.

---

## Context

Project structure:

- `lib/features/<feature_name>/`
  - `presentation/`
  - `data/`
  - `domain/`

State management:

- Riverpod

Navigation:

- go_router

UI system:

- centralized theme and design tokens

---

## Phase 1. Analyze first (DO NOT CODE)

Before creating files, identify:

- the feature purpose
- whether it is UI-only, local-data, or API-driven
- whether similar functionality already exists
- what screens, widgets, providers or repositories are actually needed
- whether the feature needs navigation
- whether the feature owns state or reuses existing shared state

In this phase:

- do not create files yet
- do not scaffold blindly
- do not assume every feature needs all layers

---

## Phase 2. Decide the minimum required structure

Create only the layers that are truly needed.

### UI-only feature

Use only:

- `presentation/`

### Feature with state but no external data

Use:

- `presentation/`
- `domain/` only if business logic or entities justify it

### Feature with API/local persistence

Use:

- `presentation/`
- `domain/`
- `data/`

Do not create empty folders or placeholder files without purpose.

---

## Recommended structure

When needed, use:

- `features/<feature_name>/`
  - `presentation/`
    - `screens/`
    - `widgets/`
    - `controllers/`
  - `data/`
    - `datasources/`
    - `dtos/`
    - `repositories/`
    - `mappers/` (if needed)
  - `domain/`
    - `entities/`
    - `repositories/`

Only add folders that the feature actually uses.

---

## Base files

Create only what is justified by the feature.

Possible files:

- `<feature>_screen.dart`
- `<feature>_controller.dart`
- `<feature>_repository.dart`
- `<feature>_repository_impl.dart`
- `<feature>_remote_data_source.dart`
- `<entity>.dart`
- `<dto>.dart`
- feature widgets if needed

Do not scaffold files "just in case".

---

## Responsibilities

### presentation/

- screens
- reusable widgets for that feature
- Riverpod controllers/providers
- UI state rendering

### domain/

- feature entities
- repository contracts
- pure business rules

### data/

- remote/local data sources
- DTOs
- mappers
- repository implementations

---

## Rules

- Keep files minimal and purposeful
- Do not overengineer
- UI must not call APIs directly
- Controllers/providers handle UI-facing logic and state
- Do not duplicate patterns already present in other features
- Reuse shared widgets and existing infrastructure when possible
- Do not add `domain/` or `data/` if the feature does not need them

---

## State rules

- Use Riverpod for feature state
- Keep a single source of truth
- Do not duplicate state between screen-local variables and providers
- If the feature shares state across screens, keep it in providers

---

## Navigation rules

- If the feature introduces a new screen, identify the router changes required
- Use go_router
- Do not use Navigator directly if the project standard is go_router

---

## UI rules

- Follow the centralized design system
- Do not hardcode colors, spacing or text styles if tokens exist
- Reuse shared components before creating new ones
- Keep widgets small and composable

---

## Integration checklist

Before implementation, specify:

1. feature purpose
2. required layers
3. files to create or modify
4. state ownership
5. navigation impact
6. data source needs
7. reusable components to leverage

---

## Output format

Before coding, respond with:

1. feature analysis
2. minimal structure required
3. files to create/modify
4. step-by-step implementation plan
5. assumptions or open questions

Then implement step by step.

---

## Constraints

- Do not create unnecessary files
- Do not add empty abstractions
- Do not refactor unrelated features
- Do not introduce new patterns without justification
- Do not create repositories or DTOs if there is no real data layer need

---

## Goal

The final feature should:

- fit naturally into the existing architecture
- use only the necessary layers
- remain easy to maintain
- avoid unnecessary complexity
