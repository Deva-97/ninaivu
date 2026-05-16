import 'package:insurance_reminders/domain/repositories/user_repository.dart';

class DeleteUserUseCase {
  DeleteUserUseCase(this._repository);

  final UserRepository _repository;

  Future<void> call(String userId) => _repository.softDeleteUser(userId);
}
