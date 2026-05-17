# Project Structure Guide

This document helps a new developer quickly understand where each part of Ninaivu lives and how to trace a feature end to end.

## Top-Level Folders

- `lib/`: main Flutter application code
- `assets/`: images and bundled visual assets
- `test/`: widget and unit tests
- `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/`: platform runners and platform-specific configuration
- `firestore.rules`: Firestore security rules
- `pubspec.yaml`: dependencies, assets, and Flutter package metadata

## `lib/` Layout

### `lib/main.dart`

App entry point. This file initializes Firebase, Crashlytics, notifications, shared preferences, Google sign-in, and the global theme controller before starting the app.

### `lib/app.dart`

Root `GetMaterialApp` configuration. This is where routes, theme, and responsive theme scaling are wired together.

### `lib/core/`

Shared infrastructure used across the entire app.

- `constants/`: app-wide values such as strings, colors, enums, and fixed constants
- `database/`: SQLite helper and table/column names
- `permissions/`: role and permission helpers
- `services/`: authentication, storage, sync, notifications, analytics, preferences, and reminder-related services
- `theme/`: light/dark theme setup and theme controller
- `utils/`: generic helper logic
- `validation/`: business validation helpers
- `widgets/`: reusable UI widgets such as buttons, empty states, logo, text fields, and responsive helpers

### `lib/data/`

Implementation layer for persistence and integration.

- `datasources/local/`: SQLite reads and writes for each feature
- `datasources/remote/`: Firestore reads and writes for each feature
- `models/`: DTO and storage models that map to and from domain entities
- `repositories/`: repository implementations that coordinate local and remote data handling

### `lib/domain/`

Business layer that stays independent from Flutter UI details.

- `entities/`: core business objects like `Client`, `Policy`, `FollowUp`, and `Reminder`
- `repositories/`: abstract contracts used by the domain layer
- `usecases/`: one-file-per-action business operations grouped by feature

### `lib/presentation/`

User-facing layer for screens, navigation, state, and dependency injection.

- `bindings/`: GetX dependency registration per feature
- `controllers/`: screen and workflow state management
- `modules/`: actual UI screens grouped by feature area
- `routes/`: route names, route table, and navigation middleware

## Feature Tracing Examples

### If you want to change a client screen

Start here:

- `lib/presentation/modules/clients/`

Then trace related logic:

- `lib/presentation/controllers/client_*`
- `lib/presentation/bindings/client_bindings.dart`
- `lib/domain/usecases/clients/`
- `lib/data/repositories/client_repository_impl.dart`
- `lib/data/datasources/local/client_local_data_source.dart`
- `lib/data/datasources/remote/client_remote_data_source.dart`

### If you want to change policy rules

Start here:

- `lib/domain/usecases/policies/`
- `lib/core/validation/policy_validator.dart`
- `lib/core/services/reminder_generator_service.dart`

Then check connected UI and persistence files:

- `lib/presentation/modules/policies/`
- `lib/presentation/controllers/policy_*`
- `lib/data/datasources/local/policy_local_data_source.dart`
- `lib/data/datasources/remote/policy_remote_data_source.dart`

### If you want to change auth flow

Start here:

- `lib/presentation/modules/common/auth/`
- `lib/core/services/auth_service.dart`
- `lib/domain/usecases/auth/`
- `lib/data/repositories/auth_repository_impl.dart`

## Common Work Areas

### New screen or UI adjustment

Usually update:

- `lib/presentation/modules/...`
- `lib/presentation/controllers/...`
- optionally `lib/presentation/bindings/...`

### New business rule

Usually update:

- `lib/domain/usecases/...`
- `lib/domain/entities/...`
- `lib/core/validation/...`

### New storage field or sync behavior

Usually update:

- `lib/core/database/database_tables.dart`
- `lib/core/database/database_helper.dart`
- `lib/data/models/...`
- `lib/data/datasources/local/...`
- `lib/data/datasources/remote/...`
- `lib/data/repositories/...`

### New route

Usually update:

- `lib/presentation/routes/app_routes.dart`
- `lib/presentation/routes/app_pages.dart`
- optionally `lib/presentation/routes/route_middleware.dart`

## Files Worth Knowing Early

- `lib/main.dart`: startup lifecycle
- `lib/app.dart`: app shell
- `lib/core/services/sync_service.dart`: sync pipeline
- `lib/core/services/reminder_generator_service.dart`: reminder generation rules
- `lib/core/services/auth_service.dart`: auth/session workflow
- `lib/core/database/database_helper.dart`: local database bootstrap
- `lib/presentation/routes/app_pages.dart`: route registration
- `lib/presentation/routes/route_middleware.dart`: route protection

## What Not To Change Casually

- Generated files like `lib/firebase_options.dart`
- Platform runner files unless the change is platform-specific
- Firebase config files unless the target Firebase project changes

## Suggested First Steps For A New Developer

1. Read `README.md`.
2. Open the feature folder you need under `lib/presentation/modules/`.
3. Read the corresponding controller file in `lib/presentation/controllers/`.
4. Follow the use case and repository chain into `domain/` and `data/`.
5. Run `flutter analyze` and `flutter test` after your changes.
