import 'package:insurance_reminders/domain/entities/app_user.dart';
import 'package:insurance_reminders/domain/repositories/user_repository.dart';

class GetAgentsUseCase {
  GetAgentsUseCase(this._repository);

  final UserRepository _repository;

  Future<List<AppUser>> call({String? query}) => _repository.getAgents(query: query);
}
