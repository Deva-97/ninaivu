import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:insurance_reminders/core/widgets.dart';
import 'package:insurance_reminders/presentation/controllers/policy_form_controller.dart';

class AddEditPolicyScreen extends GetView<PolicyFormController> {
  const AddEditPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.editingPolicy == null ? 'Add Policy' : 'Edit Policy'),
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: controller.clientIdController,
              validator: (value) => controller.validateRequired(value, 'client ID'),
              decoration: const InputDecoration(labelText: 'Client ID'),
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.selectedInsuranceType.value,
                decoration: const InputDecoration(labelText: 'Insurance Type'),
                items: PolicyFormController.insuranceTypes
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedInsuranceType.value = value;
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.policyNumberController,
              validator: (value) => controller.validateRequired(value, 'policy number'),
              decoration: const InputDecoration(labelText: 'Policy Number'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.companyNameController,
              validator: (value) => controller.validateRequired(value, 'company name'),
              decoration: const InputDecoration(labelText: 'Company Name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.premiumController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: controller.validatePremium,
              decoration: const InputDecoration(labelText: 'Premium Amount'),
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.selectedPaymentFrequency.value,
                decoration: const InputDecoration(labelText: 'Payment Frequency'),
                items: PolicyFormController.paymentFrequencies
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedPaymentFrequency.value = value;
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.selectedStatus.value,
                decoration: const InputDecoration(labelText: 'Status'),
                items: PolicyFormController.policyStatuses
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      ),
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
                title: const Text('Start Date'),
                subtitle: Text(dateFormat.format(controller.startDate.value)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () => controller.pickDate(context: context, isStartDate: true),
              ),
            ),
            Obx(
              () => ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('End Date'),
                subtitle: Text(dateFormat.format(controller.endDate.value)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () => controller.pickDate(context: context, isStartDate: false),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.vehicleNumberController,
              decoration: const InputDecoration(labelText: 'Vehicle Number'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.vehicleModelController,
              decoration: const InputDecoration(labelText: 'Vehicle Model'),
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
                  label: controller.editingPolicy == null ? 'Save Policy' : 'Update Policy',
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
