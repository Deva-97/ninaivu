# Developer Guide

This guide explains how to contribute to Ninaivu without getting lost in the codebase.

## How To Read A Feature

Use this order when you open a feature for the first time:

1. Screen in `lib/presentation/modules/...`
2. Controller in `lib/presentation/controllers/...`
3. Binding in `lib/presentation/bindings/...`
4. Use cases in `lib/domain/usecases/...`
5. Repository implementation in `lib/data/repositories/...`
6. Local and remote data sources in `lib/data/datasources/...`

This mirrors the actual runtime flow and is the fastest way to understand behavior.

## Commenting Standard

The goal is clarity, not noise.

- Add one short file-level heading to explain the file's purpose
- Add section comments only when a block would be hard to understand at a glance
- Prefer comments that explain intent, workflow, or why a decision exists
- Avoid repeating what the code already says clearly

Good example:

```dart
/// Splash screen that shows branding while the app restores auth state.
```

Avoid low-value comments like:

```dart
// Set variable
// Call function
```

## Naming Guidance

- Screens end with `_screen.dart`
- Controllers end with `_controller.dart`
- Bindings end with `_bindings.dart`
- Use cases end with `_usecase.dart`
- Repository implementations end with `_repository_impl.dart`
- Local and remote sources end with `_local_data_source.dart` and `_remote_data_source.dart`

## Where To Put New Code

### New UI

Place it in:

- `lib/presentation/modules/...`
- `lib/presentation/controllers/...`
- `lib/presentation/bindings/...` if dependency setup changes

### New business logic

Place it in:

- `lib/domain/usecases/...`
- `lib/domain/entities/...` if the model changes
- `lib/core/validation/...` if it is reusable validation logic

### New database or sync logic

Place it in:

- `lib/data/models/...`
- `lib/data/datasources/local/...`
- `lib/data/datasources/remote/...`
- `lib/data/repositories/...`
- `lib/core/database/...`

## Pull Request Self-Check

Before handing work off:

1. Run `flutter analyze`
2. Run `flutter test`
3. Verify any feature you changed manually
4. Confirm your file names and folder placement match existing patterns
5. Add or update file-level headings if you created new custom files

## Suggestions To Keep The Project Maintainable

- Keep controllers focused on UI state and interaction flow
- Keep business decisions inside use cases or validation helpers
- Keep repository code responsible for orchestration, not UI concerns
- Avoid mixing Firestore logic directly into screens
- Keep reusable widgets in `lib/core/widgets/`

## Recommended Future Improvements

- Add `CONTRIBUTING.md` if external contributors will join the project
- Add architecture decision notes if large design choices evolve
- Add more tests around sync edge cases and role-based access
