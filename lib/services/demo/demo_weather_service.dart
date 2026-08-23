import '../interfaces/weather_service.dart';
import '../../models/weather_data.dart';

class DemoWeatherService implements WeatherService {
  @override
  Future<WeatherData> getCurrentWeather(String location) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return WeatherData(
      temperature: 32.5,
      feelsLike: 35.0,
      humidity: 68,
      windSpeed: 12.4,
      windDirection: 225,
      rainProbability: 35,
      rainfall: 0.0,
      condition: 'Partly Cloudy',
      conditionIcon: '⛅',
      location: location.isNotEmpty ? location : 'Lucknow, UP',
      lastUpdated: DateTime.now(),
      forecast: _getDemoForecast(),
      agriculturalAlerts: _getDemoAlerts(),
    );
  }

  @override
  Future<List<DayForecast>> getFiveDayForecast(String location) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _getDemoForecast();
  }

  @override
  Future<List<AgriculturalAlert>> getAgriculturalAlerts(
      String location, String cropName) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _getDemoAlerts();
  }

  List<DayForecast> _getDemoForecast() {
    final now = DateTime.now();
    return [
      DayForecast(
        date: now,
        maxTemp: 34,
        minTemp: 24,
        rainProbability: 35,
        rainfall: 0,
        condition: 'Partly Cloudy',
        icon: '⛅',
      ),
      DayForecast(
        date: now.add(const Duration(days: 1)),
        maxTemp: 36,
        minTemp: 25,
        rainProbability: 60,
        rainfall: 8,
        condition: 'Light Rain',
        icon: '🌦',
      ),
      DayForecast(
        date: now.add(const Duration(days: 2)),
        maxTemp: 29,
        minTemp: 22,
        rainProbability: 80,
        rainfall: 22,
        condition: 'Heavy Rain',
        icon: '🌧',
      ),
      DayForecast(
        date: now.add(const Duration(days: 3)),
        maxTemp: 31,
        minTemp: 23,
        rainProbability: 20,
        rainfall: 0,
        condition: 'Mostly Sunny',
        icon: '🌤',
      ),
      DayForecast(
        date: now.add(const Duration(days: 4)),
        maxTemp: 33,
        minTemp: 24,
        rainProbability: 10,
        rainfall: 0,
        condition: 'Sunny',
        icon: '☀️',
      ),
    ];
  }

  List<AgriculturalAlert> _getDemoAlerts() {
    return [
      const AgriculturalAlert(
        type: AlertType.heavyRain,
        title: 'Heavy Rain Expected',
        message: 'Heavy rainfall (22mm) expected in 2 days. Avoid spraying pesticides. Ensure proper drainage.',
        severity: AlertSeverity.warning,
      ),
      const AgriculturalAlert(
        type: AlertType.irrigation,
        title: 'Irrigation Advisory',
        message: 'Temperature is high today. Consider irrigating crops in the evening to reduce evaporation.',
        severity: AlertSeverity.info,
      ),
      const AgriculturalAlert(
        type: AlertType.sprayingNotSuitable,
        title: 'Avoid Spraying Today',
        message: 'Wind speed is above 15 km/h. Not suitable for pesticide or fertilizer spraying.',
        severity: AlertSeverity.warning,
      ),
    ];
  }
}
