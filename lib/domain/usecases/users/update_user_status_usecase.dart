import 'package:ninaivu/domain/entities/app_user.dart';
import 'package:ninaivu/domain/repositories/user_repository.dart';

class UpdateUserStatusUseCase {
  UpdateUserStatusUseCase(this._repository);

  final UserRepository _repository;

  Future<AppUser> call({
    required String userId,
    required String status,
  }) => _repository.updateUserStatus(userId: userId, status: status);
}
