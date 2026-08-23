import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/crop_monitor/crop_monitor_screen.dart';
import '../screens/disease_scan/disease_scan_screen.dart';
import '../screens/market/market_screen.dart';
import '../screens/assistant/ai_assistant_screen.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations.dart';
import '../providers/app_providers.dart';
import 'package:provider/provider.dart';

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
    // Initialize weather without requesting permission immediately
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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary.withValues(alpha: 0.7),
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
    );
  }

  Widget _buildScanIcon({required bool active}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: active ? AppColors.primaryGradient : null,
        color: active ? null : AppColors.primarySurface,
        shape: BoxShape.circle,
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ]
            : null,
      ),
      child: Icon(
        Icons.document_scanner_rounded,
        color: active ? Colors.white : AppColors.primary,
        size: 20,
      ),
    );
  }
}
