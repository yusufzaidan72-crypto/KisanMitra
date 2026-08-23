import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/utils.dart';
import '../../widgets/common/app_widgets.dart';
import '../../localization/app_localizations.dart';
import '../../providers/farmer_provider.dart';
import '../../providers/app_providers.dart';
import '../../models/farmer_profile.dart';
import '../../core/constants/app_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String? _selectedState;
  bool _obscurePassword = true;
  bool _isRegistering = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    bool success;

    if (_isRegistering) {
      success = await authProvider.signUp(
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
      if (success && mounted) {
        final uid = authProvider.user?.uid ?? '';
        final nameInput = _nameCtrl.text.trim();
        final farmerProvider = context.read<FarmerProvider>();
        final cropProvider = context.read<CropMonitorProvider>();

        // Clear local crops cache for new user registration
        await cropProvider.clearCrops();

        await farmerProvider.saveProfile(FarmerProfile(
          id: uid,
          name: nameInput.isNotEmpty ? nameInput : 'Kisan',
          location: _locationCtrl.text.trim(),
          state: _selectedState ?? '',
          preferredLanguage: 'hi',
          soilType: '',
          farmSizeInAcres: 0.0,
          currentCrop: '',
        ));
      }
    } else {
      success = await authProvider.signIn(
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
      if (success && mounted) {
        final uid = authProvider.user?.uid;
        final farmerProvider = context.read<FarmerProvider>();
        final cropProvider = context.read<CropMonitorProvider>();

        // Fetch both profile and crops from Firestore for logged in user
        await farmerProvider.loadProfileForUser(uid);
        await cropProvider.loadCropsForUser(uid);
      }
    }

    if (success && mounted) {
      // Handled by AuthWrapper in main.dart
    } else if (authProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address to reset password.')),
      );
      return;
    }
    
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendPasswordReset(email);
    
    if (mounted) {
      if (success) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Reset Email Sent'),
            content: Text('A password reset link has been sent to $email. Please check your inbox.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Failed to send reset email.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.appName,
                    style: AppTextStyles.displaySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isRegistering ? 'Create your farmer account' : 'Welcome back, Farmer!',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  AppCard(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isRegistering) ...[
                          AppTextField(
                            label: 'Farmer Name',
                            hint: 'Enter your full name',
                            controller: _nameCtrl,
                            prefixIcon: const Icon(Icons.person_outline),
                            validator: (v) => (v == null || v.isEmpty) ? 'Name required' : null,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            label: 'Village / Location',
                            hint: 'Enter your village name',
                            controller: _locationCtrl,
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            validator: (v) => (v == null || v.isEmpty) ? 'Location required' : null,
                          ),
                          const SizedBox(height: 14),
                          AppDropdown<String>(
                            label: 'Select State',
                            value: _selectedState,
                            items: AppConstants.indianStates,
                            itemLabel: (s) => s,
                            prefixIcon: const Icon(Icons.map_outlined),
                            onChanged: (v) => setState(() => _selectedState = v),
                            validator: (v) => v == null ? 'State required' : null,
                          ),
                          const SizedBox(height: 14),
                        ],
                        AppTextField(
                          label: 'Email Address',
                          hint: 'Enter your email',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: (v) => (v == null || !v.contains('@')) ? 'Invalid email' : null,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (v) => (v == null || v.length < 6) ? 'Password too short' : null,
                        ),
                        if (!_isRegistering)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _handleForgotPassword,
                              child: const Text('Forgot Password?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        const SizedBox(height: 24),
                        AppButton(
                          label: _isRegistering ? 'CREATE ACCOUNT' : 'LOGIN',
                          onPressed: _handleSubmit,
                          isLoading: authProvider.isLoading,
                          width: double.infinity,
                          icon: _isRegistering ? Icons.person_add_outlined : Icons.login_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => setState(() => _isRegistering = !_isRegistering),
                    child: Text(
                      _isRegistering ? 'Already have an account? Login' : 'Don\'t have an account? Register',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
