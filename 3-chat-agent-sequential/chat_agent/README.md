# openai_chat_app

A production-ready Flutter chat app that connects to the OpenAI Responses API with streaming output (SSE). Built with Clean Architecture, SOLID, Material 3, and BYOK (user-provided API key).

## Setup

1. Install Flutter (stable) and the platform toolchains:
   - iOS: Xcode + CocoaPods
   - Android: Android Studio + SDKs
2. From the project directory, fetch dependencies:
   - `flutter pub get`
3. Run on a simulator/device:
   - `flutter run`

## Entering your API key

Open **Settings** from the chat screen and paste your OpenAI API key. The key is stored locally in secure storage and never logged. You can remove it any time.

## Architecture overview

This project follows Clean Architecture:

- **Presentation**: widgets + Riverpod controllers
- **Domain**: entities, repositories (interfaces), and use cases
- **Data**: implementations, API client, DTOs, and storage adapters

Platform services (secure storage, preferences) are abstracted so the core logic remains platform-agnostic.

### Adding Web/Desktop later

The UI is responsive (breakpoints + adaptive layout) and uses Material 3 components that already work on web/desktop. To add web/desktop support:

- Implement a web/desktop secure storage adapter behind `SecureKvStore`.
- Reuse the existing `PrefsStore` abstraction for preferences.
- Keep routing/state intact (GoRouter + Riverpod are platform-agnostic).

## Commands

- `flutter pub get`
- `flutter test`
- `flutter run`
