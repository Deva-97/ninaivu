import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurance_reminders/core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
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
      await _authService.signInWithGoogle();
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
      await _authService.sendOtp(mobileNumber: mobile);
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _isLoading,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 48),

              Icon(Icons.shield_outlined, size: 72, color: colorScheme.primary),

              const SizedBox(height: 20),

              const Text(
                'Welcome to Ninaivu',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                'Manage clients, policies, renewals and follow-ups in one place.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),

              const SizedBox(height: 40),

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

              const SizedBox(height: 16),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _continueWithMobile,
                  icon: const Icon(Icons.phone_android_rounded),
                  label: const Text('Continue with Mobile Number'),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _continueWithGoogle,
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 32),
                  label: const Text('Continue with Google'),
                ),
              ),

              const SizedBox(height: 28),

              if (_isLoading) const Center(child: CircularProgressIndicator()),

              const SizedBox(height: 32),

              Text(
                'By continuing, you agree to use Ninaivu for authorized insurance business access only.',
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
