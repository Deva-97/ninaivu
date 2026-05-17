import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ninaivu/core/constants/app_constants.dart';
import 'package:ninaivu/core/constants/app_strings.dart';
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
      _showError('Enter a valid 10-digit mobile number');
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

  AuthService get _authService => widget._authService ?? AuthService();

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final responsive = context.responsive;

    return Scaffold(
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _isLoading,
          child: ResponsiveContent(
            child: ListView(
              padding: EdgeInsets.all(responsive.pagePadding),
              children: [
                SizedBox(height: responsive.scaled(48, min: 28)),
                AppLogo(
                  size: responsive.scaled(164, min: 124),
                  semanticLabel: AppConstants.appName,
                ),
                SizedBox(height: responsive.scaled(20, min: 16)),
                Text(
                  AppStrings.loginTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: responsive.headlineSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: responsive.scaled(8, min: 6)),
                Text(
                  AppStrings.loginSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                SizedBox(height: responsive.scaled(40, min: 24)),
                TextField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    hintText: 'Enter 10-digit mobile number',
                    prefixText: '+91 ',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                SizedBox(height: responsive.itemGap),
                SizedBox(
                  height: responsive.buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: _continueWithMobile,
                    icon: const Icon(Icons.phone_android_rounded),
                    label: const Text('Continue with Mobile Number'),
                  ),
                ),
                SizedBox(height: responsive.itemGap),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.scaled(12, min: 8),
                      ),
                      child: Text(
                        'OR',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
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
                    icon: Icon(
                      Icons.g_mobiledata_rounded,
                      size: responsive.scaled(32, min: 24),
                    ),
                    label: const Text('Continue with Google'),
                  ),
                ),
                SizedBox(height: responsive.scaled(12, min: 10)),
                Text(
                  AppStrings.googleConsentNote,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: responsive.helperTextSize,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: responsive.scaled(28, min: 20)),
                if (_isLoading) const Center(child: CircularProgressIndicator()),
                SizedBox(height: responsive.scaled(32, min: 24)),
                Text(
                  'By continuing, you agree to use Ninaivu for authorized insurance business access only.',
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
