import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/global_search_controller.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

class GlobalSearchScreen extends GetView<GlobalSearchController> {
  const GlobalSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Scaffold(
      appBar: AppBar(title: Text(TranslationKeys.search.tr)),
      body: ResponsiveContent(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(responsive.pagePadding),
              child: TextField(
                controller: controller.queryController,
                decoration: InputDecoration(
                  hintText: TranslationKeys.searchHint.tr,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const AppLoadingView(message: 'Searching...');
                }
                if (controller.clients.isEmpty &&
                    controller.policies.isEmpty &&
                    controller.agents.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.search_off_rounded,
                    title: TranslationKeys.noResults.tr,
                    subtitle: TranslationKeys.searchHint.tr,
                  );
                }
                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    responsive.pagePadding,
                    0,
                    responsive.pagePadding,
                    responsive.pagePadding,
                  ),
                  children: [
                    _Section(
                      title: TranslationKeys.groupedClients.tr,
                      children: controller.clients
                          .map(
                            (client) => ListTile(
                              title: Text(client.name),
                              subtitle: Text(client.mobile),
                              onTap: () => Get.toNamed(
                                AppRoutes.clientDetails,
                                arguments: client.id,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    _Section(
                      title: TranslationKeys.groupedPolicies.tr,
                      children: controller.policies
                          .map(
                            (policy) => ListTile(
                              title: Text(policy.policyNumber),
                              subtitle: Text(
                                '${policy.insuranceType} • ${policy.vehicleNumber ?? policy.companyName}',
                              ),
                              onTap: () => Get.toNamed(
                                AppRoutes.policyDetails,
                                arguments: policy.id,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    if (controller.agents.isNotEmpty)
                      _Section(
                        title: TranslationKeys.groupedAgents.tr,
                        children: controller.agents
                            .map(
                              (agent) => ListTile(
                                title: Text(agent.name),
                                subtitle: Text(agent.mobile ?? agent.email ?? ''),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }
    final responsive = context.responsive;
    return Card(
      margin: EdgeInsets.only(bottom: responsive.itemGap),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: responsive.scaled(8, min: 8)),
        child: Column(
          children: [
            ListTile(title: Text(title)),
            ...children,
          ],
        ),
      ),
    );
  }
}
