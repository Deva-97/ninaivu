import 'package:ninaivu/domain/entities/app_user.dart';
import 'package:ninaivu/domain/repositories/user_repository.dart';

class CreateCustomerUseCase {
  CreateCustomerUseCase(this._repository);

  final UserRepository _repository;

  Future<AppUser> call({
    required String name,
    required String mobile,
    String? email,
    String? agentId,
  }) => _repository.createCustomer(
    name: name,
    mobile: mobile,
    email: email,
    agentId: agentId,
  );
}
