import 'package:get/get.dart';
import 'package:ninaivu/domain/entities/policy.dart';
import 'package:ninaivu/domain/usecases/policies/delete_policy_usecase.dart';
import 'package:ninaivu/domain/repositories/policy_repository.dart';

class PolicyDetailController extends GetxController {
  PolicyDetailController({
    required PolicyRepository policyRepository,
    required DeletePolicyUseCase deletePolicyUseCase,
  }) : _policyRepository = policyRepository,
       _deletePolicyUseCase = deletePolicyUseCase;

  final PolicyRepository _policyRepository;
  final DeletePolicyUseCase _deletePolicyUseCase;

  final policy = Rxn<Policy>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  late final String policyId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    policyId = args is Policy ? args.id : args as String;
    loadPolicy();
  }

  Future<void> loadPolicy() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      policy.value = await _policyRepository.getPolicyById(policyId);
      if (policy.value == null) {
        errorMessage.value = 'Policy not found';
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePolicy() async {
    await _deletePolicyUseCase(policyId);
    Get.back(result: true);
  }
}
