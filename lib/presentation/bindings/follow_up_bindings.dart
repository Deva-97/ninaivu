import 'package:get/get.dart';
import 'package:ninaivu/core/services/communication_service.dart';
import 'package:ninaivu/data/repositories/client_repository_impl.dart';
import 'package:ninaivu/data/repositories/follow_up_repository_impl.dart';
import 'package:ninaivu/data/repositories/policy_repository_impl.dart';
import 'package:ninaivu/domain/usecases/follow_ups/add_follow_up_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/get_client_details_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/search_clients_usecase.dart';
import 'package:ninaivu/domain/usecases/follow_ups/delete_follow_up_usecase.dart';
import 'package:ninaivu/domain/usecases/follow_ups/get_follow_up_by_id_usecase.dart';
import 'package:ninaivu/domain/usecases/follow_ups/get_follow_ups_usecase.dart';
import 'package:ninaivu/domain/usecases/follow_ups/mark_follow_up_completed_usecase.dart';
import 'package:ninaivu/domain/usecases/follow_ups/reschedule_follow_up_usecase.dart';
import 'package:ninaivu/domain/usecases/follow_ups/update_follow_up_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/get_policies_by_client_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/get_policy_by_id_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/search_policies_usecase.dart';
import 'package:ninaivu/presentation/controllers/follow_up_detail_controller.dart';
import 'package:ninaivu/presentation/controllers/follow_up_form_controller.dart';
import 'package:ninaivu/presentation/controllers/follow_up_list_controller.dart';

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
    final clientRepository = ClientRepositoryImpl();
    final policyRepository = PolicyRepositoryImpl();
    Get.lazyPut(
      () => FollowUpFormController(
        addFollowUpUseCase: AddFollowUpUseCase(repository),
        getClientDetailsUseCase: GetClientDetailsUseCase(clientRepository),
        getPoliciesByClientUseCase: GetPoliciesByClientUseCase(policyRepository),
        getPolicyByIdUseCase: GetPolicyByIdUseCase(policyRepository),
        searchClientsUseCase: SearchClientsUseCase(clientRepository),
        searchPoliciesUseCase: SearchPoliciesUseCase(policyRepository),
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
        rescheduleFollowUpUseCase: RescheduleFollowUpUseCase(repository),
        communicationService: CommunicationService(),
      ),
    );
  }
}
