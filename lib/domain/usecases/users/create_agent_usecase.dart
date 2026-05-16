import 'package:insurance_reminders/domain/entities/app_user.dart';
import 'package:insurance_reminders/domain/repositories/user_repository.dart';

class CreateAgentUseCase {
  CreateAgentUseCase(this._repository);

  final UserRepository _repository;

  Future<AppUser> call({
    required String name,
    required String mobile,
    String? email,
  }) => _repository.createAgent(name: name, mobile: mobile, email: email);
}
