import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final categoryTotals = provider.categoryTotals;
    final weeklyTotals = provider.weeklyTotals;
    final totalAmount = provider.totalFilteredAmount;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.background,
            floating: true,
            snap: true,
            title: Text(
              'Analytics',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: AppTheme.textPrimary,
              ),
            ),
          ),

          if (categoryTotals.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('📊', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(
                      'No data to analyze yet',
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add some expenses to see charts',
                      style: GoogleFonts.inter(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Weekly Bar Chart ──
                  _SectionTitle('Weekly Spending'),
                  const SizedBox(height: 12),
                  _WeeklyChart(
                    weeklyTotals: weeklyTotals,
                  ).animate().fadeIn(duration: 500.ms),

                  const SizedBox(height: 24),

                  // ── Category Donut Chart ──
                  _SectionTitle('Category Breakdown'),
                  const SizedBox(height: 12),
                  _CategoryDonut(
                    categoryTotals: categoryTotals,
                    totalAmount: totalAmount,
                    touchedIndex: _touchedIndex,
                    onTouch: (index) => setState(() => _touchedIndex = index),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 24),

                  // ── Category Legend ──
                  _SectionTitle('Category Details'),
                  const SizedBox(height: 12),
                  ..._buildCategoryRows(categoryTotals, totalAmount),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryRows(
    Map<ExpenseCategory, double> categoryTotals,
    double totalAmount,
  ) {
    final sorted =
        categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.asMap().entries.map((entry) {
      final index = entry.key;
      final cat = entry.value.key;
      final amount = entry.value.value;
      final percentage = totalAmount > 0 ? (amount / totalAmount * 100) : 0;
      final color = AppTheme.categoryColors[cat.name] ?? AppTheme.textSecondary;

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    cat.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.label,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: totalAmount > 0 ? amount / totalAmount : 0,
                        backgroundColor: AppTheme.border,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      AppTheme.formatCurrency(amount),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: GoogleFonts.inter(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: (200 + index * 60).ms)
            .slideX(begin: 0.05),
      );
    }).toList();
  }
}

// ─── Weekly Bar Chart ─────────────────────────────────────────────────────────

class _WeeklyChart extends StatelessWidget {
  final Map<String, double> weeklyTotals;

  const _WeeklyChart({required this.weeklyTotals});

  @override
  Widget build(BuildContext context) {
    final entries = weeklyTotals.entries.toList();
    final maxValue = entries.map((e) => e.value).fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxValue > 0 ? maxValue * 1.2 : 100,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine:
                (_) => const FlLine(
                  color: AppTheme.border,
                  strokeWidth: 1,
                ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  final dateStr = entries[value.toInt()].key;
                  final date = DateTime.parse(dateStr);
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('E').format(date),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barGroups:
              entries.asMap().entries.map((entry) {
                final i = entry.key;
                final amount = entry.value.value;
                final isToday = i == entries.length - 1;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: amount,
                      gradient:
                          isToday
                              ? AppTheme.primaryGradient
                              : LinearGradient(
                                colors: [
                                  AppTheme.primary.withValues(alpha: 0.4),
                                  AppTheme.primary.withValues(alpha: 0.2),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }).toList(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppTheme.surface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  AppTheme.formatCurrency(rod.toY),
                  GoogleFonts.inter(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Category Donut Chart ─────────────────────────────────────────────────────

class _CategoryDonut extends StatelessWidget {
  final Map<ExpenseCategory, double> categoryTotals;
  final double totalAmount;
  final int touchedIndex;
  final ValueChanged<int> onTouch;

  const _CategoryDonut({
    required this.categoryTotals,
    required this.totalAmount,
    required this.touchedIndex,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    final sorted =
        categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      height: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (response != null && response.touchedSection != null) {
                      onTouch(
                        response.touchedSection!.touchedSectionIndex,
                      );
                    } else {
                      onTouch(-1);
                    }
                  },
                ),
                sections:
                    sorted.asMap().entries.map((entry) {
                      final i = entry.key;
                      final cat = entry.value.key;
                      final amount = entry.value.value;
                      final color =
                          AppTheme.categoryColors[cat.name] ??
                          AppTheme.textSecondary;
                      final isTouched = i == touchedIndex;
                      return PieChartSectionData(
                        color: color,
                        value: amount,
                        title:
                            isTouched
                                ? '${(amount / totalAmount * 100).toStringAsFixed(1)}%'
                                : '',
                        radius: isTouched ? 46 : 38,
                        titleStyle: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Center overlay
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ...sorted.take(5).map((entry) {
                final cat = entry.key;
                final color =
                    AppTheme.categoryColors[cat.name] ?? AppTheme.textSecondary;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat.label.split(' ').first,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }
}
