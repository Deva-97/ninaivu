import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/policy_form_controller.dart';

class AddEditPolicyScreen extends GetView<PolicyFormController> {
  const AddEditPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.editingPolicy == null ? 'Add Policy' : 'Edit Policy'),
      ),
      body: Form(
        key: controller.formKey,
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.all(responsive.pagePadding),
            children: [
            TextFormField(
              controller: controller.clientIdController,
              validator: (value) => controller.validateRequired(value, 'client ID'),
              decoration: const InputDecoration(labelText: 'Client ID'),
            ),
            SizedBox(height: responsive.itemGap),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: controller.selectedInsuranceType.value,
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
            SizedBox(height: responsive.itemGap),
            TextFormField(
              controller: controller.policyNumberController,
              validator: (value) => controller.validateRequired(value, 'policy number'),
              decoration: const InputDecoration(labelText: 'Policy Number'),
            ),
            SizedBox(height: responsive.itemGap),
            TextFormField(
              controller: controller.companyNameController,
              validator: (value) => controller.validateRequired(value, 'company name'),
              decoration: const InputDecoration(labelText: 'Company Name'),
            ),
            SizedBox(height: responsive.itemGap),
            TextFormField(
              controller: controller.premiumController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: controller.validatePremium,
              decoration: const InputDecoration(labelText: 'Premium Amount'),
            ),
            SizedBox(height: responsive.itemGap),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: controller.selectedPaymentFrequency.value,
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
            SizedBox(height: responsive.itemGap),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: controller.selectedStatus.value,
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
            SizedBox(height: responsive.itemGap),
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
            SizedBox(height: responsive.itemGap),
            TextFormField(
              controller: controller.vehicleNumberController,
              decoration: const InputDecoration(labelText: 'Vehicle Number'),
            ),
            SizedBox(height: responsive.itemGap),
            TextFormField(
              controller: controller.vehicleModelController,
              decoration: const InputDecoration(labelText: 'Vehicle Model'),
            ),
            SizedBox(height: responsive.itemGap),
            TextFormField(
              controller: controller.notesController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            SizedBox(height: responsive.sectionGap),
            Obx(
              () => SizedBox(
                height: responsive.buttonHeight,
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
      ),
    );
  }
}
