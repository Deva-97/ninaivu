# Project Structure Guide

This document maps the important folders and the main feature entry points in Ninaivu.

## Top Level

- `lib/`: Flutter application code
- `assets/`: bundled images and identity assets
- `docs/`: contributor documentation
- `test/`: unit and widget tests
- `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/`: platform runners and native configuration
- `firestore.rules`: Firestore security rules

## `lib/`

### `lib/main.dart`

Application bootstrap:

- Firebase initialization
- Crashlytics wiring
- notifications
- shared preferences
- app settings
- background sync registration
- lifecycle observers

### `lib/app.dart`

Root `GetMaterialApp` with routes, localization, and theme selection from settings.

### `lib/core/`

Shared infrastructure.

- `constants/`: route labels, translations, colors, and app-wide constants
- `database/`: SQLite table names, columns, and bootstrap helper
- `localization/`: app languages and translations
- `permissions/`: role and access helpers
- `services/`: auth, sync, notifications, search, import/export, app lock, and profile image services
- `theme/`: material theme setup
- `utils/`: reusable helpers
- `validation/`: domain validation helpers
- `widgets/`: reusable building blocks used across screens

### `lib/data/`

Persistence and integration layer.

- `datasources/local/`: SQLite reads and writes
- `datasources/remote/`: Firestore reads and writes
- `models/`: map between local, remote, and domain shapes
- `repositories/`: combine local-first writes with sync orchestration

### `lib/domain/`

Business contracts and use cases.

- `entities/`: app data structures
- `repositories/`: abstractions used by use cases
- `usecases/`: one action per file

### `lib/presentation/`

Routes, state, and UI.

- `bindings/`: dependency registration
- `controllers/`: GetX state and workflow logic
- `modules/`: feature screens
- `routes/`: route names, page registration, and middleware

## Feature Entry Points

### Authentication and profile setup

- `lib/presentation/modules/common/auth/`
- `lib/core/services/auth_service.dart`

### Dashboards

- `lib/presentation/modules/admin/dashboard/`
- `lib/presentation/modules/agent/dashboard/`
- `lib/presentation/controllers/admin_dashboard_controller.dart`
- `lib/presentation/controllers/agent_dashboard_controller.dart`

### Clients

- `lib/presentation/modules/clients/`
- `lib/presentation/controllers/client_*`
- `lib/data/repositories/client_repository_impl.dart`

### Policies

- `lib/presentation/modules/policies/`
- `lib/presentation/controllers/policy_*`
- `lib/data/repositories/policy_repository_impl.dart`
- `lib/core/services/reminder_generator_service.dart`

### Reminders and follow-ups

- `lib/presentation/modules/reminders/`
- `lib/presentation/modules/follow_ups/`
- `lib/data/repositories/reminder_repository_impl.dart`
- `lib/data/repositories/follow_up_repository_impl.dart`

### Settings, search, and utilities

- `lib/presentation/modules/common/settings/`
- `lib/presentation/modules/common/search/`
- `lib/core/services/global_search_service.dart`
- `lib/core/services/import_export_service.dart`
- `lib/core/services/profile_image_service.dart`
- `lib/core/services/insurance_document_parser.dart`

## Sync-Related Files Worth Knowing Early

- `lib/core/services/sync_service.dart`
- `lib/core/services/auto_sync_service.dart`
- `lib/core/services/background_sync_service.dart`
- `lib/core/services/app_lifecycle_service.dart`
- `lib/data/datasources/local/sync_queue_local_data_source.dart`
- `lib/core/database/database_helper.dart`

## When A New Synced Field Is Added

You will usually touch:

- `lib/core/database/database_tables.dart`
- `lib/core/database/database_helper.dart`
- the relevant domain entity
- the relevant data model
- local data source mapping
- remote data source mapping
- repository orchestration
- `firestore.rules` if authorization or ownership changes

## Platform Files To Review For Native Features

- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`
- `web/manifest.json`

Examples in the current app:

- background sync support
- local notifications
- image picking permissions

## Do Not Change Casually

- generated Flutter/Firebase files
- platform runner files unrelated to your feature
- Firestore rules without checking repository and sync assumptions at the same time
