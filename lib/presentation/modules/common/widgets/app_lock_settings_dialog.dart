import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/services/app_lock_service.dart';

class AppLockSettingsDialog extends StatefulWidget {
  const AppLockSettingsDialog({super.key});

  @override
  State<AppLockSettingsDialog> createState() => _AppLockSettingsDialogState();
}

class _AppLockSettingsDialogState extends State<AppLockSettingsDialog> {
  final AppLockService _appLockService = Get.find<AppLockService>();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _enableBiometric = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _enableBiometric = _appLockService.isBiometricEnabled.value;
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('App Lock'),
      content: Obx(() {
        if (_appLockService.isEnabled.value) {
          return const Text(
            'App lock is currently enabled on this device. You can keep using your PIN and biometric unlock, or disable it below.',
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Set a 4-digit PIN for local privacy protection.'),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              maxLength: 4,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New PIN',
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPinController,
              maxLength: 4,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Confirm PIN',
                counterText: '',
                errorText: _errorText,
              ),
            ),
            if (_appLockService.isBiometricAvailable.value)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Use biometric unlock'),
                value: _enableBiometric,
                onChanged: (value) => setState(() => _enableBiometric = value),
              ),
          ],
        );
      }),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        Obx(() {
          if (_appLockService.isEnabled.value) {
            return FilledButton(
              onPressed: () async {
                await _appLockService.disable();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Disable'),
            );
          }

          return FilledButton(
            onPressed: _save,
            child: const Text('Enable'),
          );
        }),
      ],
    );
  }

  Future<void> _save() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();
    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      setState(() => _errorText = 'PIN must be exactly 4 digits');
      return;
    }
    if (pin != confirmPin) {
      setState(() => _errorText = 'PIN confirmation does not match');
      return;
    }

    await _appLockService.savePin(
      pin: pin,
      enableBiometric: _enableBiometric,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
