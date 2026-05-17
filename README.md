# Ninaivu

Ninaivu is an offline-first Flutter app for insurance renewal operations. It helps admins and agents manage clients, policies, reminders, follow-ups, and Firebase-backed cloud backup while keeping SQLite as the primary working store.

## Why This Project Is Easy To Work On

This repository is organized with a clear layered structure:

- `lib/core`: shared constants, services, theme, permissions, validation, database helpers, and reusable widgets
- `lib/data`: local and remote data sources, models, and repository implementations
- `lib/domain`: business entities, repository contracts, and use cases
- `lib/presentation`: routes, bindings, controllers, and UI modules
- `test`: widget and unit tests grouped by feature area

The main onboarding source for new developers is the documentation in `README.md` and the `docs/` folder.

## Quick Start

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run
```

## Tech Stack

- Flutter
- Dart
- GetX
- SQLite via `sqflite`
- Firebase Auth
- Cloud Firestore
- Firebase Crashlytics
- SharedPreferences
- `connectivity_plus`
- Local notifications

## Core Features

- Phone OTP and Google sign-in
- Admin and agent role separation
- Client management
- Policy management
- Auto-generated renewal reminders
- Follow-up tracking
- Offline-first local persistence
- Manual sync to Firestore
- Background sync retries on Android and iOS
- Last synced timestamp tracking
- Crashlytics logging for sync failures

## Architecture Summary

Ninaivu follows a practical clean architecture:

1. `presentation` handles screens, user interaction, state, navigation, and bindings.
2. `domain` contains the business rules through entities, contracts, and use cases.
3. `data` fulfills domain contracts using SQLite, Firebase, and model mapping.
4. `core` contains shared infrastructure used across all layers.

Typical flow:

`Screen -> Controller -> UseCase -> Repository -> Local/Remote Data Source`

## Project Structure

High-level guide:

- `lib/main.dart`: app bootstrap, Firebase initialization, notifications, preferences, and global dependency setup
- `lib/app.dart`: root `GetMaterialApp` configuration
- `lib/presentation/modules/common`: splash, login, OTP, profile setup, and shared module UI
- `lib/presentation/modules/admin`: admin dashboard and user management
- `lib/presentation/modules/agent`: agent dashboard
- `lib/presentation/modules/clients`: client list, detail, and create/edit flows
- `lib/presentation/modules/policies`: policy list, detail, and create/edit flows
- `lib/presentation/modules/follow_ups`: follow-up list, detail, and create/edit flows
- `lib/presentation/modules/reminders`: reminder list and detail flows
- `lib/presentation/controllers`: GetX controllers for each feature workflow
- `lib/presentation/bindings`: dependency injection setup per feature
- `lib/presentation/routes`: route names, page registration, and auth middleware
- `lib/data/datasources/local`: SQLite-facing persistence code
- `lib/data/datasources/remote`: Firestore-facing persistence code
- `lib/data/repositories`: repository implementations combining data sources
- `lib/domain/usecases`: single-purpose business actions per feature
- `lib/core/services/sync_service.dart`: offline sync orchestration
- `lib/core/services/reminder_generator_service.dart`: renewal reminder generation rules
- `lib/core/database`: database schema names and SQLite helper

For a deeper map, see [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md) and [docs/DEVELOPER_GUIDE.md](docs/DEVELOPER_GUIDE.md).

## Role Access

- `admin`
  - Access admin dashboard
  - Manage agents and customers
  - View all clients, policies, reminders, and follow-ups
- `agent`
  - Access agent dashboard only
  - Manage only records created by or assigned to the agent
  - Cannot access admin user management or global dashboard

## Offline-First Architecture

- SQLite is the source of truth
- Every create, update, and delete writes to SQLite first
- Every mutation adds an item to `sync_queue`
- `SyncService` checks connectivity and pushes pending items to Firestore
- Mobile builds also register OS-managed background sync tasks for queued items
- On success, local records are marked `synced`
- On failure, retries and error messages are stored locally and sync failures are logged to Crashlytics

## Background Sync Notes

- Android now uses WorkManager for periodic and queued sync retries even when the app is not in the foreground.
- iOS now opts into Background Fetch so the system can run sync opportunistically after the app is closed.
- Background execution is still controlled by the operating system and is never truly continuous, especially on iOS.

## SQLite Tables

- `users`
- `clients`
- `policies`
- `reminders`
- `follow_ups`
- `sync_queue`

## Sync Queue

Tracked fields:

- `id`
- `business_id`
- `table_name`
- `record_id`
- `operation`
- `payload`
- `retry_count`
- `last_error`
- `created_at`
- `updated_at`
- `sync_status`

Supported sync statuses:

- `pending_create`
- `pending_update`
- `pending_delete`
- `synced`
- `failed`

## Firestore Structure

All business data is written under:

- `businesses/{businessId}/users/{userId}`
- `businesses/{businessId}/clients/{clientId}`
- `businesses/{businessId}/policies/{policyId}`
- `businesses/{businessId}/reminders/{reminderId}`
- `businesses/{businessId}/follow_ups/{followUpId}`

## Firebase Setup Notes

1. Add the Firebase config files for the target project.
2. Confirm Firestore and Authentication are enabled.
3. Deploy Firestore rules from `firestore.rules`.
4. Confirm Crashlytics is enabled for the Android app.
5. Keep the real `android/key.properties` out of git.

## Android Release Signing

This project is safe when `android/key.properties` is missing:

- release builds fall back to debug signing locally
- actual Play Store release signing requires your own keystore

Create these locally:

- `android/key.properties`
- the keystore file referenced by `storeFile`

You can start from [android/key.properties.example](android/key.properties.example).

Example `android/key.properties`:

```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=upload
storeFile=../keystore/upload-keystore.jks
```

## Recommended Developer Workflow

1. Start in `README.md`, then open `docs/PROJECT_STRUCTURE.md`.
2. Find the feature inside `lib/presentation/modules/<feature>`.
3. Use the matching controller in `lib/presentation/controllers`.
4. Trace business logic into `lib/domain/usecases`.
5. Trace persistence into `lib/data/repositories` and `lib/data/datasources`.
6. Run `flutter analyze` and `flutter test` before handing work off.

## Suggested Coding Conventions For Future Contributors

- Keep one primary responsibility per file.
- Keep onboarding knowledge in `README.md` and the `docs/` folder so project guidance stays easy to find.
- Prefer explaining intent at section boundaries instead of commenting every line.
- Keep UI logic in `presentation`, business rules in `domain`, and storage/network code in `data`.
- Avoid editing generated files unless the generation source changes.

## Validation Commands

```bash
flutter analyze
flutter test
flutter build apk --release
```
