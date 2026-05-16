import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insurance_reminders/core/widgets.dart';
import 'package:insurance_reminders/presentation/controllers/client_form_controller.dart';

class AddEditClientScreen extends GetView<ClientFormController> {
  const AddEditClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(controller.title)),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: controller.nameController,
              validator: controller.validateName,
              decoration: const InputDecoration(labelText: 'Client Name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.mobileController,
              validator: controller.validateMobile,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Primary Mobile',
                prefixText: '+91 ',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.alternateMobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Alternate Mobile',
                prefixText: '+91 ',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.emailController,
              validator: controller.validateOptionalEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.addressController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.areaCityController,
              decoration: const InputDecoration(labelText: 'Area / City'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.notesController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 24),
            Obx(
              () => SizedBox(
                height: 52,
                child: AppButton(
                  label: controller.editingClient == null ? 'Save Client' : 'Update Client',
                  onPressed: controller.submit,
                  isLoading: controller.isSaving.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
