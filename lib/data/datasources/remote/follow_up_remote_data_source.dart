import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ninaivu/data/models/follow_up_model.dart';

class FollowUpRemoteDataSource {
  FollowUpRemoteDataSource({FirebaseFirestore? firestore}) : _firestore = firestore;

  FirebaseFirestore? _firestore;

  Future<void> upsertFollowUp(FollowUpModel followUp) async {
    await _collection(followUp.businessId).doc(followUp.id).set(
      followUp.toFirestore(),
      SetOptions(merge: true),
    );
  }

  Future<void> deleteFollowUp({
    required String businessId,
    required String followUpId,
  }) async {
    await _collection(businessId).doc(followUpId).delete();
  }

  CollectionReference<Map<String, dynamic>> _collection(String businessId) {
    return (_firestore ??= FirebaseFirestore.instance)
        .collection('businesses')
        .doc(businessId)
        .collection('follow_ups');
  }
}
