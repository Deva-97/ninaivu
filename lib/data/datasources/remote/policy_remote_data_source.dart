import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ninaivu/data/models/policy_model.dart';

class PolicyRemoteDataSource {
  PolicyRemoteDataSource({FirebaseFirestore? firestore}) : _firestore = firestore;

  FirebaseFirestore? _firestore;

  Future<void> upsertPolicy(PolicyModel policy) async {
    await _collection(policy.businessId).doc(policy.id).set(
      policy.toFirestore(),
      SetOptions(merge: true),
    );
  }

  Future<void> deletePolicy({
    required String businessId,
    required String policyId,
  }) async {
    await _collection(businessId).doc(policyId).delete();
  }

  CollectionReference<Map<String, dynamic>> _collection(String businessId) {
    return (_firestore ??= FirebaseFirestore.instance)
        .collection('businesses')
        .doc(businessId)
        .collection('policies');
  }
}
