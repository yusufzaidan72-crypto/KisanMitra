import 'dart:typed_data';
import '../../models/disease_result.dart';

abstract class DiseaseDetectionService {
  Future<DiseaseResult> analyzeImage(Uint8List imageBytes, {String? fileName});
  bool get isConfigured;
}
