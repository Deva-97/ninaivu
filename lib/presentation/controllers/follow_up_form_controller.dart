import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insurance_reminders/data/models/follow_up_model.dart';
import 'package:insurance_reminders/domain/entities/follow_up.dart';
import 'package:insurance_reminders/domain/usecases/follow_ups/add_follow_up_usecase.dart';
import 'package:insurance_reminders/domain/usecases/follow_ups/update_follow_up_usecase.dart';
import 'package:uuid/uuid.dart';

class FollowUpFormController extends GetxController {
  FollowUpFormController({
    required AddFollowUpUseCase addFollowUpUseCase,
    required UpdateFollowUpUseCase updateFollowUpUseCase,
    Uuid? uuid,
  }) : _addFollowUpUseCase = addFollowUpUseCase,
       _updateFollowUpUseCase = updateFollowUpUseCase,
       _uuid = uuid ?? const Uuid();

  final AddFollowUpUseCase _addFollowUpUseCase;
  final UpdateFollowUpUseCase _updateFollowUpUseCase;
  final Uuid _uuid;

  final formKey = GlobalKey<FormState>();
  final clientIdController = TextEditingController();
  final policyIdController = TextEditingController();
  final remarksController = TextEditingController();
  final selectedType = 'Call'.obs;
  final selectedStatus = 'Pending'.obs;
  final selectedDate = Rx<DateTime>(DateTime.now());
  final selectedTime = Rx<TimeOfDay>(TimeOfDay.now());
  final isSaving = false.obs;

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
      clientIdController.text = args['clientId'] as String? ?? '';
      policyIdController.text = args['policyId'] as String? ?? '';
    }

    if (editingFollowUp != null) {
      clientIdController.text = editingFollowUp!.clientId;
      policyIdController.text = editingFollowUp!.policyId ?? '';
      remarksController.text = editingFollowUp!.remarks ?? '';
      selectedType.value = editingFollowUp!.type;
      selectedStatus.value = editingFollowUp!.status;
      final dateTime = DateTime.fromMillisecondsSinceEpoch(
        editingFollowUp!.followUpDateTime,
      );
      selectedDate.value = dateTime;
      selectedTime.value = TimeOfDay.fromDateTime(dateTime);
    }
  }

  @override
  void onClose() {
    clientIdController.dispose();
    policyIdController.dispose();
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
        clientId: clientIdController.text.trim(),
        policyId: _nullIfEmpty(policyIdController.text),
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

  String? _nullIfEmpty(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
