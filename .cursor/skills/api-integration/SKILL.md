# API Integration

## Objective

Integrate an API endpoint into an existing feature in a clean, maintainable and consistent way, respecting the project's architecture and state management rules.

---

## Context

- HTTP client: Dio
- Architecture: feature-based
- State management: Riverpod

---

## Expected flow

UI → Controller/Notifier → Repository → DataSource → API

Do not skip layers unless the feature is explicitly simple and the existing architecture already allows it.

---

## Step 1. Analyze first

Before writing code, identify:

- endpoint path and HTTP method
- request parameters
- request body, if any
- response structure
- possible error cases
- authentication requirements
- whether similar integration already exists in the project

Do not start implementation before identifying these points.

---

## Step 2. Check existing code

Before creating new files:

- look for an existing Dio client in `core/network`
- look for reusable request/response patterns
- look for existing repository interfaces in the feature
- look for existing DTOs, entities or mappers that can be reused

Do not create duplicate infrastructure.

---

## Step 3. Create or update layers

### data/

Create or update only what is necessary:

- `datasources/<feature>_remote_data_source.dart`
- `dtos/<model>_dto.dart`
- `repositories/<feature>_repository_impl.dart`
- mappers if needed

### domain/

Create or update:

- `entities/<model>.dart`
- `repositories/<feature>_repository.dart`

### presentation/

Create or update:

- `controllers/<feature>_controller.dart`

Only add files that are actually needed by the integration.

---

## Layer responsibilities

### DataSource

- talks directly to the API
- uses Dio
- returns DTOs or data-layer models
- does not contain UI logic
- does not expose raw JSON to upper layers

### DTO

- represents the API request/response format
- contains `fromJson` / `toJson` when needed
- should not be used directly in the UI

### Mapper

- converts DTOs into domain entities
- keeps transformation logic out of controllers and widgets

### Repository

- hides data source details from presentation
- returns domain entities or domain-safe results
- handles mapping and error conversion

### Controller / Notifier

- orchestrates the use case for the UI
- exposes explicit UI states
- does not know Dio details
- does not parse JSON

---

## Rules

- Do NOT parse JSON in UI
- Do NOT parse JSON in controllers if it belongs in DTOs
- Do NOT use DTOs directly in widgets
- Do NOT expose Dio response objects outside the data layer
- Use DTOs for API transport models
- Map DTO → Entity explicitly
- Handle errors explicitly
- Keep Dio logic in the data layer
- Keep API shape isolated from the rest of the app

---

## Error handling

Handle errors explicitly for:

- network failure
- timeout
- unauthorized
- not found
- server error
- invalid response
- parsing/mapping error

Do not throw generic exceptions without context.

Convert infrastructure errors into app-friendly errors before reaching the UI.

---

## State handling

When exposing data to the UI:

- use Riverpod providers/controllers as the single source of truth
- expose explicit states:
  - loading
  - success
  - empty
  - error

Do not trigger raw Dio calls directly from widgets.

---

## Output format

Before implementation, respond with:

1. files to create or modify
2. endpoint integration flow
3. assumptions or open questions
4. step-by-step plan

Then implement step by step.

---

## Constraints

- Do not introduce new networking libraries
- Do not duplicate repository patterns
- Do not hardcode base URLs outside the proper config
- Do not create unnecessary abstractions
- Do not change unrelated feature code

---

## Goal

The final integration should:

- respect the existing feature architecture
- isolate API details in the data layer
- expose clean state to the UI
- be easy to extend and maintain
