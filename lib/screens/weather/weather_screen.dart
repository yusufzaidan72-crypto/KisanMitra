import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localizations.dart';
import '../../models/weather_data.dart';
import '../../providers/app_providers.dart';
import '../../utils/lovable_colors.dart';
import '../../widgets/widgets.dart';

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
      backgroundColor: const Color(0xFFF0FDF4),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background photo
          CachedNetworkImage(
            imageUrl: LovableColors.bgImageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: const Color(0xFFD1FAE5)),
            errorWidget: (_, __, ___) => Container(color: const Color(0xFFD1FAE5)),
          ),

          // Gradient overlay
          Container(
            decoration: const BoxDecoration(gradient: LovableColors.bgOverlay),
          ),

          // Content with custom scroll view & floating header
          SafeArea(
            child: Column(
              children: [
                _buildHeader(l, provider),
                Expanded(
                  child: Consumer<WeatherProvider>(
                    builder: (context, provider, _) {
                      if (provider.error != null && provider.weather != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(provider.error!),
                              backgroundColor: LovableColors.negative,
                              duration: const Duration(seconds: 2),
                            ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l, WeatherProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: LovableColors.glassStrong,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: LovableColors.glassBorder),
              boxShadow: LovableColors.shadowGlass,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: LovableColors.forest),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: _isSearching
                      ? TextField(
                          controller: _searchCtrl,
                          autofocus: true,
                          style: GoogleFonts.outfit(color: LovableColors.forest, fontSize: 16, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: l.isHindi ? 'शहर का नाम लिखें...' : 'Enter city name...',
                            hintStyle: GoogleFonts.plusJakartaSans(color: LovableColors.slateGreen, fontSize: 14),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                          ),
                          onSubmitted: (_) => _onSearch(),
                        )
                      : Text(
                          l.weather,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: LovableColors.forest,
                          ),
                        ),
                ),
                IconButton(
                  icon: Icon(_isSearching ? LucideIcons.x : LucideIcons.search, color: LovableColors.forest),
                  onPressed: () => setState(() => _isSearching = !_isSearching),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.navigation, color: LovableColors.emeraldAccent),
                  onPressed: () => provider.fetchWeatherWithGPS(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherContent(AppLocalizations l, WeatherData w, WeatherProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainCard(w),
          const SizedBox(height: 16),
          _buildSavedLocations(provider),
          const SizedBox(height: 16),
          _buildDetailsGrid(l, w),
          const SizedBox(height: 24),
          Text(
            l.fiveDayForecast,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: LovableColors.forest,
            ),
          ),
          const SizedBox(height: 12),
          ...w.forecast.map((f) => _buildForecastTile(f)),
          const SizedBox(height: 16),
          if (w.agriculturalAlerts.isNotEmpty) ...[
            Row(
              children: [
                const Icon(LucideIcons.alertTriangle, color: LovableColors.negative, size: 20),
                const SizedBox(width: 8),
                Text(
                  l.agriculturalAlerts,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: LovableColors.forest,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...w.agriculturalAlerts.map((a) => _buildAlertCard(a)),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMainCard(WeatherData w) {
    return LovableGlassCard(
      strong: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassChip(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.mapPin, color: LovableColors.emeraldAccent, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            w.location.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              color: LovableColors.forest,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${w.temperature.toStringAsFixed(1)}°C',
                      style: GoogleFonts.outfit(
                        color: LovableColors.forest,
                        fontSize: 54,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      w.condition,
                      style: GoogleFonts.outfit(
                        color: LovableColors.forest,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Feels like ${w.feelsLike.toStringAsFixed(0)}°C',
                      style: GoogleFonts.plusJakartaSans(
                        color: LovableColors.slateGreen,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(w.conditionIcon, style: const TextStyle(fontSize: 64)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(LucideIcons.clock, size: 14, color: LovableColors.slateGreen),
              const SizedBox(width: 6),
              Text(
                'Updated: ${DateFormat('hh:mm a').format(w.lastUpdated)}',
                style: GoogleFonts.plusJakartaSans(
                  color: LovableColors.slateGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
        Text(
          'Saved Locations',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: LovableColors.forest),
        ),
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
                  child: GlassChip(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Text(
                      loc,
                      style: GoogleFonts.plusJakartaSans(
                        color: isCurrent ? LovableColors.forest : LovableColors.slateGreen,
                        fontSize: 12,
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
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
      (LucideIcons.droplets, l.humidity, '${w.humidity.toInt()}%'),
      (LucideIcons.wind, l.windSpeed, '${w.windSpeed.toStringAsFixed(0)} km/h'),
      (LucideIcons.cloudRain, l.rainProbability, '${w.rainProbability.toInt()}%'),
      (LucideIcons.thermometer, l.temperature, '${w.feelsLike.toStringAsFixed(0)}°C'),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: items.map((item) {
        return LovableGlassCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LovableColors.ctaGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.$1, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.$3,
                      style: GoogleFonts.outfit(
                        color: LovableColors.forest,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.$2,
                      style: GoogleFonts.plusJakartaSans(
                        color: LovableColors.slateGreen,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildForecastTile(DayForecast f) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LovableGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(
                DateFormat('EEE, MMM d').format(f.date),
                style: GoogleFonts.outfit(
                  color: LovableColors.forest,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            Text(f.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                f.condition,
                style: GoogleFonts.plusJakartaSans(
                  color: LovableColors.slateGreen,
                  fontSize: 13,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${f.maxTemp.toInt()}° / ${f.minTemp.toInt()}°',
                  style: GoogleFonts.outfit(
                    color: LovableColors.forest,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '🌧 ${f.rainProbability.toInt()}%',
                  style: GoogleFonts.plusJakartaSans(
                    color: LovableColors.emeraldAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(AgriculturalAlert alert) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LovableGlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(LucideIcons.alertTriangle, color: LovableColors.negative, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: GoogleFonts.outfit(
                      color: LovableColors.forest,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: GoogleFonts.plusJakartaSans(
                      color: LovableColors.slateGreen,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
