import 'package:ninaivu/core/models/export_format.dart';
import 'package:ninaivu/core/permissions/permission_helper.dart';
import 'package:ninaivu/core/permissions/user_role.dart';
import 'package:ninaivu/core/services/export_service.dart';
import 'package:ninaivu/data/datasources/local/follow_up_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/reminder_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/user_local_data_source.dart';
import 'package:ninaivu/data/models/app_user_model.dart';
import 'package:ninaivu/data/repositories/client_repository_impl.dart';
import 'package:ninaivu/data/repositories/policy_repository_impl.dart';

/// Handles bulk export workflows for settings and admin utilities.
///
/// This service keeps file parsing and export orchestration out of controllers,
/// while still delegating actual record creation to repositories for validation,
/// permissions, reminder generation, and sync queue side effects.
class ImportExportService {
  ImportExportService({
    ExportService? exportService,
    ClientRepositoryImpl? clientRepository,
    PolicyRepositoryImpl? policyRepository,
    ReminderLocalDataSource? reminderLocalDataSource,
    FollowUpLocalDataSource? followUpLocalDataSource,
    UserLocalDataSource? userLocalDataSource,
  }) : _exportService = exportService ?? ExportService(),
       _clientRepository = clientRepository ?? ClientRepositoryImpl(),
       _policyRepository = policyRepository ?? PolicyRepositoryImpl(),
       _reminderLocalDataSource =
           reminderLocalDataSource ?? ReminderLocalDataSource(),
       _followUpLocalDataSource =
           followUpLocalDataSource ?? FollowUpLocalDataSource(),
       _userLocalDataSource = userLocalDataSource ?? UserLocalDataSource();

  final ExportService _exportService;
  final ClientRepositoryImpl _clientRepository;
  final PolicyRepositoryImpl _policyRepository;
  final ReminderLocalDataSource _reminderLocalDataSource;
  final FollowUpLocalDataSource _followUpLocalDataSource;
  final UserLocalDataSource _userLocalDataSource;

  Future<void> exportClientsCsv() async {
    final clients = await _clientRepository.getClients(limit: 1000, offset: 0);
    await _exportService.exportAndShare(
      baseFileName: 'clients_export',
      format: ExportFormat.csv,
      headers: const [
        'Name',
        'Mobile',
        'Email',
        'Area/City',
        'Address',
        'DOB',
        'Special Date',
        'Special Date Label',
      ],
      rows: clients
          .map(
            (client) => [
              client.name,
              client.mobile,
              client.email ?? '',
              client.areaCity ?? '',
              client.address ?? '',
              '${client.dateOfBirthMs ?? ''}',
              '${client.specialDateMs ?? ''}',
              client.specialDateLabel ?? '',
            ],
          )
          .toList(),
    );
  }

  Future<void> exportPoliciesCsv() async {
    final policies = await _policyRepository.getPolicies(
      limit: 1000,
      offset: 0,
    );
    await _exportService.exportAndShare(
      baseFileName: 'policies_export',
      format: ExportFormat.csv,
      headers: const [
        'Policy Number',
        'Policy Holder Name',
        'Insurance Type',
        'Company',
        'Client ID',
        'Vehicle Number',
        'Premium Amount',
        'Start Date',
        'End Date',
        'Status',
      ],
      rows: policies
          .map(
            (policy) => [
              policy.policyNumber,
              policy.policyHolderName ?? '',
              policy.insuranceType,
              policy.companyName,
              policy.clientId,
              policy.vehicleNumber ?? '',
              '${policy.premiumAmount}',
              '${policy.startDate}',
              '${policy.endDate}',
              policy.status,
            ],
          )
          .toList(),
    );
  }

  Future<void> exportFollowUpsCsv() async {
    final currentUser = await _requireCurrentUser();
    final isAdmin = PermissionHelper.canManageAllClients(
      currentUser.role.toAppRole(),
    );
    final rows = await _followUpLocalDataSource.getFollowUps(
      businessId: currentUser.businessId,
      isAdmin: isAdmin,
      userId: currentUser.id,
      filter: 'all',
    );
    await _exportService.exportAndShare(
      baseFileName: 'follow_ups_export',
      format: ExportFormat.csv,
      headers: const ['Client', 'Policy', 'Type', 'Date', 'Status', 'Remarks'],
      rows: rows
          .map(
            (item) => [
              item.clientName ?? '',
              item.policyNumber ?? '',
              item.type,
              '${item.followUpDateTime}',
              item.status,
              item.remarks ?? '',
            ],
          )
          .toList(),
    );
  }

  Future<void> exportRemindersCsv() async {
    final currentUser = await _requireCurrentUser();
    final isAdmin = PermissionHelper.canManageAllClients(
      currentUser.role.toAppRole(),
    );
    final rows = await _reminderLocalDataSource.getReminders(
      businessId: currentUser.businessId,
      isAdmin: isAdmin,
      userId: currentUser.id,
      filter: 'all',
    );
    await _exportService.exportAndShare(
      baseFileName: 'reminders_export',
      format: ExportFormat.csv,
      headers: const ['Client', 'Policy', 'Type', 'Date', 'Status', 'Company'],
      rows: rows
          .map(
            (item) => [
              item.clientName ?? '',
              item.policyNumber ?? '',
              item.reminderType,
              '${item.reminderDateTime}',
              item.status,
              item.companyName ?? '',
            ],
          )
          .toList(),
    );
  }

  Future<AppUserModel> _requireCurrentUser() async {
    final currentUser = await _userLocalDataSource.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Please sign in again to continue.');
    }
    return currentUser;
  }
}
