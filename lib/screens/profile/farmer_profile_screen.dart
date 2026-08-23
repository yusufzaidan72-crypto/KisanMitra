import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/farmer_profile.dart';
import '../../providers/farmer_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/common/app_widgets.dart';
import '../../localization/app_localizations.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/app_providers.dart';

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

  void _showAddLandDialog(AppLocalizations l) {
    final landNameCtrl = TextEditingController(text: 'Khet ${_lands.length + 2}');
    final landSizeCtrl = TextEditingController();
    String? landSoilType = _selectedSoilType;
    String? landCrop = _selectedCrop ?? 'Chilli / मिर्च';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.add_location_alt_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(l.isHindi ? 'अन्य खेत जोड़ें' : 'Add Another Land'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  label: l.isHindi ? 'खेत का नाम / नंबर' : 'Land Name / Number',
                  hint: 'e.g. Khet 2, Land 2',
                  controller: landNameCtrl,
                  prefixIcon: const Icon(Icons.terrain_outlined),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: l.isHindi ? 'क्षेत्रफल (एकड़ में)' : 'Farm Size (in Acres)',
                  hint: 'e.g. 2.0',
                  controller: landSizeCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.crop_square_outlined),
                ),
                const SizedBox(height: 12),
                AppDropdown<String>(
                  label: l.soilType,
                  value: landSoilType,
                  items: AppConstants.soilTypes,
                  itemLabel: (s) => s,
                  prefixIcon: const Icon(Icons.grass_outlined),
                  onChanged: (v) => setDialogState(() => landSoilType = v),
                ),
                const SizedBox(height: 12),
                AppDropdown<String>(
                  label: l.isHindi ? 'फसल (Crop)' : 'Crop',
                  value: landCrop,
                  items: AppConstants.commonCrops,
                  itemLabel: (s) => s,
                  prefixIcon: const Icon(Icons.spa_outlined),
                  onChanged: (v) => setDialogState(() => landCrop = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.isHindi ? 'रद्द करें' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final size = double.tryParse(landSizeCtrl.text) ?? 0.0;
                if (size <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.isHindi ? 'वैध क्षेत्रफल दर्ज करें' : 'Please enter valid farm size')),
                  );
                  return;
                }
                final newLand = LandDetail(
                  id: 'land_${DateTime.now().millisecondsSinceEpoch}',
                  name: landNameCtrl.text.trim().isEmpty ? 'Khet ${_lands.length + 2}' : landNameCtrl.text.trim(),
                  sizeInAcres: size,
                  soilType: landSoilType ?? 'Alluvial Soil / जलोढ़ मिट्टी',
                  crop: landCrop ?? 'Chilli / मिर्च',
                );
                setState(() {
                  _lands.add(newLand);
                });
                Navigator.pop(ctx);
              },
              child: Text(l.isHindi ? 'खेत जोड़ें' : 'Add Land'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEditing = widget.isEditing;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(l, isEditing),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isEditing) _buildWelcomeBanner(l),
                    const SizedBox(height: 8),
                    _buildSection(
                      icon: Icons.person_outline,
                      title: l.farmerName,
                      child: AppTextField(
                        label: l.farmerName,
                        hint: 'e.g. Ramesh Kumar',
                        controller: _nameCtrl,
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Name is required'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      icon: Icons.location_on_outlined,
                      title: l.location,
                      child: Column(
                        children: [
                          AppTextField(
                            label: '${l.location} / Village',
                            hint: 'e.g. Sultanpur, UP',
                            controller: _locationCtrl,
                            prefixIcon: const Icon(Icons.location_city_outlined),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Location is required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          AppDropdown<String>(
                            label: l.state,
                            value: _selectedState,
                            items: AppConstants.indianStates,
                            itemLabel: (s) => s,
                            prefixIcon: const Icon(Icons.map_outlined),
                            validator: (v) =>
                                v == null ? 'Please select state' : null,
                            onChanged: (v) => setState(() => _selectedState = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      icon: Icons.grass_outlined,
                      title: 'Farm Details / खेत की जानकारी',
                      child: Column(
                        children: [
                          AppDropdown<String>(
                            label: l.soilType,
                            value: _selectedSoilType,
                            items: AppConstants.soilTypes,
                            itemLabel: (s) => s,
                            prefixIcon: const Icon(Icons.grass_outlined),
                            validator: (v) =>
                                v == null ? 'Please select soil type' : null,
                            onChanged: (v) =>
                                setState(() => _selectedSoilType = v),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            label: '${l.farmSize} (Land 1 / मुख्य खेत)',
                            hint: 'e.g. 2.5',
                            controller: _farmSizeCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            prefixIcon: const Icon(Icons.crop_square_outlined),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Farm size is required';
                              }
                              if (double.tryParse(v) == null) {
                                return 'Enter a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          AppDropdown<String>(
                            label: l.currentCropLabel,
                            value: _selectedCrop,
                            items: AppConstants.commonCrops,
                            itemLabel: (s) => s,
                            prefixIcon: const Icon(Icons.spa_outlined),
                            validator: (v) =>
                                v == null ? 'Please select crop' : null,
                            onChanged: (v) => setState(() => _selectedCrop = v),
                          ),
                          const SizedBox(height: 16),

                          // Additional Lands List
                          if (_lands.isNotEmpty) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                l.isHindi ? 'अतिरिक्त खेत (Other Lands):' : 'Additional Lands:',
                                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._lands.asMap().entries.map((entry) {
                              final index = entry.key;
                              final land = entry.value;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.landscape_outlined, color: AppColors.primary, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(land.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                          Text('${land.sizeInAcres} Acres | ${land.soilType.split(' / ').first}${land.crop.isNotEmpty ? " | 🌾 ${land.crop.split(' / ').first}" : ""}', style: AppTextStyles.bodySmall),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _lands.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                          ],

                          // Add Another Land Button
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.add_location_alt_outlined, color: AppColors.primary),
                            label: Text(
                              l.isHindi ? '+ अन्य खेत जोड़ें (Add Another Land)' : '+ Add Another Land',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => _showAddLandDialog(l),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Consumer<FarmerProvider>(
                      builder: (context, provider, _) => AppButton(
                        label: isEditing ? l.save : l.createProfile,
                        onPressed: _onSave,
                        isLoading: provider.isLoading,
                        width: double.infinity,
                        icon: isEditing ? Icons.save_outlined : Icons.check_circle_outline,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(AppLocalizations l, bool isEditing) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      automaticallyImplyLeading: isEditing,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const Text('👨‍🌾', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(
                  isEditing ? l.editProfile : l.profileSetup,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        titlePadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildWelcomeBanner(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l.isHindi
                  ? 'अपनी जानकारी भरें — यह आपको बेहतर कृषि सलाह पाने में मदद करेगी।'
                  : 'Fill in your details to get personalized agricultural advice.',
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
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
