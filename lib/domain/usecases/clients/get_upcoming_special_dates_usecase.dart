import 'package:ninaivu/domain/entities/upcoming_client_event.dart';
import 'package:ninaivu/domain/repositories/client_repository.dart';

class GetUpcomingSpecialDatesUseCase {
  GetUpcomingSpecialDatesUseCase(this._repository);

  final ClientRepository _repository;

  Future<List<UpcomingClientEvent>> call({int withinDays = 30}) {
    return _repository.getUpcomingSpecialDates(withinDays: withinDays);
  }
}
