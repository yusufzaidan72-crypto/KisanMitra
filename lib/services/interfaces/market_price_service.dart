import '../../models/market_price.dart';

abstract class MarketPriceService {
  Future<List<MarketPrice>> getPrices({
    required String cropName,
    required String state,
    String? market,
  });
  Future<List<String>> getAvailableMarkets(String state);
  bool get isConfigured;
}
