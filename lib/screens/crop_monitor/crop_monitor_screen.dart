import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localizations.dart';
import '../../models/crop_monitor.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/farmer_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/lovable_colors.dart';
import '../../widgets/widgets.dart';

class CropMonitorScreen extends StatefulWidget {
  const CropMonitorScreen({super.key});

  @override
  State<CropMonitorScreen> createState() => _CropMonitorScreenState();
}

class _CropMonitorScreenState extends State<CropMonitorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCropsList(l),
                      _buildTasksList(l),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCropDialog,
        backgroundColor: LovableColors.emeraldAccent,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: Text(
          l.addCrop,
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: LovableColors.glassStrong,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: LovableColors.glassBorder),
              boxShadow: LovableColors.shadowGlass,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.arrowLeft, color: LovableColors.forest),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      l.cropMonitoring,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: LovableColors.forest,
                      ),
                    ),
                  ],
                ),
                TabBar(
                  controller: _tabController,
                  indicatorColor: LovableColors.emeraldAccent,
                  labelColor: LovableColors.forest,
                  unselectedLabelColor: LovableColors.slateGreen,
                  labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14),
                  unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
                  tabs: [
                    Tab(text: l.isHindi ? 'मेरी फसलें' : 'My Crops'),
                    Tab(text: l.isHindi ? 'कार्य सूची' : 'Tasks'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCropsList(AppLocalizations l) {
    return Consumer<CropMonitorProvider>(
      builder: (context, provider, _) {
        final crops = provider.crops;
        if (crops.isEmpty) {
          return Center(
            child: LovableGlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.sprout, size: 48, color: LovableColors.emeraldAccent),
                  const SizedBox(height: 12),
                  Text(
                    l.noCrops,
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: LovableColors.forest),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.noCropsSubtitle,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: LovableColors.slateGreen),
                  ),
                  const SizedBox(height: 16),
                  CtaButton(
                    label: l.addCrop,
                    icon: LucideIcons.plus,
                    onTap: _showAddCropDialog,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemCount: crops.length,
          itemBuilder: (context, i) => _buildCropCard(crops[i], l),
        );
      },
    );
  }

  Widget _buildCropCard(CropMonitor crop, AppLocalizations l) {
    final progress = crop.progressPercent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LovableGlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🌾', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crop.cropName.split(' / ').first,
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: LovableColors.forest),
                      ),
                      Text(
                        crop.growthStage.split(' / ').first,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: LovableColors.slateGreen),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${crop.cropAgeInDays} ${l.daysOld}',
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: LovableColors.emeraldAccent),
                    ),
                    Text(
                      '${crop.daysToHarvest} days to harvest',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: LovableColors.slateGreen),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(l.progress, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: LovableColors.slateGreen)),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: LovableColors.glassBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(LovableColors.emeraldAccent),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: LovableColors.forest),
                ),
              ],
            ),
            const Divider(height: 20, color: LovableColors.glassBorder),
            Row(
              children: [
                _dateStat('🌱', l.planted, DateFormat('d MMM').format(crop.plantingDate)),
                const SizedBox(width: 16),
                _dateStat('🌾', l.harvest, DateFormat('d MMM').format(crop.expectedHarvestDate)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateStat(String emoji, String label, String date) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: LovableColors.slateGreen)),
            Text(date, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: LovableColors.forest)),
          ],
        ),
      ],
    );
  }

  Widget _buildTasksList(AppLocalizations l) {
    return Consumer<CropMonitorProvider>(
      builder: (context, provider, _) {
        final allTasks = provider.crops.expand((c) => c.tasks).toList();
        allTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

        if (allTasks.isEmpty) {
          return Center(
            child: LovableGlassCard(
              padding: const EdgeInsets.all(24),
              child: Text(
                l.isHindi ? 'कोई कार्य नहीं है' : 'No pending tasks yet',
                style: GoogleFonts.outfit(fontSize: 16, color: LovableColors.forest, fontWeight: FontWeight.w600),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemCount: allTasks.length,
          itemBuilder: (context, i) => _buildTaskTile(allTasks[i]),
        );
      },
    );
  }

  Widget _buildTaskTile(CropTask task) {
    final isOverdue = task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LovableGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(LucideIcons.checkCircle2, color: LovableColors.emeraldAccent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: LovableColors.forest),
                  ),
                  Text(
                    DateFormat('d MMM yyyy').format(task.dueDate),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isOverdue ? LovableColors.negative : LovableColors.slateGreen,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: task.isCompleted,
              activeColor: LovableColors.emeraldAccent,
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCropDialog() {
    final l = AppLocalizations.of(context);
    String? selectedCrop;
    DateTime plantDate = DateTime.now();
    DateTime harvestDate = DateTime.now().add(const Duration(days: 120));
    String? selectedStage;
    String? selectedSoil;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Color(0xEDFFFFFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: StatefulBuilder(
            builder: (ctx, setModalState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.addCropTitle,
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: LovableColors.forest),
                ),
                const SizedBox(height: 16),
                AppDropdown<String>(
                  label: l.selectCropLabel,
                  value: selectedCrop,
                  items: AppConstants.commonCrops,
                  itemLabel: (s) => s,
                  onChanged: (v) => setModalState(() => selectedCrop = v),
                ),
                const SizedBox(height: 12),
                AppDropdown<String>(
                  label: l.growthStageLabel,
                  value: selectedStage,
                  items: AppConstants.growthStages,
                  itemLabel: (s) => s,
                  onChanged: (v) => setModalState(() => selectedStage = v),
                ),
                const SizedBox(height: 12),
                AppDropdown<String>(
                  label: l.soilType,
                  value: selectedSoil,
                  items: AppConstants.soilTypes,
                  itemLabel: (s) => s,
                  prefixIcon: const Icon(LucideIcons.layers, size: 18),
                  onChanged: (v) => setModalState(() => selectedSoil = v),
                ),
                const SizedBox(height: 20),
                CtaButton(
                  label: l.addCrop,
                  width: double.infinity,
                  icon: LucideIcons.plus,
                  onTap: () {
                    if (selectedCrop != null) {
                      final crop = CropMonitor(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        cropName: selectedCrop!,
                        plantingDate: plantDate,
                        expectedHarvestDate: harvestDate,
                        growthStage: selectedStage ?? AppConstants.growthStages.first,
                        soilType: selectedSoil ?? AppConstants.soilTypes.first,
                      );
                      final authUser = context.read<AuthProvider>().user;
                      final farmerProfile = context.read<FarmerProvider>().profile;
                      context.read<CropMonitorProvider>().addCrop(crop, authUser?.uid, farmerProfile);
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
