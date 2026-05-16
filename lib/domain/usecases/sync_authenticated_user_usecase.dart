import 'package:insurance_reminders/domain/repositories/auth_repository.dart';

class SyncAuthenticatedUserUseCase {
  const SyncAuthenticatedUserUseCase(this.authRepository);

  final AuthRepository authRepository;

  // TODO(dev): Replace direct AuthService splash/login checks with this use case.
}
