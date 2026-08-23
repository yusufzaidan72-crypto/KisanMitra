import 'interfaces/disease_service.dart';
import 'api/tflite_service.dart';
import 'demo/demo_disease_service.dart';

class DiseaseServiceFactory {
  static DiseaseDetectionService getService() {
    // Primary: Offline TFLite Model (No demo data shown)
    return TfliteService();
  }

  static DiseaseDetectionService getDemoService() {
    return DemoDiseaseService();
  }
}

