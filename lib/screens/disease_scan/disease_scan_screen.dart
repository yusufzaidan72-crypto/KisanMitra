import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../models/disease_result.dart';
import '../../services/disease_service_factory.dart';
import '../../services/interfaces/disease_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/app_widgets.dart';
import '../../localization/app_localizations.dart';

class DiseaseScanScreen extends StatefulWidget {
  const DiseaseScanScreen({super.key});

  @override
  State<DiseaseScanScreen> createState() => _DiseaseScanScreenState();
}

class _DiseaseScanScreenState extends State<DiseaseScanScreen> {
  Uint8List? _selectedImageBytes;
  String? _imageName;
  DiseaseResult? _result;
  bool _isAnalyzing = false;
  final _picker = ImagePicker();
  final DiseaseDetectionService _service = DiseaseServiceFactory.getService();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.plantDiseaseScan)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstructionCard(l),
            const SizedBox(height: 16),
            _buildImagePicker(l),
            if (_selectedImageBytes != null) ...[
              const SizedBox(height: 16),
              _buildAnalyzeButton(l),
            ],
            if (_isAnalyzing) ...[
              const SizedBox(height: 24),
              _buildAnalyzingWidget(l),
            ],
            if (_result != null && !_isAnalyzing) ...[
              const SizedBox(height: 24),
              _buildResultSection(l, _result!),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionCard(AppLocalizations l) {
    return AppCard(
      gradient: AppColors.primaryGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔬', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AI Plant Disease Detection',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Text(
                      l.isHindi
                          ? 'पौधे की फ़ोटो लेकर बीमारी पहचानें'
                          : 'Take a photo of the affected plant to identify disease',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipRow('📸', l.isHindi ? 'प्रभावित पत्ती की स्पष्ट फ़ोटो लें' : 'Take a clear photo of affected leaf'),
          const SizedBox(height: 4),
          _buildTipRow('☀️', l.isHindi ? 'अच्छी रोशनी में फ़ोटो लें' : 'Ensure good lighting'),
          const SizedBox(height: 4),
          _buildTipRow('🎯', l.isHindi ? 'रोगग्रस्त हिस्से को फ्रेम में रखें' : 'Focus on the diseased part'),
        ],
      ),
    );
  }

  Widget _buildTipRow(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildImagePicker(AppLocalizations l) {
    return AppCard(
      child: Column(
        children: [
          if (_selectedImageBytes != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                _selectedImageBytes!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: Text(l.isHindi ? 'दूसरी फ़ोटो लें' : 'Choose Different Photo'),
              onPressed: () => setState(() {
                _selectedImageBytes = null;
                _imageName = null;
                _result = null;
              }),
            ),
          ] else ...[
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    style: BorderStyle.solid),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        size: 56, color: AppColors.primary),
                    SizedBox(height: 10),
                    Text('Select or take a plant photo',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: l.takePhoto,
                    icon: Icons.camera_alt_outlined,
                    onPressed: () => _pickImage(ImageSource.camera),
                    backgroundColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: l.fromGallery,
                    icon: Icons.photo_library_outlined,
                    isOutlined: true,
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton(AppLocalizations l) {
    return AppButton(
      label: l.analyzeImage,
      onPressed: _analyzeImage,
      isLoading: _isAnalyzing,
      width: double.infinity,
      icon: Icons.biotech_outlined,
    );
  }

  Widget _buildAnalyzingWidget(AppLocalizations l) {
    return AppCard(
      child: Column(
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            l.isHindi
                ? 'AI पौधे का विश्लेषण कर रहा है...'
                : 'AI is analyzing the plant...',
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l.isHindi ? 'कृपया प्रतीक्षा करें' : 'Please wait a moment',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(AppLocalizations l, DiseaseResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (result.isDemo)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondarySurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.science_outlined, color: AppColors.secondary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.isHindi
                        ? '⚠️ यह DEMO परिणाम है। वास्तविक परिणाम के लिए AI API से जोड़ें।'
                        : '⚠️ This is a DEMO result. Connect a real AI API for actual detection.',
                    style: const TextStyle(color: AppColors.secondaryDark, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🦠', style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(result.diseaseName, style: AppTextStyles.titleLarge),
                        Text(result.diseaseNameHindi, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${result.confidence.toStringAsFixed(0)}%',
                        style: AppTextStyles.headlineMedium.copyWith(color: AppColors.secondary),
                      ),
                      Text(l.confidence, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _chip(result.severityEmoji, '${result.severity} Severity', AppColors.error),
                  const SizedBox(width: 8),
                  _chip('🌿', result.affectedPart, AppColors.primary),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildListCard('🩺', l.symptoms, result.symptoms, AppColors.warning.withValues(alpha: 0.08), AppColors.warning),
        const SizedBox(height: 12),
        _buildListCard('✅', l.recommendedActions, result.recommendedActions, AppColors.success.withValues(alpha: 0.08), AppColors.success),
        const SizedBox(height: 12),
        _buildListCard('🛡️', l.preventionTips, result.preventionTips, AppColors.accentLight, AppColors.accent),
      ],
    );
  }

  Widget _buildListCard(String emoji, String title, List<String> items, Color bgColor, Color accentColor) {
    return AppCard(
      backgroundColor: bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.titleMedium.copyWith(color: accentColor)),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.arrow_right, color: accentColor, size: 18),
                  const SizedBox(width: 4),
                  Expanded(child: Text(item, style: AppTextStyles.bodySmall)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String emoji, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _imageName = picked.name;
          _result = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera/Gallery error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImageBytes == null) return;
    setState(() {
      _isAnalyzing = true;
      _result = null;
    });
    try {
      final result = await _service.analyzeImage(_selectedImageBytes!, fileName: _imageName);
      if (mounted) {
        if (!result.isRecognized) {
          _showNotRecognizedPopup();
          setState(() => _isAnalyzing = false);
          return;
        }
        setState(() => _result = result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.error),
        );
      }
    }
    if (mounted) setState(() => _isAnalyzing = false);
  }

  void _showNotRecognizedPopup() {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.search_off, color: AppColors.warning),
            const SizedBox(width: 10),
            Text(l.notRecognizedTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.notRecognizedBody),
            const SizedBox(height: 12),
            Text('💡 ${l.tipsForBetterResults}'),
            Text('• ${l.tipFocus}'),
            Text('• ${l.tipLight}'),
            Text('• ${l.tipClutter}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.retry.toUpperCase()),
          ),
        ],
      ),
    );
  }
}
