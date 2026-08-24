import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localizations.dart';
import '../../models/farmer_profile.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/farmer_provider.dart';
import '../../utils/agri_image_helper.dart';
import '../../utils/app_constants.dart';
import '../../utils/lovable_colors.dart';
import '../../utils/url_helper.dart';
import '../../widgets/widgets.dart';
import '../auth/login_screen.dart';

class FarmerProfileScreen extends StatefulWidget {
  final bool isEditing;
  const FarmerProfileScreen({super.key, this.isEditing = true});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _farmSizeCtrl = TextEditingController();

  String? _selectedState;
  String? _selectedSoilType;
  String? _selectedCrop;
  String? _selectedLanguage;

  List<LandDetail> _lands = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<FarmerProvider>().profile;
    if (profile != null) {
      _nameCtrl.text = profile.name;
      _locationCtrl.text = profile.location;
      if (profile.farmSizeInAcres > 0) {
        _farmSizeCtrl.text = profile.farmSizeInAcres.toString();
      }
      _selectedState = profile.state.isNotEmpty ? profile.state : null;
      _selectedSoilType = profile.soilType.isNotEmpty ? profile.soilType : null;
      _selectedCrop = profile.currentCrop.isNotEmpty ? profile.currentCrop : null;
      _selectedLanguage = profile.preferredLanguage.isNotEmpty ? profile.preferredLanguage : 'hi';
      _lands = List.from(profile.lands);
    } else {
      _selectedLanguage = context.read<LanguageProvider>().languageCode;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _farmSizeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final farmerProvider = context.watch<FarmerProvider>();
    final profile = farmerProvider.profile;
    final isLoggedIn = profile != null && profile.name.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background photo using AgriImage
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
            child: Column(
              children: [
                _buildHeader(l),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Profile Summary Card (or Guest Card if not logged in)
                          _buildProfileSummaryCard(context, profile, isLoggedIn, l),
                          const SizedBox(height: 16),

                          // If NOT Logged In -> Show Login / Register CTA Card!
                          if (!isLoggedIn) ...[
                            LovableGlassCard(
                              strong: true,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  const Icon(LucideIcons.userPlus, size: 40, color: LovableColors.forest),
                                  const SizedBox(height: 12),
                                  Text(
                                    l.isHindi
                                        ? 'अपना किसान अकाउंट लॉग इन या रजिस्टर करें'
                                        : 'Sign In / Register your Farmer Account',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: LovableColors.forest,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    l.isHindi
                                        ? 'अपनी फसल, khet aur bhasha ko save rakhne ke liye login karein.'
                                        : 'Sign in to save your farm details, crops, and language preferences.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: LovableColors.slateGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  CtaButton(
                                    label: l.isHindi ? 'लॉग इन / अकाउंट बनाएं' : 'SIGN IN / REGISTER',
                                    icon: LucideIcons.logIn,
                                    width: double.infinity,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // 2. Personal Information & Farm Form (Available when logged in)
                          if (isLoggedIn) ...[
                            LovableGlassCard(
                              strong: true,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.isHindi ? 'व्यक्तिगत जानकारी' : 'Personal Information',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: LovableColors.forest,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  AppTextField(
                                    label: l.farmerName,
                                    hint: 'e.g. Ramesh Kumar',
                                    controller: _nameCtrl,
                                    prefixIcon: const Icon(LucideIcons.user, size: 18),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                                  ),
                                  const SizedBox(height: 14),
                                  AppTextField(
                                    label: '${l.location} / Village',
                                    hint: 'e.g. Sultanpur, Nashik',
                                    controller: _locationCtrl,
                                    prefixIcon: const Icon(LucideIcons.mapPin, size: 18),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Location is required' : null,
                                  ),
                                  const SizedBox(height: 14),
                                  AppDropdown<String>(
                                    label: l.state,
                                    value: _selectedState,
                                    items: AppConstants.indianStates,
                                    itemLabel: (s) => s,
                                    prefixIcon: const Icon(LucideIcons.map, size: 18),
                                    validator: (v) => v == null ? 'Please select state' : null,
                                    onChanged: (v) => setState(() => _selectedState = v),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Farm Details Form Card
                            LovableGlassCard(
                              strong: true,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.isHindi ? 'खेत और फसल विवरण' : 'Farm & Crop Details',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: LovableColors.forest,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  AppDropdown<String>(
                                    label: l.soilType,
                                    value: _selectedSoilType,
                                    items: AppConstants.soilTypes,
                                    itemLabel: (s) => s,
                                    prefixIcon: const Icon(LucideIcons.layers, size: 18),
                                    validator: (v) => v == null ? 'Please select soil type' : null,
                                    onChanged: (v) => setState(() => _selectedSoilType = v),
                                  ),
                                  const SizedBox(height: 14),
                                  AppTextField(
                                    label: '${l.farmSize} (Acres)',
                                    hint: 'e.g. 2.5',
                                    controller: _farmSizeCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    prefixIcon: const Icon(LucideIcons.crop, size: 18),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Farm size required' : null,
                                  ),
                                  const SizedBox(height: 14),
                                  AppDropdown<String>(
                                    label: l.currentCropLabel,
                                    value: _selectedCrop,
                                    items: AppConstants.commonCrops,
                                    itemLabel: (s) => s,
                                    prefixIcon: const Icon(LucideIcons.sprout, size: 18),
                                    validator: (v) => v == null ? 'Please select crop' : null,
                                    onChanged: (v) => setState(() => _selectedCrop = v),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // 3. Language Selection Card (WORKS WITHOUT LOGIN TOO!)
                          _buildLanguageSectionCard(context, l),
                          const SizedBox(height: 16),

                          // 4. Farmer Helplines & Support Card (WORKS WITHOUT LOGIN TOO!)
                          _buildSupportSectionCard(l),
                          const SizedBox(height: 24),

                          // Save & Logout Buttons (When Logged In)
                          if (isLoggedIn) ...[
                            CtaButton(
                              label: l.save,
                              icon: LucideIcons.save,
                              width: double.infinity,
                              isLoading: _isSaving,
                              onTap: _onSave,
                            ),
                            const SizedBox(height: 16),
                            _buildLogoutButton(context, l),
                          ],

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: LovableColors.glassStrong,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: LovableColors.glassBorder),
              boxShadow: LovableColors.shadowGlass,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: LovableColors.forest),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Text(
                  l.isHindi ? 'किसान प्रोफाइल व सेटिंग्स' : 'Profile & Settings',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: LovableColors.forest,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSummaryCard(
    BuildContext context,
    FarmerProfile? profile,
    bool isLoggedIn,
    AppLocalizations l,
  ) {
    final name = isLoggedIn ? profile!.name : (l.isHindi ? 'अतिथि किसान' : 'Guest Farmer');
    final location = isLoggedIn
        ? '${profile!.location}${profile.state.isNotEmpty ? ', ${profile.state}' : ''}'
        : (l.isHindi ? 'साइन इन करें' : 'Sign in to complete profile');

    return LovableGlassCard(
      strong: true,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LovableColors.ctaGradient,
              shape: BoxShape.circle,
              boxShadow: LovableColors.shadowGlow,
            ),

            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: LovableColors.forest,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  location,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: LovableColors.slateGreen,
                  ),
                ),
              ],
            ),
          ),
          GlassChip(
            child: Text(
              isLoggedIn ? 'Active' : 'Guest',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: isLoggedIn ? LovableColors.emeraldAccent : LovableColors.slateGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSectionCard(BuildContext context, AppLocalizations l) {
    final langProvider = context.watch<LanguageProvider>();
    final currentLang = langProvider.languageCode;

    return LovableGlassCard(
      strong: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.globe, color: LovableColors.emeraldAccent, size: 22),
              const SizedBox(width: 10),
              Text(
                l.isHindi ? 'ऐप की भाषा चुनें / Choose Language' : 'App Language / भाषा बदलें',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: LovableColors.forest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l.isHindi
                ? 'बिना लॉगिन किए अपनी पसंदीदा भाषा चुनें'
                : 'Switch app language instantly without sign-in',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: LovableColors.slateGreen,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppConstants.supportedLanguages.map((lang) {
              final code = lang['code']!;
              final name = lang['name']!;
              final isSelected = currentLang == code;
              return GestureDetector(
                onTap: () {
                  langProvider.setLanguage(code);
                  setState(() => _selectedLanguage = code);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to $name'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? LovableColors.forest : LovableColors.glass,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? LovableColors.emeraldAccent : LovableColors.glassBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : LovableColors.forest,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        const Icon(LucideIcons.check, size: 14, color: LovableColors.emeraldAccent),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

        ],
      ),
    );
  }

  Widget _buildSupportSectionCard(AppLocalizations l) {
    return LovableGlassCard(
      strong: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.phoneCall, color: LovableColors.emeraldAccent, size: 22),
              const SizedBox(width: 10),
              Text(
                l.isHindi ? 'किसान हेल्पलाइन और सहायता' : 'Farmer Support & Helplines',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: LovableColors.forest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _supportRow('Kisan Call Center', '1800-180-1551', 'tel:18001801551'),
          const SizedBox(height: 10),
          _supportRow('PM-Kisan Helpline', '155261', 'tel:155261'),
          const SizedBox(height: 10),
          _supportRow('e-NAM Agriculture Portal', 'enam.gov.in', 'https://enam.gov.in'),
        ],
      ),
    );
  }

  Widget _supportRow(String title, String subtitle, String url) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: LovableColors.glass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LovableColors.glassBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: LovableColors.forest),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: LovableColors.slateGreen),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: LovableColors.forest,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(LucideIcons.externalLink, size: 14),
            label: const Text('Connect', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            onPressed: () => url.startsWith('tel:')
                ? UrlHelper.launchPhoneDialer(url)
                : UrlHelper.launchWebBrowser(url),

          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l) {
    return LovableGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(LucideIcons.logOut, color: LovableColors.negative, size: 22),
        title: Text(
          l.isHindi ? 'लॉगआउट / खाता बदलें' : 'Sign Out / Switch Account',
          style: GoogleFonts.outfit(color: LovableColors.negative, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        onTap: () => _showLogoutDialog(context, l),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.isHindi ? 'लॉगआउट?' : 'Logout?'),
        content: Text(
          l.isHindi
              ? 'क्या आप वाकई लॉगआउट करना चाहते हैं? आपकी सेव की गई प्रोफाइल रीसेट हो जाएगी।'
              : 'Are you sure you want to sign out? Your saved profile will be reset.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<FarmerProvider>().clearProfile();
              await context.read<CropMonitorProvider>().clearCrops();
              if (context.mounted) {
                await context.read<app_auth.AuthProvider>().signOut();
              }
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
            child: const Text('Logout', style: TextStyle(color: LovableColors.negative)),
          ),
        ],
      ),
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final authUser = context.read<app_auth.AuthProvider>().user;
      final uid = (authUser?.uid != null && authUser!.uid.isNotEmpty)
          ? authUser.uid
          : (context.read<FarmerProvider>().profile?.id.isNotEmpty == true
              ? context.read<FarmerProvider>().profile!.id
              : 'farmer_${DateTime.now().millisecondsSinceEpoch}');

      final profile = FarmerProfile(
        id: uid,
        name: _nameCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        state: _selectedState ?? '',
        preferredLanguage: _selectedLanguage ?? 'hi',
        soilType: _selectedSoilType ?? '',
        farmSizeInAcres: double.tryParse(_farmSizeCtrl.text) ?? 0.0,
        currentCrop: _selectedCrop ?? '',
        phoneNumber: authUser?.email ?? '',
        lands: _lands,
      );

      final crops = context.read<CropMonitorProvider>().crops;
      await context.read<FarmerProvider>().saveProfile(profile, crops);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).isHindi
                ? 'प्रोफ़ाइल सफलतापूर्वक सहेजी गई!'
                : 'Profile updated successfully!',
          ),
          backgroundColor: LovableColors.positive,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: ${e.toString()}')),
        );
      }
    }
    setState(() => _isSaving = false);
  }
}
