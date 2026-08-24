import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localizations.dart';
import '../../models/irrigation_advice.dart';
import '../../providers/farmer_provider.dart';
import '../../services/demo/demo_irrigation_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/lovable_colors.dart';
import '../../utils/agri_image_helper.dart';
import '../../widgets/widgets.dart';

class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({super.key});

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  final _rainfallCtrl = TextEditingController(text: '5');
  final _tempCtrl = TextEditingController(text: '32');
  final _humidityCtrl = TextEditingController(text: '65');

  String? _selectedCrop;
  String? _selectedStage;
  String? _selectedSoil;
  String? _selectedForecast;

  bool _isLoading = false;
  IrrigationAdvice? _advice;
  final _service = DemoIrrigationService();


  @override
  void initState() {
    super.initState();
    final profile = context.read<FarmerProvider>().profile;
    if (profile != null) {
      _selectedCrop = profile.currentCrop.isNotEmpty ? profile.currentCrop : null;
      _selectedSoil = profile.soilType.isNotEmpty ? profile.soilType : null;
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
          // Background photo using AgriImage
          const AgriImage(
            keywordOrUrl: 'irrigation',
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
                    child: Column(
                      children: [
                        LovableGlassCard(
                          strong: true,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              AppDropdown<String>(
                                label: l.currentCropLabel,
                                value: _selectedCrop,
                                items: AppConstants.commonCrops,
                                itemLabel: (s) => s,
                                prefixIcon: const Icon(LucideIcons.sprout, size: 18),
                                onChanged: (v) => setState(() => _selectedCrop = v),
                              ),
                              const SizedBox(height: 12),
                              AppDropdown<String>(
                                label: l.growthStage,
                                value: _selectedStage,
                                items: AppConstants.growthStages,
                                itemLabel: (s) => s,
                                prefixIcon: const Icon(LucideIcons.trendingUp, size: 18),
                                onChanged: (v) => setState(() => _selectedStage = v),
                              ),
                              const SizedBox(height: 12),
                              AppDropdown<String>(
                                label: l.soilType,
                                value: _selectedSoil,
                                items: AppConstants.soilTypes,
                                itemLabel: (s) => s,
                                prefixIcon: const Icon(LucideIcons.layers, size: 18),
                                onChanged: (v) => setState(() => _selectedSoil = v),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      label: l.recentRainfall,
                                      controller: _rainfallCtrl,
                                      keyboardType: TextInputType.number,
                                      prefixIcon: const Icon(LucideIcons.droplets, size: 18),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AppTextField(
                                      label: 'Temp (°C)',
                                      controller: _tempCtrl,
                                      keyboardType: TextInputType.number,
                                      prefixIcon: const Icon(LucideIcons.thermometer, size: 18),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              CtaButton(
                                label: l.getAdvice,
                                icon: LucideIcons.droplet,
                                width: double.infinity,
                                isLoading: _isLoading,
                                onTap: _getAdvice,
                              ),

                            ],
                          ),
                        ),
                        if (_advice != null) ...[
                          const SizedBox(height: 24),
                          _buildAdviceCard(l, _advice!),
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
                  l.irrigationAdvisor,
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

  Widget _buildAdviceCard(AppLocalizations l, IrrigationAdvice advice) {
    final isRecommended = advice.irrigationRecommended;

    return LovableGlassCard(
      strong: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  gradient: LovableColors.ctaGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isRecommended ? LucideIcons.droplets : LucideIcons.check,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRecommended ? l.irrigationRecommended : l.notRequired,
                      style: GoogleFonts.outfit(
                        color: isRecommended ? LovableColors.forest : LovableColors.positive,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      advice.reason,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: LovableColors.slateGreen),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isRecommended) ...[
            const Divider(height: 24, color: LovableColors.glassBorder),
            _adviceRow(LucideIcons.clock, l.suggestedTiming, advice.timing),
            const SizedBox(height: 8),
            _adviceRow(LucideIcons.droplet, l.waterAmount, '${advice.waterAmount.toStringAsFixed(0)} mm'),
          ],
        ],
      ),
    );
  }

  Widget _adviceRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: LovableColors.emeraldAccent, size: 16),
        const SizedBox(width: 8),
        Text('$label: ', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: LovableColors.slateGreen)),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: LovableColors.forest),
        ),
      ],
    );
  }

  Future<void> _getAdvice() async {
    setState(() => _isLoading = true);
    try {
      final input = IrrigationInput(
        cropName: _selectedCrop?.split(' / ').first ?? 'Wheat',
        growthStage: _selectedStage ?? 'Vegetative Growth',
        soilType: _selectedSoil ?? 'Loamy Soil',
        recentRainfall: double.tryParse(_rainfallCtrl.text) ?? 5,
        temperature: double.tryParse(_tempCtrl.text) ?? 32,
        humidity: double.tryParse(_humidityCtrl.text) ?? 65,
        weatherForecast: _selectedForecast ?? 'Clear',
      );
      final advice = await _service.getIrrigationAdvice(input);
      setState(() => _advice = advice);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
    setState(() => _isLoading = false);
  }
}
