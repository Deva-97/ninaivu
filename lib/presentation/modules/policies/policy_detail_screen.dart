import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
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
          return const AppLoadingView(message: 'Loading policy...');
        }
        final error = controller.errorMessage.value;
        if (error != null) {
          return AppErrorView(
            title: 'Unable to load policy',
            message: error,
            onRetry: controller.loadPolicy,
          );
        }
        final policy = controller.policy.value;
        if (policy == null) {
          return const AppEmptyState(
            icon: Icons.description_outlined,
            title: 'Policy unavailable',
            subtitle: 'This policy could not be found.',
          );
        }

        return ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.all(responsive.pagePadding),
            children: [
              FormSectionCard(
                title: policy.policyNumber,
                subtitle: '${policy.companyName} • ${policy.insuranceType}',
                children: [
                  DetailFieldRow(label: 'Premium', value: currency.format(policy.premiumAmount)),
                  DetailFieldRow(
                    label: 'Start Date',
                    value: dateFormat.format(DateTime.fromMillisecondsSinceEpoch(policy.startDate)),
                  ),
                  DetailFieldRow(
                    label: 'End Date',
                    value: dateFormat.format(DateTime.fromMillisecondsSinceEpoch(policy.endDate)),
                  ),
                  DetailFieldRow(label: 'Status', value: policy.status),
                  DetailFieldRow(label: 'Renewal Status', value: policy.renewalStatus),
                  DetailFieldRow(label: 'Sync Status', value: policy.syncStatus),
                  DetailFieldRow(label: 'Client ID', value: policy.clientId),
                  DetailFieldRow(
                    label: 'Vehicle',
                    value: policy.vehicleNumber ?? policy.vehicleModel ?? 'Not applicable',
                  ),
                  DetailFieldRow(label: TranslationKeys.notes.tr, value: policy.notes ?? 'No notes'),
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
                        title: const Text('Delete policy'),
                        content: Text('Soft-delete ${policy.policyNumber}?'),
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
                  label: const Text('Delete Policy'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
