import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('bn'),
    Locale('mr'),
    Locale('ta'),
    Locale('te'),
  ];

  bool get isHindi => locale.languageCode == 'hi';

  String _t(String enText, String hiText, {String? bn, String? mr, String? ta, String? te}) {
    switch (locale.languageCode) {
      case 'hi': return hiText;
      case 'bn': return bn ?? enText;
      case 'mr': return mr ?? hiText;
      case 'ta': return ta ?? enText;
      case 'te': return te ?? enText;
      default: return enText;
    }
  }

  // App
  String get appName => _t('KisanMitra AI', 'किसान मित्र AI', 
    bn: 'কিষাণমিত্র এআই', mr: 'किसानमित्र एआय', ta: 'கிசான்மித்ரா ஏஐ', te: 'కిసాన్ మిత్ర AI');
  String get loading => _t('Loading...', 'लोड हो रहा है...', 
    bn: 'লোড হচ্ছে...', mr: 'लोड होत आहे...', ta: 'ஏற்றுகிறது...', te: 'లోడ్ అవుతోంది...');
  String get retry => _t('Retry', 'पुनः प्रयास करें',
    bn: 'আবার চেষ্টা করুন', mr: 'पुन्हा प्रयत्न करा', ta: 'மீண்டும் முயற்சிக்கவும்', te: 'మళ్లీ ప్రయత్నించండి');
  String get cancel => _t('Cancel', 'रद्द करें',
    bn: 'বাতিল করুন', mr: 'रद्द करा', ta: 'ரத்து செய்', te: 'రద్దు చేయి');
  String get save => _t('Save', 'सहेजें',
    bn: 'সংরক্ষণ করুন', mr: 'जतन करा', ta: 'சேமி', te: 'సేవ్ చేయి');
  String get next => _t('Next', 'आगे',
    bn: 'পরবর্তী', mr: 'पुढे', ta: 'அடுத்தது', te: 'తరువాత');
  String get back => _t('Back', 'पीछे',
    bn: 'পিছনে', mr: 'मागे', ta: 'பின்னால்', te: 'వెనుకకు');
  String get edit => _t('Edit', 'संपादित करें',
    bn: 'সম্পাদনা করুন', mr: 'संपादित करा', ta: 'தொகு', te: 'சవరించు');
  String get submit => _t('Submit', 'जमा करें',
    bn: 'জমা দিন', mr: 'सादर करा', ta: 'சமர்ப்பி', te: 'சమర్పించు');
  String get analyze => _t('Analyze', 'विश्लेषण करें',
    bn: 'বিশ্লেষণ করুন', mr: 'विश्लेषण करा', ta: 'பகுப்பாய்வு செய்', te: 'విశ్లేషించు');
  String get demoMode => _t('DEMO MODE', 'डेमो मोड');

  // Home
  String get goodMorning => _t('Good Morning', 'शुभ प्रभात',
    bn: 'সুপ্রভাত', mr: 'शुभ सकाळ', ta: 'காலை வணக்கம்', te: 'శుభోదయం');
  String get goodAfternoon => _t('Good Afternoon', 'नमस्ते',
    bn: 'শুভ অপরাহ্ন', mr: 'नमस्कार', ta: 'மதிய வணக்கம்', te: 'శుభ మధ్యాహ్నం');
  String get goodEvening => _t('Good Evening', 'शुभ संध्या',
    bn: 'শুভ সন্ধ্যা', mr: 'शुभ संध्याकाळ', ta: 'மாலை வணக்கம்', te: 'శుభ సాయంత్రं');
  String get farmer => _t('Farmer', 'किसान',
    bn: 'কৃষক', mr: 'शेतकरी', ta: 'விவசாயி', te: 'రైతు');
  String get dashboard => _t('Dashboard', 'डैशबोर्ड',
    bn: 'ড্যাশবোর্ড', mr: 'ডॅशबोर्ड', ta: 'டாஷ்போர்டு', te: 'డ్యాష్‌బోర్డ్');
  String get currentWeather => _t('Current Weather', 'मौजूदा मौसम',
    bn: 'বর্তমান আবহাওয়া', mr: 'सध्याचे हवामान', ta: 'தற்போதைய வானிலை', te: 'ప్రస్తుత వాతావరణం');
  String get currentCrop => _t('Current Crop', 'वर्तमान फसल',
    bn: 'বর্তমান ফসল', mr: 'सध्याचे पीक', ta: 'தற்போதைய பயிர்', te: 'ప్రస్తుత పంట');
  String get cropHealth => _t('Crop Health', 'फसल स्वास्थ्य',
    bn: 'ফসলের স্বাস্থ্য', mr: 'पिकाचे आरोग्य', ta: 'பயிர் ஆரோக்கியம்', te: 'పంట ఆరోగ్యం');
  String get irrigationStatus => _t('Irrigation Status', 'सिंचाई स्थिति',
    bn: 'সেচ অবস্থা', mr: 'सिंचन स्थिती', ta: 'பாசன நிலை', te: 'నీటిపారుదల స్థితి');
  String get quickActions => _t('Quick Actions', 'त्वरित कार्य',
    bn: 'দ্রুত পদক্ষেপ', mr: 'त्वरीत कृती', ta: 'விரைவான நடவடிக்கைகள்', te: 'శీఘ్ర చర్యలు');
  String get weatherAlerts => _t('Weather Alerts', 'मौसम चेतावनी',
    bn: 'আবহাওয়া সতর্কতা', mr: 'हवामान सूचना', ta: 'வானிலை எச்சரிக்கைகள்', te: 'వాతావరణ హెచ్చరికలు');

  // Navigation
  String get home => _t('Home', 'होम',
    bn: 'হোম', mr: 'होम', ta: 'முகப்பு', te: 'హోమ్');
  String get crops => _t('Crops', 'फसल',
    bn: 'ফসল', mr: 'पिके', ta: 'பயிர்கள்', te: 'పంటలు');
  String get scan => _t('Scan', 'स्कैन',
    bn: 'স্ক্যান', mr: 'स्कॅन', ta: 'ஸ்கேன்', te: 'స్కాన్');
  String get market => _t('Market', 'बाजार',
    bn: 'বাজার', mr: 'बाजार', ta: 'சந்தை', te: 'మార్కెట్');
  String get assistant => _t('Assistant', 'सहायक',
    bn: 'সহকারী', mr: 'सहाय्यक', ta: 'உதவியாளர்', te: 'సహాయకుడు');

  // Quick actions
  String get scanPlant => _t('Scan Plant', 'पौधा स्कैन करें',
    bn: 'উদ্ভিদ স্ক্যান', mr: 'झाडाचे स्कॅन', ta: 'ஆலை ஸ்கேன்', te: 'మొక్క స్కాన్');
  String get recommendCrop => _t('Crop Advice', 'फसल सलाह',
    bn: 'ফসল পরামর্শ', mr: 'पीक सल्ला', ta: 'பயிர் ஆலோசனை', te: 'పంట సలహా');
  String get irrigation => _t('Irrigation', 'सिंचाई',
    bn: 'সেচ', mr: 'सिंचन', ta: 'பாசனம்', te: 'నీటిపారుదల');
  String get marketPrices => _t('Market Prices', 'बाजार भाव',
    bn: 'বাজার দর', mr: 'বাজার ভাব', ta: 'சந்தை விலைகள்', te: 'మార్కెట్ ధరలు');
  String get askAI => _t('Ask AI', 'AI से पूछें',
    bn: 'এআই-কে জিজ্ঞাসা করুন', mr: 'AI ला विचारा', ta: 'AI-யிடம் கேளுங்கள்', te: 'AIని అడగండి');
  String get weather => _t('Weather', 'मौसम',
    bn: 'আবহাওয়া', mr: 'हवामान', ta: 'வானிலை', te: 'వాతావరణం');

  // Profile
  String get farmerProfile => _t('Farmer Profile', 'किसान प्रोफ़ाइल',
    bn: 'কৃষক প্রোফাইল', mr: 'शेतकरी प्रोफाइल', ta: 'விவசாயி சுயவிவரம்', te: 'రైతు ప్రొఫైల్');
  String get farmerName => _t('Farmer Name', 'किसान का नाम',
    bn: 'কৃষকের নাম', mr: 'शेतकऱ्याचे नाव', ta: 'விவசாயி பெயர்', te: 'రైతు పేరు');
  String get location => _t('Location / Village', 'स्थान / गाँव',
    bn: 'স্থান / গ্রাম', mr: 'ठिकाण / गाव', ta: 'இடம் / கிராமம்', te: 'ప్రాంతం / గ్రామం');
  String get state => _t('State', 'राज्य',
    bn: 'রাজ্য', mr: 'राज्य', ta: 'மாநிலம்', te: 'రాష్ట్రం');
  String get soilType => _t('Soil Type', 'मिट्टी का प्रकार',
    bn: 'মাটির ধরন', mr: 'मातीचा प्रकार', ta: 'मண் வகை', te: 'నేల రకం');
  String get farmSize => _t('Farm Size (Acres)', 'खेत का आकार (एकड़)',
    bn: 'খামারের আকার (একর)', mr: 'शेत आकार (एकर)', ta: 'பண்ணை அளவு (ஏக்கர்)', te: 'పొలం పరిమాణం (ఎకరాలు)');
  String get currentCropLabel => _t('Current Crop', 'वर्तमान फसल',
    bn: 'বর্তমান ফসল', mr: 'सध्याचे पीक', ta: 'தற்போதைய பயிர்', te: 'ప్రస్తుత పంట');
  String get preferredLanguage => _t('Preferred Language', 'पसंदीदा भाषा',
    bn: 'পছন্দসই ভাষা', mr: 'पसंतीची भाषा', ta: 'விருப்பமான மொழி', te: 'ఇష్టపడే భాష');
  String get createProfile => _t('Create Profile', 'प्रोफ़ाइल बनाएं',
    bn: 'প্রোফাইল তৈরি করুন', mr: 'प्रोफाइल तयार करा', ta: 'சுயவிவரத்தை உருவாக்கு', te: 'ప్రొఫైల్ సృష్టించు');
  String get editProfile => _t('Edit Profile', 'प्रोफ़ाइल संपादित करें',
    bn: 'প্রোফাইল সম্পাদনা', mr: 'प्रोफाइल संपादित करा', ta: 'சுயவிவரத்தைத் தொகு', te: 'ప్రొఫైల్‌ను సవరించు');
  String get profileSetup => _t('Profile Setup', 'प्रोफ़ाइल सेटअप',
    bn: 'প্রোফাইল সেটআপ', mr: 'प्रोफाइल सेटअप', ta: 'சுயவிவர அமைப்பு', te: 'ప్రొఫైల్ సెటప్');
  String get welcomeTitle => _t('Welcome to KisanMitra AI', 'किसान मित्र AI में स्वागत है',
    bn: 'কিষাণমিত্র এআই-তে স্বাগতম', mr: 'किसानमित्र एआय मध्ये स्वागत आहे', ta: 'கிசான்மித்ரா ஏஐ-க்கு வரவேற்கிறோம்', te: 'కిసాన్ మిత్ర AIకి స్వాగతం');
  String get welcomeSubtitle => _t(
    'Your AI-powered agricultural assistant',
    'आपका AI कृषि सहायक',
    bn: 'আপনার এআই-চালিত কৃষি সহকারী', mr: 'तुमचा एआय-आधारित कृषी सहाय्यक', ta: 'உங்கள் AI-இயங்கும் விவசாய உதவியாளர்', te: 'మీ AI-ఆధారిత వ్యవసాయ సహాయకుడు'
  );

  // Weather
  String get temperature => _t('Temperature', 'तापमान',
    bn: 'তাপমাত্রা', mr: 'तापमान', ta: 'வெப்பநிலை', te: 'ఉష్ణోగ్రత');
  String get humidity => _t('Humidity', 'आर्द्रता',
    bn: 'আর্দ্রতা', mr: 'आद्रता', ta: 'ஈரப்பதம்', te: 'తేమ');
  String get windSpeed => _t('Wind Speed', 'हवा की गति',
    bn: 'বাতাসের গতি', mr: 'वाऱ्याचा वेग', ta: 'காற்றின் வேகம்', te: 'గాలి వేగం');
  String get rainProbability => _t('Rain Probability', 'वर्षा की संभावना',
    bn: 'বৃষ্টির সম্ভাবনা', mr: 'पावसाची शक्यता', ta: 'மழை வாய்ப்பு', te: 'వర్షం పడే అవకాశం');
  String get fiveDayForecast => _t('5-Day Forecast', '5 दिन का पूर्वानुमान',
    bn: '৫ দিনের পূর্বাভাস', mr: '५ दिवसांचा अंदाज', ta: '5 நாள் முன்னறிவிப்பு', te: '5 రోజుల వాతావరణ సూచన');
  String get agriculturalAlerts => _t('Agricultural Alerts', 'कृषि चेतावनी',
    bn: 'কৃষি সতর্কতা', mr: 'कृषी सूचना', ta: 'விவசாய எச்சரிக்கைகள்', te: 'వ్యవసాయ హెచ్చరికలు');

  // Crop Recommendation
  String get cropRecommendation => _t('Crop Recommendation', 'फसल सिफारिश',
    bn: 'ফসল সুপারিশ', mr: 'पीक शिफारस', ta: 'பயிர் பரிந்துரை', te: 'పంట సిఫార్సు');
  String get soilPh => _t('Soil pH', 'मिट्टी pH',
    bn: 'মাটির পিএইচ', mr: 'मातीचा पीएच', ta: 'மண் pH', te: 'నేల pH');
  String get rainfall => _t('Annual Rainfall (mm)', 'वार्षिक वर्षा (मिमी)', 
    bn: 'বার্ষিক বৃষ্টিপাত', mr: 'वार्षिक पाऊस', ta: 'ஆண்டு மழைப்பொழிவு', te: 'వార్షిక వర్షపాతం');
  String get waterAvailability => _t('Water Availability', 'पानी की उपलब्धता',
    bn: 'জল প্রাপ্যতা', mr: 'पाण्याची उपलब्धता', ta: 'தண்ணீர் வசதி', te: 'నీటి లభ్యత');
  String get season => _t('Season', 'मौसम',
    bn: 'ঋতু', mr: 'हंगाम', ta: 'பருவம்', te: 'సీజన్');
  String get getCropRecommendations => _t('Get Recommendations', 'सिफारिश पाएं',
    bn: 'সুপারিশ পান', mr: 'शिफारस मिळवा', ta: 'பரிந்துரைகளைப் பெறுங்கள்', te: 'సిఫార్సులు పొందండి');
  String get suitability => _t('Suitability', 'उपयुक्तता',
    bn: 'উপযুক্ততা', mr: 'उपयुक्तता', ta: 'பொருத்தம்', te: 'அనుకూలత');
  String get waterReq => _t('Water Requirement', 'पानी की जरूरत',
    bn: 'জলের প্রয়োজন', mr: 'पाण्याची गरज', ta: 'தண்ணீர் தேவை', te: 'నీటి అవసరం');
  String get duration => _t('Duration', 'अवधि',
    bn: 'সময়কাল', mr: 'कालावधी', ta: 'கால அளவு', te: 'కాలపరిమితి');
  String get expectedYield => _t('Expected Yield', 'अपेक्षित उपज',
    bn: 'প্রত্যাশিত ফলন', mr: 'अपेक्षित उत्पन्न', ta: 'எதிர்பார்க்கப்படும் மகசூல்', te: 'ఆశించిన దిగుబడి');

  // Disease Scan
  String get plantDiseaseScan => _t('Plant Disease Scan', 'पौधे की बीमारी स्कैन',
    bn: 'উদ্ভিদ রোগ স্ক্যান', mr: 'वनस्पती रोग स्कॅन', ta: 'தாவர நோய் ஸ்கேன்', te: 'మొక్కల వ్యాధి స్కాన్');
  String get takePhoto => _t('Take Photo', 'फ़ोटो लें',
    bn: 'ছবি তুলুন', mr: 'फोटो काढा', ta: 'புகைப்படம் எடு', te: 'ఫోటో తీయండి');
  String get fromGallery => _t('From Gallery', 'गैलरी से',
    bn: 'গ্যালারি থেকে', mr: 'गॅलरीतून', ta: 'கேலரியில் இருந்து', te: 'గ్యాలరీ నుండి');
  String get analyzeImage => _t('Analyze Image', 'छवि विश्लेषण करें',
    bn: 'ছবি বিশ্লেষণ', mr: 'चित्राचे विश्लेषण करा', ta: 'படத்தை பகுப்பாய்வு செய்', te: 'चित்ர வி்லேசனை செய்யுங்கள்');
  String get diseaseDetected => _t('Disease Detected', 'बीमारी मिली',
    bn: 'রোগ শনাক্ত হয়েছে', mr: 'रोग आढळला', ta: 'நோய் கண்டறியப்பட்டது', te: 'వ్యాధి కనుగొనబడింది');
  String get confidence => _t('Confidence', 'आत्मविश्वास',
    bn: 'নিশ্চয়তা', mr: 'खात्री', ta: 'நம்பிக்கை', te: 'విశ్వాసం');
  String get symptoms => _t('Symptoms', 'लक्षण',
    bn: 'উপসর্গ', mr: 'लक्षणे', ta: 'அறிகுறிகள்', te: 'లక్షణాలు');
  String get recommendedActions => _t('Recommended Actions', 'अनुशंसित कार्रवाई',
    bn: 'সুপারিশকৃত ব্যবস্থা', mr: 'शिफारस केलेल्या कृती', ta: 'பரிந்துரைக்கப்பட்ட நடவடிக்கைகள்', te: 'సిఫార్సు చేసిన చర్యలు');
  String get preventionTips => _t('Prevention Tips', 'रोकथाम के टिप्स',
    bn: 'প্রতিরোধমূলক টিপস', mr: 'प्रतिबंधक टिप्स', ta: 'தடுப்பு குறிப்புகள்', te: 'నివారణ చిట్కాలు');

  // Irrigation
  String get irrigationAdvisor => _t('Irrigation Advisor', 'सिंचाई सलाहकार',
    bn: 'সেচ উপদেষ্টা', mr: 'सिंचन सल्लागार', ta: 'பாசன ஆலோசகர்', te: 'నీటిపారుదల సలహాదారు');
  String get irrigationRecommended => _t('Irrigation Recommended', 'सिंचाई की सिफारिश',
    bn: 'সেচ সুপারিশকৃত', mr: 'सिंचनाची शिफारस', ta: 'பாசனம் பரிந்துரைக்கப்படுகிறது', te: 'నీటిపారుదల సిఫార్సు చేయబడింది');
  String get notRequired => _t('Not Required Today', 'आज आवश्यक नहीं',
    bn: 'আজ প্রয়োজন নেই', mr: 'आज गरज नाही', ta: 'இன்று தேவையில்லை', te: 'ఈరోజు అవసరం లేదు');
  String get suggestedTiming => _t('Suggested Timing', 'सुझाया गया समय',
    bn: 'প্রস্তাবিত সময়', mr: 'सुचवलेली वेळ', ta: 'பரிந்துரைக்கப்பட்ட நேரம்', te: 'సూచించిన సమయం');
  String get waterAmount => _t('Water Amount', 'पानी की मात्रा',
    bn: 'জলের পরিমাণ', mr: 'पाण्याचे प्रमाण', ta: 'தண்ணீர் அளவு', te: 'నీటి పరిమాణం');
  String get nextIrrigation => _t('Next Irrigation', 'अगली सिंचाई',
    bn: 'পরবর্তী সেচ', mr: 'पुढील सिंचन', ta: 'அடுத்த பாசனம்', te: 'తదుపరి నీటిపారుదల');
  String get growthStage => _t('Growth Stage', 'वृद्धि चरण',
    bn: 'বৃদ্ধির পর্যায়', mr: 'वाढीचा टप्पा', ta: 'வளர்ச்சி நிலை', te: 'పెరుగుదల దశ');
  String get recentRainfall => _t('Recent Rainfall (mm)', 'हाल की वर्षा (मिमी)',
    bn: 'সাম্প্রতিক বৃষ্টিপাত', mr: 'अलीकडील पाऊस', ta: 'சமீபத்திய மழைப்பொழிவு', te: 'ఇటీవలి వర్షపాతం');
  String get getAdvice => _t('Get Advice', 'सलाह पाएं',
    bn: 'পরামর্শ নিন', mr: 'सल्ला मिळवा', ta: 'ஆலோசனை பெறுங்கள்', te: 'సలహా పొందండి');

  // Market
  String get marketPricesTitle => _t('Market Prices', 'बाजार भाव',
    bn: 'বাজার দর', mr: 'बाजार भाव', ta: 'சந்தை விலைகள்', te: 'మార్కెట్ ధరలు');
  String get selectCrop => _t('Select Crop', 'फसल चुनें',
    bn: 'ফসল নির্বাচন করুন', mr: 'पीक निवडा', ta: 'பயிரைத் தேர்ந்தெடுக்கவும்', te: 'పంటను ఎంచుకోండి');
  String get selectState => _t('Select State', 'राज्य चुनें',
    bn: 'রাজ্য নির্বাচন করুন', mr: 'राज्य निवडा', ta: 'மாநிலத்தைத் தேர்ந்தெடுக்கவும்', te: 'రాష్ట్రాన్ని ఎంచుకోండి');
  String get selectMarket => _t('Select Market', 'मंडी चुनें',
    bn: 'মন্ডি নির্বাচন করুন', mr: 'बाजार निवडा', ta: 'சந்தையைத் தேர்ந்தெடுக்கவும்', te: 'మార్కెట్‌ను ఎంచుకోండి');
  String get currentPrice => _t('Current Price', 'वर्तमान मूल्य',
    bn: 'বর্তমান দাম', mr: 'सध्याचा भाव', ta: 'தற்போதைய விலை', te: 'ప్రస్తుత ధర');
  String get minPrice => _t('Min Price', 'न्यूनतम मूल्य',
    bn: 'ন্যূনতম দাম', mr: 'किमान भाव', ta: 'குறைந்தபட்ச விலை', te: 'కనీస ధర');
  String get maxPrice => _t('Max Price', 'अधिकतम मूल्य',
    bn: 'সর্বোচ্চ দাম', mr: 'कमाल भाव', ta: 'அதிகபட்ச விலை', te: 'గరిష్ట ధర');
  String get lastUpdated => _t('Last Updated', 'अंतिम अपडेट',
    bn: 'শেষ আপডেট', mr: 'शेवटचे अपडेट', ta: 'கடைசியாக புதுப்பிக்கப்பட்டது', te: 'చివరిగా నవీకరించబడింది');
  String get perQuintal => _t('per Quintal', 'प्रति क्विंटल',
    bn: 'প্রতি কুইন্টাল', mr: 'प्रति क्विंटल', ta: 'குவிண்டாலுக்கு', te: 'క్వింటాల్‌కి');
  String get checkPrices => _t('Check Prices', 'भाव जांचें',
    bn: 'দাম চেক করুন', mr: 'भाव तपासा', ta: 'விலைகளைச் சரிபார்க்கவும்', te: 'ధరలను తనిఖీ చేయండి');

  // AI Assistant
  String get aiAssistant => _t('AI Krishi Assistant', 'AI कृषि सहायक',
    bn: 'এআই কৃষি সহকারী', mr: 'AI कृषी सहाय्यक', ta: 'AI விவசாய உதவியாளர்', te: 'AI కృషి సహాయకుడు');
  String get typeQuestion => _t('Type your question...', 'अपना सवाल लिखें...',
    bn: 'আপনার প্রশ্ন লিখুন...', mr: 'तुमचा प्रश्न लिहा...', ta: 'உங்கள் கேள்வியைத் தட்டச்சு செய்க...', te: 'మీ ప్రశ్నను టైప్ చేయండి...');
  String get askQuestion => _t('Ask a Question', 'सवाल पूछें',
    bn: 'প্রশ্ন জিজ্ঞাসা করুন', mr: 'प्रश्न विचारा', ta: 'கேள்வி கேளுங்கள்', te: 'ప్రశ్న అడగండి');
  String get suggestedQuestions => _t('Suggested Questions', 'सुझाए गए सवाल',
    bn: 'প্রস্তাবিত প্রশ্ন', mr: 'सुचवलेले प्रश्न', ta: 'பரிந்துரைக்கப்பட்ட கேள்விகள்', te: 'సూచించిన ప్రశ్నలు');

  // Crop Monitor
  String get cropMonitoring => _t('Crop Monitoring', 'फसल निगरानी',
    bn: 'ফসল পর্যবেক্ষণ', mr: 'पीक देखरेख', ta: 'பயிர் கண்காணிப்பு', te: 'పంట పర్యవేక్షణ');
  String get addCrop => _t('Add Crop', 'फसल जोड़ें',
    bn: 'ফসল যোগ করুন', mr: 'पीक जोडा', ta: 'பயிரைச் சேர்க்கவும்', te: 'పంటను జోడించండి');
  String get plantingDate => _t('Planting Date', 'बुवाई की तारीख',
    bn: 'রোপণের তারিখ', mr: 'लागवडीची तारीख', ta: 'நடவு தேதி', te: 'నాటిన తేదీ');
  String get harvestDate => _t('Expected Harvest', 'अपेक्षित कटाई',
    bn: 'প্রত্যাশিত ফসল কাটা', mr: 'अपेक्षित कापणी', ta: 'எதிர்பார்க்கப்படும் அறுவடை', te: 'ఆశించిన కోత');
  String get daysOld => _t('Days Old', 'दिन पुरानी',
    bn: 'দিন বয়স', mr: 'दिवस झाले', ta: 'நாட்கள் வயது', te: 'రోజుల వయస్సు');
  String get daysToHarvest => _t('Days to Harvest', 'कटाई में दिन',
    bn: 'ফসল কাটার দিন', mr: 'कापणीसाठी दिवस', ta: 'அறுవடைకు நாட்கள்', te: 'కోతకు రోజులు');
  String get progress => _t('Progress', 'प्रगति',
    bn: 'অগ্রগতি', mr: 'प्रगती', ta: 'ముன்னேற்றம்', te: 'పురోగతి');
  String get noCrops => _t('No crops added yet', 'कोई फसल नहीं जोड़ी गई',
    bn: 'এখনও কোনো ফসল যোগ করা হয়নি', mr: 'अद्याप कोणतेही पीक जोडलेले नाही', ta: 'இன்னும் பயிர்கள் எதுவும் சேர்க்கப்படவில்லை', te: 'ఇంకా పంటలు ఏవీ జోడించలేదు');
  String get upcomingTasks => _t('Upcoming Tasks', 'आगामी कार्य',
    bn: 'আসন্ন কাজ', mr: 'आगामी कार्ये', ta: 'வரவிருக்கும் பணிகள்', te: 'రాబోయే పనులు');

  // Errors
  String get networkError => _t('No internet connection', 'इंटरनेट कनेक्शन नहीं',
    bn: 'ইন্টারনেট সংযোগ নেই', mr: 'इंटरनेट कनेक्शन नाही', ta: 'இணைய இணைப்பு இல்லை', te: 'ఇంటర్నెట్ కనెక్షన్ లేదు');
  String get unknownError => _t('Something went wrong', 'कुछ गलत हुआ',
    bn: 'কিছু ভুল হয়েছে', mr: 'काहीतरी चुकीचे घडले', ta: 'ஏதோ தவறு நடந்துவிட்டது', te: 'ఏదో తప్పు జరిగింది');
  String get tryAgain => _t('Please try again', 'कृपया पुनः प्रयास करें',
    bn: 'আবার চেষ্টা করুন', mr: 'कृपया पुन्हा प्रयत्न करा', ta: 'மீண்டும் முயற்சிக்கவும்', te: 'దయచేసి మళ్లీ ప్రయత్నించండి');

  // Language select
  String get selectLanguage => _t('Select Language', 'भाषा चुनें',
    bn: 'ভাষা নির্বাচন করুন', mr: 'भाषा निवडा', ta: 'மொழியைத் தேர்ந்தெடுக்கவும்', te: 'భాషను ఎంచుకోండి');
  String get languageSubtitle => _t('Choose your preferred language', 'अपनी पसंदीदा भाषा चुनें',
    bn: 'আপনার পছন্দসই ভাষা চয়ন করুন', mr: 'तुमची पसंतीची भाषा निवडा', ta: 'உங்களுக்கு விருப்பமான மொழியைத் தேர்ந்தெடுக்கவும்', te: 'మీకు నచ్చిన భాషను ఎంచుకోండి');
  String get continueText => _t('Continue', 'जारी रखें',
    bn: 'চালিয়ে যান', mr: 'সुरू ठेवा', ta: 'தொடரவும்', te: 'కొనసాగించు');

  // Settings
  String get settings => _t('Settings', 'सेटिंग',
    bn: 'সেটিংস', mr: 'सेटिंग्ज', ta: 'அமைப்புகள்', te: 'సెట్టింగ్స్');
  String get language => _t('Language', 'भाषा',
    bn: 'ভাষা', mr: 'भाषा', ta: 'மொழி', te: 'భాష');
  String get about => _t('About', 'के बारे में',
    bn: 'সম্পর্কে', mr: 'बद्दल', ta: 'பற்றி', te: 'గురించి');
  String get version => _t('Version', 'संस्करण',
    bn: 'ভার্সন', mr: 'আवृत्ती', ta: 'பதிப்பு', te: 'వెర్షన్');
  String get logout => _t('Logout', 'लॉगआउट',
    bn: 'লগআউট', mr: 'लॉगआउट', ta: 'வெளியேறு', te: 'లాగ్ అవుట్');
  String get viewAll => _t('View All', 'सभी देखें',
    bn: 'সব দেখুন', mr: 'सर्व पहा', ta: 'அனைத்தையும் பார்', te: 'అన్నీ చూడండి');

  // Custom Banners & Dropdowns
  String get cropAdvice => _t('Smart Crop Recommendation', 'स्मार्ट फसल सिफारिश',
    bn: 'স্মার্ট ফসল সুপারিশ', mr: 'स्मार्ट पीक शिफारस', ta: 'ஸ்மார்ட் பயிர் பரிந்துரை', te: 'స్మార్ట్ పంట సిఫార్సు');
  String get cropAdviceSubtitle => _t(
    'Choose the best crop based on soil, climate & water',
    'मिट्टी, मौसम और पानी के आधार पर बेहतरीन फसल चुनें',
    bn: 'মাটি, জলবায়ু ও জলের ভিত্তিতে সেরা ফসল বেছে নিন', 
    mr: 'माती, हवामान आणि पाण्याच्या आधारावर सर्वोत्तम पीक निवडा', 
    ta: 'மண், காலநிலை மற்றும் தண்ணீரின் அடிப்படையில் சிறந்த பயிரைத் தேர்ந்தெடுக்கவும்', 
    te: 'నేల, వాతావరణం మరియు నీటి ఆధారంగా ఉత్తమ పంటను ఎంచుకోండి'
  );
  String get waterAbundant => _t('Abundant', 'प्रचुर', bn: 'প্রচুর', mr: 'भरपूर', ta: 'ஏராளமான', te: 'సమృద్ధిగా');
  String get waterModerate => _t('Moderate', 'मध्यम', bn: 'মাঝারি', mr: 'मध्यम', ta: 'மிதமான', te: 'మితమైన');
  String get waterScarce => _t('Scarce', 'कम', bn: 'স্বল্প', mr: 'टंचाई', ta: 'பற்றாக்குறை', te: 'కొరత');
  String get methodDrip => _t('Drip Irrigation', 'ड्रिप सिंचाई', bn: 'ড্রিপ সেচ', mr: 'ठिबक सिंचन', ta: 'சொட்டு நீர் பாசனம்', te: 'బిందు సేద్యం');
  String get methodSprinkler => _t('Sprinkler', 'फव्वारा', bn: 'স্প্রিঙ্কলার', mr: 'तुषार सिंचन', ta: 'தெளிப்பான்', te: 'స్ప్రింక్లర్');
  String get methodFlood => _t('Flood', 'बाढ़', bn: 'প্লাবন', mr: 'पूर', ta: 'வெள்ளம்', te: 'వరద');
  String get methodFurrow => _t('Furrow', 'नाली', bn: 'নালা', mr: 'सरी', ta: 'பள்ளம்', te: 'ఫర్రో');
  String get forecastClear => _t('Clear', 'साफ़', bn: 'পরিষ্কার', mr: 'स्वच्छ', ta: 'தெளிவானது', te: 'స్పష్టంగా ఉంది');
  String get forecastCloudy => _t('Partly Cloudy', 'आंशिक बादल', bn: 'আংশিক মেঘला', mr: 'अंशतः ढगाळ', ta: 'ஓரளவு மேகமூட்டம்', te: 'పాక్షికంగా మేఘావృతం');
  String get forecastHeavyRain => _t('Heavy Rain Expected', 'भारी बारिश', bn: 'ভারী বৃষ্টি', mr: 'मुसळधार पाऊस', ta: 'கனமழை எதிர்பார்க்கப்படுகிறது', te: 'భారీ వర్షం సూచన');
  String get forecastLightRain => _t('Light Rain', 'हल्की बारिश', bn: 'হালকা বৃষ্টি', mr: 'हलका पाऊस', ta: 'லேசான மழை', te: 'చినుకులు');

  // AI Assistant Specific
  String get assistantWelcome => _t(
    '🌾 Hello! I am your AI Agricultural Assistant.\n\nI can help with:\n• Crop Selection\n• Irrigation\n• Plant Diseases\n• Weather\n• Market Prices\n\nAsk your question in any language! 👇',
    '🌾 नमस्ते! मैं आपका AI कृषि सहायक हूं।\n\nमैं इन विषयों में मदद कर सकता हूं:\n• फसल चयन और बुवाई\n• सिंचाई और पानी प्रबंधन\n• पौधे की बीमारियां\n• मौसम और खेती\n• बाजार भाव\n\nअपना सवाल किसी भी भाषा में पूछें! 👇',
    bn: '🌾 নমস্কার! আমি আপনার এআই কৃষি সহকারী।\n\nআমি এই বিষয়গুলিতে সাহায্য করতে পারি:\n• ফসল নির্বাচন\n• সেচ\n• উদ্ভিদের রোগ\n• আবহাওয়া\n• বাজার দর\n\nআপনার প্রশ্ন যেকোনো ভাষায় জিজ্ঞাসা করুন! 👇',
    mr: '🌾 नमस्कार! मी तुमचा AI कृषी सहाय्यक आहे.\n\nमी या विषयांमध्ये मदत करू शकतो:\n• पीक निवड\n• सिंचन\n• वनस्पतींचे रोग\n• हवामान\n• बाजार भाव\n\nतुमचा प्रश्न कोणत्याही भाषेत विचारा! 👇',
    ta: '🌾 வணக்கம்! நான் உங்கள் AI விவசாய உதவியாளர்.\n\nநான் இந்த தலைப்புகளில் உதவ முடியும்:\n• பயிர் தேர்வு\n• பாசனம்\n• தாவர நோய்கள்\n• வானிலை\n• சந்தை விலைகள்\n\nஉங்கள் கேள்வியை எந்த மொழியிலும் கேளுங்கள்! 👇',
    te: '🌾 నమస్కారం! నేను మీ AI కృషి సహాయకుడిని.\n\nనేను ఈ విషయాలలో సహాయం చేయగలను:\n• పంట ఎంపిక\n• నీటిపారుదల\n• మొక్కల వ్యాధులు\n• వాతావరణం\n• మార్కెట్ ధరలు\n\nమీ ప్రశ్నను ఏ భాషలోనైనా అడగండి! 👇'
  );
  String get resetChat => _t('Reset Conversation', 'बातचीत रीसेट करें', bn: 'কথোপকথন রিসেট করুন', mr: 'संवाद रिसेट करा', ta: 'உரையாடலை மீட்டமை', te: 'సంభాషణను రీసెట్ చేయండి');
  String get demoModeLabel => _t('Demo Mode — Predefined responses', 'डेमो मोड — पूर्वनिर्धारित उत्तर', bn: 'ডেমো মোড — পূর্বনির্ধারিত উত্তর', mr: 'डेमो मोड — पूर्व-निर्धारित उत्तरे', ta: 'டெமோ பயன்முறை — முன் வரையறுக்கப்பட்ட பதில்கள்', te: 'డెమో మోడ్ — ముందుగా నిర్ణయించిన సమాధానాలు');
  String get assistantError => _t('Sorry, I could not answer that. Please try again.', 'क्षमा करें, मैं उसका उत्तर नहीं दे सका। कृपया पुनः प्रयास करें।', bn: 'দুঃখিত, আমি উত্তর দিতে পারিনি। আবার চেষ্টা করুন।', mr: 'क्षमस्व, मी उत्तर देऊ शकलो नाही. कृपया पुन्हा प्रयत्न करा.', ta: 'மன்னிக்கவும், என்னால் அதற்கு பதிலளிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.', te: 'క్షమించండి, నేను దానికి సమాధానం చెప్పలేకపోయాను. దయచేసి మళ్లీ ప్రయత్నించండి.');

  // Suggestions
  String get suggestGrow => _t('Which crop should I grow?', 'कौन सी फसल उगाऊं?', bn: 'কোন ফসল ফলাবো?', mr: 'मी कोणते पीक घेऊ?', ta: 'நான் எந்தப் பயிரை வளர்க்க வேண்டும்?', te: 'నేను ఏ పంటను పండించాలి?');
  String get suggestLeaves => _t('Why are my leaves yellow?', 'पत्तियां पीली क्यों हो रही हैं?', bn: 'আমার পাতা হলুদ কেন?', mr: 'माझी पाने पिवळी का पडत आहेत?', ta: 'என் இலைகள் ஏன் மஞ்சளாக இருக்கின்றன?', te: 'నా ఆకులు ఎందుకు పసుపు రంగులోకి మారుతున్నాయి?');
  String get suggestIrrigate => _t('When should I irrigate?', 'सिंचाई कब करूं?', bn: 'কখন সেচ দেব?', mr: 'मी कधी सिंचन करावे?', ta: 'நான் எப்போது பாசனம் செய்ய வேண்டும்?', te: 'నేను ఎప్పుడు నీటిపారుదల చేయాలి?');
  String get suggestRain => _t('What to do before heavy rain?', 'भारी बारिश से पहले क्या करूं?', bn: 'ভারী বৃষ্টির আগে কি করব?', mr: 'मुसळधार पावसापूर्वी काय करावे?', ta: 'கனமழைக்கு முன் என்ன செய்ய வேண்டும்?', te: 'భారీ వర్షానికి ముందు ఏమి చేయాలి?');
  String get suggestProtect => _t('How to protect my crop?', 'फसल की सुरक्षा कैसे करूं?', bn: 'কিভাবে আমার ফসল রক্ষা করব?', mr: 'मी माझे पीक कसे वाचवू?', ta: 'எனது பயிரை எவ்வாறு பாதுகாப்பது?', te: 'నా పంటను ఎలా రక్షించుకోవాలి?');
  String get suggestPrice => _t('What is the market price?', 'बाजार में फसल का सही दाम क्या है?', bn: 'বাজার দর কি?', mr: 'बाजारातील भाव काय आहे?', ta: 'சந்தை விலை என்ன?', te: 'మార్కెట్ ధర ఎంత?');

  // Market Screen Specific
  String get mandiPricesTitle => _t('Mandi / Market Prices', 'मंडी / बाजार भाव', bn: 'মন্ডি / বাজার দর', mr: 'मंडी / बाजार भाव', ta: 'மண்டி / சந்தை விலைகள்', te: 'మండి / మార్కెట్ ధరలు');
  String get mandiPricesSubtitle => _t('Know the right price for your crop', 'अपनी फसल का सही मूल्य जानें', bn: 'আপনার ফসলের সঠিক দাম জানুন', mr: 'तुमच्या पिकाचा योग्य भाव जाणून घ्या', ta: 'உங்கள் பயிருக்கான சரியான விலையைத் தெரிந்து கொள்ளுங்கள்', te: 'మీ పంటకు సరైన ధరను తెలుసుకోండి');
  String get mspInfoTitle => _t('Government MSP Info', 'सरकारी MSP जानकारी', bn: 'সরকারি এমএসপি তথ্য', mr: 'सरकारी एमएसपी माहिती', ta: 'அரசு MSP தகவல்', te: 'ప్రభుత్వ MSP సమాచారం');
  String get mspInfoBody => _t(
    'For MSP (Minimum Support Price) information, visit PM-KISAN portal or call 1800-180-1551.', 
    'MSP (Minimum Support Price) की जानकारी के लिए PM-KISAN पोर्टल देखें या 1800-180-1551 पर कॉल करें।',
    bn: 'MSP (ন্যূনতম সমর্থন মূল্য) তথ্যের জন্য, PM-KISAN পোর্টাল দেখুন বা 1800-180-1551 নম্বরে কল করুন।',
    mr: 'MSP (किमान आधारभूत किंमत) माहितीसाठी, PM-KISAN पोर्टलला भेट द्या किंवा 1800-180-1551 वर कॉल करा.',
    ta: 'MSP (குறைந்தபட்ச ஆதரவு விலை) தகவலுக்கு, PM-KISAN போர்ட்டலைப் பார்வையிடவும் அல்லது 1800-180-1551 ஐ அழைக்கவும்.',
    te: 'MSP (కనీస మద్దతు ధర) సమాచారం కోసం, PM-KISAN పోర్టల్‌ని సందర్శించండి లేదా 1800-180-1551కి కాల్ చేయండి.'
  );
  String get noMarketData => _t('No data found for this crop today.', 'आज इस फसल के लिए कोई डेटा नहीं मिला।', bn: 'আজ এই ফসলের জন্য কোনো তথ্য পাওয়া যায়নি।', mr: 'आज या पिकासाठी कोणतीही माहिती मिळाली नाही.', ta: 'இந்த பயிருக்கு இன்று தரவு எதுவும் கிடைக்கவில்லை.', te: 'ఈ పంటకు ఈరోజు సమాచారం ఏదీ కనుగొనబడలేదు.');
  String get tryDifferentSearch => _t('Please try a different crop, state or market.', 'कृपया दूसरी फसल, राज्य या मंडी चुनें।', bn: 'অনুগ্রহ করে অন্য ফসল, রাজ্য বা মন্ডি চেষ্টা করুন।', mr: 'कृपया दुसरे पीक, राज्य किंवा बाजार निवडा.', ta: 'தயவுசெய்து வேறு பயிர், மாநிலம் அல்லது சந்தையை முயற்சிக்கவும்.', te: 'దయచేసి వేరే పంట, రాష్ట్రం లేదా మార్కెట్‌ని ప్రయత్నించండి.');
  String get errorSelectCrop => _t('Please select a crop', 'कृपया एक फसल चुनें', bn: 'অনুগ্রহ করে একটি ফসল নির্বাচন করুন', mr: 'कृपया पीक निवडा', ta: 'தயவுசெய்து ஒரு பயிரைத் தேர்ந்தெடுக்கவும்', te: 'దయచేసి ఒక పంటను ఎంచుకోండి');

  // Crop Monitor Specific
  String get addCropTitle => _t('Add Crop', 'फसल जोड़ें', bn: 'ফসল যোগ করুন', mr: 'पीक जोडा', ta: 'பயிரைச் சேர்க்கவும்', te: 'పంటను జోడించండి');
  String get selectCropLabel => _t('Select Crop', 'फसल चुनें', bn: 'ফসল নির্বাচন করুন', mr: 'पीक निवडा', ta: 'பயிரைத் தேர்ந்தெடுக்கவும்', te: 'పంటను ఎంచుకోండి');
  String get growthStageLabel => _t('Growth Stage', 'वृद्धि चरण', bn: 'বৃদ্ধির পর্যায়', mr: 'वाढीचा टप्पा', ta: 'வளர்ச்சி நிலை', te: 'పెరుగుదల దశ');
  String get noCropsSubtitle => _t('Add your first crop to start monitoring', 'अपनी पहली फसल जोड़ें और उसकी निगरानी शुरू करें', bn: 'আপনার প্রথম ফসল যোগ করুন এবং পর্যবেক্ষণ শুরু করুন', mr: 'देखरेख सुरू करण्यासाठी तुमचे पहिले पीक जोडा', ta: 'கண்காணிப்பைத் தொடங்க உங்கள் முதல் பயிரைச் சேர்க்கவும்', te: 'పర్యవేక్షణను ప్రారంభించడానికి మీ మొదటి పంటను జోడించండి');
  String get planted => _t('Planted', 'बुवाई की गई', bn: 'রোপণ করা হয়েছে', mr: 'लागवड केली', ta: 'நடப்பட்டது', te: 'నాటిన');
  String get harvest => _t('Harvest', 'कटाई', bn: 'ফসল কাটা', mr: 'कापणी', ta: 'அறுவடை', te: 'కోత');
  String get tasksDue => _t('tasks due', 'कार्य बाकी हैं', bn: 'কাজ बाकी আছে', mr: 'कामे बाकी आहेत', ta: 'பணிகள் உள்ளன', te: 'పనులు బాకీ ఉన్నాయి');

  // Not Recognized
  String get notRecognizedTitle => _t('Not Recognized', 'पहचाना नहीं गया', bn: 'চেনা যায়নি', mr: 'ओळखले नाही', ta: 'அடையாளம் காணப்படவில்லை', te: 'గుర్తించబడలేదు');
  String get notRecognizedBody => _t(
    'The AI could not identify a specific disease in this image with high confidence.',
    'AI इस फोटो में किसी विशेष बीमारी की पहचान उच्च सटीकता के साथ नहीं कर सका।',
    bn: 'এআই এই ছবিতে কোনো নির্দিষ্ট রোগ সঠিকভাবে শনাক্ত করতে পারেনি।',
    mr: 'एआय या फोटोमध्ये कोणत्याही विशिष्ट रोगाची ओळख पटवू शकले नाही.',
    ta: 'இந்த படத்தில் உள்ள குறிப்பிட்ட நோயை AI-ஆல் அதிக நம்பிக்கையுடன் அடையாளம் காண முடியவில்லை.',
    te: 'AI ఈ చిత్రంలో నిర్దిష్ట వ్యాధిని ఖచ్చితంగా గుర్తించలేకపోయింది.'
  );
  String get tipsForBetterResults => _t('Tips for better results:', 'बेहतर परिणाम के लिए टिप्स:', bn: 'ভালো ফলের জন্য টিপস:', mr: 'चांगल्या निकालासाठी टिप्स:', ta: 'சிறந்த முடிவுகளுக்கான உதவிக்குறிப்புகள்:', te: 'మెరుగైన ఫలితాల కోసం చిట్కాలు:');
  String get tipFocus => _t('Focus clearly on the affected leaf.', 'प्रभावित पत्ती पर स्पष्ट रूप से फोकस करें।', bn: 'আক্রান্ত পাতার ওপর পরিষ্কারভাবে ফোকাস করুন।', mr: 'बाधित पानावर स्पष्टपणे फोकस करा.', ta: 'பாதிக்கப்பட்ட இலையைத் தெளிவாகப் படம் பிடிக்கவும்.', te: 'ప్రభావితమైన ఆకుపై స్పష్టంగా ఫోకస్ చేయండి.');
  String get tipLight => _t('Ensure there is bright, natural light.', 'सुनिश्चित करें कि रोशनी पर्याप्त और प्राकृतिक हो।', bn: 'পর্যাপ্ত ও প্রাকৃতিক আলো নিশ্চিত করুন।', mr: 'पुरेशा आणि नैसर्गिक उजेडाची खात्री करा.', ta: 'பிரகாசமான, இயற்கை ஒளி இருப்பதை உறுதி செய்யவும்.', te: 'ప్రకాశవంతమైన, సహజ కాంతి ఉండేలా చూసుకోండి.');
  String get tipClutter => _t('Avoid background clutter.', 'बैकग्राउंड में फालतू चीज़ें न रखें।', bn: 'ব্যাকগ্রাউন্ডে অপ্রয়োজনীয় জিনিস এড়িয়ে চলুন।', mr: 'बॅकराउंडमध्ये अनावश्यक गोष्टी टाळा.', ta: 'பின்னணியில் தேவையற்ற பொருட்கள் இருப்பதைத் தவிர்க்கவும்.', te: 'బ్యాక్‌గ్రౌండ్‌లో ఇతర వస్తువులు లేకుండా చూసుకోండి.');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'hi', 'bn', 'mr', 'ta', 'te'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
