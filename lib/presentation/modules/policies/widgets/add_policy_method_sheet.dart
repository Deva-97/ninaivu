import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/services/policy_document_extraction_exception.dart';
import 'package:ninaivu/core/services/policy_document_picker_service.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/domain/usecases/policies/extract_policy_from_document_usecase.dart';
import 'package:ninaivu/presentation/bindings/policy_bindings.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

enum AddPolicyMethod { manual, hardCopyCamera, galleryImage, softCopyPdf }

class AddPolicyMethodSheet extends StatelessWidget {
  const AddPolicyMethodSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          responsive.pagePadding,
          responsive.itemGap,
          responsive.pagePadding,
          responsive.pagePadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TranslationKeys.addPolicy.tr,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: responsive.itemGap),
            _MethodTile(
              icon: Icons.keyboard_alt_outlined,
              title: TranslationKeys.enterManually.tr,
              onTap: () => Get.back(result: AddPolicyMethod.manual),
            ),
            _MethodTile(
              icon: Icons.document_scanner_outlined,
              title: TranslationKeys.extractFromInsuranceHardCopy.tr,
              onTap: () => Get.back(result: AddPolicyMethod.hardCopyCamera),
            ),
            _MethodTile(
              icon: Icons.photo_library_outlined,
              title: TranslationKeys.choosePolicyImageFromGallery.tr,
              onTap: () => Get.back(result: AddPolicyMethod.galleryImage),
            ),
            _MethodTile(
              icon: Icons.picture_as_pdf_outlined,
              title: TranslationKeys.chooseSoftCopyPdf.tr,
              onTap: () => Get.back(result: AddPolicyMethod.softCopyPdf),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showAddPolicyMethodSheet({
  String? clientId,
  Future<void> Function()? onPolicySaved,
}) async {
  final method = await Get.bottomSheet<AddPolicyMethod>(
    const AddPolicyMethodSheet(),
    isScrollControlled: true,
    backgroundColor: Get.theme.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );

  if (method == null) {
    return;
  }

  if (method == AddPolicyMethod.manual) {
    await _openPolicyForm(clientId: clientId, onPolicySaved: onPolicySaved);
    return;
  }

  ensurePolicyDocumentExtractionDependencies();
  final source = switch (method) {
    AddPolicyMethod.hardCopyCamera => PolicyDocumentSource.camera,
    AddPolicyMethod.galleryImage => PolicyDocumentSource.gallery,
    AddPolicyMethod.softCopyPdf => PolicyDocumentSource.pdf,
    AddPolicyMethod.manual => PolicyDocumentSource.camera,
  };

  _showLoadingDialog();
  try {
    final extractedData = await Get.find<ExtractPolicyFromDocumentUseCase>()(
      source,
    );
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    if (extractedData == null) {
      Get.snackbar(
        TranslationKeys.addPolicy.tr,
        TranslationKeys.noFileSelected.tr,
      );
      return;
    }
    await _openPolicyForm(
      clientId: clientId,
      extractedPolicyData: extractedData,
      onPolicySaved: onPolicySaved,
    );
  } on PolicyDocumentExtractionException catch (error) {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    final message = [
      error.messageKey.tr,
      if (error.detailKey != null) error.detailKey!.tr,
    ].join(' ');
    Get.snackbar(TranslationKeys.addPolicy.tr, message.trim());
  } catch (_) {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    Get.snackbar(
      TranslationKeys.addPolicy.tr,
      TranslationKeys.couldNotReadDocument.tr,
    );
  }
}

Future<void> _openPolicyForm({
  String? clientId,
  Object? extractedPolicyData,
  Future<void> Function()? onPolicySaved,
}) async {
  final arguments = <String, dynamic>{}
    ..addAll(clientId != null ? {'clientId': clientId} : const {})
    ..addAll(
      extractedPolicyData != null
          ? {'extractedPolicyData': extractedPolicyData}
          : const {},
    );
  final refreshed = await Get.toNamed(
    AppRoutes.policyForm,
    arguments: arguments.isEmpty ? null : arguments,
  );
  if (refreshed == true && onPolicySaved != null) {
    await onPolicySaved();
  }
}

void _showLoadingDialog() {
  Get.dialog<void>(
    PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(TranslationKeys.extractingPolicyDetails.tr)),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
