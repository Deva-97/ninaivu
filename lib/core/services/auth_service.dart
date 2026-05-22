import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ninaivu/core/database/database_tables.dart';
import 'package:ninaivu/core/services/app_preferences.dart';
import 'package:ninaivu/core/services/background_sync_service.dart';
import 'package:ninaivu/core/services/sync_service.dart';
import 'package:ninaivu/data/datasources/local/sync_queue_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/user_local_data_source.dart';
import 'package:ninaivu/data/datasources/remote/user_remote_data_source.dart';
import 'package:ninaivu/data/models/app_user_model.dart';
import 'package:ninaivu/data/models/sync_queue_model.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';
import 'package:uuid/uuid.dart';

part 'auth_service_bootstrap.dart';
part 'auth_service_google.dart';
part 'auth_service_helpers.dart';
part 'auth_service_phone.dart';
part 'auth_service_profile.dart';
part 'auth_service_session.dart';

/// Minimal result object used by the OTP screen when Firebase issues a new
/// verification id and resend token pair.
class OtpSendResult {
  final String verificationId;
  final int? resendToken;

  const OtpSendResult({
    required this.verificationId,
    required this.resendToken,
  });
}

/// Coordinates sign-in, profile completion, and local session bootstrap.
///
/// The service prefers local user data when available, falls back to Firestore
/// when needed, and then routes the user to the correct entry screen.
class AuthService {
  static const String _googleServerClientId =
      '302492772767-kjt4v9mmk9dh3n447alcadrumhi2qlq2.apps.googleusercontent.com';
  static Future<void>? _googleSignInInitialization;

  final FirebaseAuth? firebaseAuth;
  final UserLocalDataSource userLocalDataSource;
  final UserRemoteDataSource userRemoteDataSource;
  final SyncQueueLocalDataSource _syncQueueLocalDataSource;
  final SyncService _syncService;
  final Uuid _uuid;

  AuthService({
    FirebaseAuth? firebaseAuth,
    UserLocalDataSource? userLocalDataSource,
    UserRemoteDataSource? userRemoteDataSource,
    SyncQueueLocalDataSource? syncQueueLocalDataSource,
    SyncService? syncService,
    Uuid? uuid,
  }) : firebaseAuth = firebaseAuth ?? _safeFirebaseAuthInstance(),
       userLocalDataSource = userLocalDataSource ?? UserLocalDataSource(),
       userRemoteDataSource = userRemoteDataSource ?? UserRemoteDataSource(),
       _syncQueueLocalDataSource =
           syncQueueLocalDataSource ?? SyncQueueLocalDataSource(),
       _syncService = syncService ?? SyncService(),
       _uuid = uuid ?? const Uuid();

  User? get currentUser => firebaseAuth?.currentUser;

  Future<void> checkAuthFromSplash() => _checkAuthFromSplash();

  Future<void> signInWithGoogle() => _signInWithGoogle();

  Future<void> sendOtp({required String mobileNumber}) =>
      _sendOtp(mobileNumber: mobileNumber);

  Future<OtpSendResult> resendOtp({
    required String mobileNumber,
    required int? resendToken,
  }) => _resendOtp(mobileNumber: mobileNumber, resendToken: resendToken);

  Future<void> verifyOtp({
    required String verificationId,
    required String otp,
  }) => _verifyOtp(verificationId: verificationId, otp: otp);

  Future<void> checkUserAfterLogin() => _checkUserAfterLogin();

  Future<String?> checkUserAfterLoginError() => _checkUserAfterLoginError();

  Future<void> completeProfile({
    required String name,
    required String? mobile,
    required String? email,
    required String inviteCode,
  }) => _completeProfile(
    name: name,
    mobile: mobile,
    email: email,
    inviteCode: inviteCode,
  );

  Future<void> logout() => _logout();
}
