import 'package:ninaivu/domain/entities/app_user.dart';
import 'package:ninaivu/domain/repositories/user_repository.dart';

class UpdateCurrentUserProfileImageUseCase {
  UpdateCurrentUserProfileImageUseCase(this._repository);

  final UserRepository _repository;

  Future<AppUser> call({
    String? profileImageData,
    bool removeImage = false,
  }) {
    return _repository.updateCurrentUserProfileImage(
      profileImageData: profileImageData,
      removeImage: removeImage,
    );
  }
}
