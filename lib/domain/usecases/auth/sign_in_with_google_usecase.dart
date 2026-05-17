import 'package:ninaivu/domain/repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  SignInWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signInWithGoogle();
}
