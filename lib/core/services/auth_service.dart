import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ninaivu/core/database/database_tables.dart';
import 'package:ninaivu/core/services/background_sync_service.dart';
import 'package:ninaivu/core/services/app_preferences.dart';
import 'package:ninaivu/core/services/sync_service.dart';
import 'package:ninaivu/data/datasources/local/sync_queue_local_data_source.dart';
import 'package:ninaivu/data/datasources/local/user_local_data_source.dart';
import 'package:ninaivu/data/datasources/remote/user_remote_data_source.dart';
import 'package:ninaivu/data/models/app_user_model.dart';
import 'package:ninaivu/data/models/sync_queue_model.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';
import 'package:uuid/uuid.dart';

class OtpSendResult {
  final String verificationId;
  final int? resendToken;

  const OtpSendResult({
    required this.verificationId,
    required this.resendToken,
  });
}

class AuthService {
  final FirebaseAuth firebaseAuth;
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
  }) : firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       userLocalDataSource = userLocalDataSource ?? UserLocalDataSource(),
       userRemoteDataSource = userRemoteDataSource ?? UserRemoteDataSource(),
       _syncQueueLocalDataSource =
           syncQueueLocalDataSource ?? SyncQueueLocalDataSource(),
       _syncService = syncService ?? SyncService(),
       _uuid = uuid ?? const Uuid();

  User? get currentUser => firebaseAuth.currentUser;

  Future<void> checkAuthFromSplash() async {
    await Future.delayed(const Duration(seconds: 1));

    final user = firebaseAuth.currentUser;
    if (user == null) {
      final preferences = await AppPreferences.getInstance();
      await preferences.clearSession();
      await BackgroundSyncService.instance.cancelAllTasks();
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    await checkUserAfterLogin();
  }

  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Google sign-in did not return an ID token');
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await firebaseAuth.signInWithCredential(credential);
      await checkUserAfterLogin();
    } on GoogleSignInException catch (e) {
      throw Exception(e.description ?? 'Google login failed');
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e, fallback: 'Google login failed'));
    } catch (e) {
      final message = _errorMessage(e);
      if (_looksLikeGoogleReauthIssue(message)) {
        try {
          await GoogleSignIn.instance.signOut();
          final googleUser = await GoogleSignIn.instance.authenticate();
          final googleAuth = googleUser.authentication;
          final idToken = googleAuth.idToken;

          if (idToken == null || idToken.isEmpty) {
            throw Exception('Google sign-in did not return an ID token');
          }

          final credential = GoogleAuthProvider.credential(idToken: idToken);
          await firebaseAuth.signInWithCredential(credential);
          await checkUserAfterLogin();
          return;
        } on GoogleSignInException catch (retryError) {
          throw Exception(retryError.description ?? 'Google login failed');
        } on FirebaseAuthException catch (retryError) {
          throw Exception(
            _friendlyAuthError(retryError, fallback: 'Google login failed'),
          );
        } catch (retryError) {
          throw Exception(_errorMessage(retryError));
        }
      }

      throw Exception(message);
    }
  }

  Future<void> sendOtp({required String mobileNumber}) async {
    final completer = Completer<void>();
    final formattedNumber = _formatIndianPhoneNumber(mobileNumber);

    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: formattedNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await firebaseAuth.signInWithCredential(credential);
          await checkUserAfterLogin();
          if (!completer.isCompleted) {
            completer.complete();
          }
        } on FirebaseAuthException catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(
              Exception(
                _friendlyAuthError(e, fallback: 'OTP verification failed'),
              ),
            );
          }
        } catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(Exception(_errorMessage(e)));
          }
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(
            Exception(_friendlyAuthError(e, fallback: 'OTP sending failed')),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        Get.toNamed(
          AppRoutes.otpVerification,
          arguments: {
            'verificationId': verificationId,
            'mobileNumber': mobileNumber,
            'resendToken': resendToken,
          },
        );
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

    return completer.future;
  }

  Future<OtpSendResult> resendOtp({
    required String mobileNumber,
    required int? resendToken,
  }) async {
    final completer = Completer<OtpSendResult>();
    final formattedNumber = _formatIndianPhoneNumber(mobileNumber);

    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: formattedNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: resendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await firebaseAuth.signInWithCredential(credential);
          await checkUserAfterLogin();
          if (!completer.isCompleted) {
            completer.complete(
              OtpSendResult(verificationId: '', resendToken: resendToken),
            );
          }
        } on FirebaseAuthException catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(
              Exception(
                _friendlyAuthError(e, fallback: 'OTP verification failed'),
              ),
            );
          }
        } catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(Exception(_errorMessage(e)));
          }
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(
            Exception(_friendlyAuthError(e, fallback: 'OTP resend failed')),
          );
        }
      },
      codeSent: (String verificationId, int? newResendToken) {
        if (!completer.isCompleted) {
          completer.complete(
            OtpSendResult(
              verificationId: verificationId,
              resendToken: newResendToken,
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

    return completer.future;
  }

  Future<void> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await firebaseAuth.signInWithCredential(credential);
      await checkUserAfterLogin();
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e, fallback: 'Invalid OTP'));
    } catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  Future<void> checkUserAfterLogin() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) {
      final preferences = await AppPreferences.getInstance();
      await preferences.clearSession();
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    final preferences = await AppPreferences.getInstance();
    final localUser = await userLocalDataSource.getUserById(firebaseUser.uid);

    if (localUser != null && localUser.profileCompleted) {
      await preferences.saveSession(
        userId: localUser.id,
        role: localUser.role,
        businessId: localUser.businessId,
      );
      await BackgroundSyncService.instance.ensureRegistered();
      _navigateByRole(localUser.role);
      return;
    }

    try {
      final remoteUser = await userRemoteDataSource.getUserById(firebaseUser.uid);
      if (remoteUser != null && remoteUser.profileCompleted) {
        await userLocalDataSource.insertOrUpdateUser(remoteUser);
        await userLocalDataSource.markUserSynced(remoteUser.id);
        await preferences.saveSession(
          userId: remoteUser.id,
          role: remoteUser.role,
          businessId: remoteUser.businessId,
        );
        await BackgroundSyncService.instance.ensureRegistered();
        _navigateByRole(remoteUser.role);
        return;
      }
    } on UserFetchUnavailableException {
      debugPrint(
        'Firestore user lookup is temporarily unavailable for ${firebaseUser.uid}.',
      );

      if (localUser != null) {
        await preferences.saveSession(
          userId: localUser.id,
          role: localUser.role,
          businessId: localUser.businessId,
        );
        await BackgroundSyncService.instance.ensureRegistered();
        Get.offAllNamed(AppRoutes.profileSetup);
        return;
      }

      throw Exception(
        'We could not verify your account right now. '
        'Please check your connection and try again.',
      );
    } on FirebaseException catch (e) {
      debugPrint(
        'Firestore user lookup failed for ${firebaseUser.uid}: ${e.code} ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('Unexpected auth lookup error for ${firebaseUser.uid}: $e');
      rethrow;
    }

    Get.offAllNamed(AppRoutes.profileSetup);
  }

  Future<String?> checkUserAfterLoginError() async {
    try {
      await checkUserAfterLogin();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Authentication failed. Please try again.';
    } on FirebaseException catch (e) {
      return e.message ?? 'Unable to reach the server right now.';
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<void> completeProfile({
    required String name,
    required String? mobile,
    required String? email,
    required String inviteCode,
  }) async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    final role = _getRoleFromInviteCode(inviteCode);
    final now = DateTime.now().millisecondsSinceEpoch;
    final user = AppUserModel(
      id: firebaseUser.uid,
      businessId: UserRemoteDataSource.defaultBusinessId,
      name: name,
      mobile: mobile,
      email: email,
      role: role,
      status: 'active',
      profileCompleted: true,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      syncStatus: 'pending_create',
      createdBy: firebaseUser.uid,
      agentId: role == 'agent' ? firebaseUser.uid : null,
    );

    await userLocalDataSource.insertOrUpdateUser(user);
    await _syncQueueLocalDataSource.enqueue(
      SyncQueueModel(
        id: _uuid.v4(),
        businessId: user.businessId,
        tableName: DatabaseTables.users,
        recordId: user.id,
        operation: 'create',
        payload: user.toMap(),
        retryCount: 0,
        createdAt: now,
        updatedAt: now,
        syncStatus: 'pending_create',
      ),
    );
    final syncedCount = await _syncService.syncPendingData();
    if (syncedCount == 0) {
      throw Exception(
        'Your profile was saved only on this device. Firebase backup did not complete yet. '
        'Please check your connection and try again.',
      );
    }

    final preferences = await AppPreferences.getInstance();
    await preferences.saveSession(
      userId: user.id,
      role: user.role,
      businessId: user.businessId,
    );
    await BackgroundSyncService.instance.ensureRegistered();

    _navigateByRole(role);
  }

  Future<void> logout() async {
    await firebaseAuth.signOut();
    await GoogleSignIn.instance.signOut();
    final preferences = await AppPreferences.getInstance();
    await preferences.clearSession();
    await BackgroundSyncService.instance.cancelAllTasks();
    Get.offAllNamed(AppRoutes.login);
  }

  String _getRoleFromInviteCode(String inviteCode) {
    final code = inviteCode.trim().toUpperCase();
    if (code == 'NINAIVU_ADMIN') {
      return 'admin';
    }
    if (code == 'NINAIVU_AGENT') {
      return 'agent';
    }
    throw Exception('Invalid invite code');
  }

  void _navigateByRole(String role) {
    switch (role) {
      case 'admin':
        Get.offAllNamed(AppRoutes.adminDashboard);
        break;
      case 'agent':
        Get.offAllNamed(AppRoutes.agentDashboard);
        break;
      default:
        Get.offAllNamed(AppRoutes.login);
    }
  }

  String _friendlyAuthError(
    FirebaseAuthException e, {
    required String fallback,
  }) {
    final code = e.code.toLowerCase();
    final message = (e.message ?? '').toLowerCase();

    if (message.contains('billing_not_enabled') ||
        code == 'billing-not-enabled' ||
        code == 'internal-error') {
      if (message.contains('billing_not_enabled')) {
        return 'Phone login is not enabled for this Firebase project yet. '
            'Enable billing in Google Cloud/Firebase for this project, then try again.';
      }
    }

    if (code == 'invalid-phone-number') {
      return 'Enter a valid mobile number with the correct country format.';
    }
    if (code == 'too-many-requests') {
      return 'Too many OTP attempts were made. Please wait a while and try again.';
    }
    if (code == 'session-expired') {
      return 'The OTP session expired. Please request a new OTP.';
    }
    if (code == 'invalid-verification-code') {
      return 'The OTP you entered is incorrect. Please try again.';
    }
    if (code == 'network-request-failed') {
      return 'Network error while contacting Firebase. Please check your connection and try again.';
    }

    return e.message ?? fallback;
  }

  String _formatIndianPhoneNumber(String mobileNumber) {
    final digitsOnly = mobileNumber.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length == 10) {
      return '+91$digitsOnly';
    }

    if (digitsOnly.length == 12 && digitsOnly.startsWith('91')) {
      return '+$digitsOnly';
    }

    if (mobileNumber.trim().startsWith('+')) {
      return mobileNumber.trim();
    }

    return '+$digitsOnly';
  }

  String _errorMessage(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }

    return error.toString();
  }

  bool _looksLikeGoogleReauthIssue(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('sign_in_failed') ||
        normalized.contains('user did not grant permission') ||
        normalized.contains('failed to recover auth') ||
        normalized.contains('canceled') ||
        normalized.contains('cancelled');
  }
}
