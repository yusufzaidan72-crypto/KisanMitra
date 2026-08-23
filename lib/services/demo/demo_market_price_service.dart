import '../interfaces/market_price_service.dart';
import '../../models/market_price.dart';
import '../../core/constants/app_constants.dart';

class DemoMarketPriceService implements MarketPriceService {
  @override
  bool get isConfigured => false;

  @override
  Future<List<String>> getAvailableMarkets(String state) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return AppConstants.demoMarkets;
  }

  @override
  Future<List<MarketPrice>> getPrices({
    required String cropName,
    required String state,
    String? market,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return _getDemoPrices(cropName, state, market);
  }

  List<MarketPrice> _getDemoPrices(String cropName, String state, String? market) {
    final marketName = market ?? 'APMC ${state.split(' ').first}';
    final priceMap = _basePrices[cropName.split(' / ').first] ?? _basePrices['Wheat']!;

    return [
      MarketPrice(
        cropName: cropName.split(' / ').first,
        cropNameHindi: cropName.contains('/') ? cropName.split('/ ').last : cropName,
        currentPrice: priceMap['current']!,
        minPrice: priceMap['min']!,
        maxPrice: priceMap['max']!,
        unit: 'per Quintal',
        marketName: marketName,
        state: state,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        isDemo: true,
        priceChangePercent: priceMap['change']!,
      ),
      MarketPrice(
        cropName: cropName.split(' / ').first,
        cropNameHindi: cropName.contains('/') ? cropName.split('/ ').last : cropName,
        currentPrice: priceMap['current']! * 0.97,
        minPrice: priceMap['min']! * 0.95,
        maxPrice: priceMap['max']! * 0.98,
        unit: 'per Quintal',
        marketName: 'Nearby ${state.split(' ').first} APMC',
        state: state,
        lastUpdated: DateTime.now().subtract(const Duration(hours: 4)),
        isDemo: true,
        priceChangePercent: priceMap['change']! * -0.5,
      ),
    ];
  }

  static const Map<String, Map<String, double>> _basePrices = {
    'Wheat': {'current': 2250, 'min': 2100, 'max': 2400, 'change': 2.3},
    'Rice': {'current': 3200, 'min': 2950, 'max': 3500, 'change': 1.8},
    'Maize': {'current': 1850, 'min': 1700, 'max': 2000, 'change': -1.2},
    'Cotton': {'current': 6800, 'min': 6500, 'max': 7200, 'change': 3.5},
    'Sugarcane': {'current': 350, 'min': 320, 'max': 380, 'change': 0.8},
    'Soybean': {'current': 4600, 'min': 4200, 'max': 5000, 'change': -2.1},
    'Mustard': {'current': 5200, 'min': 4800, 'max': 5600, 'change': 4.2},
    'Potato': {'current': 1200, 'min': 900, 'max': 1500, 'change': -5.3},
    'Tomato': {'current': 2800, 'min': 1800, 'max': 4200, 'change': 12.5},
    'Onion': {'current': 1800, 'min': 1200, 'max': 2400, 'change': -8.1},
    'Chickpea': {'current': 5500, 'min': 5100, 'max': 5900, 'change': 1.5},
    'Groundnut': {'current': 5800, 'min': 5400, 'max': 6200, 'change': 2.8},
  };
}
