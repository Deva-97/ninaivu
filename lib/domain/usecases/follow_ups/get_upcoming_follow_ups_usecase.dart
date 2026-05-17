import 'package:ninaivu/domain/entities/follow_up.dart';
import 'package:ninaivu/domain/repositories/follow_up_repository.dart';

class GetUpcomingFollowUpsUseCase {
  GetUpcomingFollowUpsUseCase(this._repository);

  final FollowUpRepository _repository;

  Future<List<FollowUp>> call({int withinDays = 30}) =>
      _repository.getUpcomingFollowUps(withinDays: withinDays);
}
