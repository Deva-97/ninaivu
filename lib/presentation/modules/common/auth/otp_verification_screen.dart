import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/services/auth_service.dart';
import 'package:ninaivu/core/widgets/responsive_layout.dart';

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
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _isLoading,
          child: ResponsiveContent(
            child: ListView(
              padding: EdgeInsets.all(responsive.pagePadding),
              children: [
                SizedBox(height: responsive.sectionGap),
                Icon(
                  Icons.sms_outlined,
                  size: responsive.heroIconSize,
                  color: colorScheme.primary,
                ),
                SizedBox(height: responsive.sectionGap),
                Text(
                  'OTP Verification',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: responsive.titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: responsive.scaled(8, min: 6)),
                Text(
                  'Enter the OTP sent to +91 $_mobileNumber',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                SizedBox(height: responsive.scaled(32, min: 24)),
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
                SizedBox(height: responsive.scaled(20, min: 16)),
                SizedBox(
                  height: responsive.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _verifyOtp,
                    child: _isLoading
                        ? SizedBox(
                            width: responsive.scaled(22, min: 18),
                            height: responsive.scaled(22, min: 18),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text('Verify OTP'),
                  ),
                ),
                SizedBox(height: responsive.itemGap),
                SizedBox(
                  height: responsive.compactButtonHeight,
                  child: OutlinedButton.icon(
                    onPressed: _canResend ? _resendOtp : null,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(_resendButtonText),
                  ),
                ),
                SizedBox(height: responsive.itemGap),
                Text(
                  'Didn\'t receive the SMS? You can request a new OTP after 60 seconds.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: responsive.helperTextSize,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
