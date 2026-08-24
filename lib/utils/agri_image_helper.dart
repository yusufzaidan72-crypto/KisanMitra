import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'lovable_colors.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Smart Agriculture Internet Asset Helper
/// Dynamically fetches and caches high-definition photos & visual assets
/// related to agriculture, farming, crops, soil, grass, and weather.
/// ─────────────────────────────────────────────────────────────────────────────
class AgriImageHelper {
  static const Map<String, String> _agriPhotoMap = {
    'farm': 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1600&q=80',
    'grass': 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
    'wheat': 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80',
    'rice': 'https://images.unsplash.com/photo-1535242208474-9a279b24b27e?auto=format&fit=crop&w=1200&q=80',
    'tomato': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=1200&q=80',
    'onion': 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?auto=format&fit=crop&w=1200&q=80',
    'cotton': 'https://images.unsplash.com/photo-1595186532296-608b2611684c?auto=format&fit=crop&w=1200&q=80',
    'irrigation': 'https://images.unsplash.com/photo-1563514227147-6d2ff665a6a0?auto=format&fit=crop&w=1200&q=80',
    'disease': 'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?auto=format&fit=crop&w=1200&q=80',
    'soil': 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?auto=format&fit=crop&w=1200&q=80',
    'weather': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80',
    'mandi': 'https://images.unsplash.com/photo-1488459716781-31db52582fe9?auto=format&fit=crop&w=1200&q=80',
    'farmer': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=600&q=80',
  };

  /// Returns a high-definition agriculture image URL for a given keyword
  static String getUrl(String keyword, {int width = 800, int height = 600}) {
    final key = keyword.toLowerCase().trim();
    if (_agriPhotoMap.containsKey(key)) {
      return _agriPhotoMap[key]!;
    }
    // Dynamic Unsplash keyword generator fallback
    final cleanKeyword = Uri.encodeComponent(key.isEmpty ? 'farm' : '$key,agriculture,grass');
    return 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=$width&h=$height&q=80&keywords=$cleanKeyword';
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Smart Agriculture Cached Image Widget with Glass Shimmer Loading & Fallback
/// ─────────────────────────────────────────────────────────────────────────────
class AgriImage extends StatelessWidget {
  final String keywordOrUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const AgriImage({
    super.key,
    required this.keywordOrUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final String url = keywordOrUrl.startsWith('http')
        ? keywordOrUrl
        : AgriImageHelper.getUrl(keywordOrUrl);

    Widget imageWidget = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          borderRadius: borderRadius,
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(LovableColors.emeraldAccent),
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          borderRadius: borderRadius,
        ),
        child: const Center(
          child: Icon(Icons.grass_rounded, color: LovableColors.forest, size: 32),
        ),
      ),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    if (boxShadow != null) {
      imageWidget = Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: boxShadow,
        ),
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
