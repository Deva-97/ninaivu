import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/localization/localized_value_helper.dart';
import 'package:ninaivu/core/utils/whatsapp_template_builder.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/policy_detail_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/app_shell.dart';
import 'package:ninaivu/presentation/modules/common/widgets/whatsapp_template_selector.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

class PolicyDetailScreen extends GetView<PolicyDetailController> {
  const PolicyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'Rs. ');
    final dateFormat = DateFormat('dd MMM yyyy');
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationKeys.policyDetails.tr),
        actions: [
          IconButton(
            onPressed: () async {
              final policy = controller.policy.value;
              if (policy == null) return;
              final refreshed = await Get.toNamed(AppRoutes.policyForm, arguments: policy);
              if (refreshed == true) {
                await controller.loadPolicy();
              }
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return AppLoadingView(message: TranslationKeys.loadingPolicy.tr);
        }
        final error = controller.errorMessage.value;
        if (error != null) {
          return AppErrorView(
            title: TranslationKeys.unableToLoadPolicy.tr,
            message: error,
            onRetry: controller.loadPolicy,
          );
        }
        final policy = controller.policy.value;
        if (policy == null) {
          return AppEmptyState(
            icon: Icons.description_outlined,
            title: TranslationKeys.policyUnavailable.tr,
            subtitle: TranslationKeys.policyNotFound.tr,
          );
        }

        return ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.all(responsive.pagePadding),
            children: [
              FormSectionCard(
                title: policy.policyNumber,
                subtitle:
                    '${policy.companyName} • ${LocalizedValueHelper.policyInsuranceType(policy.insuranceType)}',
                children: [
                  DetailFieldRow(
                    label: TranslationKeys.premium.tr,
                    value: currency.format(policy.premiumAmount),
                  ),
                  DetailFieldRow(
                    label: TranslationKeys.startDate.tr,
                    value: dateFormat.format(DateTime.fromMillisecondsSinceEpoch(policy.startDate)),
                  ),
                  DetailFieldRow(
                    label: TranslationKeys.endDate.tr,
                    value: dateFormat.format(DateTime.fromMillisecondsSinceEpoch(policy.endDate)),
                  ),
                  DetailFieldRow(
                    label: TranslationKeys.status.tr,
                    value: LocalizedValueHelper.policyStatus(policy.status),
                  ),
                  DetailFieldRow(
                    label: TranslationKeys.renewalStatus.tr,
                    value: LocalizedValueHelper.renewalStatus(policy.renewalStatus),
                  ),
                  DetailFieldRow(label: TranslationKeys.syncStatus.tr, value: policy.syncStatus),
                  DetailFieldRow(label: TranslationKeys.clientLabel.tr, value: policy.clientId),
                  DetailFieldRow(
                    label: TranslationKeys.vehicle.tr,
                    value:
                        policy.vehicleNumber ??
                        policy.vehicleModel ??
                        TranslationKeys.notApplicable.tr,
                  ),
                  DetailFieldRow(
                    label: TranslationKeys.notes.tr,
                    value: policy.notes ?? TranslationKeys.noNotes.tr,
                  ),
                ],
              ),
              SizedBox(height: responsive.itemGap),
              if (controller.client.value?.mobile != null)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppButton(
                      label: TranslationKeys.call.tr,
                      icon: Icons.call_outlined,
                      onPressed: controller.callClient,
                      expanded: false,
                    ),
                    AppButton(
                      label: TranslationKeys.whatsapp.tr,
                      icon: Icons.chat_outlined,
                      outlined: true,
                      expanded: false,
                      onPressed: () => showWhatsAppTemplateSelector(
                        context: context,
                        mobile: controller.client.value!.mobile,
                        data: WhatsAppTemplateData(
                          clientName: controller.client.value!.name,
                          mobile: controller.client.value!.mobile,
                          policyNumber: policy.policyNumber,
                          companyName: policy.companyName,
                          insuranceType: policy.insuranceType,
                          expiryDateMillis: policy.endDate,
                          premiumAmount: policy.premiumAmount,
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: responsive.itemGap),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () async {
                    final confirmed = await Get.dialog<bool>(
                      AlertDialog(
                        title: Text(TranslationKeys.deletePolicy.tr),
                        content: Text(
                          '${TranslationKeys.softDeletePolicy.tr}\n${policy.policyNumber}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(result: false),
                            child: Text(TranslationKeys.cancel.tr),
                          ),
                          ElevatedButton(
                            onPressed: () => Get.back(result: true),
                            child: Text(TranslationKeys.delete.tr),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await controller.deletePolicy();
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: Text(TranslationKeys.deletePolicyButton.tr),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
