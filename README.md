# Ninaivu

Ninaivu is an offline-first Flutter app for insurance renewal operations. It helps admins and agents manage clients, policies, reminders, follow-ups, and Firebase-backed cloud backup for Android release builds.

## Project Overview

Ninaivu stores operational data in local SQLite first so the app remains usable without connectivity. Firestore is used as a cloud sync and backup layer, not as the primary source of truth.

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

## Features

- Phone OTP and Google sign-in
- Admin and agent role separation
- Client management
- Policy management
- Auto-generated renewal reminders
- Follow-up tracking
- Offline-first local persistence
- Manual sync to Firestore
- Last synced timestamp tracking
- Crashlytics logging for sync failures

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
- On success, local records are marked `synced`
- On failure, retries and error messages are stored locally and sync failures are logged to Crashlytics

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
5. For release signing, keep the real `android/key.properties` out of git.

## Android Release Signing

This project is safe when `android/key.properties` is missing:

- release builds fall back to debug signing locally
- actual Play Store release signing requires your own keystore

Create these locally:

- `android/key.properties`
- keystore file referenced by `storeFile`

You can start from [android/key.properties.example](android/key.properties.example).

Example `android/key.properties`:

```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=upload
storeFile=../keystore/upload-keystore.jks
```

## Build Commands

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
```

## Recommended Release Validation

Run this exact sequence before Android release:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

If release build fails only because `key.properties` is missing, add the local keystore setup above and retry.
