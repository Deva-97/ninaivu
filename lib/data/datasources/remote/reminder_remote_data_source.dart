import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ninaivu/data/models/reminder_model.dart';

class ReminderRemoteDataSource {
  ReminderRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> upsertReminder(ReminderModel reminder) async {
    await _collection(reminder.businessId).doc(reminder.id).set(
      reminder.toFirestore(),
      SetOptions(merge: true),
    );
  }

  Future<void> deleteReminder({
    required String businessId,
    required String reminderId,
  }) async {
    await _collection(businessId).doc(reminderId).delete();
  }

  CollectionReference<Map<String, dynamic>> _collection(String businessId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('reminders');
  }
}
