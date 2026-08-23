import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localizations.dart';
import '../../models/farmer_profile.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/farmer_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/lovable_colors.dart';
import '../../widgets/widgets.dart';

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
          backgroundColor: LovableColors.negative,
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
            title: Text('Reset Email Sent', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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
      backgroundColor: const Color(0xFFF0FDF4),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background photo
          CachedNetworkImage(
            imageUrl: LovableColors.bgImageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: const Color(0xFFD1FAE5)),
            errorWidget: (_, __, ___) => Container(color: const Color(0xFFD1FAE5)),
          ),

          // Gradient overlay
          Container(
            decoration: const BoxDecoration(gradient: LovableColors.bgOverlay),
          ),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Badge
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LovableColors.ctaGradient,
                            shape: BoxShape.circle,
                            boxShadow: LovableColors.shadowGlow,
                          ),
                          child: const Center(
                            child: Icon(
                              LucideIcons.sprout,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l.appName,
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: LovableColors.forest,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isRegistering ? 'Create your farmer account' : 'Welcome back, Farmer!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: LovableColors.slateGreen,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Form Card in Glassmorphism
                        LovableGlassCard(
                          strong: true,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_isRegistering) ...[
                                AppTextField(
                                  label: 'Farmer Name',
                                  hint: 'Enter your full name',
                                  controller: _nameCtrl,
                                  prefixIcon: const Icon(LucideIcons.user, size: 18),
                                  validator: (v) => (v == null || v.isEmpty) ? 'Name required' : null,
                                ),
                                const SizedBox(height: 14),
                                AppTextField(
                                  label: 'Village / Location',
                                  hint: 'Enter your village name',
                                  controller: _locationCtrl,
                                  prefixIcon: const Icon(LucideIcons.mapPin, size: 18),
                                  validator: (v) => (v == null || v.isEmpty) ? 'Location required' : null,
                                ),
                                const SizedBox(height: 14),
                                AppDropdown<String>(
                                  label: 'Select State',
                                  value: _selectedState,
                                  items: AppConstants.indianStates,
                                  itemLabel: (s) => s,
                                  prefixIcon: const Icon(LucideIcons.map, size: 18),
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
                                prefixIcon: const Icon(LucideIcons.mail, size: 18),
                                validator: (v) => (v == null || !v.contains('@')) ? 'Invalid email' : null,
                              ),
                              const SizedBox(height: 14),
                              AppTextField(
                                label: 'Password',
                                hint: 'Enter your password',
                                controller: _passwordCtrl,
                                obscureText: _obscurePassword,
                                prefixIcon: const Icon(LucideIcons.lock, size: 18),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                    color: LovableColors.slateGreen,
                                    size: 18,
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
                                    child: Text(
                                      'Forgot Password?',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: LovableColors.forest,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              if (authProvider.isLoading)
                                const Center(
                                  child: CircularProgressIndicator(color: LovableColors.emeraldAccent),
                                )
                              else
                                CtaButton(
                                  label: _isRegistering ? 'CREATE ACCOUNT' : 'LOGIN',
                                  icon: _isRegistering ? LucideIcons.userPlus : LucideIcons.logIn,
                                  width: double.infinity,
                                  onTap: _handleSubmit,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Toggle Register / Login
                        TextButton(
                          onPressed: () => setState(() => _isRegistering = !_isRegistering),
                          child: Text(
                            _isRegistering ? 'Already have an account? Login' : 'Don\'t have an account? Register',
                            style: GoogleFonts.plusJakartaSans(
                              color: LovableColors.forest,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
