import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insurance_reminders/data/models/policy_model.dart';
import 'package:insurance_reminders/domain/entities/policy.dart';
import 'package:insurance_reminders/domain/usecases/policies/add_policy_usecase.dart';
import 'package:insurance_reminders/domain/usecases/policies/update_policy_usecase.dart';
import 'package:uuid/uuid.dart';

class PolicyFormController extends GetxController {
  PolicyFormController({
    required AddPolicyUseCase addPolicyUseCase,
    required UpdatePolicyUseCase updatePolicyUseCase,
    Uuid? uuid,
  }) : _addPolicyUseCase = addPolicyUseCase,
       _updatePolicyUseCase = updatePolicyUseCase,
       _uuid = uuid ?? const Uuid();

  final AddPolicyUseCase _addPolicyUseCase;
  final UpdatePolicyUseCase _updatePolicyUseCase;
  final Uuid _uuid;

  final formKey = GlobalKey<FormState>();
  final clientIdController = TextEditingController();
  final policyNumberController = TextEditingController();
  final companyNameController = TextEditingController();
  final premiumController = TextEditingController();
  final vehicleNumberController = TextEditingController();
  final vehicleModelController = TextEditingController();
  final notesController = TextEditingController();
  final selectedInsuranceType = 'Bike'.obs;
  final selectedPaymentFrequency = 'Yearly'.obs;
  final selectedStatus = 'Active'.obs;
  final startDate = Rx<DateTime>(DateTime.now());
  final endDate = Rx<DateTime>(DateTime.now().add(const Duration(days: 365)));
  final isSaving = false.obs;

  Policy? editingPolicy;

  static const insuranceTypes = <String>[
    'Bike',
    'Car',
    'Health',
    'Term',
    'Life',
    'Commercial Vehicle',
    'Other',
  ];

  static const paymentFrequencies = <String>[
    'Monthly',
    'Quarterly',
    'Half-yearly',
    'Yearly',
    'Single',
    'Other',
  ];

  static const policyStatuses = <String>[
    'Active',
    'Expired',
    'Renewed',
    'Cancelled',
    'Pending',
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Policy) {
      editingPolicy = args;
    } else if (args is Map<String, dynamic>) {
      editingPolicy = args['policy'] as Policy?;
      clientIdController.text = args['clientId'] as String? ?? '';
    }

    if (editingPolicy != null) {
      clientIdController.text = editingPolicy!.clientId;
      policyNumberController.text = editingPolicy!.policyNumber;
      companyNameController.text = editingPolicy!.companyName;
      premiumController.text = editingPolicy!.premiumAmount.toStringAsFixed(0);
      vehicleNumberController.text = editingPolicy!.vehicleNumber ?? '';
      vehicleModelController.text = editingPolicy!.vehicleModel ?? '';
      notesController.text = editingPolicy!.notes ?? '';
      selectedInsuranceType.value = editingPolicy!.insuranceType;
      selectedPaymentFrequency.value =
          editingPolicy!.paymentFrequency ?? selectedPaymentFrequency.value;
      selectedStatus.value = editingPolicy!.status;
      startDate.value = DateTime.fromMillisecondsSinceEpoch(editingPolicy!.startDate);
      endDate.value = DateTime.fromMillisecondsSinceEpoch(editingPolicy!.endDate);
    }
  }

  @override
  void onClose() {
    clientIdController.dispose();
    policyNumberController.dispose();
    companyNameController.dispose();
    premiumController.dispose();
    vehicleNumberController.dispose();
    vehicleModelController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> pickDate({
    required BuildContext context,
    required bool isStartDate,
  }) async {
    final initial = isStartDate ? startDate.value : endDate.value;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }
    if (isStartDate) {
      startDate.value = picked;
      if (!endDate.value.isAfter(picked)) {
        endDate.value = picked.add(const Duration(days: 365));
      }
    } else {
      endDate.value = picked;
    }
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!endDate.value.isAfter(startDate.value)) {
      Get.snackbar('Invalid dates', 'Policy end date must be after start date.');
      return;
    }

    isSaving.value = true;
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final premium = double.parse(premiumController.text.trim());
      final basePolicy = PolicyModel(
        id: editingPolicy?.id ?? _uuid.v4(),
        businessId: editingPolicy?.businessId ?? '',
        clientId: clientIdController.text.trim(),
        insuranceType: selectedInsuranceType.value,
        policyNumber: policyNumberController.text.trim(),
        companyName: companyNameController.text.trim(),
        startDate: startDate.value.millisecondsSinceEpoch,
        endDate: endDate.value.millisecondsSinceEpoch,
        premiumAmount: premium,
        paymentFrequency: selectedPaymentFrequency.value,
        vehicleNumber: _nullIfEmpty(vehicleNumberController.text),
        vehicleModel: _nullIfEmpty(vehicleModelController.text),
        status: selectedStatus.value,
        notes: _nullIfEmpty(notesController.text),
        createdBy: editingPolicy?.createdBy ?? '',
        agentId: editingPolicy?.agentId,
        subAgentId: editingPolicy?.subAgentId,
        customerUserId: editingPolicy?.customerUserId,
        assignedTo: editingPolicy?.assignedTo,
        createdAt: editingPolicy?.createdAt ?? now,
        updatedAt: now,
        isDeleted: false,
        syncStatus: editingPolicy == null ? 'pending_create' : 'pending_update',
      );

      if (editingPolicy == null) {
        await _addPolicyUseCase(basePolicy);
      } else {
        await _updatePolicyUseCase(basePolicy);
      }

      Get.back(result: true);
    } catch (e) {
      Get.snackbar('Unable to save', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSaving.value = false;
    }
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter $fieldName';
    }
    return null;
  }

  String? validatePremium(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter premium amount';
    }
    final premium = double.tryParse(value.trim());
    if (premium == null || premium <= 0) {
      return 'Enter a valid positive amount';
    }
    return null;
  }

  String? _nullIfEmpty(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
