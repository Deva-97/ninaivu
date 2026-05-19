import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/follow_up_form_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/searchable_client_picker.dart';
import 'package:ninaivu/presentation/modules/common/widgets/searchable_policy_picker.dart';

class AddEditFollowUpScreen extends GetView<FollowUpFormController> {
  const AddEditFollowUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.editingFollowUp == null
              ? 'Add Follow-up'
              : 'Edit Follow-up',
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.all(responsive.pagePadding),
            children: [
              Obx(
                () => SearchableClientPicker(
                  label: 'Client',
                  selectedClient: controller.selectedClient.value,
                  errorText: controller.clientValidationMessage.value,
                  onSearch: controller.searchClients,
                  onChanged: controller.selectClient,
                ),
              ),
              SizedBox(height: responsive.itemGap),
              Obx(
                () => SearchablePolicyPicker(
                  label: 'Policy',
                  selectedPolicy: controller.selectedPolicy.value,
                  enabled: controller.selectedClient.value != null,
                  onSearch: controller.searchPolicies,
                  onChanged: controller.selectPolicy,
                  onClear: controller.clearPolicy,
                ),
              ),
              SizedBox(height: responsive.itemGap),
              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: controller.selectedType.value,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: FollowUpFormController.followUpTypes
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectedType.value = value;
                    }
                  },
                ),
              ),
              SizedBox(height: responsive.itemGap),
              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: controller.selectedStatus.value,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: FollowUpFormController.followUpStatuses
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
                  title: const Text('Follow-up Date'),
                  subtitle: Text(
                    dateFormat.format(controller.selectedDate.value),
                  ),
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
              SizedBox(height: responsive.itemGap),
              TextFormField(
                controller: controller.remarksController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Remarks'),
              ),
              SizedBox(height: responsive.sectionGap),
              Obx(
                () => SizedBox(
                  height: responsive.buttonHeight,
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
      ),
    );
  }
}
