import 'dart:typed_data';
import '../interfaces/disease_service.dart';
import '../../models/disease_result.dart';

class DemoDiseaseService implements DiseaseDetectionService {
  @override
  bool get isConfigured => false;

  @override
  Future<DiseaseResult> analyzeImage(Uint8List imageBytes, {String? fileName}) async {
    // Simulate analysis delay
    await Future.delayed(const Duration(seconds: 2));

    // Demo result - always clearly labeled
    return const DiseaseResult(
      diseaseName: 'Leaf Blight (Demo)',
      diseaseNameHindi: 'पत्ती झुलसा (डेमो)',
      confidence: 72.5,
      isDemo: true,
      severity: 'Medium',
      affectedPart: 'Leaves',
      symptoms: [
        'Brown or yellow spots on leaves',
        'Wilting of leaf edges',
        'Dark lesions spreading from leaf tip',
        'Premature leaf drop',
      ],
      recommendedActions: [
        'Remove and destroy infected leaves immediately',
        'Apply copper-based fungicide (Mancozeb 75% WP @ 2g/L)',
        'Improve air circulation by reducing plant density',
        'Avoid overhead irrigation; use drip if possible',
        'Consult your local Krishi Vigyan Kendra (KVK)',
      ],
      preventionTips: [
        'Use disease-resistant varieties',
        'Maintain proper spacing between plants',
        'Avoid waterlogging in fields',
        'Practice crop rotation every season',
        'Apply preventive fungicide before monsoon',
      ],
    );
  }
}
