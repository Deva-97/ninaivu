import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/domain/entities/app_user.dart';
import 'package:ninaivu/domain/usecases/users/create_agent_usecase.dart';
import 'package:ninaivu/domain/usecases/users/create_customer_usecase.dart';
import 'package:ninaivu/domain/usecases/users/get_agents_usecase.dart';
import 'package:ninaivu/domain/usecases/users/update_user_status_usecase.dart';

class AdminUserFormController extends GetxController {
  AdminUserFormController({
    required this.isAgentForm,
    required CreateAgentUseCase createAgentUseCase,
    required CreateCustomerUseCase createCustomerUseCase,
    required UpdateUserStatusUseCase updateUserStatusUseCase,
    required GetAgentsUseCase getAgentsUseCase,
  }) : _createAgentUseCase = createAgentUseCase,
       _createCustomerUseCase = createCustomerUseCase,
       _updateUserStatusUseCase = updateUserStatusUseCase,
       _getAgentsUseCase = getAgentsUseCase;

  final bool isAgentForm;
  final CreateAgentUseCase _createAgentUseCase;
  final CreateCustomerUseCase _createCustomerUseCase;
  final UpdateUserStatusUseCase _updateUserStatusUseCase;
  final GetAgentsUseCase _getAgentsUseCase;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final status = 'active'.obs;
  final availableAgents = <AppUser>[].obs;
  final selectedAgentId = RxnString();
  final isSaving = false.obs;

  AppUser? editingUser;

  String get title => editingUser == null
      ? (isAgentForm ? TranslationKeys.addAgent.tr : TranslationKeys.addCustomer.tr)
      : (isAgentForm ? TranslationKeys.editAgent.tr : TranslationKeys.editCustomer.tr);

  @override
  void onInit() {
    super.onInit();
    editingUser = Get.arguments as AppUser?;
    if (editingUser != null) {
      nameController.text = editingUser!.name;
      mobileController.text = editingUser!.mobile ?? '';
      emailController.text = editingUser!.email ?? '';
      status.value = editingUser!.status;
      selectedAgentId.value = editingUser!.agentId;
    }
    if (!isAgentForm) {
      loadAgents();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    super.onClose();
  }

  Future<void> loadAgents() async {
    try {
      availableAgents.assignAll(await _getAgentsUseCase());
    } catch (_) {
      availableAgents.clear();
    }
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    isSaving.value = true;
    try {
      if (editingUser == null) {
        if (isAgentForm) {
          await _createAgentUseCase(
            name: nameController.text.trim(),
            mobile: mobileController.text.trim(),
            email: _nullIfEmpty(emailController.text),
          );
        } else {
          await _createCustomerUseCase(
            name: nameController.text.trim(),
            mobile: mobileController.text.trim(),
            email: _nullIfEmpty(emailController.text),
            agentId: selectedAgentId.value,
          );
        }
      } else {
        await _updateUserStatusUseCase(
          userId: editingUser!.id,
          status: status.value,
        );
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

  String? validateName(String? value) {
    if (value == null || value.trim().length < 2) {
      return TranslationKeys.enterAValidName.tr;
    }
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || !RegExp(r'^\d{10}$').hasMatch(value.trim())) {
      return TranslationKeys.enterValid10DigitMobile.tr;
    }
    return null;
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return null;
    }
    if (!GetUtils.isEmail(email)) {
      return TranslationKeys.enterValidEmail.tr;
    }
    return null;
  }

  String? _nullIfEmpty(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
