import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Animated Deep Space Mesh Background with glowing ambient orbs
/// Creates a dynamic, parallax-ready canvas rivaling top-tier SaaS UIs
class AmbientBackground extends StatefulWidget {
  final Widget child;
  final ScrollController? scrollController;

  const AmbientBackground({
    super.key,
    required this.child,
    this.scrollController,
  });

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with TickerProviderStateMixin {
  late AnimationController _orb1Controller;
  late AnimationController _orb2Controller;
  late AnimationController _orb3Controller;

  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();

    _orb1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _orb2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _orb3Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    widget.scrollController?.addListener(_onScroll);
  }

  void _onScroll() {
    if (mounted) {
      setState(() {
        _scrollOffset = widget.scrollController?.offset ?? 0;
      });
    }
  }

  @override
  void dispose() {
    _orb1Controller.dispose();
    _orb2Controller.dispose();
    _orb3Controller.dispose();
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Deep obsidian base layer
        Container(color: const Color(0xFF050810)),

        // Animated ambient orbs (parallax offset from scroll)
        AnimatedBuilder(
          animation: Listenable.merge([_orb1Controller, _orb2Controller, _orb3Controller]),
          builder: (context, _) {
            final o1 = _orb1Controller.value;
            final o2 = _orb2Controller.value;
            final o3 = _orb3Controller.value;
            final parallaxFactor = _scrollOffset * 0.25;

            return Stack(
              children: [
                // Top-left emerald orb
                Positioned(
                  top: -120 + (o1 * 40) - (parallaxFactor * 0.6),
                  left: -80 + (o1 * 30),
                  child: _buildOrb(
                    280 + (o1 * 40),
                    AppColors.primary.withValues(alpha: 0.20 + o1 * 0.06),
                  ),
                ),
                // Bottom-right cyan orb
                Positioned(
                  bottom: -100 + (o2 * 50) + (parallaxFactor * 0.4),
                  right: -60 + (o2 * 25),
                  child: _buildOrb(
                    320 + (o2 * 50),
                    AppColors.secondary.withValues(alpha: 0.18 + o2 * 0.05),
                  ),
                ),
                // Centre-right gold orb (subtle)
                Positioned(
                  top: 300 + (o3 * 60) - (parallaxFactor * 0.3),
                  right: 40 + (o3 * 20),
                  child: _buildOrb(
                    180 + (o3 * 30),
                    AppColors.accent.withValues(alpha: 0.10 + o3 * 0.04),
                  ),
                ),
                // Subtle grid overlay for SaaS texture
                Positioned.fill(
                  child: CustomPaint(painter: _GridPainter()),
                ),
              ],
            );
          },
        ),

        // Content on top
        widget.child,
      ],
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 0.85,
            spreadRadius: size * 0.1,
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 0.5;
    const spacing = 48.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Premium Gradient Button for primary CTAs
class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;
  final double height;
  final List<Color> colors;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.width,
    this.height = 52,
    this.colors = const [Color(0xFF16A34A), Color(0xFF22C55E), Color(0xFF06B6D4)],
    this.isLoading = false,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : (_isHovered ? 1.04 : 1.0),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.colors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(widget.height / 2),
              boxShadow: [
                // 3D tactile inner depth — base shadow
                BoxShadow(
                  color: widget.colors.last.withValues(alpha: _isHovered ? 0.6 : 0.35),
                  blurRadius: _isHovered ? 28 : 18,
                  offset: const Offset(0, 6),
                ),
                // Subtle highlight on top edge (3D tactile illusion)
                const BoxShadow(
                  color: Color(0x33FFFFFF),
                  blurRadius: 1,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating pill-shaped frosted-glass stat chip for data visuals
class NeonDataChip extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;
  final String? emoji;

  const NeonDataChip({
    super.key,
    required this.label,
    required this.value,
    required this.accentColor,
    this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null)
                Text(emoji!, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: accentColor.withValues(alpha: 0.8),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fixed Floating Frosted Glass Top Navigation Bar
class FloatingNavBar extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget? leading;

  const FloatingNavBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.22),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 8)],
                // Brand pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.spa_rounded, color: AppColors.primary, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ...actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating 3D Quick Action Tile for the action grid
class ActionTile3D extends StatefulWidget {
  final String emoji;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;
  final int animationDelay;

  const ActionTile3D({
    super.key,
    required this.emoji,
    required this.label,
    required this.accentColor,
    required this.onTap,
    this.animationDelay = 0,
  });

  @override
  State<ActionTile3D> createState() => _ActionTile3DState();
}

class _ActionTile3DState extends State<ActionTile3D> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.93 : (_isHovered ? 1.06 : 1.0),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                // Floating depth shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: _isHovered ? 0.65 : 0.45),
                  blurRadius: _isHovered ? 30 : 18,
                  offset: Offset(0, _isHovered ? 20 : 10),
                ),
                // Colour glow on hover
                if (_isHovered)
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 0),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? widget.accentColor.withValues(alpha: 0.14)
                        : AppColors.glassSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isHovered
                          ? widget.accentColor.withValues(alpha: 0.65)
                          : widget.accentColor.withValues(alpha: 0.22),
                      width: _isHovered ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: widget.accentColor.withValues(alpha: _isHovered ? 0.25 : 0.14),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: widget.accentColor.withValues(alpha: _isHovered ? 0.7 : 0.3),
                            width: 1,
                          ),
                          boxShadow: _isHovered
                              ? [
                                  BoxShadow(
                                    color: widget.accentColor.withValues(alpha: 0.4),
                                    blurRadius: 14,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(widget.emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: _isHovered ? AppColors.textPrimary : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
