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

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _scanGlowController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _scanGlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().init();
    });
  }

  @override
  void dispose() {
    _scanGlowController.dispose();
    super.dispose();
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
      backgroundColor: const Color(0xFFF0FDF4),
      body: IndexedStack(

        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildFloatingBottomNav(l),
    );
  }

  Widget _buildFloatingBottomNav(AppLocalizations l) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(
        20, 8, 20, MediaQuery.of(context).padding.bottom + 12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 64,
            decoration: BoxDecoration(
              // Eco light theme: white/62% matching --glass-strong
              color: const Color(0x9EFFFFFF),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: const Color(0xBFFFFFFF),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF065F46).withValues(alpha: 0.35),
                  blurRadius: 50,
                  spreadRadius: -20,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.home_outlined, Icons.home_rounded, l.home, 0),
                _navItem(Icons.eco_outlined, Icons.eco_rounded, l.crops, 1),
                _buildScanButton(l),
                _navItem(Icons.storefront_outlined, Icons.storefront_rounded, l.market, 3),
                _navItem(Icons.smart_toy_outlined, Icons.smart_toy_rounded, l.assistant, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData inactive, IconData active, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF10B981).withValues(alpha: 0.18) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isActive ? active : inactive,
                color: isActive ? const Color(0xFF10B981) : const Color(0xFF2D6A50),
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isActive ? const Color(0xFF064E3B) : const Color(0xFF2D6A50),
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton(AppLocalizations l) {
    final isActive = _currentIndex == 2;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: AnimatedBuilder(
        animation: _scanGlowController,
        builder: (context, _) {
          final glowIntensity = _scanGlowController.value;
          return Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: isActive
                  ? AppColors.primaryGradient
                  : LinearGradient(
                      colors: [
                        AppColors.primaryDark.withValues(alpha: 0.6),
                        AppColors.secondaryDark.withValues(alpha: 0.4),
                      ],
                    ),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? AppColors.primaryLight.withValues(alpha: 0.8)
                    : AppColors.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: isActive ? 0.55 + glowIntensity * 0.25 : 0.2 + glowIntensity * 0.15,
                  ),
                  blurRadius: isActive ? 22 + glowIntensity * 10 : 14 + glowIntensity * 6,
                  spreadRadius: isActive ? 2 : 0,
                ),
              ],
            ),
            child: Icon(
              Icons.document_scanner_rounded,
              color: isActive ? AppColors.textOnPrimary : AppColors.primary,
              size: 24,
            ),
          );
        },
      ),
    );
  }
}
