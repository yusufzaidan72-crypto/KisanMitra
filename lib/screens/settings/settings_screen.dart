import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localizations.dart';
import '../../models/farmer_profile.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/farmer_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/lovable_colors.dart';
import '../../utils/url_helper.dart';
import '../../widgets/lovable_glass.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final farmer = context.watch<FarmerProvider>().profile;

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
            child: Column(
              children: [
                _buildHeader(context, l),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    children: [
                      _buildProfileCard(context, l, farmer),
                      const SizedBox(height: 16),
                      _buildSectionTitle(l.language),
                      _buildLanguageCard(context, l),
                      const SizedBox(height: 16),
                      _buildSectionTitle(l.isHindi ? 'किसान सहायता' : 'Farmer Support'),
                      _buildResourcesCard(l),
                      const SizedBox(height: 16),
                      _buildLogoutCard(context, l),
                      const SizedBox(height: 40),
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

  Widget _buildHeader(BuildContext context, AppLocalizations l) {
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
                Text(
                  l.settings,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: LovableColors.forest,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          color: LovableColors.slateGreen,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, AppLocalizations l, FarmerProfile? farmer) {
    final String name = (farmer != null && farmer.name.isNotEmpty) ? farmer.name : 'Yusuf';
    final String location = (farmer != null && farmer.location.isNotEmpty) ? farmer.location : 'Nashik, Maharashtra';

    return LovableGlassCard(
      strong: true,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LovableColors.ctaGradient,
              shape: BoxShape.circle,
              boxShadow: LovableColors.shadowGlow,
            ),
            child: const Icon(LucideIcons.user, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: LovableColors.forest),
                ),
                Text(
                  '📍 $location',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: LovableColors.slateGreen),
                ),
              ],
            ),
          ),
          GlassOutlineButton(
            label: l.isHindi ? 'एडिट' : 'Edit',
            onTap: () => Navigator.pushNamed(context, '/profile-setup', arguments: {'isEditing': true}),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, AppLocalizations l) {
    return LovableGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: AppConstants.supportedLanguages.map((lang) {
          final isSelected = context.watch<LanguageProvider>().languageCode == lang['code'];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(LucideIcons.languages, color: isSelected ? LovableColors.emeraldAccent : LovableColors.slateGreen),
            title: Text(
              lang['name']!,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: LovableColors.forest,
              ),
            ),
            trailing: isSelected ? const Icon(LucideIcons.check, color: LovableColors.emeraldAccent, size: 18) : null,
            onTap: () => context.read<LanguageProvider>().setLanguage(lang['code']!),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context, AppLocalizations l) {
    return LovableGlassCard(
      padding: const EdgeInsets.all(16),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(LucideIcons.logOut, color: LovableColors.negative),
        title: Text(
          l.isHindi ? 'लॉगआउट' : 'Logout',
          style: GoogleFonts.outfit(color: LovableColors.negative, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        onTap: () => _showLogoutDialog(context, l),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.isHindi ? 'लॉगआउट?' : 'Logout?'),
        content: Text(l.isHindi ? 'क्या आप वाकई लॉगआउट करना चाहते हैं?' : 'Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<app_auth.AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }
            },
            child: const Text('Logout', style: TextStyle(color: LovableColors.negative)),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesCard(AppLocalizations l) {
    final resources = [
      ('Kisan Call Center', '1800-180-1551', () => UrlHelper.launchPhoneDialer('1800-180-1551')),
      ('PM-KISAN Portal', 'pmkisan.gov.in', () => UrlHelper.launchWebBrowser('https://pmkisan.gov.in')),
      ('eNAM Market', 'enam.gov.in', () => UrlHelper.launchWebBrowser('https://enam.gov.in')),
    ];

    return LovableGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: resources
            .map((r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(r.$1, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: LovableColors.forest)),
                  subtitle: Text(r.$2, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: LovableColors.slateGreen)),
                  trailing: const Icon(LucideIcons.externalLink, size: 14, color: LovableColors.forest),
                  onTap: r.$3,
                ))
            .toList(),
      ),
    );
  }
}
