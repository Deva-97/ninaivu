import 'package:get/get.dart';
import 'package:insurance_reminders/data/repositories/user_repository_impl.dart';
import 'package:insurance_reminders/domain/usecases/users/create_agent_usecase.dart';
import 'package:insurance_reminders/domain/usecases/users/create_customer_usecase.dart';
import 'package:insurance_reminders/domain/usecases/users/delete_user_usecase.dart';
import 'package:insurance_reminders/domain/usecases/users/get_agents_usecase.dart';
import 'package:insurance_reminders/domain/usecases/users/get_customers_usecase.dart';
import 'package:insurance_reminders/domain/usecases/users/update_user_status_usecase.dart';
import 'package:insurance_reminders/presentation/controllers/admin_user_form_controller.dart';
import 'package:insurance_reminders/presentation/controllers/admin_user_list_controller.dart';

class AgentListBinding extends Bindings {
  @override
  void dependencies() {
    final repository = UserRepositoryImpl();
    Get.lazyPut(
      () => AdminUserListController(
        isAgentList: true,
        getAgentsUseCase: GetAgentsUseCase(repository),
        getCustomersUseCase: GetCustomersUseCase(repository),
        deleteUserUseCase: DeleteUserUseCase(repository),
      ),
    );
  }
}

class CustomerListBinding extends Bindings {
  @override
  void dependencies() {
    final repository = UserRepositoryImpl();
    Get.lazyPut(
      () => AdminUserListController(
        isAgentList: false,
        getAgentsUseCase: GetAgentsUseCase(repository),
        getCustomersUseCase: GetCustomersUseCase(repository),
        deleteUserUseCase: DeleteUserUseCase(repository),
      ),
    );
  }
}

class AgentFormBinding extends Bindings {
  @override
  void dependencies() {
    final repository = UserRepositoryImpl();
    Get.lazyPut(
      () => AdminUserFormController(
        isAgentForm: true,
        createAgentUseCase: CreateAgentUseCase(repository),
        createCustomerUseCase: CreateCustomerUseCase(repository),
        updateUserStatusUseCase: UpdateUserStatusUseCase(repository),
        getAgentsUseCase: GetAgentsUseCase(repository),
      ),
    );
  }
}

class CustomerFormBinding extends Bindings {
  @override
  void dependencies() {
    final repository = UserRepositoryImpl();
    Get.lazyPut(
      () => AdminUserFormController(
        isAgentForm: false,
        createAgentUseCase: CreateAgentUseCase(repository),
        createCustomerUseCase: CreateCustomerUseCase(repository),
        updateUserStatusUseCase: UpdateUserStatusUseCase(repository),
        getAgentsUseCase: GetAgentsUseCase(repository),
      ),
    );
  }
}
