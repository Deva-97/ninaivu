import 'package:ninaivu/domain/repositories/follow_up_repository.dart';

class DeleteFollowUpUseCase {
  DeleteFollowUpUseCase(this._repository);

  final FollowUpRepository _repository;

  Future<void> call(String followUpId) => _repository.deleteFollowUp(followUpId);
}
