# Repository Rules

## Architecture & Boundaries
- Follow Clean Architecture: Presentation → Domain → Data dependencies only.
- Domain layer must not import Flutter, Dio, or platform-specific packages.
- Data layer implements domain repositories and owns API/storage details.

## SOLID & Maintainability
- Single-responsibility classes and use cases (one action per class).
- Prefer composition over inheritance.
- Keep APIs small and testable.

## Platform-Agnostic Mindset
- UI must be responsive and usable on mobile, tablet, and desktop.
- Avoid touch-only interactions without an accessible alternative.
- All platform services must be behind abstractions.

## Security & Privacy
- Never log secrets or API keys.
- Redact Authorization headers in logs.
- Store API keys only in secure storage.

## Testing
- Write unit tests for use cases and parsers.
- Add widget tests for key UI behavior.
- Keep analyzer clean (`flutter analyze`).

## PR Checklist
- Architecture boundaries respected
- No secrets in logs or source
- Tests added/updated and passing
- `flutter analyze` clean
