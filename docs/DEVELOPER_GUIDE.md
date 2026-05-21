# Developer Guide

This guide is the quickest way to understand how Ninaivu is put together and how to change it safely.

## Trace A Feature In This Order

1. Screen in `lib/presentation/modules/...`
2. Controller in `lib/presentation/controllers/...`
3. Binding in `lib/presentation/bindings/...`
4. Use case in `lib/domain/usecases/...`
5. Repository in `lib/data/repositories/...`
6. Local and remote data sources in `lib/data/datasources/...`

That order mirrors runtime behavior and keeps debugging grounded in the real flow.

## High-Value Work Areas

### Auth and onboarding

- `lib/core/services/auth_service.dart`
- `lib/presentation/modules/common/auth/`

Notes:
- Profile completion saves locally first, then queues backup.
- Successful sessions persist through `AppPreferences`.

### Offline save and sync

- `lib/core/services/sync_service.dart`
- `lib/core/services/auto_sync_service.dart`
- `lib/core/services/background_sync_service.dart`
- `lib/data/datasources/local/sync_queue_local_data_source.dart`

Notes:
- Mutations should write to SQLite before attempting network work.
- Queue entries should reflect the same business scope as the local record.
- Background retry behavior should remain best-effort and OS-managed.

### Lifecycle, app lock, and resume behavior

- `lib/core/services/app_lifecycle_service.dart`
- `lib/core/services/app_lock_service.dart`
- `lib/main.dart`

Notes:
- Resume should be idempotent.
- Pause/detach should remain safe for app-lock and background scheduling hooks.

### Settings, search, and imports

- `lib/presentation/modules/common/settings/`
- `lib/presentation/modules/common/search/`
- `lib/core/services/import_export_service.dart`
- `lib/core/services/global_search_service.dart`
- `lib/core/services/profile_image_service.dart`

## File Size Rule

Keep source files at or below 500 lines where practical. If a file starts drifting past that limit, prefer extracting:

- repeated specs or constants
- helpers with a single clear responsibility
- feature-specific widgets or services

## Firebase and Rules

- Business data lives under `businesses/{businessId}/...`
- Firestore writes should always include the matching `businessId`
- If you add a new synced collection or ownership field, update:
  - `firestore.rules`
  - local model mapping
  - remote model mapping
  - sync queue handling

## Platform Permissions

When you add native-facing features, check the platform files in the same change:

- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`
- `web/manifest.json`

Current examples:

- notifications
- boot-completed receivers
- photo library access for profile image picking

## Before Handing Work Off

1. Run `flutter analyze`
2. Run `flutter test`
3. Manually verify the changed flow if it touches routing, sync, auth, or platform behavior
4. Update `README.md` or `docs/` if the feature surface changed

## Good Next Tests To Add

- offline profile completion and later sync recovery
- sync failure and retry edge cases
- role-based route protection
- settings import/export controller behavior
