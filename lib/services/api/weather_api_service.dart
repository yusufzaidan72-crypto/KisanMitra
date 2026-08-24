import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/weather_data.dart';
import '../interfaces/weather_service.dart';
import '../demo/demo_weather_service.dart';
import '../../core/config/app_config.dart';

class WeatherApiService implements WeatherService {
  final String _baseUrl = 'https://api.weatherapi.com/v1';
  final DemoWeatherService _fallback = DemoWeatherService();

  @override
  Future<WeatherData> getCurrentWeather(String location) async {
    final apiKey = AppConfig.weatherApiKey;
    if (apiKey.isEmpty) {
      return _fallback.getCurrentWeather(location);
    }

    final query = location.isEmpty ? 'Lucknow' : location;
    final url = Uri.parse('$_baseUrl/forecast.json?key=$apiKey&q=$query&days=5&aqi=no&alerts=yes');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseWeatherData(data);
      }
    } catch (e) {
      debugPrint('Weather API fallback to demo: $e');
    }
    return _fallback.getCurrentWeather(location);
  }

  @override
  Future<List<DayForecast>> getFiveDayForecast(String location) async {
    final data = await getCurrentWeather(location);
    return data.forecast;
  }

  @override
  Future<List<AgriculturalAlert>> getAgriculturalAlerts(
      String location, String cropName) async {
    final data = await getCurrentWeather(location);
    return data.agriculturalAlerts;
  }

  WeatherData _parseWeatherData(Map<String, dynamic> data) {
    final current = data['current'];
    final location = data['location'];
    final forecastDays = data['forecast']['forecastday'] as List;

    final List<DayForecast> forecastList = forecastDays.map((day) {
      final dateStr = day['date'] as String;
      final dayData = day['day'];
      return DayForecast(
        date: DateTime.parse(dateStr),
        maxTemp: (dayData['maxtemp_c'] as num).toDouble(),
        minTemp: (dayData['mintemp_c'] as num).toDouble(),
        rainProbability: (dayData['daily_chance_of_rain'] as num).toDouble(),
        rainfall: (dayData['totalprecip_mm'] as num).toDouble(),
        condition: dayData['condition']['text'],
        icon: _getEmojiForCondition(dayData['condition']['text']),
      );
    }).toList();

    return WeatherData(
      temperature: (current['temp_c'] as num).toDouble(),
      feelsLike: (current['feelslike_c'] as num).toDouble(),
      humidity: (current['humidity'] as num).toDouble(),
      windSpeed: (current['wind_kph'] as num).toDouble(),
      windDirection: (current['wind_degree'] as num).toInt(),
      rainProbability: forecastList.isNotEmpty ? forecastList.first.rainProbability : 0,
      rainfall: (current['precip_mm'] as num).toDouble(),
      condition: current['condition']['text'],
      conditionIcon: _getEmojiForCondition(current['condition']['text']),
      location: '${location['name']}, ${location['region']}',
      lastUpdated: DateTime.now(),
      forecast: forecastList,
      agriculturalAlerts: _generateAgriAlerts(current, forecastList),
    );
  }

  String _getEmojiForCondition(String text) {
    final t = text.toLowerCase();
    if (t.contains('sun') || t.contains('clear')) return '☀️';
    if (t.contains('cloud') && t.contains('partly')) return '⛅';
    if (t.contains('cloud')) return '☁️';
    if (t.contains('rain') || t.contains('drizzle')) return '🌧️';
    if (t.contains('thunder')) return '⛈️';
    if (t.contains('snow')) return '❄️';
    if (t.contains('mist') || t.contains('fog')) return '🌫️';
    return '🌡️';
  }

  List<AgriculturalAlert> _generateAgriAlerts(Map<String, dynamic> current, List<DayForecast> forecast) {
    final List<AgriculturalAlert> alerts = [];
    final wind = (current['wind_kph'] as num).toDouble();
    final temp = (current['temp_c'] as num).toDouble();

    if (wind > 15) {
      alerts.add(const AgriculturalAlert(
        type: AlertType.sprayingNotSuitable,
        title: 'Avoid Spraying Today',
        message: 'Wind speed is high. Pesticide spraying might drift.',
        severity: AlertSeverity.warning,
      ));
    }

    if (temp > 35) {
      alerts.add(const AgriculturalAlert(
        type: AlertType.irrigation,
        title: 'Heat Stress Warning',
        message: 'High temperatures detected. Increase irrigation frequency.',
        severity: AlertSeverity.warning,
      ));
    }

    for (var i = 1; i < 3 && i < forecast.length; i++) {
      if (forecast[i].rainProbability > 70) {
        alerts.add(AgriculturalAlert(
          type: AlertType.heavyRain,
          title: 'Rain Expected',
          message: 'High chance of rain on ${forecast[i].date.day}/${forecast[i].date.month}. Plan harvesting accordingly.',
          severity: AlertSeverity.info,
        ));
        break;
      }
    }

    return alerts;
  }
}
