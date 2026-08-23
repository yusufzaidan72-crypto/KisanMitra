import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/home/home_screen.dart';
import '../screens/crop_monitor/crop_monitor_screen.dart';
import '../screens/disease_scan/disease_scan_screen.dart';
import '../screens/market/market_screen.dart';
import '../screens/assistant/ai_assistant_screen.dart';
import '../utils/utils.dart';
import '../localization/app_localizations.dart';
import '../providers/app_providers.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().init();
    });
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    CropMonitorScreen(),
    DiseaseScanScreen(),
    MarketScreen(),
    AIAssistantScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary.withValues(alpha: 0.85),
          border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textMuted,
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home_rounded),
                  label: l.home,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.spa_outlined),
                  activeIcon: const Icon(Icons.spa_rounded),
                  label: l.crops,
                ),
                BottomNavigationBarItem(
                  icon: _buildScanIcon(active: _currentIndex == 2),
                  activeIcon: _buildScanIcon(active: true),
                  label: l.scan,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.storefront_outlined),
                  activeIcon: const Icon(Icons.storefront_rounded),
                  label: l.market,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.smart_toy_outlined),
                  activeIcon: const Icon(Icons.smart_toy_rounded),
                  label: l.assistant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanIcon({required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: active ? AppColors.primaryGradient : null,
        color: active ? null : AppColors.cardBg,
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? AppColors.primaryLight : AppColors.border,
          width: 1,
        ),
        boxShadow: active
            ? [
                const BoxShadow(
                  color: AppColors.primaryGlow,
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Icon(
        Icons.document_scanner_rounded,
        color: active ? AppColors.textOnPrimary : AppColors.primary,
        size: 20,
      ),
    );
  }
}
