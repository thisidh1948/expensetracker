import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpenseBarChart extends StatelessWidget {
  final List<BarChartGroupData> barGroups = [
    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8)]),
    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10)]),
    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14)]),
    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15)]),
    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 13)]),
    BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 10)]),
    BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 8)]),
    BarChartGroupData(x: 7, barRods: [BarChartRodData(toY: 6)]),
    BarChartGroupData(x: 8, barRods: [BarChartRodData(toY: 5)]),
    BarChartGroupData(x: 9, barRods: [BarChartRodData(toY: 9)]),
    BarChartGroupData(x: 10, barRods: [BarChartRodData(toY: 12)]),
    BarChartGroupData(x: 11, barRods: [BarChartRodData(toY: 14)]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Expense Bar Chart')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AspectRatio(
            aspectRatio: 1.5,
            child: BarChart(
              BarChartData(
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        switch (value.toInt()) {
                          case 0:
                            return Text('Jan');
                          case 1:
                            return Text('Feb');
                          case 2:
                            return Text('Mar');
                          case 3:
                            return Text('Apr');
                          case 4:
                            return Text('May');
                          case 5:
                            return Text('Jun');
                          case 6:
                            return Text('Jul');
                          case 7:
                            return Text('Aug');
                          case 8:
                            return Text('Sep');
                          case 9:
                            return Text('Oct');
                          case 10:
                            return Text('Nov');
                          case 11:
                            return Text('Dec');
                          default:
                            return Text('');
                        }
                      },
                    ),
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