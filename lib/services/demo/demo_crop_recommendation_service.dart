import '../interfaces/crop_recommendation_service.dart';
import '../../models/crop_recommendation.dart';

class DemoCropRecommendationService implements CropRecommendationService {
  @override
  Future<List<CropRecommendation>> getRecommendations(
      CropRecommendationInput input) async {
    await Future.delayed(const Duration(seconds: 1));

    final season = input.season.toLowerCase();


    // Rule-based demo engine
    final allCrops = _getAllCropDatabase();
    final scored = allCrops.map((crop) {
      double score = crop.suitabilityScore;
      if (season.contains('kharif') && _kharifCrops.contains(crop.cropName)) {
        score = (score + 0.1).clamp(0.0, 1.0);
      }
      if (season.contains('rabi') && _rabiCrops.contains(crop.cropName)) {
        score = (score + 0.1).clamp(0.0, 1.0);
      }
      if (input.temperature > 30 && _hotWeatherCrops.contains(crop.cropName)) {
        score = (score + 0.05).clamp(0.0, 1.0);
      }
      if (input.rainfall > 800 && _highRainfallCrops.contains(crop.cropName)) {
        score = (score + 0.05).clamp(0.0, 1.0);
      }
      return CropRecommendation(
        cropName: crop.cropName,
        cropNameHindi: crop.cropNameHindi,
        suitabilityScore: score,
        waterRequirement: crop.waterRequirement,
        growingDuration: crop.growingDuration,
        season: crop.season,
        reason: crop.reason,
        soilSuitability: crop.soilSuitability,
        tips: crop.tips,
        expectedYield: crop.expectedYield,
        icon: crop.icon,
      );
    }).toList();

    scored.sort((a, b) => b.suitabilityScore.compareTo(a.suitabilityScore));
    return scored.take(5).toList();
  }

  static const List<String> _kharifCrops = ['Rice', 'Cotton', 'Maize', 'Soybean', 'Bajra'];
  static const List<String> _rabiCrops = ['Wheat', 'Mustard', 'Chickpea', 'Lentil', 'Potato'];
  static const List<String> _hotWeatherCrops = ['Cotton', 'Maize', 'Bajra', 'Groundnut'];
  static const List<String> _highRainfallCrops = ['Rice', 'Maize', 'Sugarcane'];

  List<CropRecommendation> _getAllCropDatabase() {
    return [
      const CropRecommendation(
        cropName: 'Wheat',
        cropNameHindi: 'गेहूं',
        suitabilityScore: 0.88,
        waterRequirement: 'Medium (450-650mm)',
        growingDuration: '120-150 days',
        season: 'Rabi',
        reason: 'Ideal for your soil type and temperature range. High market demand.',
        soilSuitability: 'Loamy, Clay Loam',
        expectedYield: '25-35 quintals/acre',
        icon: '🌾',
        tips: [
          'Sow in October-November for best yield',
          'Apply DAP at 50kg/acre at sowing',
          'First irrigation at 20-25 days after sowing',
          'Watch for Yellow Rust disease in February',
        ],
      ),
      const CropRecommendation(
        cropName: 'Rice',
        cropNameHindi: 'धान',
        suitabilityScore: 0.82,
        waterRequirement: 'High (1000-2000mm)',
        growingDuration: '90-120 days',
        season: 'Kharif',
        reason: 'Suitable for high rainfall areas. Good market price in current season.',
        soilSuitability: 'Clay, Heavy Loam',
        expectedYield: '20-30 quintals/acre',
        icon: '🌾',
        tips: [
          'Transplant seedlings at 25-30 days age',
          'Maintain 5cm standing water in early stages',
          'Apply Zinc Sulphate for deficiency',
          'Watch for stem borer and BPH pests',
        ],
      ),
      const CropRecommendation(
        cropName: 'Maize',
        cropNameHindi: 'मक्का',
        suitabilityScore: 0.79,
        waterRequirement: 'Medium (500-800mm)',
        growingDuration: '80-110 days',
        season: 'Kharif',
        reason: 'Good for warm temperatures. Growing industrial demand for animal feed.',
        soilSuitability: 'Sandy Loam, Loam',
        expectedYield: '18-25 quintals/acre',
        icon: '🌽',
        tips: [
          'Plant at 60x20cm spacing',
          'Apply Urea in split doses',
          'Control Fall Armyworm early',
          'Ensure good drainage',
        ],
      ),
      const CropRecommendation(
        cropName: 'Soybean',
        cropNameHindi: 'सोयाबीन',
        suitabilityScore: 0.76,
        waterRequirement: 'Medium (500-700mm)',
        growingDuration: '95-120 days',
        season: 'Kharif',
        reason: 'Nitrogen-fixing crop. Improves soil health. High protein demand.',
        soilSuitability: 'Well-drained Loam, Clay Loam',
        expectedYield: '10-15 quintals/acre',
        icon: '🫘',
        tips: [
          'Treat seeds with Rhizobium culture',
          'Avoid waterlogging — ensure drainage',
          'Use broad-leaf weedicides at 2-3 weeks',
          'Harvest when 95% pods turn brown',
        ],
      ),
      const CropRecommendation(
        cropName: 'Mustard',
        cropNameHindi: 'सरसों',
        suitabilityScore: 0.74,
        waterRequirement: 'Low (250-400mm)',
        growingDuration: '90-120 days',
        season: 'Rabi',
        reason: 'Low water requirement. Good for dry areas. Strong market in northern India.',
        soilSuitability: 'Sandy Loam, Loam',
        expectedYield: '6-10 quintals/acre',
        icon: '🌻',
        tips: [
          'Sow in October for optimal yield',
          'Apply Sulphur fertilizer for better oil content',
          'Watch for Alternaria blight disease',
          'Harvest before pods start shattering',
        ],
      ),
      const CropRecommendation(
        cropName: 'Chickpea',
        cropNameHindi: 'चना',
        suitabilityScore: 0.71,
        waterRequirement: 'Low (300-500mm)',
        growingDuration: '90-110 days',
        season: 'Rabi',
        reason: 'Drought tolerant. Fixes atmospheric nitrogen. High pulse demand.',
        soilSuitability: 'Sandy Loam, Black Soil',
        expectedYield: '8-12 quintals/acre',
        icon: '🫘',
        tips: [
          'Treat seeds with Rhizobium + Phosphate solubilizing bacteria',
          'Avoid excessive nitrogen fertilizer',
          'Control pod borer with Bt spray',
          'One irrigation at flowering stage is critical',
        ],
      ),
    ];
  }
}
