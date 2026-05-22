import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ninaivu/data/models/client_model.dart';

class ClientRemoteDataSource {
  ClientRemoteDataSource({FirebaseFirestore? firestore}) : _firestore = firestore;

  FirebaseFirestore? _firestore;

  Future<void> upsertClient(ClientModel client) async {
    await _collection(client.businessId).doc(client.id).set(
      client.toFirestore(),
      SetOptions(merge: true),
    );
  }

  Future<void> deleteClient({
    required String businessId,
    required String clientId,
  }) async {
    await _collection(businessId).doc(clientId).delete();
  }

  CollectionReference<Map<String, dynamic>> _collection(String businessId) {
    return (_firestore ??= FirebaseFirestore.instance)
        .collection('businesses')
        .doc(businessId)
        .collection('clients');
  }
}
