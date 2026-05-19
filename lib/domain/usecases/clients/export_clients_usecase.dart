import 'package:intl/intl.dart';
import 'package:ninaivu/core/models/export_format.dart';
import 'package:ninaivu/core/services/export_service.dart';
import 'package:ninaivu/domain/repositories/client_repository.dart';

class ExportClientsUseCase {
  ExportClientsUseCase(this._repository, this._exportService);

  final ClientRepository _repository;
  final ExportService _exportService;

  Future<void> call({required ExportFormat format}) async {
    final clients = await _repository.getClients(limit: 5000);
    await _exportService.exportAndShare(
      baseFileName: 'ninaivu_clients_${DateTime.now().millisecondsSinceEpoch}',
      format: format,
      headers: const [
        'Name',
        'Mobile',
        'Alternate Mobile',
        'Email',
        'Area/City',
        'Address',
        'Notes',
        'Created At',
      ],
      rows: clients
          .map(
            (client) => [
              client.name,
              client.mobile,
              client.alternateMobile ?? '',
              client.email ?? '',
              client.areaCity ?? '',
              client.address ?? '',
              client.notes ?? '',
              DateFormat('dd MMM yyyy, hh:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(client.createdAt),
              ),
            ],
          )
          .toList(),
    );
  }
}
