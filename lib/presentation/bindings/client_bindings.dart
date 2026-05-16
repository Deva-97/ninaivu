import 'package:get/get.dart';
import 'package:insurance_reminders/data/repositories/client_repository_impl.dart';
import 'package:insurance_reminders/domain/usecases/clients/add_client_usecase.dart';
import 'package:insurance_reminders/domain/usecases/clients/delete_client_usecase.dart';
import 'package:insurance_reminders/domain/usecases/clients/get_client_details_usecase.dart';
import 'package:insurance_reminders/domain/usecases/clients/get_clients_usecase.dart';
import 'package:insurance_reminders/domain/usecases/clients/search_clients_usecase.dart';
import 'package:insurance_reminders/domain/usecases/clients/update_client_usecase.dart';
import 'package:insurance_reminders/presentation/controllers/client_detail_controller.dart';
import 'package:insurance_reminders/presentation/controllers/client_form_controller.dart';
import 'package:insurance_reminders/presentation/controllers/client_list_controller.dart';

class ClientListBinding extends Bindings {
  @override
  void dependencies() {
    final repository = ClientRepositoryImpl();
    Get.lazyPut(
      () => ClientListController(
        getClientsUseCase: GetClientsUseCase(repository),
        searchClientsUseCase: SearchClientsUseCase(repository),
        deleteClientUseCase: DeleteClientUseCase(repository),
      ),
    );
  }
}

class ClientFormBinding extends Bindings {
  @override
  void dependencies() {
    final repository = ClientRepositoryImpl();
    Get.lazyPut(
      () => ClientFormController(
        addClientUseCase: AddClientUseCase(repository),
        updateClientUseCase: UpdateClientUseCase(repository),
      ),
    );
  }
}

class ClientDetailBinding extends Bindings {
  @override
  void dependencies() {
    final repository = ClientRepositoryImpl();
    Get.lazyPut(
      () => ClientDetailController(
        getClientDetailsUseCase: GetClientDetailsUseCase(repository),
        deleteClientUseCase: DeleteClientUseCase(repository),
      ),
    );
  }
}
