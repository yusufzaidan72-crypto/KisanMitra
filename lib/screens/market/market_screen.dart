import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/market_price.dart';
import '../../services/market_service_factory.dart';
import '../../utils/utils.dart';
import '../../widgets/common/app_widgets.dart';
import '../../localization/app_localizations.dart';

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
      appBar: AppBar(title: Text(l.marketPricesTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(l),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                children: [
                  AppDropdown<String>(
                    label: l.selectCrop,
                    value: _selectedCrop,
                    items: _popularCrops,
                    itemLabel: (s) => s,
                    prefixIcon: const Icon(Icons.spa_outlined),
                    onChanged: (v) => setState(() => _selectedCrop = v),
                  ),
                  const SizedBox(height: 12),
                  AppDropdown<String>(
                    label: l.selectState,
                    value: _selectedState,
                    items: AppConstants.indianStates,
                    itemLabel: (s) => s,
                    prefixIcon: const Icon(Icons.map_outlined),
                    onChanged: (v) async {
                      setState(() => _selectedState = v);
                      if (v != null) {
                        final markets =
                            await _service.getAvailableMarkets(v);
                        setState(() {
                          _markets = markets;
                          _selectedMarket = null;
                        });
                      }
                    },
                  ),
                  if (_markets.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    AppDropdown<String>(
                      label: l.selectMarket,
                      value: _selectedMarket,
                      items: _markets,
                      itemLabel: (s) => s,
                      prefixIcon: const Icon(Icons.store_outlined),
                      onChanged: (v) => setState(() => _selectedMarket = v),
                    ),
                  ],
                  const SizedBox(height: 16),
                  AppButton(
                    label: l.checkPrices,
                    onPressed: _getPrices,
                    isLoading: _isLoading,
                    width: double.infinity,
                    icon: Icons.trending_up,
                  ),
                ],
              ),
            ),
            if (_prices != null) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(l.marketPricesTitle, style: AppTextStyles.titleLarge),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.success, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'LIVE API',
                          style: TextStyle(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l.isHindi
                    ? '🟢 Agmarknet / eNAM Mandi API से लाइव मंडी भाव।'
                    : '🟢 Live mandi prices from Agmarknet / eNAM API.',
                style: const TextStyle(
                    color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              ..._prices!.map((p) => _buildPriceCard(p, l)),
            ],
            const SizedBox(height: 16),
            _buildMSPCard(l),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.harvestGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Text('📊', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.mandiPricesTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l.mandiPricesSubtitle,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(MarketPrice price, AppLocalizations l) {
    final isUp = price.isPriceUp;
    final changeColor = isUp ? AppColors.success : AppColors.error;
    final changeIcon = isUp ? Icons.trending_up : Icons.trending_down;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(price.cropName, style: AppTextStyles.titleLarge),
                    Text('📍 ${price.marketName}',
                        style: AppTextStyles.bodySmall),
                    Text(price.state, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price.formattedPrice,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(l.perQuintal,
                      style: AppTextStyles.caption),
                  Row(
                    children: [
                      Icon(changeIcon, color: changeColor, size: 14),
                      Text(
                        '${price.priceChangePercent.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                            color: changeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _priceBox(l.minPrice, price.formattedMin, AppColors.error),
              _priceBox(l.currentPrice, price.formattedPrice, AppColors.primary),
              _priceBox(l.maxPrice, price.formattedMax, AppColors.success),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${l.lastUpdated}: ${DateFormat('d MMM, hh:mm a').format(price.lastUpdated)}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _priceBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildMSPCard(AppLocalizations l) {
    return AppCard(
      backgroundColor: AppColors.primarySurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.policy_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(l.mspInfoTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l.mspInfoBody,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => UrlHelper.launchWebBrowser('https://www.enam.gov.in'),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.open_in_new, size: 14, color: AppColors.accent),
                SizedBox(width: 4),
                Text(
                  'eNAM Portal: www.enam.gov.in',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
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
