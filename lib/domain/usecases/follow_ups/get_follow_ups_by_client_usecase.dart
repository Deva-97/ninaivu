import 'package:ninaivu/domain/entities/follow_up.dart';
import 'package:ninaivu/domain/repositories/follow_up_repository.dart';

class GetFollowUpsByClientUseCase {
  GetFollowUpsByClientUseCase(this._repository);

  final FollowUpRepository _repository;

  Future<List<FollowUp>> call(String clientId, {String? filter}) {
    return _repository.getFollowUpsByClient(clientId, filter: filter);
  }
}
