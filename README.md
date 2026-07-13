# Ninaivu

Ninaivu is an offline-first Flutter app for insurance renewal operations. SQLite is the primary working store on-device, and Firebase is used for authentication, cloud backup, and cross-device sync when connectivity is available.

## What The App Does

- Phone OTP and Google sign-in
- Admin and agent dashboards
- Agent and customer management
- Client management with profile images, birthdays, and special dates
- Policy management with renewal status tracking
- Reminder and follow-up workflows
- Global search across clients, policies, and agents
- Settings for theme, app lock, profile image, sync status, and exports
- CSV import/export for clients and policies
- Local notifications for reminders
- Background and queued sync retries on Android and iOS

## Offline-First Behavior

- Every create, update, and delete is saved to SQLite first.
- The same change is then queued in `sync_queue`.
- `SyncService` pushes queued items to Firestore when the device is online.
- `AutoSyncService` retries after connectivity changes.
- `BackgroundSyncService` registers OS-managed work so queued changes can retry after the app is backgrounded or closed.
- Profile setup now follows the same local-first pattern instead of failing just because Firebase backup is temporarily unavailable.

## Lifecycle And App Flow Notes

- On app resume, Ninaivu refreshes notifications, schedules queued background sync, and triggers an immediate sync attempt.
- On pause or detach, the app lock service is notified so the app can protect the session when returning.
- Route access is protected with GetX middleware:
  - `admin`: admin dashboard, user management, all data views
  - `agent`: agent dashboard, assigned data, settings, search

## Project Structure

- `lib/core`: shared constants, services, permissions, localization, theme, database helpers, and reusable widgets
- `lib/data`: local/remote data sources, models, and repository implementations
- `lib/domain`: entities, repository contracts, and use cases
- `lib/presentation`: routes, bindings, controllers, and screens
- `docs`: contributor-facing project guides
- `test`: unit and widget tests

See [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md) and [docs/DEVELOPER_GUIDE.md](docs/DEVELOPER_GUIDE.md) for the deeper map.

## Key Files

- `lib/main.dart`: bootstrap, Firebase, notifications, lifecycle, and global services
- `lib/core/services/auth_service.dart`: login, profile completion, and session flow
- `lib/core/services/sync_service.dart`: queued SQLite-to-Firestore sync
- `lib/core/services/background_sync_service.dart`: WorkManager-backed background sync registration
- `lib/core/services/app_lifecycle_service.dart`: resume/background lifecycle hooks
- `lib/core/services/import_export_service.dart`: CSV import/export workflows
- `lib/core/services/global_search_service.dart`: local search service
- `lib/presentation/modules/common/settings/settings_screen.dart`: settings, exports, imports, and local data controls

## Firestore Structure

Business data is stored under:

- `businesses/{businessId}/users/{userId}`
- `businesses/{businessId}/clients/{clientId}`
- `businesses/{businessId}/policies/{policyId}`
- `businesses/{businessId}/reminders/{reminderId}`
- `businesses/{businessId}/follow_ups/{followUpId}`

The current rules in [firestore.rules](firestore.rules) now also validate business scoping on document writes so queued offline changes cannot be replayed into the wrong business path.

## Permissions And Platform Notes

- Android manifest includes internet, notifications, and boot-completed support for sync/notification recovery.
- iOS now includes photo library usage messaging for profile image selection.
- `web/manifest.json` has been updated to describe the app correctly instead of the Flutter default placeholder text.

## Quick Start

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run
```

## Recommended Validation

```bash
flutter analyze
flutter test
flutter build apk --release
```
