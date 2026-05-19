import 'package:intl/intl.dart';
import 'package:ninaivu/core/models/export_format.dart';
import 'package:ninaivu/core/services/export_service.dart';
import 'package:ninaivu/domain/repositories/client_repository.dart';
import 'package:ninaivu/domain/repositories/policy_repository.dart';

class ExportPoliciesUseCase {
  ExportPoliciesUseCase(
    this._policyRepository,
    this._clientRepository,
    this._exportService,
  );

  final PolicyRepository _policyRepository;
  final ClientRepository _clientRepository;
  final ExportService _exportService;

  Future<void> call({required ExportFormat format}) async {
    final policies = await _policyRepository.getPolicies(limit: 5000);
    final clients = await _clientRepository.getClients(limit: 5000);
    final clientMap = {for (final client in clients) client.id: client.name};
    await _exportService.exportAndShare(
      baseFileName: 'ninaivu_policies_${DateTime.now().millisecondsSinceEpoch}',
      format: format,
      headers: const [
        'Client Name',
        'Policy Number',
        'Insurance Type',
        'Company Name',
        'Start Date',
        'End Date',
        'Premium Amount',
        'Payment Frequency',
        'Vehicle Number',
        'Vehicle Model',
        'Status',
        'Notes',
      ],
      rows: policies
          .map(
            (policy) => [
              clientMap[policy.clientId] ?? '',
              policy.policyNumber,
              policy.insuranceType,
              policy.companyName,
              DateFormat('dd MMM yyyy').format(
                DateTime.fromMillisecondsSinceEpoch(policy.startDate),
              ),
              DateFormat('dd MMM yyyy').format(
                DateTime.fromMillisecondsSinceEpoch(policy.endDate),
              ),
              policy.premiumAmount.toStringAsFixed(0),
              policy.paymentFrequency ?? '',
              policy.vehicleNumber ?? '',
              policy.vehicleModel ?? '',
              policy.status,
              policy.notes ?? '',
            ],
          )
          .toList(),
    );
  }
}
