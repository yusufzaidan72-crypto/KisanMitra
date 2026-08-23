import '../interfaces/ai_irrigation_service.dart';
import '../../models/irrigation_advice.dart';

class DemoIrrigationService implements IrrigationService {
  @override
  Future<IrrigationAdvice> getIrrigationAdvice(IrrigationInput input) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final bool needsIrrigation = _shouldIrrigate(input);
    final method = _recommendMethod(input.soilType);

    return IrrigationAdvice(
      irrigationRecommended: needsIrrigation,
      timing: needsIrrigation ? 'Evening — 5:00 PM to 7:00 PM' : 'Not required today',
      waterAmount: _calculateWaterAmount(input),
      unit: 'mm',
      reason: _generateReason(input, needsIrrigation),
      generalGuidance: _getGuidance(input, needsIrrigation),
      nextIrrigationDate: _getNextDate(input, needsIrrigation),
      method: method,
    );
  }

  bool _shouldIrrigate(IrrigationInput input) {
    if (input.recentRainfall > 25) return false;
    if (input.humidity > 85) return false;
    if (input.weatherForecast.toLowerCase().contains('heavy rain')) return false;
    if (input.temperature > 35) return true;
    if (input.recentRainfall < 5 && input.temperature > 28) return true;
    return input.humidity < 50;
  }

  double _calculateWaterAmount(IrrigationInput input) {
    final baseMm = _cropWaterNeeds[input.cropName.split(' ').first] ?? 30.0;
    final tempFactor = (input.temperature - 25).clamp(0.0, 15.0) * 0.5;
    final rainOffset = input.recentRainfall * 0.5;
    return (baseMm + tempFactor - rainOffset).clamp(10.0, 80.0);
  }

  IrrigationMethod _recommendMethod(String soilType) {
    final s = soilType.toLowerCase();
    if (s.contains('sandy')) return IrrigationMethod.drip;
    if (s.contains('clay')) return IrrigationMethod.flood;
    if (s.contains('loam')) return IrrigationMethod.drip;
    return IrrigationMethod.furrow;
  }

  String _generateReason(IrrigationInput input, bool needed) {
    if (!needed && input.recentRainfall > 25) {
      return 'Recent rainfall of ${input.recentRainfall}mm is sufficient for crop needs. Save water.';
    }
    if (!needed && input.weatherForecast.toLowerCase().contains('rain')) {
      return 'Rain is forecasted in the next 24-48 hours. Delay irrigation to save water.';
    }
    if (needed && input.temperature > 35) {
      return 'High temperature (${input.temperature}°C) is increasing crop water demand. Irrigate today.';
    }
    if (needed && input.recentRainfall < 5) {
      return 'Less than 5mm rainfall in recent days. Soil moisture is low. Irrigation recommended.';
    }
    return needed
        ? 'Based on current temperature, humidity, and crop stage, irrigation is advisable.'
        : 'Current soil moisture levels are adequate for crop growth.';
  }

  List<String> _getGuidance(IrrigationInput input, bool needed) {
    if (needed) {
      return [
        'Irrigate in the evening to reduce evaporation loss',
        'Apply water near the root zone, not on leaves',
        'Check soil at 6-inch depth — if dry, irrigate immediately',
        'Drip irrigation reduces water use by 30-50%',
        'Avoid waterlogging — excess water harms roots',
      ];
    }
    return [
      'Monitor soil moisture at 6-inch depth every 2 days',
      'Keep irrigation channels clear for when needed',
      'Collect rainwater in farm ponds for future use',
      'Check weather forecast daily before planning irrigation',
    ];
  }

  String _getNextDate(IrrigationInput input, bool needed) {
    if (!needed) return 'Check again in 2-3 days';
    final days = input.recentRainfall > 15 ? 7 : 4;
    final next = DateTime.now().add(Duration(days: days));
    return '${next.day}/${next.month}/${next.year}';
  }

  static const Map<String, double> _cropWaterNeeds = {
    'Wheat': 25.0,
    'Rice': 60.0,
    'Maize': 30.0,
    'Cotton': 35.0,
    'Sugarcane': 55.0,
    'Soybean': 28.0,
    'Mustard': 20.0,
    'Potato': 32.0,
    'Tomato': 40.0,
    'Onion': 25.0,
    'Chickpea': 18.0,
    'Groundnut': 30.0,
  };
}
