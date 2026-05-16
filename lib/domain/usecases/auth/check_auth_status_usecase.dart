import 'package:insurance_reminders/domain/repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  CheckAuthStatusUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.checkAuthFromSplash();
}
