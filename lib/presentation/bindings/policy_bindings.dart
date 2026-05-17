import 'package:get/get.dart';
import 'package:ninaivu/data/repositories/policy_repository_impl.dart';
import 'package:ninaivu/domain/usecases/policies/add_policy_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/delete_policy_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/get_policies_by_client_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/get_policies_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/update_policy_usecase.dart';
import 'package:ninaivu/presentation/controllers/policy_detail_controller.dart';
import 'package:ninaivu/presentation/controllers/policy_form_controller.dart';
import 'package:ninaivu/presentation/controllers/policy_list_controller.dart';

class PolicyListBinding extends Bindings {
  @override
  void dependencies() {
    final repository = PolicyRepositoryImpl();
    Get.lazyPut(
      () => PolicyListController(
        getPoliciesUseCase: GetPoliciesUseCase(repository),
        getPoliciesByClientUseCase: GetPoliciesByClientUseCase(repository),
        deletePolicyUseCase: DeletePolicyUseCase(repository),
      ),
    );
  }
}

class PolicyFormBinding extends Bindings {
  @override
  void dependencies() {
    final repository = PolicyRepositoryImpl();
    Get.lazyPut(
      () => PolicyFormController(
        addPolicyUseCase: AddPolicyUseCase(repository),
        updatePolicyUseCase: UpdatePolicyUseCase(repository),
      ),
    );
  }
}

class PolicyDetailBinding extends Bindings {
  @override
  void dependencies() {
    final repository = PolicyRepositoryImpl();
    Get.lazyPut(
      () => PolicyDetailController(
        policyRepository: repository,
        deletePolicyUseCase: DeletePolicyUseCase(repository),
      ),
    );
  }
}
