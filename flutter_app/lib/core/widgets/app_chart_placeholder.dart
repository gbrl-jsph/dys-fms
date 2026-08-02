import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// Chart container placeholder (ui-style-guide.md: `.chart-placeholder`).
///
/// Dashed border, centered bar-chart icon, and the wireframe copy
/// "Graph placeholder — Bar / line chart · populates once transactions
/// are recorded". Rendered until a real chart data source is approved.
class AppChartPlaceholder extends StatelessWidget {
  const AppChartPlaceholder({
    super.key,
    this.title = 'Graph placeholder',
    this.subtitle =
        'Bar / line chart · populates once transactions are recorded',
    this.height = 140,
  });

  final String title;
  final String subtitle;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.sp3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: CustomPaint(
        foregroundPainter: _DashedBorderPainter(
          color: AppColors.borderStrong,
          radius: AppRadius.lg,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 28,
              color: AppColors.inkMuted.withValues(alpha: 0.55),
            ),
            const SizedBox(height: AppSpacing.sp2),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.sp1),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: AppTypography.caption,
                color: AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints a dashed rounded-rect outline matching the wireframe
/// `.chart-placeholder` border (1px dashed `#D2D3DB`).
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final RRect rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final Path path = Path()
      ..addRRect(rect)
      ..close();

    const double dashLength = 6;
    const double gapLength = 4;

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashLength),
          paint,
        );
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
