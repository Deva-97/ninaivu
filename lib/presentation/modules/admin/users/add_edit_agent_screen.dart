import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insurance_reminders/core/widgets.dart';
import 'package:insurance_reminders/presentation/controllers/admin_user_form_controller.dart';

class AddEditAgentScreen extends GetView<AdminUserFormController> {
  const AddEditAgentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _AdminUserFormScaffold(controller: controller, isAgentForm: true);
  }
}

class AddEditCustomerScreen extends GetView<AdminUserFormController> {
  const AddEditCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _AdminUserFormScaffold(controller: controller, isAgentForm: false);
  }
}

class _AdminUserFormScaffold extends StatelessWidget {
  const _AdminUserFormScaffold({
    required this.controller,
    required this.isAgentForm,
  });

  final AdminUserFormController controller;
  final bool isAgentForm;

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
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.mobileController,
              keyboardType: TextInputType.phone,
              validator: controller.validateMobile,
              decoration: const InputDecoration(
                labelText: 'Mobile',
                prefixText: '+91 ',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              validator: controller.validateEmail,
              decoration: const InputDecoration(labelText: 'Email (optional)'),
            ),
            if (!isAgentForm) ...[
              const SizedBox(height: 16),
              Obx(
                () => DropdownButtonFormField<String?>(
                  value: controller.selectedAgentId.value,
                  decoration: const InputDecoration(labelText: 'Assign Agent'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Unassigned'),
                    ),
                    ...controller.availableAgents.map(
                      (agent) => DropdownMenuItem<String?>(
                        value: agent.id,
                        child: Text(agent.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => controller.selectedAgentId.value = value,
                ),
              ),
            ],
            if (controller.editingUser != null) ...[
              const SizedBox(height: 16),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: controller.status.value,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.status.value = value;
                    }
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
            Obx(
              () => SizedBox(
                height: 52,
                child: AppButton(
                  label: controller.editingUser == null ? 'Create' : 'Save',
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
