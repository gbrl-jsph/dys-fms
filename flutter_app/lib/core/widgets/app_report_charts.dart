import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../utils/formatters.dart';
import '../../features/reports/data/models/report_data.dart';

/// Real report chart widgets that render [ReportData] — not demo data.
///
/// All charts read from the API `charts` object and handle:
/// - empty datasets (shows "No data to display")
/// - single data point
/// - multiple points / multiple sectors
/// - correct labels/dates and ₱ currency tooltips
class ReportBarChart extends StatelessWidget {
  const ReportBarChart({
    super.key,
    required this.points,
    required this.title,
    this.height = 180,
    this.barColor,
  });

  final List<ChartPoint> points;
  final String title;
  final double height;
  final Color? barColor;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return _EmptyChart(height: height, message: 'No data to display');
    }

    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sp3,
        AppSpacing.sp3,
        AppSpacing.sp3,
        AppSpacing.sp2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: BarChart(
        BarChartData(
          barGroups: [
            for (int i = 0; i < points.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: points[i].total,
                    color: barColor ?? AppColors.primary,
                    width: points.length == 1 ? 32 : (points.length > 6 ? 10 : 16),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 56,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(
                    Formatters.formatCurrency(value),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 9),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final int idx = value.toInt();
                  if (idx < 0 || idx >= points.length) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      _shortLabel(points[idx].label),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 9),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _interval(points),
            getDrawingHorizontalLine: (value) => FlLine(color: AppColors.border, strokeWidth: 0.5),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.ink,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final ChartPoint p = points[group.x];
                return BarTooltipItem(
                  '${p.label}\n${Formatters.formatCurrency(p.total)}',
                  TextStyle(color: AppColors.surface, fontSize: 11, fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  static String _shortLabel(String label) {
    // "2026-07" -> "Jul 26" or keep as "2026-07" if not month format
    final RegExp monthExp = RegExp(r'^(\d{4})-(\d{2})$');
    final Match? m = monthExp.firstMatch(label);
    if (m != null) {
      final int month = int.tryParse(m.group(2)!) ?? 1;
      const List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      if (month >= 1 && month <= 12) {
        return '${months[month - 1]} ${m.group(1)!.substring(2)}';
      }
    }
    return label.length > 10 ? label.substring(0, 10) : label;
  }

  static double _interval(List<ChartPoint> points) {
    if (points.isEmpty) return 1;
    final double maxY = points.map((p) => p.total).reduce((a, b) => a > b ? a : b);
    if (maxY <= 0) return 1;
    // aim for ~4 grid lines
    return (maxY / 4).ceilToDouble();
  }
}

class ReportPieChart extends StatelessWidget {
  const ReportPieChart({
    super.key,
    required this.points,
    this.height = 180,
  });

  final List<ChartPoint> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return _EmptyChart(height: height, message: 'No data to display');
    }

    final double total = points.fold<double>(0, (sum, p) => sum + p.total);
    if (total <= 0) {
      return _EmptyChart(height: height, message: 'No data to display');
    }

    // Gold palette variations for pie slices — still black+gold theme,
    // but distinguishable slices.
    final List<Color> pieColors = _pieColors(points.length);

    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.sp3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 32,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {},
                ),
                sections: [
                  for (int i = 0; i < points.length; i++)
                    PieChartSectionData(
                      value: points[i].total,
                      title: '${((points[i].total / total) * 100).toStringAsFixed(0)}%',
                      color: pieColors[i % pieColors.length],
                      radius: 56,
                      titleStyle: TextStyle(
                        color: AppColors.inkOnPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                      badgeWidget: null,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sp3),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < points.length; i++)
                    Padding(
                      padding: EdgeInsets.only(bottom: i == points.length - 1 ? 0 : 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(top: 3),
                            decoration: BoxDecoration(
                              color: pieColors[i % pieColors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  points[i].label,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.ink,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  Formatters.formatCurrency(points[i].total),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 10,
                                        color: AppColors.inkSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  static List<Color> _pieColors(int count) {
    // Refined gold + charcoal palette variations.
    const List<Color> base = [
      Color(0xFFD4AF37), // gold
      Color(0xFF1C1B16), // near-black
      Color(0xFF8C7A2B), // dark gold
      Color(0xFFE8D48A), // light gold
      Color(0xFF5C5B50), // warm gray
      Color(0xFFC2A22B), // hover gold
      Color(0xFF3A3A35), // charcoal
      Color(0xFFF8F0D4), // pale gold
    ];
    if (count <= base.length) return base.sublist(0, count);
    // Repeat with slight variation if more slices than base.
    return List<Color>.generate(count, (i) => base[i % base.length]);
  }
}

class ReportSectorChart extends StatelessWidget {
  const ReportSectorChart({
    super.key,
    required this.sectors,
    this.height = 200,
  });

  final List<SectorComparison> sectors;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (sectors.isEmpty) {
      return _EmptyChart(height: height, message: 'No data to display');
    }

    // For single sector, show a simple summary bar instead of comparison.
    if (sectors.length == 1) {
      final SectorComparison s = sectors.first;
      return Container(
        height: height,
        padding: const EdgeInsets.all(AppSpacing.sp3),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          children: [
            Text(s.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sp2),
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: s.totalSales, color: AppColors.primary, width: 22, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: s.totalExpenses, color: AppColors.danger, width: 22, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: s.netBalance < 0 ? 0 : s.netBalance, color: AppColors.success, width: 22, borderRadius: BorderRadius.circular(4))]),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 56, getTitlesWidget: (v, m) => SideTitleWidget(meta: m, child: Text(Formatters.formatCurrency(v), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 9))))),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (v, m) {
                          const labels = ['Sales', 'Expenses', 'Net'];
                          final int idx = v.toInt();
                          if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
                          return SideTitleWidget(meta: m, child: Text(labels[idx], style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 9)));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: AppColors.border, strokeWidth: 0.5)),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.ink,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        const labels = ['Sales', 'Expenses', 'Net'];
                        final double val = [s.totalSales, s.totalExpenses, s.netBalance][group.x];
                        return BarTooltipItem('${labels[group.x]}\n${Formatters.formatCurrency(val)}', TextStyle(color: AppColors.surface, fontSize: 11, fontWeight: FontWeight.w600));
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Multiple sectors: grouped comparison
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(AppSpacing.sp3, AppSpacing.sp3, AppSpacing.sp3, AppSpacing.sp2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: BarChart(
        BarChartData(
          barGroups: [
            for (int i = 0; i < sectors.length; i++)
              BarChartGroupData(
                x: i,
                barsSpace: 4,
                barRods: [
                  BarChartRodData(toY: sectors[i].totalSales, color: AppColors.primary, width: 8, borderRadius: BorderRadius.circular(2)),
                  BarChartRodData(toY: sectors[i].totalExpenses, color: AppColors.danger, width: 8, borderRadius: BorderRadius.circular(2)),
                ],
              ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 56, getTitlesWidget: (v, m) => SideTitleWidget(meta: m, child: Text(Formatters.formatCurrency(v), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 9))))),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (v, m) {
                  final int idx = v.toInt();
                  if (idx < 0 || idx >= sectors.length) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: m,
                    child: Text(
                      sectors[idx].name.length > 8 ? sectors[idx].name.substring(0, 8) : sectors[idx].name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 9),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: AppColors.border, strokeWidth: 0.5)),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.ink,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final SectorComparison s = sectors[group.x];
                final String label = rodIndex == 0 ? 'Sales' : 'Expenses';
                final double val = rodIndex == 0 ? s.totalSales : s.totalExpenses;
                return BarTooltipItem('${s.name}\n$label: ${Formatters.formatCurrency(val)}', TextStyle(color: AppColors.surface, fontSize: 11, fontWeight: FontWeight.w600));
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.height, required this.message});

  final double height;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.sp3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, size: 28, color: AppColors.inkMuted.withValues(alpha: 0.55)),
            const SizedBox(height: AppSpacing.sp2),
            Text(message, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted)),
          ],
        ),
      ),
    );
  }
}
