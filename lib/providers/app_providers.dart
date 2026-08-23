import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import '../models/weather_data.dart';
import '../models/crop_monitor.dart';
import '../services/demo/demo_weather_service.dart';
import '../services/api/weather_api_service.dart';
import '../services/api/firestore_service.dart';
import '../models/farmer_profile.dart';
import '../services/interfaces/weather_service.dart';
import '../core/constants/app_constants.dart';
import '../core/config/app_config.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherData? _weather;
  bool _isLoading = false;
  String? _error;
  String _currentCity = '';
  List<String> _savedLocations = [];
  
  final WeatherService _realService = WeatherApiService();
  final WeatherService _demoService = DemoWeatherService();

  WeatherData? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentCity => _currentCity;
  List<String> get savedLocations => List.unmodifiable(_savedLocations);

  WeatherService get _activeService => AppConfig.isDemoMode ? _demoService : _realService;

  Future<void> init() async {
    await loadSavedLocations();
    if (_currentCity.isNotEmpty) {
      await fetchWeather(_currentCity);
    }
  }

  Future<void> loadSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    _savedLocations = prefs.getStringList(AppConstants.keyWeatherLocations) ?? [];
    _currentCity = prefs.getString(AppConstants.keyLastWeatherLocation) ?? '';
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.keyWeatherLocations, _savedLocations);
    await prefs.setString(AppConstants.keyLastWeatherLocation, _currentCity);
  }

  Future<void> fetchWeather(String location) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final query = location.trim().isEmpty ? 'Lucknow' : location.trim();
      _weather = await _activeService.getCurrentWeather(query);
      _currentCity = _weather?.location.split(',').first.trim() ?? query;
      
      if (!_savedLocations.contains(_currentCity)) {
        _savedLocations.add(_currentCity);
      }
      await _persist();
    } catch (e) {
      debugPrint('Weather Fetch Error: $e');
      _error = e.toString().contains('Exception:') ? e.toString().split('Exception: ')[1] : 'Unable to fetch weather.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeLocation(String location) async {
    _savedLocations.remove(location);
    if (_currentCity == location) {
      _currentCity = _savedLocations.isNotEmpty ? _savedLocations.first : '';
    }
    await _persist();
    notifyListeners();
  }

  Future<void> fetchWeatherWithGPS() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied.');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        ),
      );
      
      String query = '${position.latitude},${position.longitude}';
      _weather = await _activeService.getCurrentWeather(query);
      _currentCity = _weather?.location.split(',').first.trim() ?? '';
      
      if (!_savedLocations.contains(_currentCity)) {
        _savedLocations.insert(0, _currentCity);
      }
      await _persist();
    } catch (e) {
      debugPrint('Location/Weather Error: $e');
      if (e.toString().contains('denied')) {
        _error = 'Location permission denied. Please allow in settings.';
      } else if (e.toString().contains('disabled')) {
        _error = 'Location services are OFF. Please turn on GPS.';
      } else if (e.toString().contains('timeout')) {
        _error = 'Location fetch timed out. Showing default weather.';
      } else {
        _error = 'Could not find your location. Showing Lucknow.';
      }
      
      // Fallback to default weather
      if (_currentCity.isEmpty) {
        await fetchWeather('');
      } else {
        await fetchWeather(_currentCity);
      }
      notifyListeners(); 
    }
    _isLoading = false;
    notifyListeners();
  }
}

class LanguageProvider extends ChangeNotifier {
  String _languageCode = 'hi';

  String get languageCode => _languageCode;
  Locale get locale => Locale(_languageCode);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _languageCode = prefs.getString(AppConstants.keySelectedLanguage) ?? 'hi';
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keySelectedLanguage, code);
    notifyListeners();
  }
}

class CropMonitorProvider extends ChangeNotifier {
  final List<CropMonitor> _crops = [];
  bool _isLoading = false;

  List<CropMonitor> get crops => List.unmodifiable(_crops);
  bool get isLoading => _isLoading;

  Future<void> loadCrops() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> jsonList = prefs.getStringList(AppConstants.keyCropList) ?? [];
      _crops.clear();
      for (var jsonStr in jsonList) {
        _crops.add(CropMonitor.fromJson(jsonDecode(jsonStr)));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading crops: $e');
    }
  }

  /// Automatically fetch crops from Firestore for given user UID and update local state
  Future<void> loadCropsForUser(String? uid) async {
    if (uid == null || uid.isEmpty) {
      await loadCrops();
      return;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final data = await FirestoreFarmerService().fetchFarmerData(uid);
      if (data != null && data.containsKey('crops')) {
        final rawCrops = data['crops'] as List<dynamic>? ?? [];
        _crops.clear();
        for (var cMap in rawCrops) {
          if (cMap is Map) {
            _crops.add(CropMonitor.fromJson(Map<String, dynamic>.from(cMap)));
          }
        }
        await _persist();
      } else {
        await loadCrops();
      }
    } catch (e) {
      debugPrint('Error loading crops from Firestore for user $uid: $e');
      await loadCrops();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCrop(CropMonitor crop, [String? userId, FarmerProfile? profile]) async {
    _crops.add(crop);
    notifyListeners();
    await _persist(userId, profile);
  }

  Future<void> removeCrop(String id, [String? userId, FarmerProfile? profile]) async {
    _crops.removeWhere((c) => c.id == id);
    notifyListeners();
    await _persist(userId, profile);
  }

  Future<void> clearCrops() async {
    _crops.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyCropList);
    notifyListeners();
  }

  Future<void> _persist([String? userId, FarmerProfile? profile]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> jsonList = _crops.map((c) => jsonEncode(c.toJson())).toList();
      await prefs.setStringList(AppConstants.keyCropList, jsonList);

      // Sync crops array live to Cloud Firestore if profile exists
      if (profile != null && userId != null && userId.isNotEmpty) {
        FirestoreFarmerService().saveFarmerData(
          uid: userId,
          profile: profile,
          crops: _crops,
        );
      }
    } catch (e) {
      debugPrint('Error persisting crops: $e');
    }
  }
}
