import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/farmer_profile.dart';
import '../core/constants/app_constants.dart';
import '../services/api/firestore_service.dart';

class FarmerProvider extends ChangeNotifier {
  FarmerProfile? _profile;
  bool _isLoading = false;
  bool _profileComplete = false;

  FarmerProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get profileComplete => _profileComplete;

  Future<void> loadProfile() async {
    await loadProfileForUser(null);
  }

  Future<void> loadProfileForUser(String? uid) async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Try to load local profile
      final jsonStr = prefs.getString(AppConstants.keyFarmerProfile);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        _profile = FarmerProfile.fromJsonString(jsonStr);
        _profileComplete = prefs.getBool(AppConstants.keyProfileComplete) ?? true;
      }

      // 2. Fetch from Firestore if UID is available
      if (uid != null && uid.isNotEmpty) {
        final data = await FirestoreFarmerService().fetchFarmerData(uid);
        if (data != null) {
          final farmerName = data['farmerName'] as String? ?? _profile?.name ?? '';
          final location = data['location'] as String? ?? _profile?.location ?? '';
          final state = data['state'] as String? ?? _profile?.state ?? '';
          final soilType = data['soilType'] as String? ?? _profile?.soilType ?? '';
          final farmSize = (data['farmSizeInAcres'] ?? _profile?.farmSizeInAcres ?? 0.0).toDouble();
          final currentCrop = data['currentCrop'] as String? ?? _profile?.currentCrop ?? '';
          final preferredLanguage = data['preferredLanguage'] as String? ?? _profile?.preferredLanguage ?? 'hi';
          final rawLands = data['lands'] as List<dynamic>? ?? [];
          final loadedLands = rawLands.map((e) => LandDetail.fromJson(Map<String, dynamic>.from(e))).toList();

          _profile = FarmerProfile(
            id: uid,
            name: farmerName,
            location: location,
            state: state,
            soilType: soilType,
            farmSizeInAcres: farmSize,
            currentCrop: currentCrop,
            preferredLanguage: preferredLanguage,
            lands: loadedLands.isNotEmpty ? loadedLands : (_profile?.lands ?? []),
          );
          _profileComplete = true;
          await prefs.setString(AppConstants.keyFarmerProfile, _profile!.toJsonString());
          await prefs.setBool(AppConstants.keyProfileComplete, true);
        }
      }
    } catch (e) {
      debugPrint('Error loading farmer profile for user $uid: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveProfile(FarmerProfile profile, [dynamic crops]) async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyFarmerProfile, profile.toJsonString());
      await prefs.setBool(AppConstants.keyProfileComplete, true);
      _profile = profile;
      _profileComplete = true;

      // Sync live to Cloud Firestore
      final uid = profile.id.isNotEmpty
          ? profile.id
          : 'farmer_${DateTime.now().millisecondsSinceEpoch}';
      FirestoreFarmerService().saveFarmerData(
        uid: uid,
        profile: profile,
        crops: crops != null ? List.from(crops) : null,
      );
    } catch (e) {
      debugPrint('Firestore save error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyFarmerProfile);
    await prefs.remove(AppConstants.keyProfileComplete);
    _profile = null;
    _profileComplete = false;
    notifyListeners();
  }
}
