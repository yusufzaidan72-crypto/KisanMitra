import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/farmer_provider.dart';
import '../../providers/app_providers.dart';
import '../../models/farmer_profile.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/common/app_widgets.dart';
import '../../localization/app_localizations.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../core/utils/url_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final farmer = context.watch<FarmerProvider>().profile;

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card
          _buildProfileCard(context, l, farmer),
          const SizedBox(height: 16),

          // Language
          _buildSectionTitle(l.language),
          _buildLanguageCard(context, l),
          const SizedBox(height: 16),

          // Resources
          _buildSectionTitle(l.isHindi ? 'किसान सहायता' : 'Farmer Support'),
          _buildResourcesCard(l),
          const SizedBox(height: 16),

          // Logout
          _buildLogoutCard(context, l),
          const SizedBox(height: 16),

          // About
          _buildSectionTitle(l.about),
          _buildAboutCard(l),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, AppLocalizations l, FarmerProfile? farmer) {
    final String name = (farmer != null && farmer.name.isNotEmpty) ? farmer.name : (l.isHindi ? 'किसान मित्र' : 'Farmer');
    final String location = (farmer != null && farmer.location.isNotEmpty)
        ? '${farmer.location}${farmer.state.isNotEmpty ? ", ${farmer.state}" : ""}'
        : (l.isHindi ? 'स्थान दर्ज करें' : 'Set location');
    final String farmInfo = (farmer != null && farmer.farmSizeInAcres > 0)
        ? '${farmer.farmSizeInAcres} Acres (${farmer.soilType.split(' / ').first})${farmer.currentCrop.isNotEmpty ? " | 🌾 ${farmer.currentCrop.split(' / ').first}" : ""}'
        : (l.isHindi ? 'प्रोफ़ाइल / खेत विवरण दर्ज करें' : 'Add farm details');

    final List<LandDetail> lands = farmer != null ? farmer.lands : [];

    return AppCard(
      gradient: AppColors.heroGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                    child: Text('👨‍🌾', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '📍 $location',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '🌾 Land 1: $farmInfo',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: Text(
                  l.isHindi ? 'एडिट' : 'Edit',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/profile-setup',
                  arguments: {'isEditing': true},
                ),
              ),
            ],
          ),

          if (lands.isNotEmpty) ...[
            const Divider(color: Colors.white24, height: 16),
            ...lands.map((land) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.terrain_outlined, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${land.name}: ${land.sizeInAcres} Acres (${land.soilType.split(' / ').first})${land.crop.isNotEmpty ? " | 🌾 ${land.crop.split(' / ').first}" : ""}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, AppLocalizations l) {
    return AppCard(
      child: Column(
        children: AppConstants.supportedLanguages.map((lang) {
          final isSelected =
              context.watch<LanguageProvider>().languageCode == lang['code'];

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primarySurface
                    : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  lang['name']!.substring(0, 1),
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            title: Text(lang['name']!,
                style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal)),
            subtitle: Text(lang['englishName']!,
                style: AppTextStyles.bodySmall),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: AppColors.primary)
                : const Icon(Icons.radio_button_unchecked,
                    color: AppColors.border),
            onTap: () => context
                .read<LanguageProvider>()
                .setLanguage(lang['code']!),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context, AppLocalizations l) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.logout, color: AppColors.error),
        ),
        title: Text(
          l.isHindi ? 'लॉगआउट' : 'Logout',
          style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          l.isHindi ? 'एप्लिकेशन से बाहर निकलें' : 'Sign out of the application',
          style: AppTextStyles.bodySmall,
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
        content: Text(
          l.isHindi
              ? 'क्या आप वाकई लॉगआउट करना चाहते हैं?'
              : 'Are you sure you want to sign out?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.isHindi ? 'नहीं' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final farmerProvider = context.read<FarmerProvider>();
              final cropProvider = context.read<CropMonitorProvider>();
              final nav = Navigator.of(context);
              Navigator.pop(ctx);
              await context.read<app_auth.AuthProvider>().signOut();
              await farmerProvider.clearProfile();
              await cropProvider.clearCrops();
              nav.pushNamedAndRemoveUntil('/', (route) => false);
            },
            child: Text(l.isHindi ? 'हाँ, लॉगआउट' : 'Yes, Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesCard(AppLocalizations l) {
    final resources = [
      ('📞', 'Kisan Call Center', '1800-180-1551 (Free)', () => UrlHelper.launchPhoneDialer('1800-180-1551')),
      ('🌐', 'PM-KISAN Portal', 'pmkisan.gov.in', () => UrlHelper.launchWebBrowser('https://pmkisan.gov.in')),
      ('📈', 'eNAM Market', 'enam.gov.in', () => UrlHelper.launchWebBrowser('https://enam.gov.in')),
      ('🔬', 'Soil Testing', 'soiltesting.dac.gov.in', () => UrlHelper.launchWebBrowser('https://soiltesting.dac.gov.in')),
    ];

    return AppCard(
      child: Column(
        children: resources
            .map((r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text(r.$1, style: const TextStyle(fontSize: 22)),
                  title: Text(r.$2, style: AppTextStyles.bodyMedium),
                  subtitle: Text(r.$3,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.accent)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.textSecondary),
                  onTap: r.$4,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildAboutCard(AppLocalizations l) {
    return AppCard(
      child: Column(
        children: [
          const Row(
            children: [
              Text('🌾', style: TextStyle(fontSize: 32)),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('KisanMitra AI',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('v1.0.0',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
          const Divider(height: 20),
          const Text(
            'An AI-powered agricultural assistant designed to help Indian farmers make better farming decisions through technology.',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Built with ❤️ for Indian Farmers',
                    style: TextStyle(color: AppColors.primary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
