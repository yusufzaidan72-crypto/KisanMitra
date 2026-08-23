import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../providers/app_providers.dart';
import '../../utils/app_constants.dart';
import '../../utils/lovable_colors.dart';
import '../../widgets/lovable_glass.dart';

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

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _buildLogo().animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0),
                      const SizedBox(height: 28),
                      _buildLanguageCard().animate().fadeIn(duration: 600.ms, delay: 150.ms),
                      const SizedBox(height: 28),
                      _buildContinueButton(context).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LovableColors.ctaGradient,
            shape: BoxShape.circle,
            boxShadow: LovableColors.shadowGlow,
          ),
          child: const Center(
            child: Icon(
              LucideIcons.sprout,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'किसान मित्र AI',
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: LovableColors.forest,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'KisanMitra AI',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: LovableColors.slateGreen,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        GlassChip(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.sparkles, size: 14, color: LovableColors.emeraldAccent),
              const SizedBox(width: 6),
              Text(
                'AI-Powered Agricultural Assistant',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: LovableColors.slateGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageCard() {
    return LovableGlassCard(
      strong: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Language / भाषा चुनें',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: LovableColors.forest,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose your preferred language for app interface & AI responses',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: LovableColors.slateGreen,
            ),
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
          color: isSelected ? LovableColors.glassStrong : LovableColors.glass,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? LovableColors.emeraldAccent : LovableColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? LovableColors.shadowGlow : null,
        ),
        child: Row(
          children: [
            Text(
              lang['name']!,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: LovableColors.forest,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${lang['englishName']})',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: LovableColors.slateGreen,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(LucideIcons.checkCircle2, color: LovableColors.emeraldAccent, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return CtaButton(
      label: 'जारी रखें / Continue',
      icon: LucideIcons.arrowRight,
      width: double.infinity,
      onTap: _onContinue,
    );
  }

  Future<void> _onContinue() async {
    final langProvider = context.read<LanguageProvider>();
    await langProvider.setLanguage(_selectedCode);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/main');
  }
}
