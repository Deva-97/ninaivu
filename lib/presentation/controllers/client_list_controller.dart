import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/services/communication_service.dart';
import 'package:ninaivu/core/models/export_format.dart';
import 'package:ninaivu/domain/entities/client.dart';
import 'package:ninaivu/domain/usecases/clients/delete_client_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/export_clients_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/get_clients_usecase.dart';

class ClientListController extends GetxController {
  ClientListController({
    required GetClientsUseCase getClientsUseCase,
    required DeleteClientUseCase deleteClientUseCase,
    required ExportClientsUseCase exportClientsUseCase,
    required CommunicationService communicationService,
  }) : _getClientsUseCase = getClientsUseCase,
       _deleteClientUseCase = deleteClientUseCase,
       _exportClientsUseCase = exportClientsUseCase,
       _communicationService = communicationService;

  final GetClientsUseCase _getClientsUseCase;
  final DeleteClientUseCase _deleteClientUseCase;
  final ExportClientsUseCase _exportClientsUseCase;
  final CommunicationService _communicationService;

  static const int _pageSize = 50;

  final searchController = TextEditingController();
  final scrollController = ScrollController();
  final clients = <Client>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = RxnString();

  Timer? _debounce;
  int _nextOffset = 0;
  int _requestVersion = 0;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    scrollController.addListener(_onScroll);
    loadClients();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadClients() => _loadClients(reset: true);

  Future<void> loadMoreClients() => _loadClients(reset: false);

  Future<void> _loadClients({required bool reset}) async {
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
      final query = searchController.text.trim();
      final result = await _getClientsUseCase(
        query: query.isEmpty ? null : query,
        limit: _pageSize,
        offset: _nextOffset,
      );

      if (requestVersion != _requestVersion || isClosed) {
        return;
      }

      if (reset) {
        clients.assignAll(result);
      } else {
        clients.addAll(result);
      }
      _nextOffset = clients.length;
      hasMore.value = result.length >= _pageSize;
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

  Future<void> deleteClient(String clientId) async {
    await _deleteClientUseCase(clientId);
    await loadClients();
  }

  Future<void> exportClients(ExportFormat format) =>
      _exportClientsUseCase(format: format);

  Future<void> callClient(String mobile) async {
    await _communicationService.openDialer(mobile);
  }

  Future<void> whatsappClient(String mobile) async {
    await _communicationService.openWhatsAppChat(mobile);
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), loadClients);
  }

  void _onScroll() {
    if (!scrollController.hasClients) {
      return;
    }

    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      loadMoreClients();
    }
  }
}
