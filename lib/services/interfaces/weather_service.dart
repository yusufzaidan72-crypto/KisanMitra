import '../../models/weather_data.dart';

abstract class WeatherService {
  Future<WeatherData> getCurrentWeather(String location);
  Future<List<DayForecast>> getFiveDayForecast(String location);
  Future<List<AgriculturalAlert>> getAgriculturalAlerts(String location, String cropName);
}
