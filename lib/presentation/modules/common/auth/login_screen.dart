import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/constants/app_constants.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/services/auth_service.dart';
import 'package:ninaivu/core/widgets/app_logo.dart';
import 'package:ninaivu/core/widgets/responsive_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    AuthService? authService,
    Future<void> Function()? onGoogleSignIn,
    Future<void> Function(String mobileNumber)? onSendOtp,
  }) : _authService = authService,
       _onGoogleSignIn = onGoogleSignIn,
       _onSendOtp = onSendOtp;

  final AuthService? _authService;
  final Future<void> Function()? _onGoogleSignIn;
  final Future<void> Function(String mobileNumber)? _onSendOtp;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  AuthService get _authService => widget._authService ?? AuthService();

  Future<void> _continueWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      if (widget._onGoogleSignIn != null) {
        await widget._onGoogleSignIn!.call();
      } else {
        await _authService.signInWithGoogle();
      }
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _continueWithMobile() async {
    final mobile = _mobileController.text.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
      _showError(TranslationKeys.enterValid10DigitMobile.tr);
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (widget._onSendOtp != null) {
        await widget._onSendOtp!.call(mobile);
      } else {
        await _authService.sendOtp(mobileNumber: mobile);
      }
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _isLoading,
          child: ResponsiveContent(
            child: ListView(
              padding: EdgeInsets.all(responsive.pagePadding),
              children: [
                SizedBox(height: responsive.scaled(28, min: 20)),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(responsive.scaled(22, min: 18)),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: AppLogo(
                      size: responsive.scaled(132, min: 112),
                      semanticLabel: AppConstants.appName,
                    ),
                  ),
                ),
                SizedBox(height: responsive.scaled(24, min: 20)),
                Text(
                  TranslationKeys.loginTitle.tr,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                SizedBox(height: responsive.scaled(8, min: 6)),
                Text(
                  TranslationKeys.loginSubtitle.tr,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(height: responsive.sectionGap),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(responsive.pagePadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TranslationKeys.mobileNumber.tr,
                          style: theme.textTheme.titleMedium,
                        ),
                        SizedBox(height: responsive.scaled(14, min: 12)),
                        TextField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            labelText: TranslationKeys.mobileNumber.tr,
                            hintText: TranslationKeys.enter10DigitMobile.tr,
                            prefixText: '+91 ',
                            counterText: '',
                          ),
                        ),
                        SizedBox(height: responsive.itemGap),
                        SizedBox(
                          height: responsive.buttonHeight,
                          child: ElevatedButton.icon(
                            onPressed: _continueWithMobile,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: Text(TranslationKeys.continueWithMobile.tr),
                          ),
                        ),
                        SizedBox(height: responsive.itemGap),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                TranslationKeys.orLabel.tr,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        SizedBox(height: responsive.itemGap),
                        SizedBox(
                          height: responsive.buttonHeight,
                          child: OutlinedButton.icon(
                            onPressed: _continueWithGoogle,
                            icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                            label: Text(TranslationKeys.continueWithGoogle.tr),
                          ),
                        ),
                        SizedBox(height: responsive.scaled(12, min: 10)),
                        Text(
                          TranslationKeys.googleConsentNote.tr,
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isLoading) ...[
                  SizedBox(height: responsive.sectionGap),
                  const Center(child: CircularProgressIndicator()),
                ],
                SizedBox(height: responsive.sectionGap),
                Text(
                  TranslationKeys.authorizedBusinessUseOnly.tr,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
