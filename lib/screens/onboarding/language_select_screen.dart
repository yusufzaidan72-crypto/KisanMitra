import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/utils.dart';
import '../../providers/app_providers.dart';
import '../../widgets/widgets.dart';
import 'package:provider/provider.dart';

class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  String _selectedCode = 'hi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                const SizedBox(height: 12),
                _buildLogo().animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0),
                const SizedBox(height: 28),
                _buildLanguageCard().animate().fadeIn(duration: 600.ms, delay: 150.ms),
                const SizedBox(height: 32),
                _buildContinueButton(context).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                const SizedBox(height: 24),
              ],
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
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.primaryGlow,
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/app_logo.png',
              width: 96,
              height: 96,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'किसान मित्र AI',
          style: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          'KisanMitra AI',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryLight, letterSpacing: 1.5),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryDark.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: Text(
            'AI-Powered Agricultural Assistant',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageCard() {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      borderColor: AppColors.glassBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Language / भाषा चुनें',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Choose your preferred language',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 20),
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
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryDark.withValues(alpha: 0.3)
              : AppColors.backgroundSecondary.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: AppColors.primaryGlow,
                    blurRadius: 10,
                    spreadRadius: 0,
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              lang['name']!,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${lang['englishName']})',
              style: AppTextStyles.bodySmall,
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
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
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
          shadowColor: AppColors.primaryGlow,
        ),
        child: Text(
          'जारी रखें / Continue',
          style: AppTextStyles.button.copyWith(color: AppColors.textOnPrimary, fontSize: 16),
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
