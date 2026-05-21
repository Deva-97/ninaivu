import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
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
      title: Text(TranslationKeys.appLock.tr),
      content: Obx(() {
        if (_appLockService.isEnabled.value) {
          return Text(
            TranslationKeys.appLockEnabledDescription.tr,
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(TranslationKeys.setPinDescription.tr),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              maxLength: 4,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: TranslationKeys.newPin.tr,
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
                labelText: TranslationKeys.confirmPin.tr,
                counterText: '',
                errorText: _errorText,
              ),
            ),
            if (_appLockService.isBiometricAvailable.value)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(TranslationKeys.useBiometricUnlock.tr),
                value: _enableBiometric,
                onChanged: (value) => setState(() => _enableBiometric = value),
              ),
          ],
        );
      }),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(TranslationKeys.close.tr),
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
              child: Text(TranslationKeys.disable.tr),
            );
          }

          return FilledButton(
            onPressed: _save,
            child: Text(TranslationKeys.enable.tr),
          );
        }),
      ],
    );
  }

  Future<void> _save() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();
    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      setState(() => _errorText = TranslationKeys.pinMustBeExactly4Digits.tr);
      return;
    }
    if (pin != confirmPin) {
      setState(
        () => _errorText = TranslationKeys.pinConfirmationDoesNotMatch.tr,
      );
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
