import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:insurance_reminders/core/services/auth_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isResending = false;

  late String _verificationId;
  late String _mobileNumber;
  int? _resendToken;

  Timer? _resendTimer;
  int _remainingSeconds = 60;

  bool get _canResend => _remainingSeconds == 0 && !_isLoading && !_isResending;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>?;

    _verificationId = args?['verificationId'] as String? ?? '';
    _mobileNumber = args?['mobileNumber'] as String? ?? '';
    _resendToken = args?['resendToken'] as int?;

    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();

    setState(() {
      _remainingSeconds = 60;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        return;
      }

      if (mounted) {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      _showError('Enter a valid 6-digit OTP');
      return;
    }

    if (_verificationId.isEmpty) {
      _showError('Verification session expired. Please resend OTP.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.verifyOtp(verificationId: _verificationId, otp: otp);
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() => _isResending = true);

    try {
      final result = await _authService.resendOtp(
        mobileNumber: _mobileNumber,
        resendToken: _resendToken,
      );

      if (!mounted) return;

      setState(() {
        if (result.verificationId.isNotEmpty) {
          _verificationId = result.verificationId;
        }
        _resendToken = result.resendToken;
        _otpController.clear();
      });

      _startResendTimer();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP resent successfully')));
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String get _resendButtonText {
    if (_isResending) {
      return 'Resending OTP...';
    }

    if (_remainingSeconds > 0) {
      return 'Resend OTP in $_remainingSeconds sec';
    }

    return 'Resend OTP';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _isLoading,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 24),

              Icon(Icons.sms_outlined, size: 72, color: colorScheme.primary),

              const SizedBox(height: 24),

              const Text(
                'OTP Verification',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                'Enter the OTP sent to +91 $_mobileNumber',
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),

              const SizedBox(height: 32),

              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  hintText: 'Enter 6-digit OTP',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _verifyOtp,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text('Verify OTP'),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _canResend ? _resendOtp : null,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(_resendButtonText),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Didn’t receive the SMS? You can request a new OTP after 60 seconds.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
