import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/models/export_format.dart';
import 'package:ninaivu/domain/entities/policy.dart';
import 'package:ninaivu/domain/usecases/policies/delete_policy_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/export_policies_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/get_policies_by_client_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/get_policies_usecase.dart';

class PolicyListController extends GetxController {
  PolicyListController({
    required GetPoliciesUseCase getPoliciesUseCase,
    required GetPoliciesByClientUseCase getPoliciesByClientUseCase,
    required DeletePolicyUseCase deletePolicyUseCase,
    required ExportPoliciesUseCase exportPoliciesUseCase,
  }) : _getPoliciesUseCase = getPoliciesUseCase,
       _getPoliciesByClientUseCase = getPoliciesByClientUseCase,
       _deletePolicyUseCase = deletePolicyUseCase,
       _exportPoliciesUseCase = exportPoliciesUseCase;

  static const int _pageSize = 50;

  final GetPoliciesUseCase _getPoliciesUseCase;
  final GetPoliciesByClientUseCase _getPoliciesByClientUseCase;
  final DeletePolicyUseCase _deletePolicyUseCase;
  final ExportPoliciesUseCase _exportPoliciesUseCase;

  final searchController = TextEditingController();
  final scrollController = ScrollController();
  final policies = <Policy>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = RxnString();

  Timer? _debounce;
  String? clientId;
  int _nextOffset = 0;
  int _requestVersion = 0;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      clientId = args['clientId'] as String?;
    }
    searchController.addListener(_onSearchChanged);
    scrollController.addListener(_onScroll);
    loadPolicies();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadPolicies() => _loadPolicies(reset: true);

  Future<void> loadMorePolicies() => _loadPolicies(reset: false);

  Future<void> _loadPolicies({required bool reset}) async {
    if (reset) {
      isLoading.value = true;
      errorMessage.value = null;
      hasMore.value = true;
      _nextOffset = 0;
    } else {
      if (isLoading.value || isLoadingMore.value || !hasMore.value) {
        return;
      }
      isLoadingMore.value = true;
    }

    final requestVersion = ++_requestVersion;

    try {
      List<Policy> result;
      if (clientId != null && clientId!.isNotEmpty) {
        if (!reset) {
          return;
        }
        result = await _getPoliciesByClientUseCase(clientId!);
      } else {
        final query = searchController.text.trim();
        result = await _getPoliciesUseCase(
          query: query.isEmpty ? null : query,
          limit: _pageSize,
          offset: _nextOffset,
        );
      }

      if (requestVersion != _requestVersion || isClosed) {
        return;
      }

      if (reset) {
        policies.assignAll(result);
      } else {
        policies.addAll(result);
      }
      _nextOffset = policies.length;
      hasMore.value = clientId != null && clientId!.isNotEmpty
          ? false
          : result.length >= _pageSize;
    } catch (e) {
      if (requestVersion == _requestVersion && !isClosed) {
        errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      if (requestVersion == _requestVersion && !isClosed) {
        isLoading.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> deletePolicy(String policyId) async {
    await _deletePolicyUseCase(policyId);
    await loadPolicies();
  }

  Future<void> exportPolicies(ExportFormat format) =>
      _exportPoliciesUseCase(format: format);

  void _onSearchChanged() {
    if (clientId != null && clientId!.isNotEmpty) {
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), loadPolicies);
  }

  void _onScroll() {
    if (!scrollController.hasClients || clientId != null && clientId!.isNotEmpty) {
      return;
    }

    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      loadMorePolicies();
    }
  }
}
