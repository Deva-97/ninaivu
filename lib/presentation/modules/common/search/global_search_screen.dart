import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/global_search_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/app_shell.dart';
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
              child: AppSearchField(
                controller: controller.queryController,
                hintText: TranslationKeys.searchHint.tr,
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
                            (client) => ClientCard(
                              client: client,
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
                            (policy) => PolicyCard(
                              policy: policy,
                              subtitle:
                                  '${policy.insuranceType} • ${policy.vehicleNumber ?? policy.companyName}',
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
                              (agent) => Card(
                                child: ListTile(
                                  title: Text(agent.name),
                                  subtitle: Text(agent.mobile ?? agent.email ?? ''),
                                ),
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
    return Padding(
      padding: EdgeInsets.only(bottom: responsive.itemGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: title),
          SizedBox(height: responsive.scaled(10, min: 8)),
          ...children.map(
            (child) => Padding(
              padding: EdgeInsets.only(bottom: responsive.scaled(10, min: 8)),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
