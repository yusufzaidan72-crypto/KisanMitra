class WeatherData {
  final double temperature;
  final double feelsLike;
  final double humidity;
  final double windSpeed;
  final int windDirection;
  final double rainProbability;
  final double rainfall;
  final String condition;
  final String conditionIcon;
  final String location;
  final DateTime lastUpdated;
  final List<DayForecast> forecast;
  final List<AgriculturalAlert> agriculturalAlerts;

  const WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.rainProbability,
    required this.rainfall,
    required this.condition,
    required this.conditionIcon,
    required this.location,
    required this.lastUpdated,
    required this.forecast,
    required this.agriculturalAlerts,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
        temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
        feelsLike: (json['feelsLike'] as num?)?.toDouble() ?? 0.0,
        humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
        windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0.0,
        windDirection: (json['windDirection'] as num?)?.toInt() ?? 0,
        rainProbability: (json['rainProbability'] as num?)?.toDouble() ?? 0.0,
        rainfall: (json['rainfall'] as num?)?.toDouble() ?? 0.0,
        condition: json['condition'] as String? ?? '',
        conditionIcon: json['conditionIcon'] as String? ?? '01d',
        location: json['location'] as String? ?? '',
        lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated'] as String) : DateTime.now(),
        forecast: (json['forecast'] as List? ?? [])
            .map((item) => DayForecast.fromJson(item as Map<String, dynamic>))
            .toList(),
        agriculturalAlerts: (json['agriculturalAlerts'] as List? ?? [])
            .map((item) => AgriculturalAlert.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'feelsLike': feelsLike,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'windDirection': windDirection,
        'rainProbability': rainProbability,
        'rainfall': rainfall,
        'condition': condition,
        'conditionIcon': conditionIcon,
        'location': location,
        'lastUpdated': lastUpdated.toIso8601String(),
        'forecast': forecast.map((f) => f.toJson()).toList(),
        'agriculturalAlerts': agriculturalAlerts.map((a) => a.toJson()).toList(),
      };
}

class DayForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final double rainProbability;
  final double rainfall;
  final String condition;
  final String icon;

  const DayForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.rainProbability,
    required this.rainfall,
    required this.condition,
    required this.icon,
  });

  factory DayForecast.fromJson(Map<String, dynamic> json) => DayForecast(
        date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
        maxTemp: (json['maxTemp'] as num?)?.toDouble() ?? 0.0,
        minTemp: (json['minTemp'] as num?)?.toDouble() ?? 0.0,
        rainProbability: (json['rainProbability'] as num?)?.toDouble() ?? 0.0,
        rainfall: (json['rainfall'] as num?)?.toDouble() ?? 0.0,
        condition: json['condition'] as String? ?? '',
        icon: json['icon'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'maxTemp': maxTemp,
        'minTemp': minTemp,
        'rainProbability': rainProbability,
        'rainfall': rainfall,
        'condition': condition,
        'icon': icon,
      };
}

class AgriculturalAlert {
  final AlertType type;
  final String title;
  final String message;
  final AlertSeverity severity;

  const AgriculturalAlert({
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
  });

  factory AgriculturalAlert.fromJson(Map<String, dynamic> json) => AgriculturalAlert(
        type: AlertType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => AlertType.heavyRain,
        ),
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        severity: AlertSeverity.values.firstWhere(
          (e) => e.name == json['severity'],
          orElse: () => AlertSeverity.info,
        ),
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'title': title,
        'message': message,
        'severity': severity.name,
      };
}

enum AlertType { heavyRain, highTemp, lowTemp, strongWind, irrigation, sprayingSuitable, sprayingNotSuitable, frost }

enum AlertSeverity { info, warning, critical }

