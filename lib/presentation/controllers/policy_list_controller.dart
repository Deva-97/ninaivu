import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/domain/entities/policy.dart';
import 'package:ninaivu/domain/usecases/policies/delete_policy_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/get_policies_by_client_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/get_policies_usecase.dart';

class PolicyListController extends GetxController {
  PolicyListController({
    required GetPoliciesUseCase getPoliciesUseCase,
    required GetPoliciesByClientUseCase getPoliciesByClientUseCase,
    required DeletePolicyUseCase deletePolicyUseCase,
  }) : _getPoliciesUseCase = getPoliciesUseCase,
       _getPoliciesByClientUseCase = getPoliciesByClientUseCase,
       _deletePolicyUseCase = deletePolicyUseCase;

  final GetPoliciesUseCase _getPoliciesUseCase;
  final GetPoliciesByClientUseCase _getPoliciesByClientUseCase;
  final DeletePolicyUseCase _deletePolicyUseCase;

  final searchController = TextEditingController();
  final policies = <Policy>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  String? clientId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      clientId = args['clientId'] as String?;
    }
    loadPolicies();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadPolicies() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      if (clientId != null && clientId!.isNotEmpty) {
        policies.assignAll(await _getPoliciesByClientUseCase(clientId!));
      } else {
        policies.assignAll(await _getPoliciesUseCase(query: searchController.text.trim()));
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePolicy(String policyId) async {
    await _deletePolicyUseCase(policyId);
    await loadPolicies();
  }
}
