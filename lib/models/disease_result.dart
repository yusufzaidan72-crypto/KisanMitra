class DiseaseResult {
  final String diseaseName;
  final String diseaseNameHindi;
  final double confidence;
  final List<String> symptoms;
  final List<String> recommendedActions;
  final List<String> preventionTips;
  final bool isDemo;
  final bool isRecognized;
  final String severity;
  final String affectedPart;

  const DiseaseResult({
    required this.diseaseName,
    required this.diseaseNameHindi,
    required this.confidence,
    required this.symptoms,
    required this.recommendedActions,
    required this.preventionTips,
    required this.isDemo,
    this.isRecognized = true,
    required this.severity,
    required this.affectedPart,
  });

  factory DiseaseResult.fromJson(Map<String, dynamic> json) => DiseaseResult(
        diseaseName: json['diseaseName'] as String? ?? '',
        diseaseNameHindi: json['diseaseNameHindi'] as String? ?? '',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        symptoms: (json['symptoms'] as List? ?? []).map((e) => e.toString()).toList(),
        recommendedActions: (json['recommendedActions'] as List? ?? []).map((e) => e.toString()).toList(),
        preventionTips: (json['preventionTips'] as List? ?? []).map((e) => e.toString()).toList(),
        isDemo: json['isDemo'] as bool? ?? false,
        isRecognized: json['isRecognized'] as bool? ?? true,
        severity: json['severity'] as String? ?? 'low',
        affectedPart: json['affectedPart'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'diseaseName': diseaseName,
        'diseaseNameHindi': diseaseNameHindi,
        'confidence': confidence,
        'symptoms': symptoms,
        'recommendedActions': recommendedActions,
        'preventionTips': preventionTips,
        'isDemo': isDemo,
        'isRecognized': isRecognized,
        'severity': severity,
        'affectedPart': affectedPart,
      };

  DiseaseResult copyWith({
    String? diseaseName,
    String? diseaseNameHindi,
    double? confidence,
    List<String>? symptoms,
    List<String>? recommendedActions,
    List<String>? preventionTips,
    bool? isDemo,
    bool? isRecognized,
    String? severity,
    String? affectedPart,
  }) {
    return DiseaseResult(
      diseaseName: diseaseName ?? this.diseaseName,
      diseaseNameHindi: diseaseNameHindi ?? this.diseaseNameHindi,
      confidence: confidence ?? this.confidence,
      symptoms: symptoms ?? this.symptoms,
      recommendedActions: recommendedActions ?? this.recommendedActions,
      preventionTips: preventionTips ?? this.preventionTips,
      isDemo: isDemo ?? this.isDemo,
      isRecognized: isRecognized ?? this.isRecognized,
      severity: severity ?? this.severity,
      affectedPart: affectedPart ?? this.affectedPart,
    );
  }

  String get severityEmoji {
    switch (severity.toLowerCase()) {
      case 'high': return '🔴';
      case 'medium': return '🟡';
      case 'low': return '🟢';
      default: return '⚪';
    }
  }
}

