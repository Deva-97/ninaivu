import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/localization/localized_value_helper.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/follow_up_form_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/app_shell.dart';
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
              ? TranslationKeys.addFollowUp.tr
              : '${TranslationKeys.edit.tr} ${TranslationKeys.followUps.tr}',
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.all(responsive.pagePadding),
            children: [
              FormSectionCard(
                title: TranslationKeys.followUpDetails.tr,
                children: [
                  Obx(
                    () => SearchableClientPicker(
                      label: TranslationKeys.clientLabel.tr,
                      selectedClient: controller.selectedClient.value,
                      errorText: controller.clientValidationMessage.value,
                      onSearch: controller.searchClients,
                      onChanged: controller.selectClient,
                    ),
                  ),
                  Obx(
                    () => SearchablePolicyPicker(
                      label: TranslationKeys.policyLabel.tr,
                      selectedPolicy: controller.selectedPolicy.value,
                      enabled: controller.selectedClient.value != null,
                      onSearch: controller.searchPolicies,
                      onChanged: controller.selectPolicy,
                      onClear: controller.clearPolicy,
                    ),
                  ),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      initialValue: controller.selectedType.value,
                      decoration: InputDecoration(
                        labelText: TranslationKeys.type.tr,
                      ),
                      items: FollowUpFormController.followUpTypes
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                LocalizedValueHelper.followUpType(item),
                              ),
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
                  Obx(
                    () => DropdownButtonFormField<String>(
                      initialValue: controller.selectedStatus.value,
                      decoration: InputDecoration(
                        labelText: TranslationKeys.status.tr,
                      ),
                      items: FollowUpFormController.followUpStatuses
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                LocalizedValueHelper.followUpStatus(item),
                              ),
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
                  Obx(
                    () => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(TranslationKeys.followUpDate.tr),
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
                      title: Text(TranslationKeys.followUpTime.tr),
                      subtitle: Text(
                        controller.selectedTime.value.format(context),
                      ),
                      trailing: const Icon(Icons.access_time_outlined),
                      onTap: () => controller.pickTime(context),
                    ),
                  ),
                  TextFormField(
                    controller: controller.remarksController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: TranslationKeys.remarks.tr,
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.sectionGap),
              Obx(
                () => SizedBox(
                  height: responsive.buttonHeight,
                  child: AppButton(
                    label: controller.editingFollowUp == null
                        ? TranslationKeys.saveFollowUp.tr
                        : TranslationKeys.updateFollowUp.tr,
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
