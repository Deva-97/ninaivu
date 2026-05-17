You are working on my Flutter app repository:

Repo: Deva-97/ninaivu
Branch: master
App name: Ninaivu
Target: Complete Version 1 MVP for Android release, keeping iOS-ready code where possible.

Important current repo state:
- Flutter app already exists.
- Dependencies already include Firebase Auth, Firebase Core, Cloud Firestore, Crashlytics, Analytics, Google Sign-In, sqflite, path, path_provider, SharedPreferences, flutter_local_notifications, timezone, connectivity_plus, intl, uuid, url_launcher, and GetX.
- main.dart already initializes Firebase, Crashlytics, NotificationService, GoogleSignIn, ThemeController, and runs InsuranceRemindersApp.
- Auth screens exist: Login, OTP Verification, Profile Setup.
- Auth flow exists with Google Sign-In and mobile OTP.
- There is NO separate signup screen. Keep only Login -> Google/Mobile -> Profile Setup/Role Check.
- SQLite database already has schema for users, clients, policies, reminders, follow_ups, and sync_queue.
- AdminDashboardScreen and AgentDashboardScreen are currently placeholder screens with static zero values.
- app_routes.dart already has route constants for clients, policies, reminders, and follow-ups, but app_pages.dart does not yet register those feature pages.
- Current AuthService directly handles auth orchestration and has a TODO to move logic behind repository/usecase layers.

Main objective:
Complete Ninaivu Version 1 as an offline-first insurance reminder and policy management app for Android release.

Tech stack rules:
- Flutter + Dart.
- GetX for routing/controller state.
- Clean Architecture.
- SQLite/sqflite is the primary local source of truth.
- Firebase Auth for login.
- Firestore for cloud backup/sync.
- Firebase Crashlytics and Analytics for release monitoring.
- flutter_local_notifications for renewal reminders.
- SharedPreferences only for small settings: userId, role, businessId, theme, lastSyncTime.
- Do not add Hive.
- Do not add heavy animation/image packages.
- Do not call Firebase directly from UI.
- Do not compare dates as strings.
- Store dates as integer milliseconds in SQLite.
- Use DateTime in Dart and formatted dates only in UI.
- Use soft delete, not hard delete.
- Use pagination and SQLite indexes.
- Use search debounce.
- Permission checks must happen at UI, usecase/repository, and Firestore rules level.

Version 1 roles:
1. Admin
- Full access.
- Can create/manage agents.
- Can create/manage clients/customers.
- Can create/view/edit/delete policies.
- Can view all reminders and follow-ups.
- Can view reports/dashboard.
- Can activate/deactivate users.
- Can assign work later if time permits.

2. Agent
- Can manage own clients only.
- Can manage own policies only.
- Can create reminders and follow-ups.
- Can call/WhatsApp customers.
- Can view own dashboard and reports.
- Cannot view other agents’ data.
- Cannot create admin.
- Cannot access global settings.

Keep fields ready for future roles:
- sub_agent_id
- customer_user_id
- assigned_to

Firestore structure:
businesses/{businessId}/users/{userId}
businesses/{businessId}/clients/{clientId}
businesses/{businessId}/policies/{policyId}
businesses/{businessId}/reminders/{reminderId}
businesses/{businessId}/follow_ups/{followUpId}

Required folder structure:
lib/
  main.dart
  app.dart
  firebase_options.dart

  core/
    constants/
    database/
    errors/
    permissions/
    services/
    theme/
    utils/
    widgets/

  data/
    models/
    datasources/local/
    datasources/remote/
    repositories/

  domain/
    entities/
    repositories/
    usecases/

  presentation/
    routes/
    bindings/
    modules/common/
    modules/admin/
    modules/agent/
    modules/sub_agent/
    modules/customer/

Implementation work:
Complete all incomplete weeks from the roadmap.

==================================================
WEEK 1 COMPLETION: FOUNDATION CLEANUP
==================================================

1. Clean Architecture cleanup
- Move auth business logic away from UI where possible.
- Add AuthRepository abstraction in domain/repositories.
- Add AuthRepositoryImpl in data/repositories.
- Add usecases:
  - CheckAuthStatusUseCase
  - SignInWithGoogleUseCase
  - SendOtpUseCase
  - VerifyOtpUseCase
  - CompleteProfileUseCase
  - LogoutUseCase
- Keep existing UI working.
- Use GetX bindings/controllers instead of directly creating service classes inside screens where possible.

2. SharedPreferences helper
Create AppPreferences service for:
- userId
- role
- businessId
- themeMode
- lastSyncTime
- clearSession()

3. Permission helper
Create role permission system:
- AppRole enum: admin, agent, subAgent, customer
- Permission helper methods:
  - canManageUsers
  - canManageAllClients
  - canManageOwnClients
  - canManagePolicies
  - canDeletePolicy
  - canViewGlobalDashboard
  - canAccessSettings
- Use this in UI and repositories.

4. Android release safety
Fix android/app/build.gradle.kts:
- Do not crash when key.properties is missing.
- Use debug signing only for debug.
- Use release signing only when key.properties exists.
- Add clear TODO comments for generating release keystore.
- Ensure flutter build apk --release and flutter build appbundle --release can run after key.properties is added.
- Keep app label as Ninaivu.

5. Android notification release setup
- Ensure POST_NOTIFICATIONS permission flow works for Android 13+.
- Ensure local notification channel is created.
- Add exact alarm handling only if needed; avoid requesting unnecessary sensitive permissions.
- Add safe error handling.

==================================================
WEEK 2: USER AND ROLE MANAGEMENT
==================================================

Build full user management for Admin.

Data:
- AppUserModel already exists; improve it if required.
- Add fields if missing:
  - id
  - businessId
  - name
  - mobile
  - email
  - role
  - status: active/inactive
  - profileCompleted
  - createdAt
  - updatedAt
  - isDeleted
  - syncStatus
  - createdBy
  - agentId optional

Local datasource:
- UserLocalDataSource:
  - getCurrentUser()
  - getUserById()
  - getUsersByRole()
  - getAgents()
  - getCustomers()
  - insertOrUpdateUser()
  - updateUserStatus()
  - softDeleteUser()
  - searchUsers()
  - countAgents()
  - countCustomers()

Remote datasource:
- UserRemoteDataSource:
  - getUserById()
  - upsertUser()
  - syncUser()
  - fetchUsersForBusiness()

Repository:
- UserRepository
- UserRepositoryImpl

Usecases:
- CreateAgentUseCase
- CreateCustomerUseCase
- GetAgentsUseCase
- GetCustomersUseCase
- UpdateUserStatusUseCase
- DeleteUserUseCase

UI:
Admin module:
- AgentListScreen
- AddEditAgentScreen
- CustomerListScreen
- AddEditCustomerScreen

Rules:
- Admin can create agents and customers.
- Agent cannot create users.
- Do not create separate signup screen.
- Invite code flow can remain for now but should be clean and testable.
- For first MVP, use simple invite code or admin-created account model, whichever fits existing code better.

==================================================
WEEK 3: CLIENT MODULE
==================================================

Build client module fully.

Fields:
- id
- business_id
- name
- mobile
- alternate_mobile
- email
- address
- area_city
- notes
- created_by
- agent_id
- sub_agent_id
- customer_user_id
- assigned_to
- created_at
- updated_at
- is_deleted
- sync_status

Data/model:
- ClientModel
- ClientEntity if following entity/model split.

Local datasource:
- insertClient
- updateClient
- softDeleteClient
- getClientById
- getClientsForAdmin
- getClientsForAgent
- searchClientsByNameOrMobile
- countClientsForAdmin
- countClientsForAgent
- getClientsPaginated

Repository/usecases:
- AddClientUseCase
- UpdateClientUseCase
- DeleteClientUseCase
- GetClientsUseCase
- SearchClientsUseCase
- GetClientDetailsUseCase

UI:
- ClientListScreen
- AddEditClientScreen
- ClientDetailScreen

UX:
- Search by name/mobile with debounce.
- Admin sees all clients.
- Agent sees only own clients where created_by or agent_id matches current user.
- Client card should show name, mobile, area/city, policy count if available.
- Actions:
  - call using url_launcher tel:
  - WhatsApp using url_launcher
  - view policies
  - view follow-ups
  - edit
  - delete with confirmation
- Empty states, loading states, and error states required.

==================================================
WEEK 4: POLICY MODULE
==================================================

Build policy module fully.

Fields:
- id
- business_id
- client_id
- insurance_type
- policy_number
- company_name
- start_date integer milliseconds
- end_date integer milliseconds
- premium_amount
- payment_frequency
- vehicle_number
- vehicle_model
- status
- notes
- created_by
- agent_id
- sub_agent_id
- customer_user_id
- assigned_to
- created_at
- updated_at
- is_deleted
- sync_status

Insurance types:
- Bike
- Car
- Health
- Term
- Life
- Commercial Vehicle
- Other

Policy status:
- Active
- Expired
- Renewed
- Cancelled
- Pending

Payment frequency:
- Monthly
- Quarterly
- Half-yearly
- Yearly
- Single
- Other

Data:
- PolicyModel
- PolicyLocalDataSource
- PolicyRemoteDataSource
- PolicyRepository
- PolicyRepositoryImpl

Usecases:
- AddPolicyUseCase
- UpdatePolicyUseCase
- DeletePolicyUseCase
- GetPoliciesUseCase
- GetPoliciesByClientUseCase
- GetExpiringPoliciesUseCase
- GetExpiredPoliciesUseCase

UI:
- PolicyListScreen
- AddEditPolicyScreen
- PolicyDetailScreen

Rules:
- Admin sees all policies.
- Agent sees own policies.
- On policy create:
  - save policy in SQLite first
  - add sync queue entry
  - generate reminders automatically
  - schedule local notifications
- On policy update:
  - update policy locally
  - cancel old reminders/notifications
  - regenerate reminders based on new expiry date
  - add sync queue entry
- On policy delete:
  - soft-delete policy
  - soft-delete related reminders
  - cancel notifications
  - add sync queue entry
- Do not compare date strings.
- Use date pickers and store milliseconds.

==================================================
WEEK 5: REMINDER MODULE
==================================================

Build reminder module fully.

Reminder generation:
When a policy is created or updated, generate reminders:
- 30 days before expiry
- 15 days before expiry
- 7 days before expiry
- 1 day before expiry
- On expiry date

Fields:
- id
- business_id
- client_id
- policy_id
- reminder_date_time
- reminder_type
- status
- notification_id
- created_by
- agent_id
- sub_agent_id
- customer_user_id
- assigned_to
- created_at
- updated_at
- is_deleted
- sync_status

Reminder status:
- pending
- notified
- completed
- missed
- cancelled

Reminder types:
- renewal_30_days
- renewal_15_days
- renewal_7_days
- renewal_1_day
- renewal_today

Implementation:
- ReminderModel
- ReminderLocalDataSource
- ReminderRepository
- ReminderGeneratorService
- ReminderSchedulerService using existing NotificationService
- Deterministic notificationId generation to avoid duplicates.
- Cancel notifications by notificationId.
- Skip scheduling reminders in the past.
- Keep reminders in SQLite even if notification scheduling fails; mark scheduling issue clearly if needed.
- Add sync_queue entries.

UI:
- ReminderListScreen
- ReminderDetailScreen
- Filters:
  - Today
  - Upcoming 7 days
  - Upcoming 30 days
  - Missed
  - Completed
- Mark reminder completed.
- Admin sees all.
- Agent sees own.

==================================================
WEEK 6: FOLLOW-UP MODULE
==================================================

Build follow-up module fully.

Fields:
- id
- business_id
- client_id
- policy_id optional
- follow_up_date_time
- type
- status
- remarks
- created_by
- agent_id
- sub_agent_id
- customer_user_id
- assigned_to
- created_at
- updated_at
- is_deleted
- sync_status

Types:
- Call
- WhatsApp
- Visit
- Payment Reminder
- Document Collection
- Renewal Discussion

Status:
- Pending
- Completed
- Missed
- Cancelled

Data:
- FollowUpModel
- FollowUpLocalDataSource
- FollowUpRepository
- FollowUpRepositoryImpl

Usecases:
- AddFollowUpUseCase
- UpdateFollowUpUseCase
- DeleteFollowUpUseCase
- MarkFollowUpCompletedUseCase
- GetTodayFollowUpsUseCase
- GetMissedFollowUpsUseCase
- GetUpcomingFollowUpsUseCase

UI:
- FollowUpListScreen
- AddEditFollowUpScreen
- FollowUpDetailScreen

UX:
- From client detail, allow adding follow-up.
- From policy detail, allow adding follow-up linked to policy.
- Follow-up card should show client name, date/time, type, status, remarks preview.
- Actions:
  - call customer
  - WhatsApp customer
  - mark completed
  - edit
  - cancel/delete
- Auto-detect missed follow-ups: pending follow-ups with follow_up_date_time < now.

==================================================
WEEK 7: ASSIGNMENT PREPARATION
==================================================

Prepare assignment system without overbuilding.

Rules:
- Keep assigned_to usable in clients, policies, reminders, follow-ups.
- Admin can assign client/follow-up to an agent if time permits.
- Agent should only see:
  - records created by them OR
  - records assigned to them OR
  - records with agent_id equal to them
- Keep sub-agent fields ready, but do not build full sub-agent UI.
- Keep customer_user_id ready, but do not build customer portal.

UI if practical:
- AssignAgentBottomSheet
- Used from client detail or follow-up detail.
- Admin-only.

==================================================
WEEK 8: DASHBOARDS
==================================================

Replace placeholder dashboard values with real SQLite counts.

Admin dashboard:
- Total Agents
- Total Customers
- Total Clients
- Total Policies
- Renewals Today
- Upcoming 7 Days
- Expired Policies
- Pending Follow-ups
- Missed Follow-ups

Agent dashboard:
- My Clients
- My Policies
- Renewals Today
- Upcoming 7 Days
- Upcoming 30 Days
- Follow-ups Today
- Missed Follow-ups

Implementation:
- DashboardLocalDataSource
- DashboardRepository
- DashboardController
- AdminDashboardController
- AgentDashboardController

UI:
- Professional blue theme.
- Cards with icons.
- Clear status badges.
- Quick actions:
  - Add Client
  - Add Policy
  - Add Follow-up
  - View Renewals
- Pull to refresh.
- No static values.
- Counts must come from SQLite.
- Agent dashboard must filter by current user.

==================================================
WEEK 9: FIREBASE SYNC
==================================================

Build sync system.

sync_queue table:
- id
- business_id
- table_name
- record_id
- operation
- payload
- retry_count
- last_error
- created_at
- updated_at
- sync_status

Sync status:
- pending_create
- pending_update
- pending_delete
- synced
- failed

Implementation:
- SyncQueueModel
- SyncQueueLocalDataSource
- SyncService
- Firestore remote datasources for:
  - users
  - clients
  - policies
  - reminders
  - follow_ups

Flow:
- Every create/update/delete saves to SQLite first.
- Add sync_queue entry.
- When online, SyncService pushes pending queue items to Firestore.
- On success:
  - mark record sync_status as synced
  - mark queue item synced or remove it safely
- On failure:
  - increment retry_count
  - save last_error
  - mark failed after sensible retry threshold
- Add manual Sync Now button in settings/dashboard.
- Store lastSyncTime in SharedPreferences.
- Use connectivity_plus for online detection.
- Do not block core app usage when offline.
- Firestore writes must use:
  businesses/{businessId}/{collection}/{docId}

Firestore field format:
Use camelCase in Firestore, snake_case in SQLite. Provide mapper methods.

==================================================
WEEK 10: ROLE SECURITY AND FIRESTORE RULES
==================================================

Add role guards.

UI:
- Hide unauthorized actions.
- Admin-only:
  - user management
  - global dashboard
  - all clients/policies/followups/reminders
  - delete all data
- Agent:
  - own records only
  - no global settings
  - no admin creation

Route guards:
- Add GetMiddleware or equivalent route protection.
- Prevent direct route access to admin pages by agent.

Repository/usecase:
- Validate permissions again.
- Never rely only on UI hiding.

Firestore rules:
Create firestore.rules file or update existing rules:
- Users can read their own user doc.
- Admin can read/write business users.
- Admin can read/write all clients/policies/reminders/follow_ups in business.
- Agent can read/write only records where:
  - createdBy == request.auth.uid OR
  - agentId == request.auth.uid OR
  - assignedTo == request.auth.uid
- Block customer/sub-agent writes for MVP unless explicitly needed.
- Prevent deleted/inactive users from writing if possible.

==================================================
WEEK 11: TESTING AND RELIABILITY
==================================================

Add essential tests and reliability checks.

Tests:
- Unit tests for:
  - date calculations
  - reminder generation
  - role permission helper
  - policy status calculation
  - dashboard count queries if practical
- Widget tests for:
  - Login screen basic rendering
  - Client form validation
  - Policy form validation

Reliability:
- Crashlytics logs for:
  - login failures
  - sync failures
  - notification scheduling failures
- Validate app behavior:
  - offline add client
  - offline add policy
  - reminder generated locally
  - sync when online
  - role filtering
  - soft delete
  - Android notification permission
  - release build

==================================================
WEEK 12: POLISH AND ANDROID RELEASE
==================================================

Polish:
- Loading states.
- Empty states.
- Error states.
- Form validation.
- Search debounce.
- Confirmation dialogs.
- Professional UI.
- Light/dark theme support.
- Status colors:
  - green for completed/renewed/active
  - orange for upcoming/pending
  - red for expired/missed/cancelled
- App name should be Ninaivu.

Android release:
- Fix release signing config safely.
- Add release build checklist in README:
  - flutter clean
  - flutter pub get
  - flutter analyze
  - flutter test
  - flutter build apk --release
  - flutter build appbundle --release
- Ensure version in pubspec is correct.
- Ensure minSdk/targetSdk are compatible with Firebase and notifications.
- Do not commit key.properties.
- Add .gitignore entries if missing:
  - android/key.properties
  - *.jks
  - *.keystore

README:
Update README with:
- Project overview.
- Tech stack.
- Features.
- Role access.
- Offline-first architecture.
- SQLite tables.
- Firebase setup notes.
- Android release commands.

==================================================
CODING QUALITY RULES
==================================================

Before modifying:
- Inspect existing files and preserve working auth flow.
- Do not delete working Firebase/Google/mobile login code.
- Do not break current package name:
  com.devendiran.ninaivu
- Keep existing Firebase options intact unless correction is required.
- Keep app title Ninaivu.
- Keep code Android-first but iOS-ready.

Architecture:
- UI -> Controller -> UseCase -> Repository -> Local/Remote Datasource.
- SQLite is source of truth.
- Firestore is sync/backup.
- No Firebase calls directly from screens.
- Use repositories for data access.
- Use clear model mapping:
  - toMap/fromMap for SQLite
  - toFirestore/fromFirestore for Firestore

Date handling:
- Store all dates in SQLite as integer milliseconds.
- Use DateTime for logic.
- Use intl only for UI display.
- Never compare formatted date strings.

Database:
- Keep existing tables.
- Add safe migrations instead of destructive changes.
- Do not drop user data.
- Use indexes for filters and search.
- Use LIMIT/OFFSET pagination for large lists.

Notifications:
- Schedule only future reminders.
- Cancel old notifications during policy update/delete.
- Store notificationId in reminders table.
- Handle Android notification permission gracefully.

Sync:
- Never require internet to create client/policy/follow-up.
- Always write to SQLite first.
- Queue Firestore sync separately.
- On sync failure, app must still work.

UI:
- Minimal, professional insurance CRM style.
- Use cards, rounded corners, clear spacing.
- Use common reusable widgets where possible:
  - AppTextField
  - AppPrimaryButton
  - StatusBadge
  - EmptyStateWidget
  - LoadingWidget
  - ConfirmDialog
  - DashboardMetricCard

Validation:
- Mobile: 10 digits for Indian number.
- Email optional but validate format when entered.
- Policy endDate must be after startDate.
- Premium amount must be valid positive number.
- Required fields must show clear errors.

Deliverables:
1. Implement missing modules and screens.
2. Register all routes in app_pages.dart.
3. Add controllers/bindings where needed.
4. Add local/remote datasources, repositories, usecases, and models.
5. Replace static dashboard values with real SQLite values.
6. Implement sync_queue and SyncService.
7. Add Firestore security rules file.
8. Fix Android release signing safety.
9. Add tests where practical.
10. Update README with setup and Android release instructions.

After implementation:
Run:
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release

Fix all analyzer/build errors.
If release build cannot complete because key.properties is missing, make sure debug/profile still work and document release keystore steps clearly in README.
