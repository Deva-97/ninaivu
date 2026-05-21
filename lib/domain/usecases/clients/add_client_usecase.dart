import 'package:ninaivu/domain/entities/client.dart';
import 'package:ninaivu/domain/repositories/client_repository.dart';

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
    String? profileImagePath,
    int? dateOfBirthMs,
    int? specialDateMs,
    String? specialDateLabel,
  }) => _repository.addClient(
    name: name,
    mobile: mobile,
    alternateMobile: alternateMobile,
    email: email,
    address: address,
    areaCity: areaCity,
    notes: notes,
    profileImagePath: profileImagePath,
    dateOfBirthMs: dateOfBirthMs,
    specialDateMs: specialDateMs,
    specialDateLabel: specialDateLabel,
  );
}
