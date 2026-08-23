import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/crop_monitor.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/farmer_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/common/app_widgets.dart';
import '../../localization/app_localizations.dart';

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
      appBar: AppBar(
        title: Text(l.cropMonitoring),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: l.isHindi ? 'मेरी फसलें' : 'My Crops'),
            Tab(text: l.isHindi ? 'कार्य सूची' : 'Tasks'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCropDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l.addCrop,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCropsList(l),
          _buildTasksList(l),
        ],
      ),
    );
  }

  Widget _buildCropsList(AppLocalizations l) {
    return Consumer<CropMonitorProvider>(
      builder: (context, provider, _) {
        final crops = provider.crops;
        if (crops.isEmpty) {
          return EmptyStateWidget(
            title: l.noCrops,
            subtitle: l.noCropsSubtitle,
            icon: Icons.spa_outlined,
            actionLabel: l.addCrop,
            onAction: _showAddCropDialog,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: crops.length,
          itemBuilder: (context, i) => _buildCropCard(crops[i], l),
        );
      },
    );
  }

  Widget _buildCropCard(CropMonitor crop, AppLocalizations l) {
    final progress = crop.progressPercent;
    final progressColor = progress < 0.5
        ? AppColors.accent
        : progress < 0.8
            ? AppColors.secondary
            : AppColors.success;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌾', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(crop.cropName.split(' / ').first,
                        style: AppTextStyles.titleLarge),
                    Text(
                      crop.growthStage.split(' / ').first,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${crop.cropAgeInDays} ${l.daysOld}',
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.primary),
                  ),
                  Text(
                    '${crop.daysToHarvest} ${l.daysToHarvest}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(l.progress, style: AppTextStyles.bodySmall),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.w600, color: progressColor),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              _dateStat('🌱', l.planted,
                  DateFormat('d MMM').format(crop.plantingDate)),
              const SizedBox(width: 16),
              _dateStat('🌾', l.harvest,
                  DateFormat('d MMM').format(crop.expectedHarvestDate)),
              const Spacer(),
              if (crop.tasks.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${crop.tasks.where((t) => !t.isCompleted).length} ${l.tasksDue}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.secondary),
                  ),
                ),
            ],
          ),
          if (crop.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notes, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(crop.notes,
                        style: AppTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ],
        ],
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
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textSecondary)),
            Text(date, style: AppTextStyles.bodySmall),
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
          return EmptyStateWidget(
            title: l.isHindi ? 'कोई कार्य नहीं' : 'No tasks yet',
            subtitle: l.isHindi
                ? 'फसल जोड़ें और कार्य नियोजित करें'
                : 'Add crops to see upcoming tasks',
            icon: Icons.task_outlined,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: allTasks.length,
          itemBuilder: (context, i) => _buildTaskTile(allTasks[i]),
        );
      },
    );
  }

  Widget _buildTaskTile(CropTask task) {
    final isOverdue = task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;
    final (icon, color) = switch (task.type) {
      TaskType.irrigation => (Icons.water_drop_outlined, AppColors.accent),
      TaskType.fertilizer => (Icons.eco_outlined, AppColors.success),
      TaskType.pesticide => (Icons.bug_report_outlined, AppColors.warning),
      TaskType.harvest => (Icons.agriculture_outlined, AppColors.secondary),
      _ => (Icons.check_circle_outline, AppColors.primary),
    };

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: AppTextStyles.titleSmall),
                Text(
                  DateFormat('d MMM yyyy').format(task.dueDate),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isOverdue ? AppColors.error : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isOverdue)
            const Icon(Icons.warning_amber, color: AppColors.warning, size: 18),
          Checkbox(
            value: task.isCompleted,
            activeColor: AppColors.primary,
            onChanged: (_) {},
          ),
        ],
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (ctx, setModalState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.addCropTitle,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
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
                prefixIcon: const Icon(Icons.landscape_outlined),
                onChanged: (v) => setModalState(() => selectedSoil = v),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: l.addCrop,
                width: double.infinity,
                icon: Icons.add,
                onPressed: () {
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
    );
  }
}
