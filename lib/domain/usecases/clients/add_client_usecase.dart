import 'package:insurance_reminders/domain/entities/client.dart';
import 'package:insurance_reminders/domain/repositories/client_repository.dart';

class AddClientUseCase {
  AddClientUseCase(this._repository);

  final ClientRepository _repository;

  Future<Client> call({
    required String name,
    required String mobile,
    String? alternateMobile,
    String? email,
    String? address,
    String? areaCity,
    String? notes,
  }) => _repository.addClient(
    name: name,
    mobile: mobile,
    alternateMobile: alternateMobile,
    email: email,
    address: address,
    areaCity: areaCity,
    notes: notes,
  );
}
