import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/client_form_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/app_shell.dart';

class AddEditClientScreen extends GetView<ClientFormController> {
  const AddEditClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(title: Text(controller.title)),
      body: Form(
        key: controller.formKey,
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.all(responsive.pagePadding),
            children: [
              Center(
                child: Obx(
                  () => ProfileAvatar(
                    name: controller.nameController.text.isEmpty
                        ? 'Client'
                        : controller.nameController.text,
                    imagePath: controller.profileImagePath.value,
                    radius: 42,
                    onTap: controller.pickProfileImage,
                  ),
                ),
              ),
              SizedBox(height: responsive.sectionGap),
              FormSectionCard(
                title: 'Client Information',
                subtitle: 'Add the primary contact details used across policies and follow-ups.',
                children: [
                  TextFormField(
                    controller: controller.nameController,
                    validator: controller.validateName,
                    decoration: const InputDecoration(labelText: 'Client Name'),
                  ),
                  TextFormField(
                    controller: controller.mobileController,
                    validator: controller.validateMobile,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: TranslationKeys.mobileNumber.tr,
                      prefixText: '+91 ',
                    ),
                  ),
                  Obx(() {
                    final warning = controller.duplicateMobileMessage.value;
                    if (warning == null) return const SizedBox.shrink();
                    return Text(
                      warning,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    );
                  }),
                  TextFormField(
                    controller: controller.alternateMobileController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Alternate Mobile',
                      prefixText: '+91 ',
                    ),
                  ),
                  TextFormField(
                    controller: controller.emailController,
                    validator: controller.validateOptionalEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: TranslationKeys.email.tr),
                  ),
                ],
              ),
              SizedBox(height: responsive.itemGap),
              FormSectionCard(
                title: 'Additional Details',
                children: [
                  TextFormField(
                    controller: controller.addressController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: InputDecoration(labelText: TranslationKeys.address.tr),
                  ),
                  TextFormField(
                    controller: controller.areaCityController,
                    decoration: InputDecoration(labelText: TranslationKeys.areaCity.tr),
                  ),
                  TextFormField(
                    controller: controller.notesController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: InputDecoration(labelText: TranslationKeys.notes.tr),
                  ),
                  Obx(
                    () => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(TranslationKeys.birthday.tr),
                      subtitle: Text(
                        controller.dateOfBirthMs.value == null
                            ? TranslationKeys.optional.tr
                            : dateFormat.format(
                                DateTime.fromMillisecondsSinceEpoch(
                                  controller.dateOfBirthMs.value!,
                                ),
                              ),
                      ),
                      trailing: const Icon(Icons.calendar_month_outlined),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: controller.dateOfBirthMs.value == null
                              ? DateTime.now()
                              : DateTime.fromMillisecondsSinceEpoch(
                                  controller.dateOfBirthMs.value!,
                                ),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          controller.dateOfBirthMs.value = picked.millisecondsSinceEpoch;
                        }
                      },
                    ),
                  ),
                  Obx(
                    () => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(TranslationKeys.specialDate.tr),
                      subtitle: Text(
                        controller.specialDateMs.value == null
                            ? TranslationKeys.optional.tr
                            : dateFormat.format(
                                DateTime.fromMillisecondsSinceEpoch(
                                  controller.specialDateMs.value!,
                                ),
                              ),
                      ),
                      trailing: const Icon(Icons.event_outlined),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: controller.specialDateMs.value == null
                              ? DateTime.now()
                              : DateTime.fromMillisecondsSinceEpoch(
                                  controller.specialDateMs.value!,
                                ),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          controller.specialDateMs.value = picked.millisecondsSinceEpoch;
                        }
                      },
                    ),
                  ),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      initialValue: controller.specialDateLabel.value,
                      decoration: InputDecoration(labelText: TranslationKeys.specialDateLabel.tr),
                      items: [
                        DropdownMenuItem(
                          value: TranslationKeys.anniversary.tr,
                          child: Text(TranslationKeys.anniversary.tr),
                        ),
                        DropdownMenuItem(
                          value: TranslationKeys.policyDiscussion.tr,
                          child: Text(TranslationKeys.policyDiscussion.tr),
                        ),
                        DropdownMenuItem(
                          value: TranslationKeys.familyReminder.tr,
                          child: Text(TranslationKeys.familyReminder.tr),
                        ),
                        DropdownMenuItem(
                          value: TranslationKeys.other.tr,
                          child: Text(TranslationKeys.other.tr),
                        ),
                      ],
                      onChanged: (value) => controller.specialDateLabel.value = value,
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.sectionGap),
              Obx(
                () => SizedBox(
                  height: responsive.buttonHeight,
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
      ),
    );
  }
}
