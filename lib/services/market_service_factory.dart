import 'api/agmarknet_service.dart';
import 'interfaces/market_price_service.dart';
import '../core/config/app_config.dart';

class MarketServiceFactory {
  static MarketPriceService getService() {
    // If not demo mode or if Agmarknet service is available, return live Agmarknet API service
    if (!AppConfig.isDemoMode || AppConfig.hasMarketApi) {
      return AgmarknetService();
    }
    // Return live Agmarknet service as primary working service
    return AgmarknetService();
  }
}
