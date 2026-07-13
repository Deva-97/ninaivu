import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';

typedef LifecycleResumeCallback = Future<void> Function();
typedef LifecycleBackgroundCallback = void Function();
typedef LifecycleErrorReporter =
    Future<void> Function(Object error, StackTrace stackTrace, String reason);

class AppLifecycleService with WidgetsBindingObserver {
  AppLifecycleService({
    required LifecycleResumeCallback onResume,
    LifecycleBackgroundCallback? onBackground,
    LifecycleErrorReporter? errorReporter,
  }) : _onResume = onResume,
       _onBackground = onBackground,
       _errorReporter = errorReporter ?? _defaultErrorReporter;

  final LifecycleResumeCallback _onResume;
  final LifecycleBackgroundCallback? _onBackground;
  final LifecycleErrorReporter _errorReporter;

  bool _started = false;
  Future<void>? _activeResumeOperation;

  void start() {
    if (_started) {
      return;
    }

    WidgetsBinding.instance.addObserver(this);
    _started = true;
  }

  void stop() {
    if (!_started) {
      return;
    }

    WidgetsBinding.instance.removeObserver(this);
    _started = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_started) {
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _onBackground?.call();
    }

    if (state == AppLifecycleState.resumed) {
      unawaited(_handleResume());
    }
  }

  Future<void> _handleResume() async {
    final activeOperation = _activeResumeOperation;
    if (activeOperation != null) {
      return activeOperation;
    }

    final operation = _runResumeCallback();
    _activeResumeOperation = operation;

    try {
      await operation;
    } finally {
      if (identical(_activeResumeOperation, operation)) {
        _activeResumeOperation = null;
      }
    }
  }

  Future<void> _runResumeCallback() async {
    try {
      await _onResume();
    } catch (error, stackTrace) {
      await _errorReporter(error, stackTrace, 'App resume handling failed');
    }
  }

  static Future<void> _defaultErrorReporter(
    Object error,
    StackTrace stackTrace,
    String reason,
  ) async {
    FirebaseCrashlytics.instance.log('$reason: $error');
    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: false,
    );
  }
}
