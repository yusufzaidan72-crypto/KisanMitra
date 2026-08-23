import 'dart:convert';

class LandDetail {
  final String id;
  final String name;
  final double sizeInAcres;
  final String soilType;
  final String crop;

  const LandDetail({
    required this.id,
    required this.name,
    required this.sizeInAcres,
    required this.soilType,
    this.crop = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sizeInAcres': sizeInAcres,
        'soilType': soilType,
        'crop': crop,
      };

  factory LandDetail.fromJson(Map<String, dynamic> json) => LandDetail(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        sizeInAcres: (json['sizeInAcres'] ?? 0.0).toDouble(),
        soilType: json['soilType'] ?? '',
        crop: json['crop'] ?? '',
      );
}

class FarmerProfile {
  final String id;
  final String name;
  final String location;
  final String state;
  final String preferredLanguage;
  final String soilType;
  final double farmSizeInAcres;
  final String currentCrop;
  final String phoneNumber;
  final List<LandDetail> lands;

  const FarmerProfile({
    required this.id,
    required this.name,
    required this.location,
    required this.state,
    required this.preferredLanguage,
    required this.soilType,
    required this.farmSizeInAcres,
    required this.currentCrop,
    this.phoneNumber = '',
    this.lands = const [],
  });

  FarmerProfile copyWith({
    String? id,
    String? name,
    String? location,
    String? state,
    String? preferredLanguage,
    String? soilType,
    double? farmSizeInAcres,
    String? currentCrop,
    String? phoneNumber,
    List<LandDetail>? lands,
  }) {
    return FarmerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      state: state ?? this.state,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      soilType: soilType ?? this.soilType,
      farmSizeInAcres: farmSizeInAcres ?? this.farmSizeInAcres,
      currentCrop: currentCrop ?? this.currentCrop,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      lands: lands ?? this.lands,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'state': state,
        'preferredLanguage': preferredLanguage,
        'soilType': soilType,
        'farmSizeInAcres': farmSizeInAcres,
        'currentCrop': currentCrop,
        'phoneNumber': phoneNumber,
        'lands': lands.map((l) => l.toJson()).toList(),
      };

  factory FarmerProfile.fromJson(Map<String, dynamic> json) {
    final rawLands = json['lands'] as List<dynamic>? ?? [];
    final loadedLands = rawLands
        .map((e) => LandDetail.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return FarmerProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      state: json['state'] ?? '',
      preferredLanguage: json['preferredLanguage'] ?? 'hi',
      soilType: json['soilType'] ?? '',
      farmSizeInAcres: (json['farmSizeInAcres'] ?? 0.0).toDouble(),
      currentCrop: json['currentCrop'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      lands: loadedLands,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory FarmerProfile.fromJsonString(String jsonStr) =>
      FarmerProfile.fromJson(jsonDecode(jsonStr));

  String get firstName {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Kisan';
    return trimmed.split(' ').first;
  }
}
