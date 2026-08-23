import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/farmer_provider.dart';
import '../../providers/app_providers.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../models/weather_data.dart';
import '../../models/crop_monitor.dart';
import '../../widgets/widgets.dart';
import '../../localization/app_localizations.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final weatherProvider = context.read<WeatherProvider>();
    if (weatherProvider.currentCity.isEmpty) {
      final profile = context.read<FarmerProvider>().profile;
      await weatherProvider.fetchWeather(profile?.location ?? 'Lucknow');
    } else {
      await weatherProvider.fetchWeather(weatherProvider.currentCity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final farmer = context.watch<FarmerProvider>().profile;
    final firstName = farmer?.firstName ?? l.farmer;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? l.goodMorning : hour < 17 ? l.goodAfternoon : l.goodEvening;

    return Scaffold(
      backgroundColor: const Color(0xFF050810),
      body: AmbientBackground(
        scrollController: _scrollController,
        child: Stack(
          children: [
            // Scrollable main content
            RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.cardBg,
              onRefresh: _loadData,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Top padding for the floating nav bar
                  SliverToBoxAdapter(
                    child: SizedBox(height: MediaQuery.of(context).padding.top + 84),
                  ),

                  // ─────── HERO SECTION ───────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: _buildHeroSection(l, greeting, firstName),
                    ),
                  ),

                  // ─────── WEATHER CARD ───────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _buildWeatherCard(l)
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 600.ms)
                          .slideY(begin: 0.15, end: 0, delay: 400.ms, duration: 600.ms,
                              curve: Curves.easeOutCubic),
                    ),
                  ),

                  // ─────── CROPS SECTION ───────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _buildCropSection(l, farmer)
                          .animate()
                          .fadeIn(delay: 550.ms, duration: 600.ms)
                          .slideY(begin: 0.15, end: 0, delay: 550.ms, duration: 600.ms,
                              curve: Curves.easeOutCubic),
                    ),
                  ),

                  // ─────── SECTION HEADER: Quick Actions ───────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                    sliver: SliverToBoxAdapter(
                      child: _buildSectionHeader(
                        l.isHindi ? 'त्वरित कार्य' : 'Quick Actions',
                        icon: Icons.grid_view_rounded,
                      ).animate()
                          .fadeIn(delay: 650.ms, duration: 500.ms),
                    ),
                  ),

                  // ─────── 3D FLOATING ACTION GRID ───────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: _buildActionGrid(l),
                    ),
                  ),

                  // ─────── BOTTOM PADDING ───────
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),

            // Floating pill navbar (always on top)
            FloatingNavBar(
              title: 'KisanMitra AI',
              actions: [
                _buildNotificationBell(context, l),
                const SizedBox(width: 4),
                _buildSettingsButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HERO SECTION — staggered spring reveal
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildHeroSection(AppLocalizations l, String greeting, String firstName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting line
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.primaryGlow,
                    blurRadius: 16,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: const Center(child: Text('👨‍🌾', style: TextStyle(fontSize: 22))),
            ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1), duration: 500.ms, curve: Curves.easeOutBack),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                Text(
                  firstName,
                  style: AppTextStyles.headlineLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).animate().fadeIn(delay: 150.ms, duration: 500.ms),
              ],
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Main hero headline — gradient text
        ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: Text(
            l.isHindi
                ? 'स्मार्ट कृषि सहायक के साथ\nपैदावार बढ़ाएं'
                : 'Empowering Your\nHarvest with AI',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 800.ms)
            .slideY(
              begin: 0.35,
              end: 0,
              delay: 200.ms,
              duration: 800.ms,
              curve: const Cubic(0.175, 0.885, 0.32, 1.275),
            ),

        const SizedBox(height: 14),

        // Tagline
        Text(
          l.isHindi
              ? 'मौसम सलाह, रोग पहचान और लाइव मंडी भाव एक ही स्थान पर प्राप्त करें।'
              : 'Disease diagnosis, predictive weather & real-time mandi prices — all in one place.',
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.65,
            color: AppColors.textSecondary.withValues(alpha: 0.9),
            fontWeight: FontWeight.w400,
          ),
        )
            .animate()
            .fadeIn(delay: 350.ms, duration: 700.ms)
            .slideY(begin: 0.2, end: 0, delay: 350.ms, duration: 700.ms, curve: Curves.easeOutCubic),

        const SizedBox(height: 24),

        // CTA buttons row
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            GradientButton(
              label: l.isHindi ? '🔍 रोग स्कैन करें' : '🔍 Scan Disease',
              onPressed: () => Navigator.pushNamed(context, '/disease-scan'),
              colors: const [Color(0xFF16A34A), Color(0xFF22C55E), Color(0xFF06B6D4)],
            ).animate().fadeIn(delay: 480.ms, duration: 600.ms)
                .slideX(begin: -0.1, end: 0, delay: 480.ms, duration: 600.ms, curve: Curves.easeOutCubic),

            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/crop-recommend'),
              icon: const Icon(Icons.auto_awesome, size: 16, color: AppColors.accent),
              label: Text(
                l.isHindi ? 'AI सलाह' : 'AI Advice',
                style: const TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                side: BorderSide(color: AppColors.accent.withValues(alpha: 0.6), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
            ).animate().fadeIn(delay: 540.ms, duration: 600.ms)
                .slideX(begin: 0.1, end: 0, delay: 540.ms, duration: 600.ms, curve: Curves.easeOutCubic),
          ],
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // WEATHER CARD — neon data chips + 3D glass card
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildWeatherCard(AppLocalizations l) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return GlassCard(
            blur: 15,
            elevation: 1.5,
            child: SizedBox(
              height: 120,
              child: LoadingWidget(message: l.isHindi ? 'मौसम डेटा लोड हो रहा है...' : 'Fetching live weather...'),
            ),
          );
        }
        if (provider.error != null) {
          return GlassCard(
            blur: 15,
            elevation: 1,
            child: ErrorStateWidget(message: provider.error!, onRetry: _loadData),
          );
        }
        final w = provider.weather;
        if (w == null) return const SizedBox.shrink();

        return GlassCard(
          blur: 15,
          elevation: 1.8,
          borderColor: AppColors.secondary.withValues(alpha: 0.5),
          onTap: () => Navigator.pushNamed(context, '/weather'),
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.wb_sunny_outlined, color: AppColors.secondary, size: 13),
                                  const SizedBox(width: 4),
                                  Text(
                                    l.currentWeather,
                                    style: const TextStyle(
                                      color: AppColors.secondaryLight,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => context.read<WeatherProvider>().fetchWeatherWithGPS(),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on, size: 13, color: AppColors.textMuted),
                                  const SizedBox(width: 2),
                                  Text(w.location, style: AppTextStyles.bodySmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ShaderMask(
                          shaderCallback: (r) => const LinearGradient(
                            colors: [AppColors.textPrimary, AppColors.secondaryLight],
                          ).createShader(r),
                          child: Text(
                            '${w.temperature.toStringAsFixed(0)}°C',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          w.condition,
                          style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // Weather icon + agriculture alert
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(w.conditionIcon, style: const TextStyle(fontSize: 56)),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _showNotificationDialog(context, l, provider.weather?.agriculturalAlerts ?? []),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.accentSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.notifications_active, color: AppColors.accent, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                l.isHindi ? 'अलर्ट' : 'Alerts',
                                style: const TextStyle(color: AppColors.accentLight, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Neon data chips row — neon glowing values
              Row(
                children: [
                  Expanded(
                    child: NeonDataChip(
                      emoji: '💧',
                      label: l.humidity,
                      value: '${w.humidity.toInt()}%',
                      accentColor: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: NeonDataChip(
                      emoji: '🌬️',
                      label: l.windSpeed,
                      value: '${w.windSpeed.toStringAsFixed(0)} km/h',
                      accentColor: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: NeonDataChip(
                      emoji: '🌧️',
                      label: l.rainProbability,
                      value: '${w.rainProbability.toInt()}%',
                      accentColor: AppColors.accent,
                    ),
                  ),
                ],
              ),

              // Tap hint
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    l.isHindi ? 'पूरी रिपोर्ट देखें →' : 'Full forecast →',
                    style: TextStyle(
                      color: AppColors.secondary.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // CROPS SECTION
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildCropSection(AppLocalizations l, dynamic farmer) {
    return Consumer<CropMonitorProvider>(
      builder: (context, provider, _) {
        final crops = provider.crops;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              l.currentCrop,
              icon: Icons.eco_rounded,
              actionLabel: crops.isEmpty ? (l.isHindi ? '+ जोड़ें' : '+ Add') : l.viewAll,
              onAction: () => Navigator.pushNamed(context, '/crops'),
            ),
            const SizedBox(height: 14),
            if (crops.isEmpty)
              _buildNoCropState(l)
            else
              SizedBox(
                height: 116,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: crops.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) =>
                      SizedBox(width: 260, child: _buildCropCard(crops[i], l)),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCropCard(CropMonitor crop, AppLocalizations l) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      margin: EdgeInsets.zero,
      elevation: 1.5,
      borderColor: AppColors.primary.withValues(alpha: 0.4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              boxShadow: const [
                BoxShadow(color: AppColors.primaryGlow, blurRadius: 12, spreadRadius: 1),
              ],
            ),
            child: const Text('🌾', style: TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  crop.cropName.split(' / ').first,
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(crop.growthStage.split(' / ').first, style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: crop.progressPercent.clamp(0.0, 1.0),
                      child: Container(
                        height: 5,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(color: AppColors.primaryGlow, blurRadius: 6),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCropState(AppLocalizations l) {
    return GlassCard(
      elevation: 1.2,
      borderColor: AppColors.primary.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: const Text('🌱', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.isHindi ? 'कोई फसल नहीं जोड़ी गई है' : 'No crops added yet',
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  l.isHindi
                      ? 'अपनी फसल ट्रैक करना शुरू करें।'
                      : 'Start tracking your crops now.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 3D FLOATING ACTION GRID — Asymmetric 2x3 + featured tile layout
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildActionGrid(AppLocalizations l) {
    final actions = [
      _Action('🌱', l.recommendCrop, AppColors.primary, '/crop-recommend'),
      _Action('🔍', l.scanPlant, AppColors.secondary, '/disease-scan'),
      _Action('💧', l.irrigation, AppColors.accent, '/irrigation'),
      _Action('📊', l.marketPrices, AppColors.secondaryLight, '/market'),
      _Action('🤖', l.askAI, AppColors.primaryLight, '/assistant'),
      _Action('⛅', l.weather, AppColors.info, '/weather'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.9,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) => ActionTile3D(
        emoji: actions[i].emoji,
        label: actions[i].label,
        accentColor: actions[i].color,
        onTap: () => Navigator.pushNamed(context, actions[i].route),
        animationDelay: i,
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: 700 + i * 70), duration: 500.ms)
          .slideY(
            begin: 0.2,
            end: 0,
            delay: Duration(milliseconds: 700 + i * 70),
            duration: 500.ms,
            curve: Curves.easeOutCubic,
          )
          .scale(
            begin: const Offset(0.88, 0.88),
            end: const Offset(1, 1),
            delay: Duration(milliseconds: 700 + i * 70),
            duration: 500.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(
    String title, {
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const Spacer(),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSettingsButton() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/settings'),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(Icons.settings_outlined, color: AppColors.textSecondary, size: 17),
      ),
    );
  }

  Widget _buildNotificationBell(BuildContext context, AppLocalizations l) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, _) {
        final alerts = weatherProvider.weather?.agriculturalAlerts ?? [];
        return GestureDetector(
          onTap: () => _showNotificationDialog(context, l, alerts),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 17),
              ),
              if (alerts.isNotEmpty)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.error.withValues(alpha: 0.6), blurRadius: 6)],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationDialog(BuildContext context, AppLocalizations l, List<AgriculturalAlert> alerts) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Row(
          children: [
            const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              l.isHindi ? 'कृषि सूचनाएं & अलर्ट' : 'Agricultural Alerts',
              style: AppTextStyles.titleLarge,
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: alerts.isEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    const Icon(Icons.notifications_off_outlined, size: 44, color: AppColors.primary),
                    const SizedBox(height: 14),
                    Text(
                      l.isHindi ? 'अभी कोई नई सूचना नहीं है' : 'No new notifications',
                      style: AppTextStyles.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.isHindi
                          ? 'मौसम अलर्ट, बारिश और फसल सलाह यहां दिखेंगे।'
                          : 'Weather alerts & crop advisories will appear here.',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: alerts.map((a) => _buildAlertTile(a)).toList(),
                  ),
                ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(l.isHindi ? 'ठीक है' : 'OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTile(AgriculturalAlert alert) {
    final (color, icon) = switch (alert.severity) {
      AlertSeverity.critical => (AppColors.error, Icons.warning_amber_rounded),
      AlertSeverity.warning => (AppColors.warning, Icons.info_rounded),
      _ => (AppColors.accent, Icons.check_circle_outline),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title, style: AppTextStyles.titleSmall.copyWith(color: color, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(alert.message, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Action {
  final String emoji, label, route;
  final Color color;
  const _Action(this.emoji, this.label, this.color, this.route);
}
