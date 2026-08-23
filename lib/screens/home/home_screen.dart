import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/app_providers.dart';
import '../../providers/farmer_provider.dart';
import '../../utils/lovable_colors.dart';
import '../../widgets/lovable_glass.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Live mandi data (mirrors the Lovable blueprint)
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

// ─────────────────────────────────────────────────────────────────────────────
// KisanMitra Home Screen — Lovable Blueprint Port
// ─────────────────────────────────────────────────────────────────────────────
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
    final isWide = MediaQuery.of(context).size.width > 768;
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Layer 1: Farm background photo ───────────────────────────────────
          CachedNetworkImage(
            imageUrl: LovableColors.bgImageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: const Color(0xFFD1FAE5)),
            errorWidget: (_, __, ___) => Container(color: const Color(0xFFD1FAE5)),
          ),

          // ── Layer 2: Gradient overlay (matches Lovable CSS) ──────────────────
          Container(
            decoration: const BoxDecoration(gradient: LovableColors.bgOverlay),
          ),

          // ── Layer 3: Scrollable content ──────────────────────────────────────
          RefreshIndicator(
            color: LovableColors.emeraldAccent,
            onRefresh: _loadWeather,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Space for the floating navbar
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).padding.top + 88,
                  ),
                ),

                // ── Hero Section ─────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: _buildHero(context),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 56)),

                // ── Bento Grid ───────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                  sliver: SliverToBoxAdapter(
                    child: isWide
                        ? _buildWideBentoGrid(context)
                        : _buildNarrowBentoGrid(context),
                  ),
                ),
              ],
            ),
          ),

          // ── Layer 4: Floating Pill Navbar ────────────────────────────────────
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
  // NAV BAR — pill frosted glass, matches Lovable header exactly
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildNavBar(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1152),
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 24 : 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: LovableColors.glassStrong,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: LovableColors.glassBorder, width: 1),
            boxShadow: LovableColors.shadowGlass,
          ),
          child: Row(
            children: [
              // Brand
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LovableColors.ctaGradient,
                      shape: BoxShape.circle,
                      boxShadow: LovableColors.shadowGlow,
                    ),
                    child: const Icon(Icons.eco_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'KisanMitra',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: LovableColors.forest,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Nav links (desktop only)
              if (isWide) ...[
                _navLink('Dashboard', active: true),
                _navLink('Market'),
                _navLink('Scanner'),
                const SizedBox(width: 8),
              ],

              // Avatar pill
              _buildAvatarPill(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navLink(String label, {bool active = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? LovableColors.glassStrong : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? LovableColors.forest : LovableColors.slateGreen,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPill(BuildContext context) {
    final farmer = context.watch<FarmerProvider>().profile;
    final name = farmer?.firstName ?? 'Yusuf';
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/profile'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: LovableColors.glass,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: LovableColors.glassBorder),
            ),
            child: Row(
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: LovableColors.avatarUrl,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 32,
                      height: 32,
                      color: LovableColors.emeraldAccent,
                      child: Center(
                        child: Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: LovableColors.forest,
                  ),
                ),
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
  Widget _buildHero(BuildContext context) {
    return Column(
      children: [
        // "Kharif season insights are live" badge
        GlassChip(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, size: 14, color: LovableColors.emeraldAccent),
              const SizedBox(width: 6),
              Text(
                'Kharif season insights are live',
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

        const SizedBox(height: 24),

        // Main headline with gradient text on "harvest richer"
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.outfit(
              fontSize: MediaQuery.of(context).size.width > 600 ? 60 : 38,
              fontWeight: FontWeight.w800,
              color: LovableColors.forest,
              height: 1.08,
              letterSpacing: -1.2,
            ),
            children: [
              const TextSpan(text: 'Grow smarter, '),
              WidgetSpan(
                child: ShaderMask(
                  shaderCallback: (r) => LovableColors.textGradient.createShader(r),
                  child: Text(
                    'harvest richer',
                    style: GoogleFonts.outfit(
                      fontSize: MediaQuery.of(context).size.width > 600 ? 60 : 38,
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

        const SizedBox(height: 20),

        // Subtitle
        Text(
          'Real-time field intelligence for your farm — weather warnings, mandi rates\nand instant AI diagnosis of crop disease from a single photo.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            height: 1.6,
            color: LovableColors.slateGreen,
            fontWeight: FontWeight.w400,
          ),
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 600.ms),

        const SizedBox(height: 32),

        // CTA buttons row
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            CtaButton(
              label: 'Scan Crop Disease',
              icon: Icons.document_scanner_rounded,
              onTap: () => Navigator.pushNamed(context, '/disease-scan'),
            )
                .animate()
                .fadeIn(delay: 420.ms, duration: 600.ms)
                .slideX(begin: -0.15, end: 0, delay: 420.ms, duration: 600.ms, curve: Curves.easeOutCubic),

            GlassOutlineButton(
              label: 'View field report',
              trailingIcon: Icons.arrow_outward_rounded,
              onTap: () => Navigator.pushNamed(context, '/crop-monitor'),
            )
                .animate()
                .fadeIn(delay: 490.ms, duration: 600.ms)
                .slideX(begin: 0.15, end: 0, delay: 490.ms, duration: 600.ms, curve: Curves.easeOutCubic),
          ],
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BENTO GRID — wide (desktop): 6-col grid
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildWideBentoGrid(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: Weather (md:col-span-3) + AI (md:col-span-3)
        Expanded(
          child: Column(
            children: [
              _buildWeatherCard(context)
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, delay: 600.ms, duration: 600.ms, curve: Curves.easeOutCubic),
              const SizedBox(height: 20),
              _buildAICard(context)
                  .animate()
                  .fadeIn(delay: 750.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, delay: 750.ms, duration: 600.ms, curve: Curves.easeOutCubic),
            ],
          ),
        ),
        const SizedBox(width: 20),

        // Right column: Mandi prices (md:col-span-3 md:row-span-2)
        Expanded(
          child: _buildMandiCard(context)
              .animate()
              .fadeIn(delay: 680.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0, delay: 680.ms, duration: 600.ms, curve: Curves.easeOutCubic),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BENTO GRID — narrow (mobile): stacked
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildNarrowBentoGrid(BuildContext context) {
    return Column(
      children: [
        _buildWeatherCard(context).animate().fadeIn(delay: 600.ms, duration: 500.ms),
        const SizedBox(height: 16),
        _buildMandiCard(context).animate().fadeIn(delay: 700.ms, duration: 500.ms),
        const SizedBox(height: 16),
        _buildAICard(context).animate().fadeIn(delay: 800.ms, duration: 500.ms),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // WEATHER CARD
  // ───────────────────────────────────────────────────────────────────────────
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
        final rainProb = w != null ? '${w.rainProbability.toInt()}%' : 'Moist';

        return LovableGlassCard(
          onTap: () => Navigator.pushNamed(context, '/weather'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // City + weather icon row
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
                            fontWeight: FontWeight.w500,
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

              const SizedBox(height: 24),

              // Weather chips grid
              Row(
                children: [
                  Expanded(
                    child: _weatherChip('💧', humidity, 'Humidity'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _weatherChip('🌬️', wind, 'Wind'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _weatherChip('🌱', rainProb, 'Soil'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Crop alert
              GlassChip(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 16, color: LovableColors.negative),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: LovableColors.slateGreen,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Crop alert: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: LovableColors.forest,
                              ),
                            ),
                            TextSpan(
                              text: 'High humidity may trigger leaf blight in tomato. Inspect lower foliage within 48 hours.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: LovableColors.forest,
            ),
          ),
          const SizedBox(height: 2),
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

  // ───────────────────────────────────────────────────────────────────────────
  // MANDI PRICES CARD
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildMandiCard(BuildContext context) {
    return LovableGlassCard(
      onTap: () => Navigator.pushNamed(context, '/market'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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

          // Mandi rows
          ..._mandiData.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MandiRowWidget(row: row),
            ),
          ),

          const SizedBox(height: 4),

          // Best sell today footer
          GlassChip(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BEST SELL TODAY',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: LovableColors.slateGreen,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tomato · Kolar +6.9%',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: LovableColors.forest,
                        ),
                      ),
                    ],
                  ),
                ),
                CtaButton(
                  label: 'Open market',
                  trailingIcon: Icons.arrow_outward_rounded,
                  onTap: () => Navigator.pushNamed(context, '/market'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // AI CHAT CARD
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildAICard(BuildContext context) {
    return LovableGlassCard(
      onTap: () => Navigator.pushNamed(context, '/assistant'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LovableColors.ctaGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: LovableColors.shadowGlow,
                ),
                child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ask KisanMitra AI',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: LovableColors.forest,
                    ),
                  ),
                  Text(
                    'Answers in Hindi, Marathi & English',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: LovableColors.slateGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          GlassChip(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              '"Which fertilizer dose suits my 2-acre wheat field this week?"',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: LovableColors.slateGreen,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 16),

          CtaButton(
            label: 'Start a conversation',
            icon: Icons.arrow_outward_rounded,
            width: double.infinity,
            onTap: () => Navigator.pushNamed(context, '/assistant'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual Mandi price row with hover effect
// ─────────────────────────────────────────────────────────────────────────────
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
      child: AnimatedScale(
        scale: _hovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: const Cubic(0.22, 1, 0.36, 1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
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
                        widget.row.up ? Icons.trending_up : Icons.trending_down,
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
      ),
    );
  }
}
