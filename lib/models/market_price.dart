class MarketPrice {
  final String cropName;
  final String cropNameHindi;
  final double currentPrice;
  final double minPrice;
  final double maxPrice;
  final String unit;
  final String marketName;
  final String state;
  final DateTime lastUpdated;
  final bool isDemo;
  final double priceChangePercent;

  const MarketPrice({
    required this.cropName,
    required this.cropNameHindi,
    required this.currentPrice,
    required this.minPrice,
    required this.maxPrice,
    required this.unit,
    required this.marketName,
    required this.state,
    required this.lastUpdated,
    required this.isDemo,
    required this.priceChangePercent,
  });

  bool get isPriceUp => priceChangePercent >= 0;

  String get formattedPrice => '₹${currentPrice.toStringAsFixed(0)}';
  String get formattedMin => '₹${minPrice.toStringAsFixed(0)}';
  String get formattedMax => '₹${maxPrice.toStringAsFixed(0)}';

  factory MarketPrice.fromJson(Map<String, dynamic> json) => MarketPrice(
        cropName: json['cropName'] as String? ?? '',
        cropNameHindi: json['cropNameHindi'] as String? ?? '',
        currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
        minPrice: (json['minPrice'] as num?)?.toDouble() ?? 0.0,
        maxPrice: (json['maxPrice'] as num?)?.toDouble() ?? 0.0,
        unit: json['unit'] as String? ?? 'Quintal',
        marketName: json['marketName'] as String? ?? '',
        state: json['state'] as String? ?? '',
        lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated'] as String) : DateTime.now(),
        isDemo: json['isDemo'] as bool? ?? false,
        priceChangePercent: (json['priceChangePercent'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'cropName': cropName,
        'cropNameHindi': cropNameHindi,
        'currentPrice': currentPrice,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'unit': unit,
        'marketName': marketName,
        'state': state,
        'lastUpdated': lastUpdated.toIso8601String(),
        'isDemo': isDemo,
        'priceChangePercent': priceChangePercent,
      };

  MarketPrice copyWith({
    String? cropName,
    String? cropNameHindi,
    double? currentPrice,
    double? minPrice,
    double? maxPrice,
    String? unit,
    String? marketName,
    String? state,
    DateTime? lastUpdated,
    bool? isDemo,
    double? priceChangePercent,
  }) {
    return MarketPrice(
      cropName: cropName ?? this.cropName,
      cropNameHindi: cropNameHindi ?? this.cropNameHindi,
      currentPrice: currentPrice ?? this.currentPrice,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      unit: unit ?? this.unit,
      marketName: marketName ?? this.marketName,
      state: state ?? this.state,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isDemo: isDemo ?? this.isDemo,
      priceChangePercent: priceChangePercent ?? this.priceChangePercent,
    );
  }
}

