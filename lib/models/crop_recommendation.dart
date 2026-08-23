class CropRecommendation {
  final String cropName;
  final String cropNameHindi;
  final double suitabilityScore;
  final String waterRequirement;
  final String growingDuration;
  final String season;
  final String reason;
  final String soilSuitability;
  final List<String> tips;
  final String expectedYield;
  final String icon;

  const CropRecommendation({
    required this.cropName,
    required this.cropNameHindi,
    required this.suitabilityScore,
    required this.waterRequirement,
    required this.growingDuration,
    required this.season,
    required this.reason,
    required this.soilSuitability,
    required this.tips,
    required this.expectedYield,
    required this.icon,
  });

  factory CropRecommendation.fromJson(Map<String, dynamic> json) => CropRecommendation(
        cropName: json['cropName'] as String? ?? '',
        cropNameHindi: json['cropNameHindi'] as String? ?? '',
        suitabilityScore: (json['suitabilityScore'] as num?)?.toDouble() ?? 0.0,
        waterRequirement: json['waterRequirement'] as String? ?? '',
        growingDuration: json['growingDuration'] as String? ?? '',
        season: json['season'] as String? ?? '',
        reason: json['reason'] as String? ?? '',
        soilSuitability: json['soilSuitability'] as String? ?? '',
        tips: (json['tips'] as List? ?? []).map((e) => e.toString()).toList(),
        expectedYield: json['expectedYield'] as String? ?? '',
        icon: json['icon'] as String? ?? '🌾',
      );

  Map<String, dynamic> toJson() => {
        'cropName': cropName,
        'cropNameHindi': cropNameHindi,
        'suitabilityScore': suitabilityScore,
        'waterRequirement': waterRequirement,
        'growingDuration': growingDuration,
        'season': season,
        'reason': reason,
        'soilSuitability': soilSuitability,
        'tips': tips,
        'expectedYield': expectedYield,
        'icon': icon,
      };

  String get suitabilityLabel {
    if (suitabilityScore >= 0.85) return 'Excellent';
    if (suitabilityScore >= 0.70) return 'Good';
    if (suitabilityScore >= 0.55) return 'Moderate';
    return 'Low';
  }
}

class CropRecommendationInput {
  final String location;
  final String state;
  final String soilType;
  final double soilPh;
  final double temperature;
  final double rainfall;
  final String waterAvailability;
  final String season;

  const CropRecommendationInput({
    required this.location,
    required this.state,
    required this.soilType,
    required this.soilPh,
    required this.temperature,
    required this.rainfall,
    required this.waterAvailability,
    required this.season,
  });

  factory CropRecommendationInput.fromJson(Map<String, dynamic> json) => CropRecommendationInput(
        location: json['location'] as String? ?? '',
        state: json['state'] as String? ?? '',
        soilType: json['soilType'] as String? ?? '',
        soilPh: (json['soilPh'] as num?)?.toDouble() ?? 7.0,
        temperature: (json['temperature'] as num?)?.toDouble() ?? 25.0,
        rainfall: (json['rainfall'] as num?)?.toDouble() ?? 100.0,
        waterAvailability: json['waterAvailability'] as String? ?? '',
        season: json['season'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'location': location,
        'state': state,
        'soilType': soilType,
        'soilPh': soilPh,
        'temperature': temperature,
        'rainfall': rainfall,
        'waterAvailability': waterAvailability,
        'season': season,
      };
}

