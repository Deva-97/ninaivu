import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/admin_user_form_controller.dart';

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
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(title: Text(controller.title)),
      body: Form(
        key: controller.formKey,
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.all(responsive.pagePadding),
            children: [
              TextFormField(
                controller: controller.nameController,
                validator: controller.validateName,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: responsive.itemGap),
              TextFormField(
                controller: controller.mobileController,
                keyboardType: TextInputType.phone,
                validator: controller.validateMobile,
                decoration: const InputDecoration(
                  labelText: 'Mobile',
                  prefixText: '+91 ',
                ),
              ),
              SizedBox(height: responsive.itemGap),
              TextFormField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                ),
              ),
              if (!isAgentForm) ...[
                SizedBox(height: responsive.itemGap),
                Obx(
                  () => DropdownButtonFormField<String?>(
                    initialValue: controller.selectedAgentId.value,
                    decoration: const InputDecoration(
                      labelText: 'Assign Agent',
                    ),
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
                    onChanged: (value) =>
                        controller.selectedAgentId.value = value,
                  ),
                ),
              ],
              if (controller.editingUser != null) ...[
                SizedBox(height: responsive.itemGap),
                Obx(
                  () => DropdownButtonFormField<String>(
                    initialValue: controller.status.value,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(
                        value: 'inactive',
                        child: Text('Inactive'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.status.value = value;
                      }
                    },
                  ),
                ),
              ],
              SizedBox(height: responsive.sectionGap),
              Obx(
                () => SizedBox(
                  height: responsive.buttonHeight,
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
      ),
    );
  }
}
