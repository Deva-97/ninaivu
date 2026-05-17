import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ninaivu/core/services/app_lifecycle_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLifecycleService', () {
    test('runs resume callback when app resumes', () async {
      var resumeCalls = 0;
      final service = AppLifecycleService(
        onResume: () async {
          resumeCalls++;
        },
      );

      service.start();
      service.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future<void>.delayed(Duration.zero);
      service.stop();

      expect(resumeCalls, 1);
    });

    test('does not overlap resume work on repeated resumed events', () async {
      var resumeCalls = 0;
      final completer = Completer<void>();
      final service = AppLifecycleService(
        onResume: () async {
          resumeCalls++;
          await completer.future;
        },
      );

      service.start();
      service.didChangeAppLifecycleState(AppLifecycleState.resumed);
      service.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future<void>.delayed(Duration.zero);

      expect(resumeCalls, 1);

      completer.complete();
      await Future<void>.delayed(Duration.zero);
      service.stop();
    });

    test('captures resume callback failures instead of throwing', () async {
      Object? reportedError;
      String? reportedReason;
      final service = AppLifecycleService(
        onResume: () async {
          throw StateError('boom');
        },
        errorReporter: (error, stackTrace, reason) async {
          reportedError = error;
          reportedReason = reason;
        },
      );

      service.start();
      service.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future<void>.delayed(Duration.zero);
      service.stop();

      expect(reportedError, isA<StateError>());
      expect(reportedReason, 'App resume handling failed');
    });
  });
}
