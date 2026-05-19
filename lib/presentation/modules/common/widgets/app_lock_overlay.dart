import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/services/app_lock_service.dart';

class AppLockOverlay extends StatefulWidget {
  const AppLockOverlay({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AppLockOverlay> createState() => _AppLockOverlayState();
}

class _AppLockOverlayState extends State<AppLockOverlay> {
  final TextEditingController _pinController = TextEditingController();
  final AppLockService _appLockService = Get.find<AppLockService>();
  String? _errorText;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!_appLockService.isEnabled.value || !_appLockService.isLocked.value) {
        return widget.child;
      }
      final biometricAvailable =
          _appLockService.isBiometricEnabled.value &&
          _appLockService.isBiometricAvailable.value;

      return Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          ColoredBox(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Card(
                  margin: const EdgeInsets.all(24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'App Locked',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text('Use biometric or enter your 4-digit PIN to continue.'),
                        const SizedBox(height: 20),
                        if (biometricAvailable) ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _unlockWithBiometric,
                              icon: const Icon(Icons.fingerprint),
                              label: const Text('Use biometric'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'or',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                        ],
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Use PIN',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pinController,
                          maxLength: 4,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'PIN',
                            errorText: _errorText,
                            counterText: '',
                          ),
                          onSubmitted: (_) => _unlockWithPin(),
                        ),
                        const SizedBox(height: 12),
                        if (!biometricAvailable &&
                            _appLockService.isBiometricEnabled.value &&
                            _errorText != null) ...[
                          Text(
                            _errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        FilledButton(
                          onPressed: _unlockWithPin,
                          child: const Text('Unlock'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  // PIN verification stays local and never touches auth/session state.
  void _unlockWithPin() {
    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      setState(() => _errorText = 'Enter your 4-digit PIN');
      return;
    }
    final isValid = _appLockService.verifyPin(pin);
    setState(() => _errorText = isValid ? null : 'Incorrect PIN');
    if (isValid) {
      _pinController.clear();
    }
  }

  Future<void> _unlockWithBiometric() async {
    final isValid = await _appLockService.unlockWithBiometric();
    if (!isValid && mounted) {
      setState(() => _errorText = 'Biometric unlock was not completed');
    }
  }
}
