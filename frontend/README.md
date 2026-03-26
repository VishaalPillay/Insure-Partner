# Frontend (Flutter)

This folder is for the Flutter mobile application. It is intended to provide the native UI, state management, real-time map/hazard experience, and all calls to the backend (Render) and Supabase.

## Files

- `pubspec.yaml`: Flutter app manifest and dependencies (currently placeholders per the repo outline: `supabase_flutter`, `provider`, `flutter_map`).
- `lib/main.dart`: App entry point placeholder (intended location for app initialization and MultiProvider wiring).

## Folders (`lib/`)

- `lib/core/`: App-wide foundations (expected: theme, constants, routing/navigation, and Supabase initialization).
- `lib/models/`: Strongly typed Dart models (expected: generated/maintained from the database schema).
- `lib/providers/`: State management (expected: `AuthState`, `PolicyState`, `ClaimState`, etc.).
- `lib/screens/`: UI pages/screens (expected: `LoginScreen`, `DashboardScreen`, `LiveMapScreen`, etc.).
- `lib/services/`: Integration layer (expected: HTTP calls to the backend API + Supabase DB calls).
- `lib/shared/`: Reusable widgets and UI components (expected: buttons, hazard cards, modals).

## Notes

- This repository currently contains **structure and placeholders only**; feature implementation will populate the modules above.
