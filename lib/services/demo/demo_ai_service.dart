import '../interfaces/ai_irrigation_service.dart';

class DemoAIService implements AIAssistantService {
  static const Map<String, List<String>> _hiResponses = {
    'फसल': [
      'आपकी मिट्टी और मौसम के अनुसार, गेहूं और सरसों की खेती सबसे उपयुक्त रहेगी। अक्टूबर-नवंबर में बुवाई करें।\n\n⚠️ सलाह: बुवाई से पहले मिट्टी परीक्षण जरूर करवाएं।',
    ],
    'सिंचाई': [
      'आज का तापमान अधिक है। शाम 5-7 बजे के बीच सिंचाई करें — इससे पानी की बचत होगी और फसल को ज्यादा फायदा होगा।\n\n💡 टिप: ड्रिप सिंचाई से 40% पानी की बचत होती है।',
    ],
    'रोग': [
      'पत्तियों का पीला होना आमतौर पर नाइट्रोजन की कमी या पत्ती झुलसा रोग का संकेत है।\n\n✅ करें: यूरिया का छिड़काव करें (2% घोल) या Mancozeb फफूंदनाशक का उपयोग करें।\n⚠️ चेतावनी: अगर 3 दिनों में सुधार न हो तो KVK से संपर्क करें।',
    ],
    'बारिश': [
      'भारी बारिश से पहले ये काम करें:\n1. खेत में पानी निकासी की जांच करें\n2. कीटनाशक का छिड़काव रोक दें\n3. कटाई के लिए तैयार फसल को सुरक्षित जगह रखें\n4. मेड़बंदी मजबूत करें',
    ],
    'बाजार': [
      'इस समय गेहूं का भाव ₹2200-2400 प्रति क्विंटल है। बिक्री के लिए APMC मंडी जाएं या eNAM पोर्टल पर ऑनलाइन बेचें।\n\n💡 MSP की जानकारी के लिए PM-KISAN पोर्टल देखें।',
    ],
  };

  static const Map<String, List<String>> _enResponses = {
    'crop': [
      'Based on current season and weather, Wheat and Mustard are most suitable for your area. Sow in October-November for best yield.\n\n⚠️ Tip: Get your soil tested before sowing for best results.',
    ],
    'irrigat': [
      'With today\'s high temperature, irrigate your crops in the evening (5-7 PM) to minimize evaporation and maximize water absorption.\n\n💡 Tip: Drip irrigation can save up to 40% water.',
    ],
    'disease': [
      'Yellow leaves usually indicate Nitrogen deficiency or Leaf Blight disease.\n\n✅ Action: Apply 2% Urea spray or Mancozeb fungicide.\n⚠️ Warning: If no improvement in 3 days, consult your local KVK.',
    ],
    'yellow': [
      'Yellowing of leaves can have several causes:\n1. Nitrogen deficiency — apply Urea\n2. Leaf Blight — apply fungicide\n3. Waterlogging — improve drainage\n4. Iron deficiency — apply Ferrous Sulphate\n\nCheck the pattern of yellowing to identify the exact cause.',
    ],
    'rain': [
      'Before heavy rain:\n1. Check field drainage channels\n2. Stop pesticide spraying\n3. Secure mature/ready-to-harvest crops\n4. Strengthen bunds and ridges\n5. Harvest if crop is ready',
    ],
    'market': [
      'Current wheat price: ₹2200-2400 per quintal. Visit APMC Mandi or use eNAM online portal.\n\n💡 Check MSP rates at PM-KISAN portal before selling.',
    ],
    'protect': [
      'To protect your crop:\n1. Regular field monitoring (2x per week)\n2. Use IPM - Integrated Pest Management\n3. Apply preventive fungicide before monsoon\n4. Maintain field hygiene - remove crop debris\n5. Use certified disease-resistant seeds next season',
    ],
  };

  static const String _defaultHi =
      'आपका सवाल महत्वपूर्ण है। कृपया अपनी फसल का नाम, स्थान और समस्या की विस्तृत जानकारी दें, तो मैं बेहतर सलाह दे सकता हूं।\n\n📞 तुरंत मदद के लिए: किसान कॉल सेंटर — 1800-180-1551 (निःशुल्क)';

  static const String _defaultEn =
      'Please provide more details about your crop name, location, and the specific issue for better advice.\n\n📞 For immediate help: Kisan Call Center — 1800-180-1551 (Toll Free)';

  @override
  Future<String> askQuestion(String question, {String language = 'hi'}) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final q = question.toLowerCase();

    if (language == 'hi') {
      for (final entry in _hiResponses.entries) {
        if (q.contains(entry.key)) return entry.value.first;
      }
      // Also check English keywords for Hindi response
      for (final entry in _enResponses.entries) {
        if (q.contains(entry.key)) {
          return _hiResponses[_enToHiKey(entry.key)]?.first ?? _defaultHi;
        }
      }
      return _defaultHi;
    } else {
      for (final entry in _enResponses.entries) {
        if (q.contains(entry.key)) return entry.value.first;
      }
      return _defaultEn;
    }
  }

  @override
  Future<String> getContextualAdvice(String context) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return 'Based on current conditions: Ensure adequate water supply and monitor for pests. Contact your local agriculture officer for personalized guidance.';
  }

  String _enToHiKey(String enKey) {
    const map = {
      'crop': 'फसल',
      'irrigat': 'सिंचाई',
      'disease': 'रोग',
      'rain': 'बारिश',
      'market': 'बाजार',
    };
    return map[enKey] ?? '';
  }
}
