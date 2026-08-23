import '../../models/crop_recommendation.dart';

abstract class CropRecommendationService {
  Future<List<CropRecommendation>> getRecommendations(CropRecommendationInput input);
}
