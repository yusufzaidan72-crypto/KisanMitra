class AppConstants {
  // App
  static const String appName = 'KisanMitra AI';
  static const String appVersion = '1.0.0';

  // Shared Preferences Keys
  static const String keyFarmerProfile = 'farmer_profile';
  static const String keySelectedLanguage = 'selected_language';
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyProfileComplete = 'profile_complete';
  static const String keyCropList = 'crop_list';
  static const String keyWeatherLocations = 'weather_locations';
  static const String keyLastWeatherLocation = 'last_weather_location';

  // Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'hi', 'name': 'हिंदी', 'englishName': 'Hindi'},
    {'code': 'en', 'name': 'English', 'englishName': 'English'},
    {'code': 'bn', 'name': 'বাংলা', 'englishName': 'Bengali'},
    {'code': 'mr', 'name': 'मराठी', 'englishName': 'Marathi'},
    {'code': 'ta', 'name': 'தமிழ்', 'englishName': 'Tamil'},
    {'code': 'te', 'name': 'తెలుగు', 'englishName': 'Telugu'},
  ];

  // Soil Types
  static const List<String> soilTypes = [
    'Alluvial Soil / जलोढ़ मिट्टी',
    'Black Soil / काली मिट्टी',
    'Red Soil / लाल मिट्टी',
    'Laterite Soil / लेटराइट मिट्टी',
    'Sandy Soil / रेतीली मिट्टी',
    'Clay Soil / चिकनी मिट्टी',
    'Loamy Soil / दोमट मिट्टी',
    'Saline Soil / लवणीय मिट्टी',
  ];

  // Indian States
  static const List<String> indianStates = [
    'Andhra Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
    'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra',
    'Odisha', 'Punjab', 'Rajasthan', 'Tamil Nadu',
    'Telangana', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
  ];

  // Common Crops
  static const List<String> commonCrops = [
    'Wheat / गेहूं', 'Rice / चावल', 'Maize / मक्का',
    'Cotton / कपास', 'Sugarcane / गन्ना', 'Soybean / सोयाबीन',
    'Mustard / सरसों', 'Potato / आलू', 'Tomato / टमाटर',
    'Onion / प्याज', 'Groundnut / मूंगफली', 'Chilli / मिर्च',
    'Turmeric / हल्दी', 'Garlic / लहसुन', 'Bajra / बाजरा',
    'Jowar / ज्वार', 'Lentil / मसूर', 'Chickpea / चना',
  ];

  // Growth Stages
  static const List<String> growthStages = [
    'Seed Germination / बीज अंकुरण',
    'Seedling / पौधा',
    'Vegetative Growth / वानस्पतिक वृद्धि',
    'Flowering / फूलना',
    'Fruiting / फलना',
    'Ripening / पकना',
    'Harvesting / कटाई',
  ];

  // Seasons
  static const List<String> seasons = [
    'Kharif (जून-नवंबर)', 'Rabi (नवंबर-अप्रैल)', 'Zaid (मार्च-जून)',
  ];

  // Market names (demo)
  static const List<String> demoMarkets = [
    'Azadpur Mandi, Delhi', 'APMC Mumbai, Maharashtra',
    'Bangalore APMC, Karnataka', 'Vashi Mandi, Navi Mumbai',
    'Guwahati APMC, Assam', 'Siliguri Mandi, West Bengal',
    'Ghazipur Mandi, Uttar Pradesh', 'Kolhapur APMC, Maharashtra',
  ];
}
