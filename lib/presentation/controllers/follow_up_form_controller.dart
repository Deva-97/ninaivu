import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/domain/entities/client.dart';
import 'package:ninaivu/domain/entities/policy.dart';
import 'package:ninaivu/data/models/follow_up_model.dart';
import 'package:ninaivu/domain/entities/follow_up.dart';
import 'package:ninaivu/domain/usecases/follow_ups/add_follow_up_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/get_client_details_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/search_clients_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/get_policies_by_client_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/get_policy_by_id_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/search_policies_usecase.dart';
import 'package:ninaivu/domain/usecases/follow_ups/update_follow_up_usecase.dart';
import 'package:uuid/uuid.dart';

class FollowUpFormController extends GetxController {
  FollowUpFormController({
    required AddFollowUpUseCase addFollowUpUseCase,
    required GetClientDetailsUseCase getClientDetailsUseCase,
    required GetPoliciesByClientUseCase getPoliciesByClientUseCase,
    required GetPolicyByIdUseCase getPolicyByIdUseCase,
    required SearchClientsUseCase searchClientsUseCase,
    required SearchPoliciesUseCase searchPoliciesUseCase,
    required UpdateFollowUpUseCase updateFollowUpUseCase,
    Uuid? uuid,
  }) : _addFollowUpUseCase = addFollowUpUseCase,
       _getClientDetailsUseCase = getClientDetailsUseCase,
       _getPoliciesByClientUseCase = getPoliciesByClientUseCase,
       _getPolicyByIdUseCase = getPolicyByIdUseCase,
       _searchClientsUseCase = searchClientsUseCase,
       _searchPoliciesUseCase = searchPoliciesUseCase,
       _updateFollowUpUseCase = updateFollowUpUseCase,
       _uuid = uuid ?? const Uuid();

  final AddFollowUpUseCase _addFollowUpUseCase;
  final GetClientDetailsUseCase _getClientDetailsUseCase;
  final GetPoliciesByClientUseCase _getPoliciesByClientUseCase;
  final GetPolicyByIdUseCase _getPolicyByIdUseCase;
  final SearchClientsUseCase _searchClientsUseCase;
  final SearchPoliciesUseCase _searchPoliciesUseCase;
  final UpdateFollowUpUseCase _updateFollowUpUseCase;
  final Uuid _uuid;

  final formKey = GlobalKey<FormState>();
  final remarksController = TextEditingController();
  final selectedType = 'Call'.obs;
  final selectedStatus = 'Pending'.obs;
  final selectedDate = Rx<DateTime>(DateTime.now());
  final selectedTime = Rx<TimeOfDay>(TimeOfDay.now());
  final isSaving = false.obs;
  final selectedClient = Rxn<Client>();
  final selectedPolicy = Rxn<Policy>();
  final clientValidationMessage = RxnString();

  FollowUp? editingFollowUp;

  static const followUpTypes = <String>[
    'Call',
    'WhatsApp',
    'Visit',
    'Payment Reminder',
    'Document Collection',
    'Renewal Discussion',
  ];

  static const followUpStatuses = <String>[
    'Pending',
    'Completed',
    'Missed',
    'Cancelled',
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is FollowUp) {
      editingFollowUp = args;
    } else if (args is Map<String, dynamic>) {
      editingFollowUp = args['followUp'] as FollowUp?;
      final initialClientId = args['clientId'] as String?;
      final initialPolicyId = args['policyId'] as String?;
      if (initialClientId != null && initialClientId.isNotEmpty) {
        _loadClient(initialClientId);
      }
      if (initialPolicyId != null && initialPolicyId.isNotEmpty) {
        _loadPolicy(initialPolicyId);
      }
    }

    if (editingFollowUp != null) {
      remarksController.text = editingFollowUp!.remarks ?? '';
      selectedType.value = editingFollowUp!.type;
      selectedStatus.value = editingFollowUp!.status;
      final dateTime = DateTime.fromMillisecondsSinceEpoch(
        editingFollowUp!.followUpDateTime,
      );
      selectedDate.value = dateTime;
      selectedTime.value = TimeOfDay.fromDateTime(dateTime);
      _loadClient(editingFollowUp!.clientId);
      if ((editingFollowUp!.policyId ?? '').isNotEmpty) {
        _loadPolicy(editingFollowUp!.policyId!);
      }
    }
  }

  @override
  void onClose() {
    remarksController.dispose();
    super.onClose();
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
    );
    if (picked != null) {
      selectedTime.value = picked;
    }
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (selectedClient.value == null) {
      clientValidationMessage.value = TranslationKeys.selectClientBeforeSaving.tr;
      return;
    }

    isSaving.value = true;
    try {
      final scheduledAt = DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
        selectedTime.value.hour,
        selectedTime.value.minute,
      );
      final now = DateTime.now().millisecondsSinceEpoch;
      final model = FollowUpModel(
        id: editingFollowUp?.id ?? _uuid.v4(),
        businessId: editingFollowUp?.businessId ?? '',
        clientId: selectedClient.value!.id,
        policyId: selectedPolicy.value?.id,
        followUpDateTime: scheduledAt.millisecondsSinceEpoch,
        type: selectedType.value,
        status: selectedStatus.value,
        remarks: _nullIfEmpty(remarksController.text),
        createdBy: editingFollowUp?.createdBy ?? '',
        agentId: editingFollowUp?.agentId,
        subAgentId: editingFollowUp?.subAgentId,
        customerUserId: editingFollowUp?.customerUserId,
        assignedTo: editingFollowUp?.assignedTo,
        createdAt: editingFollowUp?.createdAt ?? now,
        updatedAt: now,
        isDeleted: false,
        syncStatus: editingFollowUp == null ? 'pending_create' : 'pending_update',
        clientName: editingFollowUp?.clientName,
        clientMobile: editingFollowUp?.clientMobile,
        policyNumber: editingFollowUp?.policyNumber,
      );

      if (editingFollowUp == null) {
        await _addFollowUpUseCase(model);
      } else {
        await _updateFollowUpUseCase(model);
      }

      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        TranslationKeys.unableToSave.tr,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      isSaving.value = false;
    }
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '${TranslationKeys.enterFieldPrefix.tr} $fieldName';
    }
    return null;
  }

  Future<List<Client>> searchClients(String query) => _searchClientsUseCase(query);

  Future<List<Policy>> searchPolicies(String query) async {
    final clientId = selectedClient.value?.id;
    if (clientId == null || clientId.isEmpty) {
      return const [];
    }
    if (query.trim().isEmpty) {
      return _getPoliciesByClientUseCase(clientId);
    }
    return _searchPoliciesUseCase(query: query, clientId: clientId);
  }

  void selectClient(Client client) {
    selectedClient.value = client;
    clientValidationMessage.value = null;
    if (selectedPolicy.value?.clientId != client.id) {
      selectedPolicy.value = null;
    }
  }

  void selectPolicy(Policy policy) {
    if (selectedClient.value == null || policy.clientId != selectedClient.value!.id) {
      clientValidationMessage.value =
          TranslationKeys.selectedPolicyMustBelongToSelectedClient.tr;
      return;
    }
    selectedPolicy.value = policy;
  }

  void clearPolicy() {
    selectedPolicy.value = null;
  }

  Future<void> _loadClient(String clientId) async {
    selectedClient.value = await _getClientDetailsUseCase(clientId);
  }

  Future<void> _loadPolicy(String policyId) async {
    selectedPolicy.value = await _getPolicyByIdUseCase(policyId);
  }

  String? _nullIfEmpty(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
