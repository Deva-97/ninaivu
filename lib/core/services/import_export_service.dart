import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:ninaivu/core/models/export_format.dart';
import 'package:ninaivu/core/permissions/permission_helper.dart';
import 'package:ninaivu/core/permissions/user_role.dart';
import 'package:ninaivu/core/services/export_service.dart';
import 'package:ninaivu/data/datasources/local/follow_up_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/policy_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/reminder_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/user_local_data_source.dart';
import 'package:ninaivu/data/models/app_user_model.dart';
import 'package:ninaivu/data/repositories/client_repository_impl.dart';
import 'package:ninaivu/data/repositories/policy_repository_impl.dart';
import 'package:ninaivu/domain/entities/policy.dart';
import 'package:uuid/uuid.dart';

/// Aggregated result returned after CSV imports so the UI can show a compact summary.
class ImportSummary {
  const ImportSummary({
    required this.addedCount,
    required this.skippedCount,
    required this.duplicateCount,
    required this.failedCount,
  });

  final int addedCount;
  final int skippedCount;
  final int duplicateCount;
  final int failedCount;
}

/// Handles bulk CSV import/export workflows for settings and admin utilities.
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
    PolicyLocalDataSource? policyLocalDataSource,
    UserLocalDataSource? userLocalDataSource,
    Uuid? uuid,
  }) : _exportService = exportService ?? ExportService(),
       _clientRepository = clientRepository ?? ClientRepositoryImpl(),
       _policyRepository = policyRepository ?? PolicyRepositoryImpl(),
       _reminderLocalDataSource =
           reminderLocalDataSource ?? ReminderLocalDataSource(),
       _followUpLocalDataSource =
           followUpLocalDataSource ?? FollowUpLocalDataSource(),
       _policyLocalDataSource = policyLocalDataSource ?? PolicyLocalDataSource(),
       _userLocalDataSource = userLocalDataSource ?? UserLocalDataSource(),
       _uuid = uuid ?? const Uuid();

  final ExportService _exportService;
  final ClientRepositoryImpl _clientRepository;
  final PolicyRepositoryImpl _policyRepository;
  final ReminderLocalDataSource _reminderLocalDataSource;
  final FollowUpLocalDataSource _followUpLocalDataSource;
  final PolicyLocalDataSource _policyLocalDataSource;
  final UserLocalDataSource _userLocalDataSource;
  final Uuid _uuid;

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
    final policies = await _policyRepository.getPolicies(limit: 1000, offset: 0);
    await _exportService.exportAndShare(
      baseFileName: 'policies_export',
      format: ExportFormat.csv,
      headers: const [
        'Policy Number',
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

  Future<ImportSummary?> importClientsCsv() async {
    final file = await _pickCsvFile();
    if (file == null) {
      return null;
    }
    final rows = await _readCsvRows(file);
    if (rows.length <= 1) {
      return const ImportSummary(
        addedCount: 0,
        skippedCount: 0,
        duplicateCount: 0,
        failedCount: 0,
      );
    }

    var added = 0;
    var skipped = 0;
    var duplicate = 0;
    var failed = 0;
    for (final row in rows.skip(1)) {
      try {
        // Imports intentionally skip partial rows instead of failing the whole
        // file, which makes spreadsheet cleanup less brittle for users.
        final name = _readColumn(row, 0);
        final mobile = _readColumn(row, 1);
        if (name.isEmpty || mobile.isEmpty) {
          skipped++;
          continue;
        }
        final existing = await _clientRepository.findClientByMobile(mobile: mobile);
        if (existing != null) {
          duplicate++;
          continue;
        }
        await _clientRepository.addClient(
          name: name,
          mobile: mobile,
          email: _nullable(_readColumn(row, 2)),
          areaCity: _nullable(_readColumn(row, 3)),
          address: _nullable(_readColumn(row, 4)),
          dateOfBirthMs: int.tryParse(_readColumn(row, 5)),
          specialDateMs: int.tryParse(_readColumn(row, 6)),
          specialDateLabel: _nullable(_readColumn(row, 7)),
        );
        added++;
      } catch (_) {
        failed++;
      }
    }
    return ImportSummary(
      addedCount: added,
      skippedCount: skipped,
      duplicateCount: duplicate,
      failedCount: failed,
    );
  }

  Future<ImportSummary?> importPoliciesCsv() async {
    final file = await _pickCsvFile();
    if (file == null) {
      return null;
    }
    final rows = await _readCsvRows(file);
    if (rows.length <= 1) {
      return const ImportSummary(
        addedCount: 0,
        skippedCount: 0,
        duplicateCount: 0,
        failedCount: 0,
      );
    }

    final currentUser = await _requireCurrentUser();
    final isAdmin = PermissionHelper.canManageAllClients(
      currentUser.role.toAppRole(),
    );
    var added = 0;
    var skipped = 0;
    var duplicate = 0;
    var failed = 0;
    for (final row in rows.skip(1)) {
      try {
        // Duplicate detection stays local-first for speed and to match the same
        // visibility rules the rest of the app applies for admins vs agents.
        final policyNumber = _readColumn(row, 0);
        final insuranceType = _readColumn(row, 1);
        final companyName = _readColumn(row, 2);
        final clientId = _readColumn(row, 3);
        if (policyNumber.isEmpty ||
            insuranceType.isEmpty ||
            companyName.isEmpty ||
            clientId.isEmpty) {
          skipped++;
          continue;
        }
        final existing = await _policyLocalDataSource.findPolicyByNumber(
          businessId: currentUser.businessId,
          policyNumber: policyNumber,
          isAdmin: isAdmin,
          userId: currentUser.id,
        );
        if (existing != null) {
          duplicate++;
          continue;
        }
        await _policyRepository.addPolicy(
          Policy(
            id: _uuid.v4(),
            businessId: currentUser.businessId,
            clientId: clientId,
            insuranceType: insuranceType,
            policyNumber: policyNumber,
            companyName: companyName,
            startDate: int.tryParse(_readColumn(row, 6)) ??
                DateTime.now().millisecondsSinceEpoch,
            endDate: int.tryParse(_readColumn(row, 7)) ??
                DateTime.now()
                    .add(const Duration(days: 365))
                    .millisecondsSinceEpoch,
            premiumAmount: double.tryParse(_readColumn(row, 5)) ?? 0,
            vehicleNumber: _nullable(_readColumn(row, 4)),
            status: _readColumn(row, 8).isEmpty ? 'Active' : _readColumn(row, 8),
            renewalStatus: 'Not Contacted',
            paymentFrequency: null,
            vehicleModel: null,
            notes: null,
            createdBy: currentUser.id,
            agentId: currentUser.role == 'agent' ? currentUser.id : null,
            subAgentId: null,
            customerUserId: null,
            assignedTo: currentUser.id,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
            isDeleted: false,
            syncStatus: 'pending_create',
          ),
        );
        added++;
      } catch (error) {
        debugPrint('Policy import row failed: $error');
        failed++;
      }
    }
    return ImportSummary(
      addedCount: added,
      skippedCount: skipped,
      duplicateCount: duplicate,
      failedCount: failed,
    );
  }

  Future<File?> _pickCsvFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
    );
    final path = result?.files.single.path;
    if (path == null || path.isEmpty) {
      return null;
    }
    return File(path);
  }

  Future<List<List<String>>> _readCsvRows(File file) async {
    final content = utf8.decode(await file.readAsBytes());
    return content
        .split(RegExp(r'\r?\n'))
        .where((line) => line.trim().isNotEmpty)
        .map(_parseCsvLine)
        .toList();
  }

  List<String> _parseCsvLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;
    // This small parser supports quoted commas well enough for the template
    // files used in the app without pulling in a larger CSV dependency.
    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        values.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    values.add(buffer.toString().trim());
    return values;
  }

  String _readColumn(List<String> row, int index) {
    if (index >= row.length) {
      return '';
    }
    return row[index].replaceAll('"', '').trim();
  }

  String? _nullable(String value) => value.isEmpty ? null : value;

  Future<AppUserModel> _requireCurrentUser() async {
    final currentUser = await _userLocalDataSource.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Please sign in again to continue.');
    }
    return currentUser;
  }
}
