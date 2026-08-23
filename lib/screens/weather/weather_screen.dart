import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/weather_data.dart';
import '../../widgets/common/app_widgets.dart';
import '../../localization/app_localizations.dart';
import '../../core/config/app_config.dart';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _searchCtrl = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    if (_searchCtrl.text.trim().isEmpty) return;
    context.read<WeatherProvider>().fetchWeather(_searchCtrl.text.trim());
    setState(() => _isSearching = false);
    _searchCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: l.isHindi ? 'शहर का नाम लिखें...' : 'Enter city name...',
                    hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchCtrl.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70, size: 20),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.white, size: 20),
                          onPressed: _onSearch,
                        ),
                      ],
                    ),
                  ),
                  onChanged: (v) => setState(() {}),
                  onSubmitted: (_) => _onSearch(),
                ),
              )
            : Text(l.weather),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () => setState(() => _isSearching = !_isSearching),
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () => provider.fetchWeatherWithGPS(),
          ),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, _) {
          // Show error as a Snackbar if it just happened
          if (provider.error != null && provider.weather != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(provider.error!), duration: const Duration(seconds: 2)),
              );
            });
          }

          if (provider.isLoading) return LoadingWidget(message: l.loading);
          if (provider.error != null && provider.weather == null) {
            return ErrorStateWidget(
              message: provider.error!,
              onRetry: () => provider.fetchWeather(''),
            );
          }
          final w = provider.weather;
          if (w == null) return const SizedBox.shrink();
          return _buildWeatherContent(l, w, provider);
        },
      ),
    );
  }

  Widget _buildWeatherContent(AppLocalizations l, WeatherData w, WeatherProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main weather hero
          _buildMainCard(w),
          const SizedBox(height: 16),
          // Saved Locations
          _buildSavedLocations(provider),
          const SizedBox(height: 16),
          // Details grid
          _buildDetailsGrid(l, w),
          const SizedBox(height: 20),
          // 5-day forecast
          SectionHeader(title: l.fiveDayForecast),
          const SizedBox(height: 12),
          ...w.forecast.map((f) => _buildForecastTile(f)),
          const SizedBox(height: 16),
          if (w.agriculturalAlerts.isNotEmpty) ...[
            Row(children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(l.agriculturalAlerts, style: AppTextStyles.titleLarge),
              if (AppConfig.isDemoMode) ...[
                const Spacer(),
                const DemoBadge(),
              ],
            ]),
            const SizedBox(height: 12),
            ...w.agriculturalAlerts.map((a) => _buildAlertCard(a)),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildMainCard(WeatherData w) {
    return AppCard(
      gradient: AppColors.weatherGradient,
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_outlined, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(w.location, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${w.temperature.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(w.condition, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(
                      'Feels like ${w.feelsLike.toStringAsFixed(0)}°C',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(w.conditionIcon, style: const TextStyle(fontSize: 68)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time_rounded, size: 12, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  'Updated: ${DateFormat('hh:mm a').format(w.lastUpdated)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedLocations(WeatherProvider provider) {
    if (provider.savedLocations.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Saved Locations / सुरक्षित स्थान', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: provider.savedLocations.length,
            itemBuilder: (context, i) {
              final loc = provider.savedLocations[i];
              final isCurrent = provider.currentCity == loc;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => provider.fetchWeather(loc),
                  onLongPress: () => provider.removeLocation(loc),
                  child: Chip(
                    label: Text(loc),
                    backgroundColor: isCurrent ? AppColors.primary : Colors.white,
                    side: BorderSide(color: isCurrent ? AppColors.primary : AppColors.border),
                    labelStyle: TextStyle(
                      color: isCurrent ? Colors.white : AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                    onDeleted: isCurrent ? null : () => provider.removeLocation(loc),
                    deleteIconColor: AppColors.error,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsGrid(AppLocalizations l, WeatherData w) {
    final items = [
      ('💧', l.humidity, '${w.humidity.toInt()}%'),
      ('🌬️', l.windSpeed, '${w.windSpeed.toStringAsFixed(0)} km/h'),
      ('🌧️', l.rainProbability, '${w.rainProbability.toInt()}%'),
      ('🌡️', l.temperature, '${w.feelsLike.toStringAsFixed(0)}°C (feels)'),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: items
          .map((item) => AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(item.$1, style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.$3, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          Text(item.$2, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildForecastTile(DayForecast f) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              DateFormat('EEE, MMM d').format(f.date),
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Text(f.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(f.condition, style: AppTextStyles.bodySmall),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${f.maxTemp.toInt()}° / ${f.minTemp.toInt()}°',
                style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '🌧 ${f.rainProbability.toInt()}%',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(AgriculturalAlert alert) {
    final (color, bgColor) = switch (alert.severity) {
      AlertSeverity.critical => (AppColors.error, AppColors.error.withValues(alpha: 0.08)),
      AlertSeverity.warning => (AppColors.warning, AppColors.warning.withValues(alpha: 0.08)),
      _ => (AppColors.accent, AppColors.accentSurface),
    };

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      backgroundColor: bgColor,
      border: Border.all(color: color.withValues(alpha: 0.3)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.agriculture_rounded, color: color, size: 22),
          const SizedBox(width: 12),
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
}
