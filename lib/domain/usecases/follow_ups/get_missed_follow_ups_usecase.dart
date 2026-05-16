import 'package:insurance_reminders/domain/entities/follow_up.dart';
import 'package:insurance_reminders/domain/repositories/follow_up_repository.dart';

class GetMissedFollowUpsUseCase {
  GetMissedFollowUpsUseCase(this._repository);

  final FollowUpRepository _repository;

  Future<List<FollowUp>> call() => _repository.getMissedFollowUps();
}
