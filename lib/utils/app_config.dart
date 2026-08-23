import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static bool get isDemoMode {
    try {
      final val = dotenv.env['DEMO_MODE'] ?? 'false';
      return val.toLowerCase() == 'true';
    } catch (e) {
      debugPrint('AppConfig.isDemoMode fallback: $e');
      return false;
    }
  }

  static String get weatherApiKey {
    try {
      return dotenv.env['WEATHER_API_KEY'] ?? '';
    } catch (_) {
      return '';
    }
  }

  static String get geminiApiKey {
    try {
      return dotenv.env['GEMINI_API_KEY'] ?? '';
    } catch (_) {
      return '';
    }
  }

  static String get marketApiKey {
    try {
      return dotenv.env['MARKET_API_KEY'] ?? '';
    } catch (_) {
      return '';
    }
  }

  static String get diseaseApiUrl {
    try {
      return dotenv.env['DISEASE_API_URL'] ?? '';
    } catch (_) {
      return '';
    }
  }

  static String get hfApiToken {
    try {
      return dotenv.env['HF_API_TOKEN'] ?? '';
    } catch (_) {
      return '';
    }
  }

  static String get defaultLanguage {
    try {
      return dotenv.env['DEFAULT_LANGUAGE'] ?? 'hi';
    } catch (_) {
      return 'hi';
    }
  }

  static bool get hasWeatherApi => weatherApiKey.isNotEmpty;
  static bool get hasGeminiApi => geminiApiKey.isNotEmpty;
  static bool get hasMarketApi => marketApiKey.isNotEmpty;
  static bool get hasDiseaseApi => diseaseApiUrl.isNotEmpty;
  static bool get hasHfToken => hfApiToken.isNotEmpty;

  static void debugPrintConfig() {
    debugPrint('🛠️ --- App Configuration Debug ---');
    debugPrint('🔹 Demo Mode: $isDemoMode');
    debugPrint('🔹 Weather API Key: ${weatherApiKey.length > 5 ? "${weatherApiKey.substring(0, 5)}***" : "Empty"}');
    debugPrint('🔹 Disease Detection: Local Plant Disease Database (Offline)');
    debugPrint('🔹 Default Language: $defaultLanguage');
    debugPrint('🛠️ --------------------------------');
  }
}
