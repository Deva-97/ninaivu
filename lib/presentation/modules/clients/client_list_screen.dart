import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/client_list_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/app_shell.dart';
import 'package:ninaivu/presentation/modules/common/widgets/export_format_picker.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

class ClientListScreen extends GetView<ClientListController> {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return AppShellScaffold(
      currentTab: AppShellTab.clients,
      dashboardRoute: AppRoutes.agentDashboard,
      title: TranslationKeys.clients.tr,
      subtitle: TranslationKeys.searchManageClientPortfolio.tr,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final refreshed = await Get.toNamed(AppRoutes.clientForm);
          if (refreshed == true) {
            await controller.loadClients();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(TranslationKeys.addClient.tr),
      ),
      actions: [
        AppIconButton(
          tooltip: TranslationKeys.exportClients.tr,
          icon: Icons.ios_share_outlined,
          onPressed: () async {
            final format = await showExportFormatPicker(
              title: TranslationKeys.exportClients.tr,
            );
            if (format != null) {
              await controller.exportClients(format);
            }
          },
        ),
      ],
      body: Column(
        children: [
          ResponsiveContent(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
              child: AppSearchField(
                controller: controller.searchController,
                hintText: TranslationKeys.searchHint.tr,
                onRefresh: controller.loadClients,
              ),
            ),
          ),
          SizedBox(height: responsive.itemGap),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return AppLoadingView(
                  message: TranslationKeys.loadingClients.tr,
                );
              }

              final error = controller.errorMessage.value;
              if (error != null) {
                return AppErrorView(
                  title: TranslationKeys.unableToLoadClients.tr,
                  message: error,
                  onRetry: controller.loadClients,
                );
              }

              if (controller.clients.isEmpty) {
                return AppEmptyState(
                  icon: Icons.people_outline_rounded,
                  title: TranslationKeys.noClientsYet.tr,
                  subtitle: TranslationKeys.noClientsSubtitle.tr,
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadClients,
                child: ResponsiveContent(
                  child: ListView.separated(
                    controller: controller.scrollController,
                    padding: EdgeInsets.fromLTRB(
                      responsive.pagePadding,
                      0,
                      responsive.pagePadding,
                      responsive.scaled(110, min: 96),
                    ),
                    itemCount:
                        controller.clients.length +
                        (controller.isLoadingMore.value ? 1 : 0),
                    separatorBuilder: (_, _) =>
                        SizedBox(height: responsive.scaled(12, min: 10)),
                    itemBuilder: (context, index) {
                      if (index >= controller.clients.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final client = controller.clients[index];
                      return ClientCard(
                        client: client,
                        onCall: () => controller.callClient(client.mobile),
                        onWhatsApp: () =>
                            controller.whatsappClient(client.mobile),
                        onTap: () async {
                          final refreshed = await Get.toNamed(
                            AppRoutes.clientDetails,
                            arguments: client.id,
                          );
                          if (refreshed == true) {
                            await controller.loadClients();
                          }
                        },
                        onMenuSelected: (value) async {
                          try {
                            if (value == 'policies') {
                              await Get.toNamed(
                                AppRoutes.policies,
                                arguments: {'clientId': client.id},
                              );
                            } else if (value == 'edit') {
                              final refreshed = await Get.toNamed(
                                AppRoutes.clientForm,
                                arguments: client,
                              );
                              if (refreshed == true) {
                                await controller.loadClients();
                              }
                            } else if (value == 'delete') {
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
                                await controller.deleteClient(client.id);
                              }
                            }
                          } catch (e) {
                            Get.snackbar(
                              TranslationKeys.actionFailed.tr,
                              e.toString().replaceFirst('Exception: ', ''),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
