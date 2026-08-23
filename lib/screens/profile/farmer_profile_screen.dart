import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localizations.dart';
import '../../models/farmer_profile.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/farmer_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/lovable_colors.dart';
import '../../widgets/widgets.dart';

class FarmerProfileScreen extends StatefulWidget {
  final bool isEditing;
  const FarmerProfileScreen({super.key, this.isEditing = false});

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
      _selectedLanguage = 'hi';
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
    final isEditing = widget.isEditing;

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
                _buildHeader(l, isEditing),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LovableGlassCard(
                            strong: true,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Personal Information',
                                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: LovableColors.forest),
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
                                  hint: 'e.g. Sultanpur',
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
                          LovableGlassCard(
                            strong: true,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Farm Details',
                                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: LovableColors.forest),
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
                          const SizedBox(height: 24),
                          CtaButton(
                            label: isEditing ? l.save : l.createProfile,
                            icon: isEditing ? LucideIcons.save : LucideIcons.checkCircle2,
                            width: double.infinity,
                            onTap: _onSave,
                          ),
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

  Widget _buildHeader(AppLocalizations l, bool isEditing) {
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
                if (isEditing)
                  IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, color: LovableColors.forest),
                    onPressed: () => Navigator.pop(context),
                  ),
                Text(
                  isEditing ? l.editProfile : l.profileSetup,
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

  Future<void> _onSave() async {
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

    if (widget.isEditing) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } else {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }
}
