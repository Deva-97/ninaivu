import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:insurance_reminders/data/models/app_user_model.dart';

class UserFetchUnavailableException implements Exception {
  const UserFetchUnavailableException();

  @override
  String toString() => 'User data is temporarily unavailable.';
}

class UserRemoteDataSource {
  final FirebaseFirestore firestore;

  UserRemoteDataSource({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  static const String defaultBusinessId = 'default_business';

  Future<AppUserModel?> getUserById(String userId) async {
    FirebaseException? lastError;

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final doc = await firestore
            .collection('businesses')
            .doc(defaultBusinessId)
            .collection('users')
            .doc(userId)
            .get();

        if (!doc.exists || doc.data() == null) return null;

        return AppUserModel.fromFirestore(doc.data()!);
      } on FirebaseException catch (e) {
        lastError = e;

        if (!_isTransientFirestoreError(e) || attempt == 2) {
          break;
        }

        final backoff = Duration(milliseconds: 400 * (attempt + 1));
        debugPrint(
          'Retrying Firestore user fetch for $userId after ${e.code}: '
          'attempt ${attempt + 1}',
        );
        await Future.delayed(backoff);
      }
    }

    if (lastError != null && _isTransientFirestoreError(lastError)) {
      throw const UserFetchUnavailableException();
    }

    if (lastError != null) {
      throw lastError;
    }

    return null;
  }

  Future<void> createOrUpdateUser(AppUserModel user) async {
    await firestore
        .collection('businesses')
        .doc(user.businessId)
        .collection('users')
        .doc(user.id)
        .set(user.toFirestore(), SetOptions(merge: true));
  }

  bool _isTransientFirestoreError(FirebaseException exception) {
    return exception.code == 'unavailable' ||
        exception.code == 'deadline-exceeded' ||
        exception.code == 'resource-exhausted' ||
        exception.code == 'aborted';
  }
}
