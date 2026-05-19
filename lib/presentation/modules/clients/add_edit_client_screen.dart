import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/client_form_controller.dart';

class AddEditClientScreen extends GetView<ClientFormController> {
  const AddEditClientScreen({super.key});

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
