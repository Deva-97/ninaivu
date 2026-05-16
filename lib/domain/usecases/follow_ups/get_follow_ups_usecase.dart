import 'package:insurance_reminders/domain/entities/follow_up.dart';
import 'package:insurance_reminders/domain/repositories/follow_up_repository.dart';

class GetFollowUpsUseCase {
  GetFollowUpsUseCase(this._repository);

  final FollowUpRepository _repository;

  Future<List<FollowUp>> call({String filter = 'today'}) =>
      _repository.getFollowUps(filter: filter);
}
