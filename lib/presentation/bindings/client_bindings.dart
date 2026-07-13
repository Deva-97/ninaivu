import 'package:get/get.dart';
import 'package:ninaivu/core/services/communication_service.dart';
import 'package:ninaivu/core/services/export_service.dart';
import 'package:ninaivu/core/services/profile_image_service.dart';
import 'package:ninaivu/data/repositories/client_repository_impl.dart';
import 'package:ninaivu/data/repositories/follow_up_repository_impl.dart';
import 'package:ninaivu/data/repositories/policy_repository_impl.dart';
import 'package:ninaivu/data/repositories/reminder_repository_impl.dart';
import 'package:ninaivu/domain/usecases/clients/add_client_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/check_duplicate_client_mobile_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/delete_client_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/export_clients_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/find_client_by_mobile_usecase.dart';
import 'package:ninaivu/domain/usecases/follow_ups/get_follow_ups_by_client_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/get_client_details_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/get_clients_usecase.dart';
import 'package:ninaivu/domain/usecases/policies/get_policies_by_client_usecase.dart';
import 'package:ninaivu/domain/usecases/reminders/get_reminders_by_client_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/update_client_usecase.dart';
import 'package:ninaivu/presentation/controllers/client_detail_controller.dart';
import 'package:ninaivu/presentation/controllers/client_form_controller.dart';
import 'package:ninaivu/presentation/controllers/client_list_controller.dart';

class ClientListBinding extends Bindings {
  @override
  void dependencies() {
    final repository = ClientRepositoryImpl();
    Get.lazyPut(
      () => ClientListController(
        getClientsUseCase: GetClientsUseCase(repository),
        deleteClientUseCase: DeleteClientUseCase(repository),
        exportClientsUseCase: ExportClientsUseCase(repository, ExportService()),
        communicationService: CommunicationService(),
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
        checkDuplicateClientMobileUseCase: CheckDuplicateClientMobileUseCase(
          repository,
        ),
        findClientByMobileUseCase: FindClientByMobileUseCase(repository),
        updateClientUseCase: UpdateClientUseCase(repository),
        profileImageService: ProfileImageService(),
      ),
    );
  }
}

class ClientDetailBinding extends Bindings {
  @override
  void dependencies() {
    final repository = ClientRepositoryImpl();
    final policyRepository = PolicyRepositoryImpl();
    final reminderRepository = ReminderRepositoryImpl();
    final followUpRepository = FollowUpRepositoryImpl();
    Get.lazyPut(
      () => ClientDetailController(
        getClientDetailsUseCase: GetClientDetailsUseCase(repository),
        deleteClientUseCase: DeleteClientUseCase(repository),
        getFollowUpsByClientUseCase: GetFollowUpsByClientUseCase(
          followUpRepository,
        ),
        getPoliciesByClientUseCase: GetPoliciesByClientUseCase(
          policyRepository,
        ),
        getRemindersByClientUseCase: GetRemindersByClientUseCase(
          reminderRepository,
        ),
        updateClientUseCase: UpdateClientUseCase(repository),
        communicationService: CommunicationService(),
        profileImageService: ProfileImageService(),
      ),
    );
  }
}
