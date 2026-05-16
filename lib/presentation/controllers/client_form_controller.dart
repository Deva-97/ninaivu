import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insurance_reminders/data/models/client_model.dart';
import 'package:insurance_reminders/domain/entities/client.dart';
import 'package:insurance_reminders/domain/usecases/clients/add_client_usecase.dart';
import 'package:insurance_reminders/domain/usecases/clients/update_client_usecase.dart';

class ClientFormController extends GetxController {
  ClientFormController({
    required AddClientUseCase addClientUseCase,
    required UpdateClientUseCase updateClientUseCase,
  }) : _addClientUseCase = addClientUseCase,
       _updateClientUseCase = updateClientUseCase;

  final AddClientUseCase _addClientUseCase;
  final UpdateClientUseCase _updateClientUseCase;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final alternateMobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final areaCityController = TextEditingController();
  final notesController = TextEditingController();
  final isSaving = false.obs;

  Client? editingClient;

  String get title => editingClient == null ? 'Add Client' : 'Edit Client';

  @override
  void onInit() {
    super.onInit();
    editingClient = Get.arguments as Client?;
    if (editingClient != null) {
      nameController.text = editingClient!.name;
      mobileController.text = editingClient!.mobile;
      alternateMobileController.text = editingClient!.alternateMobile ?? '';
      emailController.text = editingClient!.email ?? '';
      addressController.text = editingClient!.address ?? '';
      areaCityController.text = editingClient!.areaCity ?? '';
      notesController.text = editingClient!.notes ?? '';
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    alternateMobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    areaCityController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    isSaving.value = true;
    try {
      if (editingClient == null) {
        await _addClientUseCase(
          name: nameController.text.trim(),
          mobile: mobileController.text.trim(),
          alternateMobile: _nullIfEmpty(alternateMobileController.text),
          email: _nullIfEmpty(emailController.text),
          address: _nullIfEmpty(addressController.text),
          areaCity: _nullIfEmpty(areaCityController.text),
          notes: _nullIfEmpty(notesController.text),
        );
      } else {
        final updatedClient = ClientModel.fromEntity(editingClient!).copyWith(
          name: nameController.text.trim(),
          mobile: mobileController.text.trim(),
          alternateMobile: _nullIfEmpty(alternateMobileController.text),
          email: _nullIfEmpty(emailController.text),
          address: _nullIfEmpty(addressController.text),
          areaCity: _nullIfEmpty(areaCityController.text),
          notes: _nullIfEmpty(notesController.text),
        );
        await _updateClientUseCase(updatedClient);
      }
      Get.back(result: true);
    } catch (e) {
      Get.snackbar('Unable to save', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSaving.value = false;
    }
  }

  String? validateName(String? value) {
    if (value == null || value.trim().length < 2) {
      return 'Enter a valid name';
    }
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || !RegExp(r'^\d{10}$').hasMatch(value.trim())) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  String? validateOptionalEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return null;
    }
    if (!GetUtils.isEmail(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _nullIfEmpty(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
