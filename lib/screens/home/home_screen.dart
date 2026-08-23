import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
        ),
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(l, farmer?.firstName ?? l.farmer),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    _buildHeroBanner(l).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 20),
                    _buildWeatherCard(l).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                    const SizedBox(height: 24),
                    _buildCropSection(l, farmer).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: l.quickActions,
                      actionLabel: null,
                    ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                    const SizedBox(height: 14),
                    _buildQuickActions(l).animate().fadeIn(duration: 600.ms, delay: 350.ms),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(AppLocalizations l, String firstName) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? l.goodMorning
        : hour < 17
            ? l.goodAfternoon
            : l.goodEvening;

    return SliverAppBar(
      expandedHeight: 165,
      pinned: true,
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: AppColors.backgroundSecondary.withValues(alpha: 0.8),
      actions: [
        _buildNotificationBell(context, l),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
          onPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary.withValues(alpha: 0.7),
            border: const Border(bottom: BorderSide(color: AppColors.glassBorder, width: 1)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.spa_rounded, color: AppColors.primary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              l.appName,
                              style: AppTextStyles.demoBadge.copyWith(color: AppColors.primaryLight),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.primaryGlow,
                              blurRadius: 12,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: const Center(child: Text('👨‍🌾', style: TextStyle(fontSize: 24))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$greeting,',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                            Text(
                              firstName,
                              style: AppTextStyles.headlineLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
        titlePadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildHeroBanner(AppLocalizations l) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      borderColor: AppColors.primary.withValues(alpha: 0.4),
      backgroundColor: AppColors.glassSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.accent, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'AI SMART FARMING',
                      style: AppTextStyles.demoBadge.copyWith(color: AppColors.accentLight),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const DemoBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l.isHindi
                ? 'स्मार्ट कृषि सहायक के साथ पैदावार बढ़ाएं'
                : 'Empowering Your Harvest with AI Intelligence',
            style: AppTextStyles.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            l.isHindi
                ? 'मौसम सलाह, रोग पहचान और लाइव मंडी भाव एक ही स्थान पर प्राप्त करें।'
                : 'Instant disease diagnosis, predictive weather alerts, and real-time mandi prices.',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBell(BuildContext context, AppLocalizations l) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, _) {
        final alerts = weatherProvider.weather?.agriculturalAlerts ?? [];
        final hasAlerts = alerts.isNotEmpty;

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
              onPressed: () => _showNotificationDialog(context, l, alerts),
            ),
            if (hasAlerts)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 1.5),
                  ),
                ),
              ),
          ],
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
          borderRadius: BorderRadius.circular(20),
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
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_off_outlined, size: 44, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l.isHindi ? 'अभी कोई नई सूचना नहीं है' : 'No new notifications',
                      style: AppTextStyles.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.isHindi
                          ? 'मौसम अलर्ट, बारिश और फसल सलाह की सूचनाएं यहां प्राप्त होंगी।'
                          : 'Weather alerts, rain warnings, and crop advisory notifications will appear here.',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: alerts.map((alert) => _buildAlertCardInModal(alert)).toList(),
                  ),
                ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l.isHindi ? 'ठीक है' : 'OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCardInModal(AgriculturalAlert alert) {
    final (color, icon) = switch (alert.severity) {
      AlertSeverity.critical => (AppColors.error, Icons.warning_amber_rounded),
      AlertSeverity.warning => (AppColors.warning, Icons.info_rounded),
      _ => (AppColors.accent, Icons.check_circle_outline),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title, style: AppTextStyles.titleSmall.copyWith(color: color, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(alert.message, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(AppLocalizations l) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const GlassCard(
            child: SizedBox(
              height: 110,
              child: LoadingWidget(message: 'Fetching live weather...'),
            ),
          );
        }
        if (provider.error != null) {
          return GlassCard(
            child: ErrorStateWidget(
              message: provider.error!,
              onRetry: _loadData,
            ),
          );
        }
        final w = provider.weather;
        if (w == null) return const SizedBox.shrink();

        return GlassCard(
          borderColor: AppColors.secondary.withValues(alpha: 0.4),
          onTap: () {
            if (provider.weather == null && provider.error != null) {
              provider.fetchWeatherWithGPS();
            } else {
              Navigator.pushNamed(context, '/weather');
            }
          },
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                                color: AppColors.secondary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                l.currentWeather,
                                style: AppTextStyles.chip.copyWith(color: AppColors.secondaryLight),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => context.read<WeatherProvider>().fetchWeatherWithGPS(),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 2),
                                  Text(
                                    w.location,
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${w.temperature.toStringAsFixed(0)}°C',
                              style: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimary),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              w.condition,
                              style: AppTextStyles.titleLarge.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(w.conditionIcon, style: const TextStyle(fontSize: 52)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _weatherStat('💧', '${w.humidity.toInt()}%', l.humidity),
                    _weatherStatDivider(),
                    _weatherStat('🌬️', '${w.windSpeed.toStringAsFixed(0)} km/h', l.windSpeed),
                    _weatherStatDivider(),
                    _weatherStat('🌧️', '${w.rainProbability.toInt()}%', l.rainProbability),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _weatherStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _weatherStatDivider() {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.border,
    );
  }

  Widget _buildCropSection(AppLocalizations l, dynamic farmer) {
    return Consumer<CropMonitorProvider>(
      builder: (context, provider, _) {
        final crops = provider.crops;

        if (crops.isEmpty) {
          return GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: l.currentCrop,
                  actionLabel: l.isHindi ? '+ फसल जोड़ें' : '+ Add Crop',
                  onAction: () => Navigator.pushNamed(context, '/crops'),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.cardBg,
                          shape: BoxShape.circle,
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
                            const SizedBox(height: 2),
                            Text(
                              l.isHindi
                                  ? 'अपनी फसल की जानकारी जोड़ने के लिए "+ फसल जोड़ें" पर क्लिक करें।'
                                  : 'Tap "+ Add Crop" to start tracking your crop.',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: l.currentCrop,
              actionLabel: l.viewAll,
              onAction: () => Navigator.pushNamed(context, '/crops'),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 118,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: crops.length,
                itemBuilder: (context, i) => Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 12),
                  child: _buildSmallCropCard(crops[i], l),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSmallCropCard(CropMonitor crop, AppLocalizations l) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: const Text('🌾', style: TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(crop.cropName.split(' / ').first, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                Text(crop.growthStage.split(' / ').first, style: AppTextStyles.bodySmall),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: crop.progressPercent,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AppLocalizations l) {
    final actions = [
      _QuickAction('🌱', l.recommendCrop, AppColors.primary, '/crop-recommend'),
      _QuickAction('🔍', l.scanPlant, AppColors.secondary, '/disease-scan'),
      _QuickAction('💧', l.irrigation, AppColors.accent, '/irrigation'),
      _QuickAction('📊', l.marketPrices, AppColors.secondaryLight, '/market'),
      _QuickAction('🤖', l.askAI, AppColors.primaryLight, '/assistant'),
      _QuickAction('⛅', l.weather, AppColors.info, '/weather'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.98,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) => _buildActionTile(actions[i]),
    );
  }

  Widget _buildActionTile(_QuickAction action) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, action.route),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        margin: EdgeInsets.zero,
        borderColor: action.color.withValues(alpha: 0.3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: action.color.withValues(alpha: 0.4)),
              ),
              child: Center(child: Text(action.emoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final String emoji;
  final String label;
  final Color color;
  final String route;
  const _QuickAction(this.emoji, this.label, this.color, this.route);
}
