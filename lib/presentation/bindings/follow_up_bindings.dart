import 'package:get/get.dart';
import 'package:insurance_reminders/data/repositories/follow_up_repository_impl.dart';
import 'package:insurance_reminders/domain/usecases/follow_ups/add_follow_up_usecase.dart';
import 'package:insurance_reminders/domain/usecases/follow_ups/delete_follow_up_usecase.dart';
import 'package:insurance_reminders/domain/usecases/follow_ups/get_follow_up_by_id_usecase.dart';
import 'package:insurance_reminders/domain/usecases/follow_ups/get_follow_ups_usecase.dart';
import 'package:insurance_reminders/domain/usecases/follow_ups/mark_follow_up_completed_usecase.dart';
import 'package:insurance_reminders/domain/usecases/follow_ups/update_follow_up_usecase.dart';
import 'package:insurance_reminders/presentation/controllers/follow_up_detail_controller.dart';
import 'package:insurance_reminders/presentation/controllers/follow_up_form_controller.dart';
import 'package:insurance_reminders/presentation/controllers/follow_up_list_controller.dart';

class FollowUpListBinding extends Bindings {
  @override
  void dependencies() {
    final repository = FollowUpRepositoryImpl();
    Get.lazyPut(
      () => FollowUpListController(
        getFollowUpsUseCase: GetFollowUpsUseCase(repository),
        deleteFollowUpUseCase: DeleteFollowUpUseCase(repository),
      ),
    );
  }
}

class FollowUpFormBinding extends Bindings {
  @override
  void dependencies() {
    final repository = FollowUpRepositoryImpl();
    Get.lazyPut(
      () => FollowUpFormController(
        addFollowUpUseCase: AddFollowUpUseCase(repository),
        updateFollowUpUseCase: UpdateFollowUpUseCase(repository),
      ),
    );
  }
}

class FollowUpDetailBinding extends Bindings {
  @override
  void dependencies() {
    final repository = FollowUpRepositoryImpl();
    Get.lazyPut(
      () => FollowUpDetailController(
        getFollowUpByIdUseCase: GetFollowUpByIdUseCase(repository),
        deleteFollowUpUseCase: DeleteFollowUpUseCase(repository),
        markFollowUpCompletedUseCase: MarkFollowUpCompletedUseCase(repository),
      ),
    );
  }
}
