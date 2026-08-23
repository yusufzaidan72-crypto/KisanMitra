import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../localization/app_localizations.dart';
import '../../models/market_price.dart';
import '../../services/market_service_factory.dart';
import '../../utils/app_constants.dart';
import '../../utils/lovable_colors.dart';
import '../../utils/url_helper.dart';
import '../../widgets/widgets.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String? _selectedCrop;
  String? _selectedState;
  String? _selectedMarket;

  bool _isLoading = false;
  List<MarketPrice>? _prices;
  List<String> _markets = [];

  final _service = MarketServiceFactory.getService();

  static const List<String> _popularCrops = [
    'Wheat / गेहूं',
    'Rice / चावल',
    'Maize / मक्का',
    'Cotton / कपास',
    'Soybean / सोयाबीन',
    'Mustard / सरसों',
    'Potato / आलू',
    'Tomato / टमाटर',
    'Onion / प्याज',
    'Chickpea / चना',
    'Sugarcane / गन्ना',
    'Groundnut / मूंगफली',
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
                _buildHeader(l),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilterCard(l),
                        if (_prices != null) ...[
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Text(
                                l.marketPricesTitle,
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: LovableColors.forest,
                                ),
                              ),
                              const Spacer(),
                              GlassChip(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.checkCircle2, color: LovableColors.emeraldAccent, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      'LIVE API',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: LovableColors.forest,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ..._prices!.map((p) => _buildPriceCard(p, l)),
                        ],
                        const SizedBox(height: 20),
                        _buildMSPCard(l),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l) {
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
                  l.marketPricesTitle,
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

  Widget _buildFilterCard(AppLocalizations l) {
    return LovableGlassCard(
      strong: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          AppDropdown<String>(
            label: l.selectCrop,
            value: _selectedCrop,
            items: _popularCrops,
            itemLabel: (s) => s,
            prefixIcon: const Icon(LucideIcons.sprout, size: 18),
            onChanged: (v) => setState(() => _selectedCrop = v),
          ),
          const SizedBox(height: 14),
          AppDropdown<String>(
            label: l.selectState,
            value: _selectedState,
            items: AppConstants.indianStates,
            itemLabel: (s) => s,
            prefixIcon: const Icon(LucideIcons.map, size: 18),
            onChanged: (v) async {
              setState(() => _selectedState = v);
              if (v != null) {
                final markets = await _service.getAvailableMarkets(v);
                setState(() {
                  _markets = markets;
                  _selectedMarket = null;
                });
              }
            },
          ),
          if (_markets.isNotEmpty) ...[
            const SizedBox(height: 14),
            AppDropdown<String>(
              label: l.selectMarket,
              value: _selectedMarket,
              items: _markets,
              itemLabel: (s) => s,
              prefixIcon: const Icon(LucideIcons.store, size: 18),
              onChanged: (v) => setState(() => _selectedMarket = v),
            ),
          ],
          const SizedBox(height: 20),
          CtaButton(
            label: l.checkPrices,
            icon: LucideIcons.trendingUp,
            width: double.infinity,
            isLoading: _isLoading,
            onTap: _getPrices,
          ),

        ],
      ),
    );
  }

  Widget _buildPriceCard(MarketPrice price, AppLocalizations l) {
    final isUp = price.isPriceUp;
    final changeColor = isUp ? LovableColors.positive : LovableColors.negative;
    final changeIcon = isUp ? LucideIcons.trendingUp : LucideIcons.trendingDown;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LovableGlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        price.cropName,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: LovableColors.forest,
                        ),
                      ),
                      Text(
                        '📍 ${price.marketName}, ${price.state}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: LovableColors.slateGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price.formattedPrice,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: LovableColors.forest,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(changeIcon, color: changeColor, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '${price.priceChangePercent.abs().toStringAsFixed(1)}%',
                          style: GoogleFonts.plusJakartaSans(
                            color: changeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24, color: LovableColors.glassBorder),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _priceBox(l.minPrice, price.formattedMin, LovableColors.negative),
                _priceBox(l.currentPrice, price.formattedPrice, LovableColors.forest),
                _priceBox(l.maxPrice, price.formattedMax, LovableColors.positive),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: LovableColors.slateGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildMSPCard(AppLocalizations l) {
    return LovableGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.fileText, color: LovableColors.emeraldAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                l.mspInfoTitle,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: LovableColors.forest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.mspInfoBody,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: LovableColors.slateGreen),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => UrlHelper.launchWebBrowser('https://www.enam.gov.in'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.externalLink, size: 14, color: LovableColors.forest),
                const SizedBox(width: 4),
                Text(
                  'eNAM Portal: www.enam.gov.in',
                  style: GoogleFonts.plusJakartaSans(
                    color: LovableColors.forest,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getPrices() async {
    if (_selectedCrop == null) {
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.errorSelectCrop)),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final prices = await _service.getPrices(
        cropName: _selectedCrop!,
        state: _selectedState ?? 'Uttar Pradesh',
        market: _selectedMarket,
      );
      setState(() => _prices = prices);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
    setState(() => _isLoading = false);
  }
}
