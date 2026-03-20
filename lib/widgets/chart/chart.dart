import 'dart:math' as math;
import 'package:expense_app/main.dart';
import 'package:expense_app/models/expense.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

enum ChartMode { overview, income, expenses }

class Chart extends StatefulWidget {
  const Chart({super.key, required this.expenses});
  final List<Expense> expenses;

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  ChartMode _mode = ChartMode.overview;

  double get totalIncome => widget.expenses
      .where((e) => e.isIncome)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalExpenses => widget.expenses
      .where((e) => !e.isIncome)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get netBalance => totalIncome - totalExpenses;

  Map<Category, double> _groupByCategory(List<Expense> entries) {
    final map = {for (final cat in Category.values) cat: 0.0};
    for (final e in entries) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: _mode == ChartMode.overview
            ? _buildOverview()
            : _buildBarChart(),
      ),
    );
  }

  Widget _buildOverview() {
    final hasData = totalIncome > 0 || totalExpenses > 0;
    return Row(
      key: const ValueKey('overview'),
      children: [
        // Donut chart
        SizedBox(
          width: 140,
          height: 140,
          child: hasData
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sections: [
                          if (totalIncome > 0)
                            PieChartSectionData(
                              value: totalIncome,
                              color: kIncomeColor,
                              title: '',
                              radius: 22,
                            ),
                          if (totalExpenses > 0)
                            PieChartSectionData(
                              value: totalExpenses,
                              color: kExpenseColor,
                              title: '',
                              radius: 22,
                            ),
                        ],
                        centerSpaceRadius: 52,
                        sectionsSpace: 3,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'NET',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${netBalance >= 0 ? '+' : ''}\$${netBalance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: netBalance >= 0 ? kIncomeColor : kExpenseColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Center(
                  child: Text(
                    'No data yet',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),
        ),
        const SizedBox(width: 20),
        // Tappable summary tiles — shared font size so both match
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Pick font size based on whichever amount string is longer
              final longerLen = math.max(
                '\$${totalIncome.toStringAsFixed(2)}'.length,
                '\$${totalExpenses.toStringAsFixed(2)}'.length,
              );
              final fontSize = longerLen <= 7
                  ? 18.0
                  : longerLen <= 9
                      ? 16.0
                      : 14.0;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _mode = ChartMode.income),
                    child: _SummaryTile(
                      label: 'Income',
                      amount: totalIncome,
                      color: kIncomeColor,
                      icon: Icons.arrow_upward_rounded,
                      fontSize: fontSize,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => setState(() => _mode = ChartMode.expenses),
                    child: _SummaryTile(
                      label: 'Expenses',
                      amount: totalExpenses,
                      color: kExpenseColor,
                      icon: Icons.arrow_downward_rounded,
                      fontSize: fontSize,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final isIncome = _mode == ChartMode.income;
    final color = isIncome ? kIncomeColor : kExpenseColor;
    final label = isIncome ? 'Income' : 'Expenses';
    final entries = widget.expenses
        .where((e) => isIncome ? e.isIncome : !e.isIncome)
        .toList();
    final grouped = _groupByCategory(entries);
    final maxVal = grouped.values.isEmpty
        ? 1.0
        : grouped.values.reduce(math.max);
    final categories = Category.values;

    return Column(
      key: ValueKey(_mode),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with back button
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _mode = ChartMode.overview),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7F4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back_ios_rounded,
                        size: 11, color: Colors.grey[600]),
                    const SizedBox(width: 3),
                    Text('Overview',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  '$label Breakdown',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Bar chart
        SizedBox(
          height: 110,
          child: entries.isEmpty
              ? Center(
                  child: Text(
                    'No $label entries yet',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                )
              : BarChart(
                  BarChartData(
                    maxY: maxVal == 0 ? 1 : maxVal * 1.25,
                    barGroups: categories.asMap().entries.map((entry) {
                      final cat = entry.value;
                      final val = grouped[cat] ?? 0;
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: val,
                            color: val > 0
                                ? color
                                : color.withValues(alpha: 0.12),
                            width: 28,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (val, meta) {
                            final cat = categories[val.toInt()];
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Icon(
                                CategoryIcons[cat],
                                size: 15,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile(
      {required this.label,
      required this.amount,
      required this.color,
      required this.icon,
      required this.fontSize});
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              size: 16, color: color.withValues(alpha: 0.4)),
        ],
      ),
    );
  }
}
