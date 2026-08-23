import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/app_providers.dart';
import 'package:provider/provider.dart';

class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCode = 'hi';
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideIn,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Logo Area
                    _buildLogo(),
                    const SizedBox(height: 24),
                    // Language selector card
                    _buildLanguageCard(),
                    const SizedBox(height: 32),
                    // Continue button
                    _buildContinueButton(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/app_logo.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'किसान मित्र AI',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'KisanMitra AI',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.8),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'AI-Powered Agricultural Assistant',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Language / भाषा चुनें',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose your preferred language',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ...AppConstants.supportedLanguages.map((lang) => _buildLanguageTile(lang)),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(Map<String, String> lang) {
    final isSelected = _selectedCode == lang['code'];
    return GestureDetector(
      onTap: () => setState(() => _selectedCode = lang['code']!),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primarySurface
              : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              lang['name']!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${lang['englishName']})',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: const Text(
          'जारी रखें / Continue',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Future<void> _onContinue() async {
    final langProvider = context.read<LanguageProvider>();
    await langProvider.setLanguage(_selectedCode);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/main');
  }
}
