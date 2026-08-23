import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:typed_data';

import '../../localization/app_localizations.dart';
import '../../models/disease_result.dart';
import '../../services/disease_service_factory.dart';
import '../../services/interfaces/disease_service.dart';
import '../../utils/lovable_colors.dart';
import '../../widgets/lovable_glass.dart';
import '../../widgets/widgets.dart';

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
                  l.plantDiseaseScan,
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

  Widget _buildInstructionCard(AppLocalizations l) {
    return LovableGlassCard(
      strong: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LovableColors.ctaGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(LucideIcons.scanLine, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Plant Disease Detection',
                      style: GoogleFonts.outfit(
                        color: LovableColors.forest,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      l.isHindi
                          ? 'पौधे की फ़ोटो लेकर बीमारी पहचानें'
                          : 'Take a photo of affected plant to identify disease',
                      style: GoogleFonts.plusJakartaSans(
                        color: LovableColors.slateGreen,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildTipRow(LucideIcons.camera, l.isHindi ? 'प्रभावित पत्ती की स्पष्ट फ़ोटो लें' : 'Take a clear photo of affected leaf'),
          const SizedBox(height: 6),
          _buildTipRow(LucideIcons.sun, l.isHindi ? 'अच्छी रोशनी में फ़ोटो लें' : 'Ensure good natural lighting'),
          const SizedBox(height: 6),
          _buildTipRow(LucideIcons.target, l.isHindi ? 'रोगग्रस्त हिस्से को फ्रेम में रखें' : 'Focus closely on the diseased spot'),
        ],
      ),
    );
  }

  Widget _buildTipRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: LovableColors.emeraldAccent),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(color: LovableColors.slateGreen, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildImagePicker(AppLocalizations l) {
    return LovableGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_selectedImageBytes != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                _selectedImageBytes!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(LucideIcons.refreshCw, size: 16, color: LovableColors.forest),
              label: Text(
                l.isHindi ? 'दूसरी फ़ोटो लें' : 'Choose Different Photo',
                style: GoogleFonts.plusJakartaSans(color: LovableColors.forest, fontWeight: FontWeight.w600),
              ),
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
                color: LovableColors.glass,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: LovableColors.glassBorder),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.imagePlus, size: 48, color: LovableColors.emeraldAccent),
                    const SizedBox(height: 10),
                    Text(
                      'Select or take a plant photo',
                      style: GoogleFonts.plusJakartaSans(color: LovableColors.slateGreen, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CtaButton(
                    label: l.takePhoto,
                    icon: LucideIcons.camera,
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassOutlineButton(
                    label: l.fromGallery,
                    trailingIcon: LucideIcons.image,
                    onTap: () => _pickImage(ImageSource.gallery),
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
    return CtaButton(
      label: l.analyzeImage,
      icon: LucideIcons.sparkles,
      width: double.infinity,
      onTap: _analyzeImage,
    );
  }

  Widget _buildAnalyzingWidget(AppLocalizations l) {
    return LovableGlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const CircularProgressIndicator(color: LovableColors.emeraldAccent),
          const SizedBox(height: 16),
          Text(
            l.isHindi ? 'AI पौधे का विश्लेषण कर रहा है...' : 'AI is analyzing the plant...',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: LovableColors.forest),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            l.isHindi ? 'कृपया प्रतीक्षा करें' : 'Please wait a moment',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: LovableColors.slateGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(AppLocalizations l, DiseaseResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LovableGlassCard(
          strong: true,
          padding: const EdgeInsets.all(20),
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
                        Text(
                          result.diseaseName,
                          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: LovableColors.forest),
                        ),
                        Text(
                          result.diseaseNameHindi,
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: LovableColors.slateGreen),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${result.confidence.toStringAsFixed(0)}%',
                        style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: LovableColors.emeraldAccent),
                      ),
                      Text(
                        l.confidence,
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: LovableColors.slateGreen),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  GlassChip(
                    child: Text(
                      '${result.severityEmoji} ${result.severity} Severity',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: LovableColors.negative),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GlassChip(
                    child: Text(
                      '🌿 ${result.affectedPart}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: LovableColors.forest),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildListCard('🩺', l.symptoms, result.symptoms),
        const SizedBox(height: 12),
        _buildListCard('✅', l.recommendedActions, result.recommendedActions),
        const SizedBox(height: 12),
        _buildListCard('🛡️', l.preventionTips, result.preventionTips),
      ],
    );
  }

  Widget _buildListCard(String emoji, String title, List<String> items) {
    return LovableGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: LovableColors.forest),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.check, color: LovableColors.emeraldAccent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: LovableColors.slateGreen),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
        setState(() => _result = result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: LovableColors.negative),
        );
      }
    }
    if (mounted) setState(() => _isAnalyzing = false);
  }
}
