import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../database/models/monthlydata_chart.dart';

class MonthlyBarChart extends StatelessWidget {
  final List<MonthlyData> monthlyData;
  final bool isLoading;

  const MonthlyBarChart({
    Key? key,
    required this.monthlyData,
    this.isLoading = false,
  }) : super(key: key);

  String formatIndianNumber(double value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(1)}Cr';
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  double _getMaxValue() {
    if (monthlyData.isEmpty) {
      return 1000; // Return a default value when there's no data
    }
    final maxIncome = monthlyData
        .map((data) => data.income)
        .reduce((max, value) => max > value ? max : value);
    final maxExpense = monthlyData
        .map((data) => data.expense)
        .reduce((max, value) => max > value ? max : value);
    final maxValue = (maxIncome > maxExpense ? maxIncome : maxExpense) * 1.2;
    return maxValue > 0 ? maxValue : 1000;
  }

  String _getMonthYear(String date) {
    try {
      List<String> parts = date.split('-');
      String year = parts[0];
      String month = _getMonthName(int.parse(parts[1]));
      String shortYear = year.substring(2);
      return '$month$shortYear';
    } catch (e) {
      return '';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'jan';
      case 2: return 'feb';
      case 3: return 'mar';
      case 4: return 'apr';
      case 5: return 'may';
      case 6: return 'jun';
      case 7: return 'jul';
      case 8: return 'aug';
      case 9: return 'sep';
      case 10: return 'oct';
      case 11: return 'nov';
      case 12: return 'dec';
      default: return '';
    }
  }

  List<BarChartGroupData> _createBarGroups() {
    return List.generate(monthlyData.length, (index) {
      final double income = monthlyData[index].income;
      final double expense = monthlyData[index].expense;

      return BarChartGroupData(
        x: index,
        groupVertically: false,
        barRods: [
          // Income Bar
          BarChartRodData(
            toY: income,
            color: Colors.green.shade400,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            rodStackItems: [
              BarChartRodStackItem(0, income, Colors.green.shade400),
            ],
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxValue(),
              color: Colors.green.withOpacity(0.1),
            ),
          ),
          // Expense Bar
          BarChartRodData(
            toY: expense,
            color: Colors.red.shade400,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            rodStackItems: [
              BarChartRodStackItem(0, expense, Colors.red.shade400),
            ],
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxValue(),
              color: Colors.red.withOpacity(0.1),
            ),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (monthlyData.isEmpty) {
      return Container(
        height: 300, // Set a fixed height or adjust as needed
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No data available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Monthly Overview',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                maxY: _getMaxValue(),
                minY: 0,
                barGroups: _createBarGroups(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxValue() / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < monthlyData.length) {
                          final amount = monthlyData[index].income;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              formatIndianNumber(amount),
                              style: TextStyle(
                                color: Colors.green.shade400,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        String monthYear = monthlyData[value.toInt()].month;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _getMonthYear(monthYear),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          formatIndianNumber(value),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String label = rodIndex == 0 ? 'Income' : 'Expense';
                      return BarTooltipItem(
                        '$label: ${formatIndianNumber(rod.toY)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
              swapAnimationDuration: const Duration(milliseconds: 250),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
