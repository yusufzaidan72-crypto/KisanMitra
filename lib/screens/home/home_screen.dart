import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../providers/farmer_provider.dart';
import '../../utils/lovable_colors.dart';
import '../../utils/agri_image_helper.dart';
import '../../widgets/lovable_glass.dart';

import '../crop_monitor/crop_monitor_screen.dart';
import '../crop_recommendation/crop_recommendation_screen.dart';
import '../disease_scan/disease_scan_screen.dart';
import '../irrigation/irrigation_screen.dart';
import '../market/market_screen.dart';
import '../profile/farmer_profile_screen.dart';
import '../weather/weather_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Live mandi data
// ─────────────────────────────────────────────────────────────────────────────
class _MandiRow {
  final String crop, market, price, change;
  final bool up;
  const _MandiRow(this.crop, this.market, this.price, this.change, this.up);
}

const _mandiData = [
  _MandiRow('Wheat', 'Karnal Mandi', '₹2,340', '+4.2%', true),
  _MandiRow('Basmati Rice', 'Amritsar', '₹4,120', '+1.8%', true),
  _MandiRow('Onion', 'Nashik', '₹1,760', '-2.4%', false),
  _MandiRow('Tomato', 'Kolar', '₹1,180', '+6.9%', true),
  _MandiRow('Cotton', 'Rajkot', '₹7,450', '-0.7%', false),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadWeather());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    final wp = context.read<WeatherProvider>();
    final profile = context.read<FarmerProvider>().profile;
    await wp.fetchWeather(profile?.location ?? 'Nashik');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isWide = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Farm background photo using AgriImage
          const AgriImage(
            keywordOrUrl: 'farm',
            fit: BoxFit.cover,
          ),


          // Gradient overlay
          Container(
            decoration: const BoxDecoration(gradient: LovableColors.bgOverlay),
          ),

          // Scrollable content
          RefreshIndicator(
            color: LovableColors.emeraldAccent,
            onRefresh: _loadWeather,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).padding.top + 88,
                  ),
                ),

                // Hero Section
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: _buildHero(context, l),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 36)),

                // ALL Quick Action Feature Options Grid (Crop Suggestions, Add Crop, Disease Scan, etc.)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: _buildAllFeatureOptionsGrid(context, l),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 36)),

                // Main Bento Grid (Weather & Mandi cards - AI Card removed)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                  sliver: SliverToBoxAdapter(
                    child: isWide
                        ? _buildWideBentoGrid(context, l)
                        : _buildNarrowBentoGrid(context, l),
                  ),
                ),
              ],
            ),
          ),

          // Top Floating Pill Navbar (Top Right Profile avatar pill)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: _buildNavBar(context),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // NAV BAR — Clean top header (avatar pill opens FarmerProfileScreen directly)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildNavBar(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1152),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: LovableColors.glassStrong,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: LovableColors.glassBorder, width: 1),
            boxShadow: LovableColors.shadowGlass,
          ),
          child: Row(
            children: [
              // Brand Logo & Title
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LovableColors.ctaGradient,
                      shape: BoxShape.circle,
                      boxShadow: LovableColors.shadowGlow,
                    ),
                    child: const Icon(LucideIcons.sprout, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'KisanMitra AI',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: LovableColors.forest,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Profile Avatar Pill (opens Farmer Profile Screen on Tap)
              _buildAvatarPill(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPill(BuildContext context) {
    final farmer = context.watch<FarmerProvider>().profile;
    final name = (farmer != null && farmer.name.isNotEmpty) ? farmer.name : 'Yusuf';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FarmerProfileScreen(isEditing: true),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: LovableColors.glassStrong,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: LovableColors.glassBorder, width: 1.5),
              boxShadow: LovableColors.shadowGlass,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    gradient: LovableColors.ctaGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name[0].toUpperCase(),
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: LovableColors.forest,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(LucideIcons.userCheck, size: 16, color: LovableColors.forest),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // HERO SECTION
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildHero(BuildContext context, AppLocalizations l) {
    return Column(
      children: [
        GlassChip(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.sparkles, size: 14, color: LovableColors.emeraldAccent),
              const SizedBox(width: 6),
              Text(
                l.isHindi ? 'कृषि सलाह और अंतर्दृष्टि लाइव हैं' : 'Agricultural insights & weather are live',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: LovableColors.slateGreen,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: -0.2, end: 0, duration: 500.ms),

        const SizedBox(height: 20),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.outfit(
              fontSize: MediaQuery.of(context).size.width > 600 ? 56 : 36,
              fontWeight: FontWeight.w800,
              color: LovableColors.forest,
              height: 1.08,
              letterSpacing: -1.2,
            ),
            children: [
              TextSpan(text: l.isHindi ? 'स्मार्ट खेती करें, ' : 'Grow smarter, '),
              WidgetSpan(
                child: ShaderMask(
                  shaderCallback: (r) => LovableColors.textGradient.createShader(r),
                  child: Text(
                    l.isHindi ? 'बेहतर फसल पाएं' : 'harvest richer',
                    style: GoogleFonts.outfit(
                      fontSize: MediaQuery.of(context).size.width > 600 ? 56 : 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.08,
                      letterSpacing: -1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 150.ms, duration: 700.ms)
            .slideY(begin: 0.3, end: 0, delay: 150.ms, duration: 700.ms, curve: Curves.easeOutCubic),

        const SizedBox(height: 16),

        Text(
          l.isHindi
              ? 'मौसम अलर्ट, लाइव मंडी भाव, फसल बीमारी पहचान और AI सलाह - सब एक ही स्थान पर।'
              : 'Real-time field intelligence — weather warnings, mandi rates, and crop disease diagnosis from a photo.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            height: 1.6,
            color: LovableColors.slateGreen,
            fontWeight: FontWeight.w500,
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

        const SizedBox(height: 28),

        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            CtaButton(
              label: l.isHindi ? 'बीमारी स्कैन करें' : 'Scan Crop Disease',
              icon: LucideIcons.scanLine,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DiseaseScanScreen()),
                );
              },
            ),
            GlassOutlineButton(
              label: l.isHindi ? 'फसल सुझाव देखें' : 'Crop Suggestions',
              trailingIcon: LucideIcons.sparkles,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CropRecommendationScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // ALL FEATURE OPTIONS GRID (Crop Suggestions, Add Crop, Scan, Weather, etc.)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildAllFeatureOptionsGrid(BuildContext context, AppLocalizations l) {
    final features = [
      (
        title: l.isHindi ? 'फसल सुझाव' : 'Crop Suggestions',
        subtitle: l.isHindi ? 'मिट्टी व मौसम अनुसार फसल चुनें' : 'Tailored recommendations by soil',
        icon: LucideIcons.sparkles,
        color: const Color(0xFF10B981),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CropRecommendationScreen()),
          );
        },
      ),
      (
        title: l.isHindi ? 'फसल जोड़ें / मॉनिटर' : 'Add / Track Crop',
        subtitle: l.isHindi ? 'अपनी फसल और कार्यों का हिसाब' : 'Track growth stage & field tasks',
        icon: LucideIcons.sprout,
        color: const Color(0xFF059669),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CropMonitorScreen()),
          );
        },
      ),
      (
        title: l.isHindi ? 'रोग पहचान' : 'Disease Scanner',
        subtitle: l.isHindi ? 'फोटो खींचकर बीमारी पहचानें' : 'Instant AI leaf disease diagnosis',
        icon: LucideIcons.scanLine,
        color: const Color(0xFF06B6D4),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DiseaseScanScreen()),
          );
        },
      ),
      (
        title: l.isHindi ? 'सिंचाई सलाहकार' : 'Irrigation Advice',
        subtitle: l.isHindi ? 'पानी की आवश्यकता और समय' : 'Smart water advice & timing',
        icon: LucideIcons.droplets,
        color: const Color(0xFF0284C7),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const IrrigationScreen()),
          );
        },
      ),
      (
        title: l.isHindi ? 'मंडी भाव' : 'Live Mandi Prices',
        subtitle: l.isHindi ? 'आज के ताजा बाजार भाव' : 'Real-time crop prices & MSP trends',
        icon: LucideIcons.trendingUp,
        color: const Color(0xFF059669),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MarketScreen()),
          );
        },
      ),
      (
        title: l.isHindi ? 'मौसम पूर्वानुमान' : 'Weather Forecast',
        subtitle: l.isHindi ? 'तापमान, वर्षा और कृषि अलर्ट' : 'Temperature, rain & alerts',
        icon: LucideIcons.cloudSun,
        color: const Color(0xFFD97706),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WeatherScreen()),
          );
        },
      ),
      (
        title: l.isHindi ? 'प्रोफाइल और भाषा' : 'Profile & Settings',
        subtitle: l.isHindi ? 'प्रोफाइल, भाषा व हेल्पलाइन' : 'Edit profile, language & support',
        icon: LucideIcons.userCheck,
        color: const Color(0xFF2563EB),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FarmerProfileScreen(isEditing: true)),
          );
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Text(
                l.isHindi ? 'मुख्य सेवाएं और विकल्प' : 'All Services & Quick Actions',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: LovableColors.forest,
                ),
              ),
              const Spacer(),
              GlassChip(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  '7 Options',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: LovableColors.emeraldAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 900
                ? 3
                : (constraints.maxWidth > 550 ? 2 : 1);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: features.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                mainAxisExtent: 110,
              ),
              itemBuilder: (context, index) {
                final feat = features[index];
                return LovableGlassCard(
                  padding: const EdgeInsets.all(16),
                  onTap: feat.onTap,
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: feat.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: feat.color.withValues(alpha: 0.3)),
                        ),
                        child: Icon(feat.icon, color: feat.color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              feat.title,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: LovableColors.forest,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              feat.subtitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: LovableColors.slateGreen,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(LucideIcons.chevronRight, size: 16, color: LovableColors.slateGreen),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BENTO GRID — Weather & Mandi (AI Card Removed)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildWideBentoGrid(BuildContext context, AppLocalizations l) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildWeatherCard(context),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildMandiCard(context),
        ),
      ],
    );
  }

  Widget _buildNarrowBentoGrid(BuildContext context, AppLocalizations l) {
    return Column(
      children: [
        _buildWeatherCard(context),
        const SizedBox(height: 16),
        _buildMandiCard(context),
      ],
    );
  }

  Widget _buildWeatherCard(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (ctx, wp, _) {
        if (wp.isLoading) {
          return const LovableGlassCard(
            child: SizedBox(
              height: 180,
              child: Center(
                child: CircularProgressIndicator(color: LovableColors.emeraldAccent),
              ),
            ),
          );
        }

        final w = wp.weather;
        final city = w?.location ?? 'Nashik, Maharashtra';
        final temp = w != null ? '${w.temperature.toStringAsFixed(0)}°' : '29°';
        final condition = w?.condition ?? 'Partly cloudy · Feels like 32°';
        final humidity = w != null ? '${w.humidity.toInt()}%' : '68%';
        final wind = w != null ? '${w.windSpeed.toStringAsFixed(0)} km/h' : '12 km/h';

        return LovableGlassCard(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WeatherScreen()),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          city.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: LovableColors.slateGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          temp,
                          style: GoogleFonts.outfit(
                            fontSize: 52,
                            fontWeight: FontWeight.w700,
                            color: LovableColors.forest,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          condition,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: LovableColors.slateGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    w?.conditionIcon ?? '⛅',
                    style: const TextStyle(fontSize: 48),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _weatherChip('💧', humidity, 'Humidity')),
                  const SizedBox(width: 10),
                  Expanded(child: _weatherChip('🌬️', wind, 'Wind')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _weatherChip(String emoji, String value, String label) {
    return GlassChip(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: LovableColors.forest,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: LovableColors.slateGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMandiCard(BuildContext context) {
    return LovableGlassCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MarketScreen()),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Live Mandi Prices',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: LovableColors.forest,
                ),
              ),
              const Spacer(),
              GlassChip(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  'per quintal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: LovableColors.slateGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._mandiData.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MandiRowWidget(row: row),
            ),
          ),
        ],
      ),
    );
  }
}

class _MandiRowWidget extends StatefulWidget {
  final _MandiRow row;
  const _MandiRowWidget({required this.row});

  @override
  State<_MandiRowWidget> createState() => _MandiRowWidgetState();
}

class _MandiRowWidgetState extends State<_MandiRowWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _hovered ? LovableColors.glassStrong : LovableColors.glass,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? Colors.white : LovableColors.glassBorder,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.row.crop,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: LovableColors.forest,
                    ),
                  ),
                  Text(
                    widget.row.market,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: LovableColors.slateGreen,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.row.price,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: LovableColors.forest,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      widget.row.up ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                      size: 12,
                      color: widget.row.up ? LovableColors.positive : LovableColors.negative,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      widget.row.change,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: widget.row.up ? LovableColors.positive : LovableColors.negative,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
