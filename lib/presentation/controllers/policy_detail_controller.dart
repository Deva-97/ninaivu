import 'package:get/get.dart';
import 'package:ninaivu/core/services/communication_service.dart';
import 'package:ninaivu/domain/entities/client.dart';
import 'package:ninaivu/domain/entities/policy.dart';
import 'package:ninaivu/domain/usecases/clients/get_client_details_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/delete_policy_usecase.dart';
import 'package:ninaivu/domain/repositories/policy_repository.dart';

class PolicyDetailController extends GetxController {
  PolicyDetailController({
    required GetClientDetailsUseCase getClientDetailsUseCase,
    required PolicyRepository policyRepository,
    required DeletePolicyUseCase deletePolicyUseCase,
    required CommunicationService communicationService,
  }) : _getClientDetailsUseCase = getClientDetailsUseCase,
       _policyRepository = policyRepository,
       _deletePolicyUseCase = deletePolicyUseCase,
       _communicationService = communicationService;

  final GetClientDetailsUseCase _getClientDetailsUseCase;
  final PolicyRepository _policyRepository;
  final DeletePolicyUseCase _deletePolicyUseCase;
  final CommunicationService _communicationService;

  final client = Rxn<Client>();
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
      } else {
        client.value = await _getClientDetailsUseCase(policy.value!.clientId);
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

  Future<void> callClient() async {
    await _communicationService.openDialer(client.value?.mobile);
  }

  Future<void> whatsappClient() async {
    await _communicationService.openWhatsAppChat(client.value?.mobile);
  }
}
