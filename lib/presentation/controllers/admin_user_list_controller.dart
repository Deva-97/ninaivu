import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insurance_reminders/domain/entities/app_user.dart';
import 'package:insurance_reminders/domain/usecases/users/delete_user_usecase.dart';
import 'package:insurance_reminders/domain/usecases/users/get_agents_usecase.dart';
import 'package:insurance_reminders/domain/usecases/users/get_customers_usecase.dart';

class AdminUserListController extends GetxController {
  AdminUserListController({
    required this.isAgentList,
    required GetAgentsUseCase getAgentsUseCase,
    required GetCustomersUseCase getCustomersUseCase,
    required DeleteUserUseCase deleteUserUseCase,
  }) : _getAgentsUseCase = getAgentsUseCase,
       _getCustomersUseCase = getCustomersUseCase,
       _deleteUserUseCase = deleteUserUseCase;

  final bool isAgentList;
  final GetAgentsUseCase _getAgentsUseCase;
  final GetCustomersUseCase _getCustomersUseCase;
  final DeleteUserUseCase _deleteUserUseCase;

  final searchController = TextEditingController();
  final users = <AppUser>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  String get title => isAgentList ? 'Agents' : 'Customers';

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadUsers() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      users.assignAll(
        isAgentList
            ? await _getAgentsUseCase(query: searchController.text.trim())
            : await _getCustomersUseCase(query: searchController.text.trim()),
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUser(String userId) async {
    await _deleteUserUseCase(userId);
    await loadUsers();
  }
}
