import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'utils/utils.dart';
import 'localization/app_localizations.dart';
import 'providers/farmer_provider.dart';
import 'providers/app_providers.dart';
import 'providers/auth_provider.dart' as app_auth;


import 'screens/onboarding/splash_screen.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/language_select_screen.dart';
import 'screens/profile/farmer_profile_screen.dart';
import 'screens/weather/weather_screen.dart';
import 'screens/crop_recommendation/crop_recommendation_screen.dart';
import 'screens/disease_scan/disease_scan_screen.dart';
import 'screens/irrigation/irrigation_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'navigation/main_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase Initialization Error: $e');
  }

  // Load environment variables safely
  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (e) {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e2) {
      debugPrint("No .env file found. Proceeding with default values.");
    }
  }


  // Debug configuration
  AppConfig.debugPrintConfig();

  // UI Setup
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => FarmerProvider()..loadProfile()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()..load()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()..init()),
        ChangeNotifierProvider(create: (_) => CropMonitorProvider()..loadCrops()),
      ],
      child: const KisanMitraApp(),
    ),
  );
}

class KisanMitraApp extends StatelessWidget {
  const KisanMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, _) {
        return MaterialApp(
          title: 'KisanMitra AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          locale: langProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const AuthWrapper(),
          onGenerateRoute: _generateRoute,
        );
      },
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _buildRoute(const LanguageSelectScreen(), settings);
      case '/profile-setup':
        final args = settings.arguments as Map<String, dynamic>?;
        final isEditing = args?['isEditing'] as bool? ?? false;
        return _buildRoute(FarmerProfileScreen(isEditing: isEditing), settings);
      case '/main':
        final args = settings.arguments as Map<String, dynamic>?;
        final initialIndex = args?['index'] as int? ?? 0;
        return _buildRoute(MainNavigation(initialIndex: initialIndex), settings);
      case '/crops':
        return _buildRoute(const MainNavigation(initialIndex: 1), settings);
      case '/market':
        return _buildRoute(const MainNavigation(initialIndex: 3), settings);
      case '/weather':
        return _buildRoute(const WeatherScreen(), settings);
      case '/crop-recommend':
        return _buildRoute(const CropRecommendationScreen(), settings);
      case '/disease-scan':
        return _buildRoute(const DiseaseScanScreen(), settings);
      case '/irrigation':
        return _buildRoute(const IrrigationScreen(), settings);
      case '/settings':
        return _buildRoute(const SettingsScreen(), settings);
      default:
        return _buildRoute(const MainNavigation(), settings);
    }
  }

  PageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => page,
    );
  }
}

/// A wrapper widget that decides which screen to show based on Auth status.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _initialized = false;
  String _initialRoute = '/';
  String? _lastLoadedUid;

  @override
  void initState() {
    super.initState();
    _determineInitialRoute();
  }

  Future<void> _determineInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLanguage = prefs.getString(AppConstants.keySelectedLanguage) != null;

    if (hasLanguage) {
      _initialRoute = '/main';
    } else {
      _initialRoute = '/language-select';
    }

    // Smooth splash screen display time (like Instagram / WhatsApp)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  void _checkUserData(String uid) {
    if (_lastLoadedUid != uid) {
      _lastLoadedUid = uid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<FarmerProvider>().loadProfileForUser(uid);
          context.read<CropMonitorProvider>().loadCropsForUser(uid);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<app_auth.AuthProvider>();

    // Display animated Splash Screen while initializing app state
    if (!_initialized) {
      return const SplashScreen();
    }

    // Auth Guard
    if (!authProvider.isAuthenticated) {
      _lastLoadedUid = null;
      return const LoginScreen();
    }

    // Trigger auto-fetch from Firebase for this UID
    if (authProvider.user?.uid != null) {
      _checkUserData(authProvider.user!.uid);
    }

    // Navigation logic for authenticated users: if language set, go to /main
    switch (_initialRoute) {
      case '/main':
        return const MainNavigation();
      default:
        return const LanguageSelectScreen();
    }
  }
}
