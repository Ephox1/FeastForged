import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/theme/app_theme.dart';

/// Dashboard calorie + macro ring widget.
///
/// Spec: big ring 110 px / 10 px stroke; macro mini-rings 44 px / 4 px stroke.
/// Colors: brand (#F4A340) for kcal, success (#7EC17A) for protein,
///         info (#8FB4E8) for fat. Track = hairline-2.
/// All numbers → JetBrains Mono + tabular-nums.
class MacroRing extends StatelessWidget {
  const MacroRing({
    super.key,
    required this.consumed,
    required this.target,
    required this.protein,
    required this.proteinTarget,
    required this.carbs,
    required this.carbsTarget,
    required this.fat,
    required this.fatTarget,
  });

  final double consumed;
  final double target;
  final double protein;
  final double proteinTarget;
  final double carbs;
  final double carbsTarget;
  final double fat;
  final double fatTarget;

  @override
  Widget build(BuildContext context) {
    final netRemaining = target - consumed;
    final overTarget = netRemaining < 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(DesignTokens.r3),
        border: Border.all(color: DesignTokens.hairline),
        boxShadow: DesignTokens.shadow1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Big calorie ring ──────────────────────────────────────────
              _AnimatedRing(
                progress: target > 0
                    ? (consumed / target).clamp(0.0, 1.0)
                    : 0.0,
                diameter: DesignTokens.bigRingDiameter,
                strokeWidth: DesignTokens.bigRingStroke,
                color: overTarget ? DesignTokens.danger : DesignTokens.brand,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      consumed.toInt().toString(),
                      style: ForgeTextStyles.statHero(
                        color: overTarget
                            ? DesignTokens.danger
                            : DesignTokens.brand,
                      ),
                    ),
                    Text(
                      'KCAL',
                      style: ForgeTextStyles.eyebrow(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // ── Stats column ─────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatRow(
                      label: 'GOAL',
                      value: target.toInt().toString(),
                      valueColor: DesignTokens.ink2,
                    ),
                    const SizedBox(height: 8),
                    _StatRow(
                      label: 'EATEN',
                      value: consumed.toInt().toString(),
                      valueColor: DesignTokens.brand,
                    ),
                    const SizedBox(height: 8),
                    _StatRow(
                      label: overTarget ? 'OVER' : 'LEFT',
                      value: netRemaining.abs().toInt().toString(),
                      valueColor: overTarget
                          ? DesignTokens.danger
                          : DesignTokens.success,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: DesignTokens.hairline),
          const SizedBox(height: 20),

          // ── Macro mini-rings row ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniRing(
                label: 'PROTEIN',
                value: protein,
                target: proteinTarget,
                color: DesignTokens.success,
              ),
              _MiniRing(
                label: 'CARBS',
                value: carbs,
                target: carbsTarget,
                color: DesignTokens.brand,
              ),
              _MiniRing(
                label: 'FAT',
                value: fat,
                target: fatTarget,
                color: DesignTokens.info,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Animated ring (big) ────────────────────────────────────────────────────────

class _AnimatedRing extends StatefulWidget {
  const _AnimatedRing({
    required this.progress,
    required this.diameter,
    required this.strokeWidth,
    required this.color,
    required this.child,
  });

  final double progress;
  final double diameter;
  final double strokeWidth;
  final Color color;
  final Widget child;

  @override
  State<_AnimatedRing> createState() => _AnimatedRingState();
}

class _AnimatedRingState extends State<_AnimatedRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DesignTokens.ringAnimDuration,
    );
    _anim = CurvedAnimation(
      parent: _controller,
      curve: DesignTokens.ringAnimCurve,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedRing old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _anim = Tween<double>(
        begin: old.progress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: DesignTokens.ringAnimCurve,
        ),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        width: widget.diameter,
        height: widget.diameter,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(widget.diameter, widget.diameter),
              painter: _RingPainter(
                progress: _anim.value * widget.progress,
                color: widget.color,
                strokeWidth: widget.strokeWidth,
                trackColor: DesignTokens.hairline2,
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}

// ── Mini macro ring ────────────────────────────────────────────────────────────

class _MiniRing extends StatelessWidget {
  const _MiniRing({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  final String label;
  final double value;
  final double target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: DesignTokens.macroRingDiameter,
          height: DesignTokens.macroRingDiameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(
                  DesignTokens.macroRingDiameter,
                  DesignTokens.macroRingDiameter,
                ),
                painter: _RingPainter(
                  progress: progress,
                  color: color,
                  strokeWidth: DesignTokens.macroRingStroke,
                  trackColor: DesignTokens.hairline2,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${value.toInt()}g',
          style: ForgeTextStyles.stat(fontSize: 12, color: color),
        ),
        const SizedBox(height: 2),
        Text(label, style: ForgeTextStyles.eyebrow()),
        Text(
          'of ${target.toInt()}g',
          style: ForgeTextStyles.stat(fontSize: 10, color: DesignTokens.ink4),
        ),
      ],
    );
  }
}

// ── Stat row ──────────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label.toUpperCase(), style: ForgeTextStyles.eyebrow()),
        Text(
          value,
          style: ForgeTextStyles.stat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ── Ring painter ──────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final double strokeWidth;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0.001) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}
