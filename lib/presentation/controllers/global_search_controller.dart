import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/services/global_search_service.dart';
import 'package:ninaivu/data/models/app_user_model.dart';
import 'package:ninaivu/data/models/client_model.dart';
import 'package:ninaivu/data/models/policy_model.dart';

class GlobalSearchController extends GetxController {
  GlobalSearchController({GlobalSearchService? searchService})
    : _searchService = searchService ?? GlobalSearchService();

  final GlobalSearchService _searchService;
  final queryController = TextEditingController();
  final isLoading = false.obs;
  final clients = <ClientModel>[].obs;
  final policies = <PolicyModel>[].obs;
  final agents = <AppUserModel>[].obs;
  Timer? _debounce;
  int _requestVersion = 0;

  @override
  void onInit() {
    super.onInit();
    queryController.addListener(_onChanged);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    queryController.dispose();
    super.onClose();
  }

  Future<void> runSearch() async {
    final query = queryController.text.trim();
    final requestVersion = ++_requestVersion;
    if (query.isEmpty) {
      isLoading.value = false;
      clients.clear();
      policies.clear();
      agents.clear();
      return;
    }
    isLoading.value = true;
    try {
      final result = await _searchService.search(query);
      if (requestVersion != _requestVersion || isClosed) {
        return;
      }
      clients.assignAll(result.clients);
      policies.assignAll(result.policies);
      agents.assignAll(result.agents);
    } finally {
      if (requestVersion == _requestVersion && !isClosed) {
        isLoading.value = false;
      }
    }
  }

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), runSearch);
  }
}
