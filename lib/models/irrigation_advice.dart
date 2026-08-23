class IrrigationAdvice {
  final bool irrigationRecommended;
  final String timing;
  final double waterAmount;
  final String unit;
  final String reason;
  final List<String> generalGuidance;
  final String nextIrrigationDate;
  final IrrigationMethod method;

  const IrrigationAdvice({
    required this.irrigationRecommended,
    required this.timing,
    required this.waterAmount,
    required this.unit,
    required this.reason,
    required this.generalGuidance,
    required this.nextIrrigationDate,
    required this.method,
  });

  factory IrrigationAdvice.fromJson(Map<String, dynamic> json) => IrrigationAdvice(
        irrigationRecommended: json['irrigationRecommended'] as bool? ?? false,
        timing: json['timing'] as String? ?? '',
        waterAmount: (json['waterAmount'] as num?)?.toDouble() ?? 0.0,
        unit: json['unit'] as String? ?? 'liters/sq.m',
        reason: json['reason'] as String? ?? '',
        generalGuidance: (json['generalGuidance'] as List? ?? []).map((e) => e.toString()).toList(),
        nextIrrigationDate: json['nextIrrigationDate'] as String? ?? '',
        method: IrrigationMethod.values.firstWhere(
          (e) => e.name == json['method'],
          orElse: () => IrrigationMethod.drip,
        ),
      );

  Map<String, dynamic> toJson() => {
        'irrigationRecommended': irrigationRecommended,
        'timing': timing,
        'waterAmount': waterAmount,
        'unit': unit,
        'reason': reason,
        'generalGuidance': generalGuidance,
        'nextIrrigationDate': nextIrrigationDate,
        'method': method.name,
      };
}

class IrrigationInput {
  final String cropName;
  final String growthStage;
  final String soilType;
  final double recentRainfall;
  final double temperature;
  final double humidity;
  final String weatherForecast;

  const IrrigationInput({
    required this.cropName,
    required this.growthStage,
    required this.soilType,
    required this.recentRainfall,
    required this.temperature,
    required this.humidity,
    required this.weatherForecast,
  });

  factory IrrigationInput.fromJson(Map<String, dynamic> json) => IrrigationInput(
        cropName: json['cropName'] as String? ?? '',
        growthStage: json['growthStage'] as String? ?? '',
        soilType: json['soilType'] as String? ?? '',
        recentRainfall: (json['recentRainfall'] as num?)?.toDouble() ?? 0.0,
        temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
        humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
        weatherForecast: json['weatherForecast'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'cropName': cropName,
        'growthStage': growthStage,
        'soilType': soilType,
        'recentRainfall': recentRainfall,
        'temperature': temperature,
        'humidity': humidity,
        'weatherForecast': weatherForecast,
      };
}

enum IrrigationMethod { drip, sprinkler, flood, furrow, none }

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String? ?? '',
        text: json['text'] as String? ?? '',
        isUser: json['isUser'] as bool? ?? false,
        timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp'] as String) : DateTime.now(),
        isLoading: json['isLoading'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'isLoading': isLoading,
      };
}

