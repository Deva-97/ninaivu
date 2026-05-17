import 'package:ninaivu/domain/entities/follow_up.dart';
import 'package:ninaivu/domain/repositories/follow_up_repository.dart';

class UpdateFollowUpUseCase {
  UpdateFollowUpUseCase(this._repository);

  final FollowUpRepository _repository;

  Future<FollowUp> call(FollowUp followUp) =>
      _repository.updateFollowUp(followUp);
}
