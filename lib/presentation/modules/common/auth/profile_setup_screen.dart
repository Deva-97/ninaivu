import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ninaivu/core/services/auth_service.dart';
import 'package:ninaivu/core/widgets/responsive_layout.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _inviteCodeController = TextEditingController();

  bool _isLoading = false;

  User? get _firebaseUser {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    final user = _firebaseUser;

    _nameController.text = user?.displayName ?? '';
    _emailController.text = user?.email ?? '';

    final phoneNumber = user?.phoneNumber;
    if (phoneNumber != null && phoneNumber.startsWith('+91')) {
      _mobileController.text = phoneNumber.replaceFirst('+91', '');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _completeProfile() async {
    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final email = _emailController.text.trim();
    final inviteCode = _inviteCodeController.text.trim();

    if (name.length < 2) {
      _showError('Enter a valid name');
      return;
    }

    if (mobile.isNotEmpty && mobile.length != 10) {
      _showError('Enter a valid 10-digit mobile number');
      return;
    }

    if (inviteCode.isEmpty) {
      _showError('Enter invite code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.completeProfile(
        name: name,
        mobile: mobile.isEmpty ? null : mobile,
        email: email.isEmpty ? null : email,
        inviteCode: inviteCode,
      );
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
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _isLoading,
          child: ResponsiveContent(
            child: ListView(
              padding: EdgeInsets.all(responsive.pagePadding),
              children: [
                SizedBox(height: responsive.itemGap),
                Icon(
                  Icons.person_add_alt_1_rounded,
                  size: responsive.heroIconSize,
                  color: colorScheme.primary,
                ),
                SizedBox(height: responsive.scaled(20, min: 16)),
                Text(
                  'Complete your profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: responsive.titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: responsive.scaled(8, min: 6)),
                Text(
                  'We need a few details to set up your Ninaivu account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                SizedBox(height: responsive.scaled(32, min: 24)),
                TextField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: responsive.itemGap),
                TextField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    hintText: 'Optional for Google login',
                    prefixText: '+91 ',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                SizedBox(height: responsive.itemGap),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Optional for mobile login',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: responsive.itemGap),
                TextField(
                  controller: _inviteCodeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Invite Code',
                    hintText: 'Example: NINAIVU_ADMIN / NINAIVU_AGENT',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: responsive.sectionGap),
                SizedBox(
                  height: responsive.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _completeProfile,
                    child: const Text('Complete Setup'),
                  ),
                ),
                SizedBox(height: responsive.sectionGap),
                if (_isLoading) const Center(child: CircularProgressIndicator()),
                SizedBox(height: responsive.itemGap),
                Text(
                  'For testing use NINAIVU_ADMIN or NINAIVU_AGENT. Later, invite codes should be generated by the admin.',
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
