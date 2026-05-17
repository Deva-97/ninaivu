import 'package:get/get.dart';
import 'package:ninaivu/domain/entities/client.dart';
import 'package:ninaivu/domain/usecases/clients/delete_client_usecase.dart';
import 'package:ninaivu/domain/usecases/clients/get_client_details_usecase.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientDetailController extends GetxController {
  ClientDetailController({
    required GetClientDetailsUseCase getClientDetailsUseCase,
    required DeleteClientUseCase deleteClientUseCase,
  }) : _getClientDetailsUseCase = getClientDetailsUseCase,
       _deleteClientUseCase = deleteClientUseCase;

  final GetClientDetailsUseCase _getClientDetailsUseCase;
  final DeleteClientUseCase _deleteClientUseCase;

  final client = Rxn<Client>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  late final String clientId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    clientId = args is Client ? args.id : args as String;
    loadClient();
  }

  Future<void> loadClient() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      client.value = await _getClientDetailsUseCase(clientId);
      if (client.value == null) {
        errorMessage.value = 'Client not found';
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteClient() async {
    await _deleteClientUseCase(clientId);
    Get.back(result: true);
  }

  Future<void> callClient() async {
    final mobile = client.value?.mobile;
    if (mobile == null || mobile.isEmpty) {
      throw Exception('Mobile number not available');
    }
    final uri = Uri.parse('tel:$mobile');
    if (!await launchUrl(uri)) {
      throw Exception('Unable to open the dialer');
    }
  }

  Future<void> whatsappClient() async {
    final mobile = client.value?.mobile;
    if (mobile == null || mobile.isEmpty) {
      throw Exception('Mobile number not available');
    }
    final uri = Uri.parse('https://wa.me/91$mobile');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Unable to open WhatsApp');
    }
  }
}
