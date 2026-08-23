import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/farmer_profile.dart';
import '../../models/crop_monitor.dart';

/// Senior Developer Production Firestore Architecture for KisanMitra AI
/// Collection Structure:
///   farmers/{uid}
///     ├── farmerName: String
///     ├── phoneNumber: String
///     ├── location: String
///     ├── state: String
///     ├── soilType: String
///     ├── farmSizeInAcres: double
///     ├── currentCrop: String
///     ├── preferredLanguage: String
///     ├── crops: List<Map> [ { id, cropName, growthStage, soilType, plantingDate, expectedHarvestDate, notes } ]
///     └── updatedAt: ServerTimestamp
class FirestoreFarmerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'farmers';

  /// Save or update farmer profile along with full crops list in Firestore under user UID
  Future<bool> saveFarmerData({
    required String uid,
    required FarmerProfile profile,
    List<CropMonitor>? crops,
  }) async {
    if (uid.isEmpty) return false;

    try {
      final data = <String, dynamic>{
        'uid': uid,
        'farmerName': profile.name,
        'phoneNumber': profile.phoneNumber,
        'location': profile.location,
        'state': profile.state,
        'soilType': profile.soilType,
        'farmSizeInAcres': profile.farmSizeInAcres,
        'currentCrop': profile.currentCrop,
        'preferredLanguage': profile.preferredLanguage,
        'lands': profile.lands.map((l) => l.toJson()).toList(),
        'totalLandsCount': profile.lands.length + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (crops != null) {
        data['crops'] = crops.map((c) => c.toJson()).toList();
        data['totalCropsCount'] = crops.length;
      }

      debugPrint('🔥 Firestore Syncing to collection "$_collection", doc ID: "$uid"...');
      await _db.collection(_collection).doc(uid).set(
            data,
            SetOptions(merge: true),
          );

      debugPrint('✅ Firestore SUCCESS: Document written to collection "$_collection" for UID: $uid');
      return true;
    } catch (e, stack) {
      debugPrint('❌ Firestore SYNC ERROR: $e');
      debugPrint('$stack');
      return false;
    }
  }

  /// Fetch live farmer profile & crop list from Firestore for given UID
  Future<Map<String, dynamic>?> fetchFarmerData(String uid) async {
    if (uid.isEmpty) return null;

    try {
      final doc = await _db.collection(_collection).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!;
      }
    } catch (e) {
      debugPrint('⚠️ Firestore fetch error for UID $uid: $e');
    }
    return null;
  }

  /// Real-time stream listener for farmer profile & crops changes
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamFarmerData(String uid) {
    return _db.collection(_collection).doc(uid).snapshots();
  }
}
