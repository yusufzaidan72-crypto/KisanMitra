import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/crop_recommendation.dart';
import '../../providers/farmer_provider.dart';
import '../../services/demo/demo_crop_recommendation_service.dart';
import '../../utils/utils.dart';
import '../../widgets/common/app_widgets.dart';
import '../../localization/app_localizations.dart';

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
      appBar: AppBar(title: Text(l.cropRecommendation)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBanner(l),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    label: l.location,
                    hint: 'Enter village/city',
                    controller: _locationCtrl,
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    validator: (v) =>
                        v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  AppDropdown<String>(
                    label: l.state,
                    value: _selectedState,
                    items: AppConstants.indianStates,
                    itemLabel: (s) => s,
                    prefixIcon: const Icon(Icons.map_outlined),
                    validator: (v) => v == null ? 'Required' : null,
                    onChanged: (v) => setState(() => _selectedState = v),
                  ),
                  const SizedBox(height: 12),
                  AppDropdown<String>(
                    label: l.soilType,
                    value: _selectedSoil,
                    items: AppConstants.soilTypes,
                    itemLabel: (s) => s,
                    prefixIcon: const Icon(Icons.grass_outlined),
                    validator: (v) => v == null ? 'Required' : null,
                    onChanged: (v) => setState(() => _selectedSoil = v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Temp (°C)',
                          controller: _tempCtrl,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.thermostat_outlined),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: l.soilPh,
                          controller: _phCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: const Icon(Icons.science_outlined),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: l.rainfall,
                    controller: _rainfallCtrl,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.water_drop_outlined),
                  ),
                  const SizedBox(height: 12),
                  AppDropdown<String>(
                    label: l.season,
                    value: _selectedSeason,
                    items: AppConstants.seasons,
                    itemLabel: (s) => s,
                    prefixIcon: const Icon(Icons.wb_sunny_outlined),
                    validator: (v) => v == null ? 'Required' : null,
                    onChanged: (v) => setState(() => _selectedSeason = v),
                  ),
                  const SizedBox(height: 12),
                  AppDropdown<String>(
                    label: l.waterAvailability,
                    value: _selectedWater,
                    items: [l.waterAbundant, l.waterModerate, l.waterScarce],
                    itemLabel: (s) => s,
                    prefixIcon: const Icon(Icons.opacity_outlined),
                    validator: (v) => v == null ? 'Required' : null,
                    onChanged: (v) => setState(() => _selectedWater = v),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: l.getCropRecommendations,
                    onPressed: _getRecommendations,
                    isLoading: _isLoading,
                    width: double.infinity,
                    icon: Icons.recommend_outlined,
                  ),
                ],
              ),
            ),
            if (_results != null) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(l.cropRecommendation, style: AppTextStyles.titleLarge),
                  const Spacer(),
                  const DemoBadge(),
                ],
              ),
              const SizedBox(height: 12),
              ..._results!.asMap().entries.map(
                  (e) => _buildRecommendationCard(e.key, e.value, l)),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.cropAdvice,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l.cropAdviceSubtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
      int rank, CropRecommendation crop, AppLocalizations l) {
    final rankColors = [
      AppColors.secondary,
      AppColors.textSecondary,
      AppColors.warning,
    ];
    final color = rank < rankColors.length ? rankColors[rank] : AppColors.primary;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('#${rank + 1}',
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Text(crop.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(crop.cropName, style: AppTextStyles.titleLarge),
                    Text(crop.cropNameHindi,
                        style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              _suitabilityBadge(crop),
            ],
          ),
          const Divider(height: 20),
          _infoRow('💧', l.waterReq, crop.waterRequirement),
          const SizedBox(height: 6),
          _infoRow('⏱️', l.duration, crop.growingDuration),
          const SizedBox(height: 6),
          _infoRow('📦', l.expectedYield, crop.expectedYield),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(crop.reason,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
          if (crop.tips.isNotEmpty) ...[
            const SizedBox(height: 10),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text('Tips & Guidance',
                  style: AppTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w600)),
              children: crop.tips
                  .map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: AppColors.primary)),
                            Expanded(child: Text(tip, style: AppTextStyles.bodySmall)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _suitabilityBadge(CropRecommendation crop) {
    final color = switch (crop.suitabilityLabel) {
      'Excellent' => AppColors.success,
      'Good' => AppColors.primary,
      'Moderate' => AppColors.secondary,
      _ => AppColors.textSecondary,
    };
    return Column(
      children: [
        Text(
          '${(crop.suitabilityScore * 100).toInt()}%',
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(crop.suitabilityLabel,
            style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }

  Widget _infoRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text('$label: ', style: AppTextStyles.bodySmall),
        Expanded(
          child: Text(value,
              style: AppTextStyles.bodySmall
                  .copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ),
      ],
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
