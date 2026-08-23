import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localizations.dart';
import '../../models/crop_recommendation.dart';
import '../../providers/farmer_provider.dart';
import '../../services/demo/demo_crop_recommendation_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/lovable_colors.dart';
import '../../widgets/widgets.dart';

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});

  @override
  State<CropRecommendationScreen> createState() =>
      _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationCtrl = TextEditingController();
  final _tempCtrl = TextEditingController(text: '30');
  final _rainfallCtrl = TextEditingController(text: '800');
  final _phCtrl = TextEditingController(text: '6.5');

  String? _selectedState;
  String? _selectedSoil;
  String? _selectedSeason;
  String? _selectedWater;

  bool _isLoading = false;
  List<CropRecommendation>? _results;

  final _service = DemoCropRecommendationService();

  @override
  void initState() {
    super.initState();
    final profile = context.read<FarmerProvider>().profile;
    if (profile != null) {
      _locationCtrl.text = profile.location;
      _selectedState = profile.state.isNotEmpty &&
              AppConstants.indianStates.contains(profile.state)
          ? profile.state
          : null;
      _selectedSoil = AppConstants.soilTypes.firstWhere(
        (s) => s.contains(profile.soilType.split(' / ').first),
        orElse: () => AppConstants.soilTypes.first,
      );
    }
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Form(
                          key: _formKey,
                          child: LovableGlassCard(
                            strong: true,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                AppTextField(
                                  label: l.location,
                                  hint: 'Enter village/city',
                                  controller: _locationCtrl,
                                  prefixIcon: const Icon(LucideIcons.mapPin, size: 18),
                                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                                ),
                                const SizedBox(height: 12),
                                AppDropdown<String>(
                                  label: l.state,
                                  value: _selectedState,
                                  items: AppConstants.indianStates,
                                  itemLabel: (s) => s,
                                  prefixIcon: const Icon(LucideIcons.map, size: 18),
                                  validator: (v) => v == null ? 'Required' : null,
                                  onChanged: (v) => setState(() => _selectedState = v),
                                ),
                                const SizedBox(height: 12),
                                AppDropdown<String>(
                                  label: l.soilType,
                                  value: _selectedSoil,
                                  items: AppConstants.soilTypes,
                                  itemLabel: (s) => s,
                                  prefixIcon: const Icon(LucideIcons.layers, size: 18),
                                  validator: (v) => v == null ? 'Required' : null,
                                  onChanged: (v) => setState(() => _selectedSoil = v),
                                ),
                                const SizedBox(height: 12),
                                AppDropdown<String>(
                                  label: l.season,
                                  value: _selectedSeason,
                                  items: AppConstants.seasons,
                                  itemLabel: (s) => s,
                                  prefixIcon: const Icon(LucideIcons.sun, size: 18),
                                  validator: (v) => v == null ? 'Required' : null,
                                  onChanged: (v) => setState(() => _selectedSeason = v),
                                ),
                                const SizedBox(height: 16),
                                CtaButton(
                                  label: l.getCropRecommendations,
                                  icon: LucideIcons.sparkles,
                                  width: double.infinity,
                                  isLoading: _isLoading,
                                  onTap: _getRecommendations,
                                ),

                              ],
                            ),
                          ),
                        ),
                        if (_results != null) ...[
                          const SizedBox(height: 24),
                          Text(
                            l.cropRecommendation,
                            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: LovableColors.forest),
                          ),
                          const SizedBox(height: 12),
                          ..._results!.asMap().entries.map((e) => _buildRecommendationCard(e.key, e.value, l)),
                        ],
                        const SizedBox(height: 40),
                      ],
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
                  l.cropRecommendation,
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

  Widget _buildRecommendationCard(int rank, CropRecommendation crop, AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LovableGlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(crop.icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop.cropName,
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: LovableColors.forest),
                      ),
                      Text(
                        crop.cropNameHindi,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: LovableColors.slateGreen),
                      ),
                    ],
                  ),
                ),
                GlassChip(
                  child: Text(
                    '${(crop.suitabilityScore * 100).toInt()}% Match',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: LovableColors.emeraldAccent),
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: LovableColors.glassBorder),
            Text(
              crop.reason,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: LovableColors.slateGreen),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getRecommendations() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _results = null;
    });
    try {
      final input = CropRecommendationInput(
        location: _locationCtrl.text,
        state: _selectedState ?? '',
        soilType: _selectedSoil ?? '',
        soilPh: double.tryParse(_phCtrl.text) ?? 6.5,
        temperature: double.tryParse(_tempCtrl.text) ?? 30,
        rainfall: double.tryParse(_rainfallCtrl.text) ?? 800,
        waterAvailability: _selectedWater ?? '',
        season: _selectedSeason ?? '',
      );
      final results = await _service.getRecommendations(input);
      setState(() => _results = results);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
    setState(() => _isLoading = false);
  }
}
