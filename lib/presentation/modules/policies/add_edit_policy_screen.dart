import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/localization/localized_value_helper.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/policy_form_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/app_shell.dart';
import 'package:ninaivu/presentation/modules/common/widgets/searchable_client_picker.dart';

class AddEditPolicyScreen extends GetView<PolicyFormController> {
  const AddEditPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.editingPolicy == null
              ? TranslationKeys.addPolicy.tr
              : '${TranslationKeys.edit.tr} ${TranslationKeys.policyLabel.tr}',
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.all(responsive.pagePadding),
            children: [
              Obx(() {
                if (!controller.usedExtractedData.value) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(bottom: responsive.itemGap),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(
                        TranslationKeys.autoFilledVerifyBeforeSaving.tr,
                      ),
                    ),
                  ),
                );
              }),
              FormSectionCard(
                title: TranslationKeys.clientInformation.tr,
                subtitle: TranslationKeys.policiesLinkedToClient.tr,
                children: [
                  Obx(
                    () => SearchableClientPicker(
                      label: TranslationKeys.clientLabel.tr,
                      selectedClient: controller.selectedClient.value,
                      errorText: controller.clientValidationMessage.value,
                      helperText:
                          controller.extractedPolicyHolderHint.value == null
                          ? null
                          : TranslationKeys.extractedPolicyHolderPrompt
                                .trParams({
                                  'name': controller
                                      .extractedPolicyHolderHint
                                      .value!,
                                }),
                      initialQuery: controller.clientSearchSeed.value,
                      onSearch: controller.searchClients,
                      onChanged: controller.selectClient,
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.itemGap),
              FormSectionCard(
                title: TranslationKeys.policyDetails.tr,
                children: [
                  Obx(
                    () => DropdownButtonFormField<String>(
                      initialValue: controller.selectedInsuranceType.value,
                      decoration: InputDecoration(
                        labelText: TranslationKeys.insuranceType.tr,
                      ),
                      items: PolicyFormController.insuranceTypes
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                LocalizedValueHelper.policyInsuranceType(item),
                              ),
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
                  TextFormField(
                    controller: controller.policyNumberController,
                    validator: (value) =>
                        controller.validateRequired(value, 'policy number'),
                    decoration: InputDecoration(
                      labelText: TranslationKeys.policyNumber.tr,
                    ),
                  ),
                  TextFormField(
                    controller: controller.policyHolderNameController,
                    decoration: InputDecoration(
                      labelText: TranslationKeys.policyHolderName.tr,
                    ),
                  ),
                  TextFormField(
                    controller: controller.companyNameController,
                    validator: (value) =>
                        controller.validateRequired(value, 'company name'),
                    decoration: InputDecoration(
                      labelText: TranslationKeys.companyName.tr,
                    ),
                  ),
                  TextFormField(
                    controller: controller.premiumController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: controller.validatePremium,
                    decoration: InputDecoration(
                      labelText: TranslationKeys.premiumAmount.tr,
                    ),
                  ),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      initialValue: controller.selectedPaymentFrequency.value,
                      decoration: InputDecoration(
                        labelText: TranslationKeys.paymentFrequency.tr,
                      ),
                      items: PolicyFormController.paymentFrequencies
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                LocalizedValueHelper.paymentFrequency(item),
                              ),
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
                  Obx(
                    () => DropdownButtonFormField<String>(
                      initialValue: controller.selectedStatus.value,
                      decoration: InputDecoration(
                        labelText: TranslationKeys.status.tr,
                      ),
                      items: PolicyFormController.policyStatuses
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                LocalizedValueHelper.policyStatus(item),
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
                    () => DropdownButtonFormField<String>(
                      initialValue: controller.selectedRenewalStatus.value,
                      decoration: InputDecoration(
                        labelText: TranslationKeys.renewalStatus.tr,
                      ),
                      items: PolicyFormController.renewalStatuses
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                LocalizedValueHelper.renewalStatus(item),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedRenewalStatus.value = value;
                        }
                      },
                    ),
                  ),
                  Obx(
                    () => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(TranslationKeys.startDate.tr),
                      subtitle: Text(
                        dateFormat.format(controller.startDate.value),
                      ),
                      trailing: const Icon(Icons.calendar_today_outlined),
                      onTap: () => controller.pickDate(
                        context: context,
                        isStartDate: true,
                      ),
                    ),
                  ),
                  Obx(
                    () => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(TranslationKeys.endDate.tr),
                      subtitle: Text(
                        dateFormat.format(controller.endDate.value),
                      ),
                      trailing: const Icon(Icons.calendar_today_outlined),
                      onTap: () => controller.pickDate(
                        context: context,
                        isStartDate: false,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.itemGap),
              FormSectionCard(
                title: TranslationKeys.optionalDetails.tr,
                children: [
                  TextFormField(
                    controller: controller.vehicleNumberController,
                    decoration: InputDecoration(
                      labelText: TranslationKeys.vehicleNumber.tr,
                    ),
                  ),
                  TextFormField(
                    controller: controller.vehicleModelController,
                    decoration: InputDecoration(
                      labelText: TranslationKeys.vehicleModel.tr,
                    ),
                  ),
                  TextFormField(
                    controller: controller.notesController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: TranslationKeys.notes.tr,
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.sectionGap),
              Obx(
                () => SizedBox(
                  height: responsive.buttonHeight,
                  child: AppButton(
                    label: controller.editingPolicy == null
                        ? TranslationKeys.savePolicy.tr
                        : TranslationKeys.updatePolicy.tr,
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
