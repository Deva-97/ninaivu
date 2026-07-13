import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/client_detail_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/app_shell.dart';
import 'package:ninaivu/presentation/modules/policies/widgets/add_policy_method_sheet.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

class ClientDetailScreen extends GetView<ClientDetailController> {
  const ClientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationKeys.clientDetails.tr),
        actions: [
          IconButton(
            onPressed: () async {
              final client = controller.client.value;
              if (client == null) return;
              final refreshed = await Get.toNamed(
                AppRoutes.clientForm,
                arguments: client,
              );
              if (refreshed == true) {
                await controller.loadClient();
              }
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return AppLoadingView(message: TranslationKeys.loadingClient.tr);
        }
        final error = controller.errorMessage.value;
        if (error != null) {
          return AppErrorView(
            title: TranslationKeys.unableToLoadClient.tr,
            message: error,
            onRetry: controller.loadClient,
          );
        }
        final client = controller.client.value;
        if (client == null) {
          return AppEmptyState(
            icon: Icons.person_off_outlined,
            title: TranslationKeys.clientUnavailable.tr,
            subtitle: TranslationKeys.clientNotFound.tr,
          );
        }

        return ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.all(responsive.pagePadding),
            children: [
              ProfileAvatarBlock(
                name: client.name,
                subtitle: [
                  client.mobile,
                  client.areaCity,
                ].whereType<String>().where((e) => e.isNotEmpty).join(' • '),
                statusLabel: client.syncStatus,
                imagePath: client.profileImagePath,
                onTap: () =>
                    controller.updateProfileImage().catchError(_showError),
              ),
              SizedBox(height: responsive.itemGap),
              FormSectionCard(
                title: TranslationKeys.clientInformation.tr,
                children: [
                  DetailFieldRow(
                    label: TranslationKeys.mobile.tr,
                    value: client.mobile,
                  ),
                  DetailFieldRow(
                    label: TranslationKeys.alternate.tr,
                    value:
                        client.alternateMobile ??
                        TranslationKeys.notProvided.tr,
                  ),
                  DetailFieldRow(
                    label: TranslationKeys.email.tr,
                    value: client.email ?? TranslationKeys.notProvided.tr,
                  ),
                  DetailFieldRow(
                    label: TranslationKeys.areaCity.tr,
                    value: client.areaCity ?? TranslationKeys.notSet.tr,
                  ),
                  DetailFieldRow(
                    label: TranslationKeys.address.tr,
                    value: client.address ?? TranslationKeys.notProvided.tr,
                  ),
                  DetailFieldRow(
                    label: TranslationKeys.notes.tr,
                    value: client.notes ?? TranslationKeys.noNotes.tr,
                  ),
                  DetailFieldRow(
                    label: TranslationKeys.birthday.tr,
                    value: client.dateOfBirthMs == null
                        ? TranslationKeys.notSet.tr
                        : DateFormat('dd MMM yyyy').format(
                            DateTime.fromMillisecondsSinceEpoch(
                              client.dateOfBirthMs!,
                            ),
                          ),
                  ),
                  DetailFieldRow(
                    label: TranslationKeys.specialDate.tr,
                    value: client.specialDateMs == null
                        ? TranslationKeys.notSet.tr
                        : '${client.specialDateLabel ?? TranslationKeys.specialDate.tr} • ${DateFormat('dd MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(client.specialDateMs!))}',
                  ),
                  DetailFieldRow(
                    label: TranslationKeys.policyCount.tr,
                    value: client.policyCount.toString(),
                  ),
                ],
              ),
              SizedBox(height: responsive.itemGap),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  AppButton(
                    label: TranslationKeys.call.tr,
                    icon: Icons.call_outlined,
                    onPressed: () =>
                        controller.callClient().catchError(_showError),
                    expanded: false,
                  ),
                  AppButton(
                    label: TranslationKeys.whatsapp.tr,
                    icon: Icons.chat_outlined,
                    outlined: true,
                    onPressed: () =>
                        controller.whatsappClient().catchError(_showError),
                    expanded: false,
                  ),
                  AppButton(
                    label: TranslationKeys.policies.tr,
                    icon: Icons.description_outlined,
                    outlined: true,
                    onPressed: () => Get.toNamed(
                      AppRoutes.policies,
                      arguments: {'clientId': client.id},
                    ),
                    expanded: false,
                  ),
                  AppButton(
                    label: TranslationKeys.addPolicy.tr,
                    icon: Icons.add_card_outlined,
                    outlined: true,
                    onPressed: () => showAddPolicyMethodSheet(
                      clientId: client.id,
                      onPolicySaved: controller.loadClient,
                    ),
                    expanded: false,
                  ),
                ],
              ),
              SizedBox(height: responsive.sectionGap),
              SectionTitle(title: TranslationKeys.timeline.tr),
              SizedBox(height: responsive.itemGap),
              Obx(() {
                if (controller.timelineItems.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.timeline_outlined,
                    title: TranslationKeys.noTimelineItemsYet.tr,
                    subtitle: TranslationKeys.timelineSubtitle.tr,
                  );
                }
                return Column(
                  children: controller.timelineItems
                      .map(
                        (item) => Padding(
                          padding: EdgeInsets.only(
                            bottom: responsive.scaled(10, min: 8),
                          ),
                          child: Card(
                            child: ListTile(
                              leading: Icon(_timelineIcon(item.type)),
                              title: Text(item.title),
                              subtitle: Text(
                                '${item.subtitle}\n${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(item.dateTimeMillis))}',
                              ),
                              isThreeLine: true,
                              trailing: StatusBadge(label: item.status),
                              onTap: () => Get.toNamed(
                                item.routeName,
                                arguments: item.routeArgument,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              }),
              SizedBox(height: responsive.itemGap),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () async {
                    final confirmed = await Get.dialog<bool>(
                      AlertDialog(
                        title: Text(TranslationKeys.deleteClient.tr),
                        content: Text(
                          '${TranslationKeys.softDeleteClient.tr}\n${client.name}',
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
                      await controller.deleteClient();
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: Text(TranslationKeys.deleteClientButton.tr),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showError(Object error) {
    Get.snackbar(
      TranslationKeys.actionFailed.tr,
      error.toString().replaceFirst('Exception: ', ''),
    );
  }

  IconData _timelineIcon(String type) {
    switch (type) {
      case 'policy':
        return Icons.description_outlined;
      case 'reminder':
        return Icons.notifications_active_outlined;
      default:
        return Icons.pending_actions_outlined;
    }
  }
}
