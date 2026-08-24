import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localizations.dart';
import '../../models/farmer_profile.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/farmer_provider.dart';
import '../../utils/agri_image_helper.dart';
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
  
  // Instant Name Login controller for quick access
  final _quickNameCtrl = TextEditingController();

  String? _selectedState;
  bool _obscurePassword = true;
  bool _isRegistering = false;
  bool _isQuickLogin = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _quickNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleQuickNameLogin() async {
    final nameInput = _quickNameCtrl.text.trim();
    final nameToUse = nameInput.isNotEmpty ? nameInput : 'Kisan Mitra';

    final farmerProvider = context.read<FarmerProvider>();
    final cropProvider = context.read<CropMonitorProvider>();

    await farmerProvider.clearProfile();
    await cropProvider.clearCrops();

    final freshProfile = FarmerProfile(
      id: 'quick_${DateTime.now().millisecondsSinceEpoch}',
      name: nameToUse,
      location: 'Nashik',
      state: 'Maharashtra',
      preferredLanguage: context.read<LanguageProvider>().languageCode,
      soilType: 'Black Soil',
      farmSizeInAcres: 2.0,
      currentCrop: 'Wheat',
    );

    await farmerProvider.saveProfile(freshProfile);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    }
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
          preferredLanguage: context.read<LanguageProvider>().languageCode,
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
      Navigator.pushReplacementNamed(context, '/main');
    } else if (authProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: LovableColors.negative,
        ),
      );
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
          // Agriculture background photo using AgriImage
          const AgriImage(
            keywordOrUrl: 'farm',
            fit: BoxFit.cover,
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
                          _isQuickLogin
                              ? 'नाम डालकर सीधे प्रवेश करें'
                              : (_isRegistering ? 'Create your farmer account' : 'Welcome back, Farmer!'),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: LovableColors.slateGreen,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Form Card in Glassmorphism
                        LovableGlassCard(
                          strong: true,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_isQuickLogin) ...[
                                Text(
                                  'अपना नाम दर्ज करें / Enter Name',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: LovableColors.forest,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                AppTextField(
                                  label: 'किसान का नाम',
                                  hint: 'उदा. रमेश कुमार / Ramesh Kumar',
                                  controller: _quickNameCtrl,
                                  prefixIcon: const Icon(LucideIcons.user, size: 18),
                                ),
                                const SizedBox(height: 20),
                                CtaButton(
                                  label: 'वेबसाइट में प्रवेश करें / ENTER WEBSITE',
                                  icon: LucideIcons.arrowRight,
                                  width: double.infinity,
                                  onTap: _handleQuickNameLogin,
                                ),
                              ] else ...[
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
                                const SizedBox(height: 20),
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Toggle Quick Name Login vs Email Login
                        GlassOutlineButton(
                          label: _isQuickLogin
                              ? 'ईमेल व पासवर्ड से लॉगिन करें'
                              : 'नाम डालकर तुरंत प्रवेश करें (Instant Name Login)',
                          trailingIcon: LucideIcons.sparkles,
                          onTap: () => setState(() => _isQuickLogin = !_isQuickLogin),
                        ),
                        const SizedBox(height: 12),

                        // Toggle Register / Login
                        if (!_isQuickLogin)
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
