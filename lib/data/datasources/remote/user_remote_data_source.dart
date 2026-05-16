import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:insurance_reminders/data/models/app_user_model.dart';

class UserFetchUnavailableException implements Exception {
  const UserFetchUnavailableException();

  @override
  String toString() => 'User data is temporarily unavailable.';
}

class UserRemoteDataSource {
  UserRemoteDataSource({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore firestore;

  static const String defaultBusinessId = 'default_business';

  Future<AppUserModel?> getUserById(String userId) async {
    FirebaseException? lastError;

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final doc = await _userCollection(defaultBusinessId).doc(userId).get();
        if (!doc.exists || doc.data() == null) {
          return null;
        }

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

  Future<void> upsertUser(AppUserModel user) async {
    await _userCollection(user.businessId).doc(user.id).set(
      user.toFirestore(),
      SetOptions(merge: true),
    );
  }

  Future<void> createOrUpdateUser(AppUserModel user) => upsertUser(user);

  Future<void> syncUser(AppUserModel user) => upsertUser(user);

  Future<List<AppUserModel>> fetchUsersForBusiness(String businessId) async {
    final snapshot = await _userCollection(businessId).get();
    return snapshot.docs
        .map((doc) => AppUserModel.fromFirestore(doc.data()))
        .toList();
  }

  CollectionReference<Map<String, dynamic>> _userCollection(String businessId) {
    return firestore
        .collection('businesses')
        .doc(businessId)
        .collection('users');
  }

  bool _isTransientFirestoreError(FirebaseException exception) {
    return exception.code == 'unavailable' ||
        exception.code == 'deadline-exceeded' ||
        exception.code == 'resource-exhausted' ||
        exception.code == 'aborted';
  }
}
