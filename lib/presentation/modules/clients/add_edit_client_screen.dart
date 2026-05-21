import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/client_form_controller.dart';

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
                  radius: 40,
                  onTap: controller.pickProfileImage,
                ),
              ),
            ),
            SizedBox(height: responsive.itemGap),
            TextFormField(
              controller: controller.nameController,
              validator: controller.validateName,
              decoration: const InputDecoration(labelText: 'Client Name'),
            ),
            SizedBox(height: responsive.itemGap),
            TextFormField(
              controller: controller.mobileController,
              validator: controller.validateMobile,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Primary Mobile',
                prefixText: '+91 ',
              ),
            ),
            Obx(() {
              final warning = controller.duplicateMobileMessage.value;
              if (warning == null) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  warning,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }),
            SizedBox(height: responsive.itemGap),
            TextFormField(
              controller: controller.alternateMobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Alternate Mobile',
                prefixText: '+91 ',
              ),
            ),
            SizedBox(height: responsive.itemGap),
            TextFormField(
              controller: controller.emailController,
              validator: controller.validateOptionalEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: responsive.itemGap),
            TextFormField(
              controller: controller.addressController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            SizedBox(height: responsive.itemGap),
            TextFormField(
              controller: controller.areaCityController,
              decoration: const InputDecoration(labelText: 'Area / City'),
            ),
            SizedBox(height: responsive.itemGap),
            TextFormField(
              controller: controller.notesController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            Obx(
              () => ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Birthday'),
                subtitle: Text(
                  controller.dateOfBirthMs.value == null
                      ? 'Optional'
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
                title: const Text('Special Date'),
                subtitle: Text(
                  controller.specialDateMs.value == null
                      ? 'Optional'
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
                decoration: const InputDecoration(labelText: 'Special Date Label'),
                items: const [
                  DropdownMenuItem(value: 'Anniversary', child: Text('Anniversary')),
                  DropdownMenuItem(value: 'Policy discussion', child: Text('Policy discussion')),
                  DropdownMenuItem(value: 'Family reminder', child: Text('Family reminder')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) => controller.specialDateLabel.value = value,
              ),
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
