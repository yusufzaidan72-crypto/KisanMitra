import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localizations.dart';
import '../../models/farmer_profile.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/farmer_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/lovable_colors.dart';
import '../../utils/url_helper.dart';
import '../../widgets/widgets.dart';

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
                          // Profile Summary Card
                          _buildProfileSummaryCard(context, l),
                          const SizedBox(height: 16),

                          // Personal Information Form Card
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

                          // Language Selection Settings Card
                          _buildLanguageSectionCard(context, l),
                          const SizedBox(height: 16),

                          // Farmer Helplines & Support Card
                          _buildSupportSectionCard(l),
                          const SizedBox(height: 24),

                          // Save Profile Button
                          CtaButton(
                            label: l.save,
                            icon: LucideIcons.save,
                            width: double.infinity,
                            isLoading: _isSaving,
                            onTap: _onSave,
                          ),
                          const SizedBox(height: 16),

                          // Logout Button
                          _buildLogoutButton(context, l),
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
                Text(
                  l.isHindi ? 'प्रोफाइल व सेटिंग्स' : 'Profile & Settings',
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

  Widget _buildProfileSummaryCard(BuildContext context, AppLocalizations l) {
    final farmer = context.watch<FarmerProvider>().profile;
    final name = (farmer != null && farmer.name.isNotEmpty) ? farmer.name : 'Yusuf';
    final location = (farmer != null && farmer.location.isNotEmpty)
        ? '${farmer.location}${farmer.state.isNotEmpty ? ", ${farmer.state}" : ""}'
        : 'Nashik, Maharashtra';

    return LovableGlassCard(
      strong: true,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LovableColors.ctaGradient,
              shape: BoxShape.circle,
              boxShadow: LovableColors.shadowGlow,
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: LovableColors.forest),
                ),
                const SizedBox(height: 2),
                Text(
                  '📍 $location',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: LovableColors.slateGreen),
                ),
              ],
            ),
          ),
          GlassChip(
            child: Text(
              l.isHindi ? 'सक्रिय किसान' : 'Active Farmer',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: LovableColors.emeraldAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSectionCard(BuildContext context, AppLocalizations l) {
    final currentLang = context.watch<LanguageProvider>().languageCode;

    return LovableGlassCard(
      strong: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.languages, color: LovableColors.emeraldAccent, size: 20),
              const SizedBox(width: 10),
              Text(
                l.isHindi ? 'भाषा चयन (App Language)' : 'Language Settings',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: LovableColors.forest),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...AppConstants.supportedLanguages.map((lang) {
            final isSelected = currentLang == lang['code'];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? LovableColors.emeraldAccent.withValues(alpha: 0.15) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    lang['name']!.substring(0, 1),
                    style: GoogleFonts.outfit(
                      color: isSelected ? LovableColors.forest : LovableColors.slateGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              title: Text(
                lang['name']!,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: LovableColors.forest,
                ),
              ),
              subtitle: Text(
                lang['englishName']!,
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: LovableColors.slateGreen),
              ),
              trailing: isSelected ? const Icon(LucideIcons.checkCircle, color: LovableColors.emeraldAccent, size: 20) : null,
              onTap: () {
                setState(() => _selectedLanguage = lang['code']!);
                context.read<LanguageProvider>().setLanguage(lang['code']!);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSupportSectionCard(AppLocalizations l) {
    final resources = [
      (
        title: 'Kisan Call Center',
        subtitle: '1800-180-1551 (Toll-Free)',
        icon: LucideIcons.phoneCall,
        action: () => UrlHelper.launchPhoneDialer('1800-180-1551'),
      ),
      (
        title: 'PM-KISAN Portal',
        subtitle: 'pmkisan.gov.in',
        icon: LucideIcons.globe,
        action: () => UrlHelper.launchWebBrowser('https://pmkisan.gov.in'),
      ),
      (
        title: 'eNAM Market Portal',
        subtitle: 'enam.gov.in',
        icon: LucideIcons.externalLink,
        action: () => UrlHelper.launchWebBrowser('https://enam.gov.in'),
      ),
    ];

    return LovableGlassCard(
      strong: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.headphones, color: LovableColors.emeraldAccent, size: 20),
              const SizedBox(width: 10),
              Text(
                l.isHindi ? 'किसान सहायता व हेल्पलाइन' : 'Farmer Support & Helplines',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: LovableColors.forest),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...resources.map((r) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(r.icon, color: LovableColors.forest, size: 20),
                title: Text(r.title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: LovableColors.forest)),
                subtitle: Text(r.subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: LovableColors.slateGreen)),
                trailing: const Icon(LucideIcons.arrowUpRight, size: 16, color: LovableColors.forest),
                onTap: r.action,
              )),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l) {
    return LovableGlassCard(
      padding: const EdgeInsets.all(16),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(LucideIcons.logOut, color: LovableColors.negative, size: 22),
        title: Text(
          l.isHindi ? 'लॉगआउट करें' : 'Sign Out Account',
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
        content: Text(l.isHindi ? 'क्या आप वाकई लॉगआउट करना चाहते हैं?' : 'Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<app_auth.AuthProvider>().signOut();
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
