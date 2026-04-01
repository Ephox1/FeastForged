import 'dart:math' as math;
import 'package:flutter/material.dart';

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
    final remaining = netRemaining.clamp(0, target);
    final overTarget = netRemaining < 0;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Calorie ring
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(120, 120),
                        painter: _RingPainter(
                          progress: target > 0
                              ? (consumed / target).clamp(0, 1)
                              : 0,
                          color: scheme.primary,
                          backgroundColor: scheme.primaryContainer.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            consumed.toInt().toString(),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'kcal',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CalorieStat(
                        label: 'Goal',
                        value: target.toInt().toString(),
                        color: scheme.onSurface,
                      ),
                      const SizedBox(height: 8),
                      _CalorieStat(
                        label: 'Eaten',
                        value: consumed.toInt().toString(),
                        color: scheme.primary,
                      ),
                      const SizedBox(height: 8),
                      _CalorieStat(
                        label: overTarget ? 'Over' : 'Remaining',
                        value: overTarget
                            ? netRemaining.abs().toInt().toString()
                            : remaining.toInt().toString(),
                        color: overTarget ? scheme.error : scheme.secondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _MacroBar(
                  label: 'Protein',
                  value: protein,
                  target: proteinTarget,
                  unit: 'g',
                  color: const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 12),
                _MacroBar(
                  label: 'Carbs',
                  value: carbs,
                  target: carbsTarget,
                  unit: 'g',
                  color: const Color(0xFFFF9800),
                ),
                const SizedBox(width: 12),
                _MacroBar(
                  label: 'Fat',
                  value: fat,
                  target: fatTarget,
                  unit: 'g',
                  color: const Color(0xFFF44336),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CalorieStat extends StatelessWidget {
  const _CalorieStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.value,
    required this.target,
    required this.unit,
    required this.color,
  });

  final String label;
  final double value;
  final double target;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            color: color,
            backgroundColor: color.withValues(alpha: 0.2),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toInt()}/${target.toInt()}$unit',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
