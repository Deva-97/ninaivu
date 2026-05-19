import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/models/export_format.dart';
import 'package:ninaivu/domain/entities/client.dart';
import 'package:ninaivu/domain/usecases/clients/delete_client_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/export_clients_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/get_clients_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/search_clients_usecase.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientListController extends GetxController {
  ClientListController({
    required GetClientsUseCase getClientsUseCase,
    required SearchClientsUseCase searchClientsUseCase,
    required DeleteClientUseCase deleteClientUseCase,
    required ExportClientsUseCase exportClientsUseCase,
  }) : _getClientsUseCase = getClientsUseCase,
       _searchClientsUseCase = searchClientsUseCase,
       _deleteClientUseCase = deleteClientUseCase,
       _exportClientsUseCase = exportClientsUseCase;

  final GetClientsUseCase _getClientsUseCase;
  final SearchClientsUseCase _searchClientsUseCase;
  final DeleteClientUseCase _deleteClientUseCase;
  final ExportClientsUseCase _exportClientsUseCase;

  final searchController = TextEditingController();
  final clients = <Client>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    loadClients();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadClients() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final query = searchController.text.trim();
      clients.assignAll(
        query.isEmpty
            ? await _getClientsUseCase()
            : await _searchClientsUseCase(query),
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteClient(String clientId) async {
    await _deleteClientUseCase(clientId);
    await loadClients();
  }

  Future<void> exportClients(ExportFormat format) =>
      _exportClientsUseCase(format: format);

  Future<void> callClient(String mobile) async {
    final uri = Uri.parse('tel:$mobile');
    if (!await launchUrl(uri)) {
      throw Exception('Unable to open the dialer');
    }
  }

  Future<void> whatsappClient(String mobile) async {
    final uri = Uri.parse('https://wa.me/91$mobile');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Unable to open WhatsApp');
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), loadClients);
  }
}
