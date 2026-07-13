import 'package:ninaivu/domain/repositories/reminder_repository.dart';

class MarkReminderRenewedUseCase {
  MarkReminderRenewedUseCase(this._repository);

  final ReminderRepository _repository;

  Future<void> call(String reminderId) =>
      _repository.markReminderRenewed(reminderId);
}
