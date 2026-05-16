import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:insurance_reminders/core/widgets.dart';
import 'package:insurance_reminders/presentation/controllers/follow_up_form_controller.dart';

class AddEditFollowUpScreen extends GetView<FollowUpFormController> {
  const AddEditFollowUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.editingFollowUp == null ? 'Add Follow-up' : 'Edit Follow-up',
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: controller.clientIdController,
              decoration: const InputDecoration(labelText: 'Client ID'),
              validator: (value) => controller.validateRequired(value, 'client ID'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.policyIdController,
              decoration: const InputDecoration(
                labelText: 'Policy ID (optional)',
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.selectedType.value,
                decoration: const InputDecoration(labelText: 'Type'),
                items: FollowUpFormController.followUpTypes
                    .map(
                      (item) =>
                          DropdownMenuItem<String>(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedType.value = value;
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.selectedStatus.value,
                decoration: const InputDecoration(labelText: 'Status'),
                items: FollowUpFormController.followUpStatuses
                    .map(
                      (item) =>
                          DropdownMenuItem<String>(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedStatus.value = value;
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Follow-up Date'),
                subtitle: Text(dateFormat.format(controller.selectedDate.value)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () => controller.pickDate(context),
              ),
            ),
            Obx(
              () => ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Follow-up Time'),
                subtitle: Text(controller.selectedTime.value.format(context)),
                trailing: const Icon(Icons.access_time_outlined),
                onTap: () => controller.pickTime(context),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.remarksController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Remarks'),
            ),
            const SizedBox(height: 24),
            Obx(
              () => SizedBox(
                height: 52,
                child: AppButton(
                  label: controller.editingFollowUp == null
                      ? 'Save Follow-up'
                      : 'Update Follow-up',
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
