import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/irrigation_advice.dart';
import '../../providers/farmer_provider.dart';
import '../../providers/app_providers.dart';
import '../../services/demo/demo_irrigation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/common/app_widgets.dart';
import '../../localization/app_localizations.dart';

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
      _selectedCrop = AppConstants.commonCrops.firstWhere(
        (c) => c.contains(profile.currentCrop.split(' / ').first),
        orElse: () => AppConstants.commonCrops.first,
      );
      _selectedSoil = AppConstants.soilTypes.firstWhere(
        (s) => s.contains(profile.soilType.split(' / ').first),
        orElse: () => AppConstants.soilTypes.first,
      );
    }
    final weather = context.read<WeatherProvider>().weather;
    if (weather != null) {
      _tempCtrl.text = weather.temperature.toStringAsFixed(0);
      _humidityCtrl.text = weather.humidity.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.irrigationAdvisor)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(l),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                children: [
                  AppDropdown<String>(
                    label: l.currentCropLabel,
                    value: _selectedCrop,
                    items: AppConstants.commonCrops,
                    itemLabel: (s) => s,
                    prefixIcon: const Icon(Icons.spa_outlined),
                    onChanged: (v) => setState(() => _selectedCrop = v),
                  ),
                  const SizedBox(height: 12),
                  AppDropdown<String>(
                    label: l.growthStage,
                    value: _selectedStage,
                    items: AppConstants.growthStages,
                    itemLabel: (s) => s,
                    prefixIcon: const Icon(Icons.trending_up_outlined),
                    onChanged: (v) => setState(() => _selectedStage = v),
                  ),
                  const SizedBox(height: 12),
                  AppDropdown<String>(
                    label: l.soilType,
                    value: _selectedSoil,
                    items: AppConstants.soilTypes,
                    itemLabel: (s) => s,
                    prefixIcon: const Icon(Icons.grass_outlined),
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
                          prefixIcon: const Icon(Icons.water_drop_outlined),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Temp (°C)',
                          controller: _tempCtrl,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.thermostat_outlined),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Humidity (%)',
                    controller: _humidityCtrl,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.opacity_outlined),
                  ),
                  const SizedBox(height: 12),
                  AppDropdown<String>(
                    label: l.isHindi ? 'मौसम पूर्वानुमान' : 'Weather Forecast',
                    value: _selectedForecast,
                    items: [l.forecastClear, l.forecastCloudy, l.forecastHeavyRain, l.forecastLightRain],
                    itemLabel: (s) => s,
                    prefixIcon: const Icon(Icons.wb_cloudy_outlined),
                    onChanged: (v) => setState(() => _selectedForecast = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: l.getAdvice,
              onPressed: _getAdvice,
              isLoading: _isLoading,
              width: double.infinity,
              icon: Icons.water_drop_outlined,
            ),
            if (_advice != null) ...[
              const SizedBox(height: 24),
              _buildAdviceCard(l, _advice!),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Text('💧', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.irrigationAdvisor,
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.accent)),
                const SizedBox(height: 2),
                Text(
                  l.isHindi
                      ? 'सही समय पर सिंचाई करें, पानी बचाएं'
                      : 'Irrigate at the right time, save water',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(AppLocalizations l, IrrigationAdvice advice) {
    final isRecommended = advice.irrigationRecommended;
    final mainColor = isRecommended ? AppColors.accent : AppColors.success;
    final bgColor = isRecommended
        ? AppColors.accentLight
        : AppColors.success.withValues(alpha: 0.08);

    return Column(
      children: [
        AppCard(
          backgroundColor: bgColor,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: mainColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        isRecommended ? '💧' : '✅',
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRecommended
                              ? l.irrigationRecommended
                              : l.notRequired,
                          style: TextStyle(
                            color: mainColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(advice.reason,
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              if (isRecommended) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 14),
                _adviceRow(Icons.schedule_outlined, l.suggestedTiming,
                    advice.timing, mainColor),
                const SizedBox(height: 8),
                _adviceRow(Icons.water_outlined, l.waterAmount,
                    '${advice.waterAmount.toStringAsFixed(0)} mm', mainColor),
                const SizedBox(height: 8),
                _adviceRow(Icons.calendar_today_outlined, l.nextIrrigation,
                    advice.nextIrrigationDate, mainColor),
                const SizedBox(height: 8),
                _adviceRow(Icons.agriculture_outlined, l.isHindi ? 'विधि' : 'Method',
                    _methodLabel(advice.method, l), mainColor),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Text(l.isHindi ? 'सिंचाई मार्गदर्शन' : 'Irrigation Guidance',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 12),
              ...advice.generalGuidance.map(
                (g) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: AppColors.primary, size: 17),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(g, style: AppTextStyles.bodySmall)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _adviceRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text('$label: ', style: AppTextStyles.bodySmall),
        Text(value,
            style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }

  String _methodLabel(IrrigationMethod m, AppLocalizations l) {
    return switch (m) {
      IrrigationMethod.drip => l.methodDrip,
      IrrigationMethod.sprinkler => l.methodSprinkler,
      IrrigationMethod.flood => l.methodFlood,
      IrrigationMethod.furrow => l.methodFurrow,
      IrrigationMethod.none => l.notRequired,
    };
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
