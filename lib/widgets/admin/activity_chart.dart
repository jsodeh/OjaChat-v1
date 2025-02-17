import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/firebase_service.dart';
import '../../styles/app_theme.dart';

class ActivityChart extends StatelessWidget {
  final String timeRange;
  final FirebaseService _firebaseService = FirebaseService();

  ActivityChart({
    Key? key,
    required this.timeRange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _firebaseService.getPayoutAnalytics(timeRange),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final chartData = (data['chartData'] as List).cast<Map<String, dynamic>>();
        final labels = (data['labels'] as List).cast<String>();

        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 1,
              verticalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.white10,
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Colors.white10,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= labels.length) return Text('');
                    return Text(
                      labels[value.toInt()],
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: _calculateInterval(chartData),
                  reservedSize: 42,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '₦${value.toInt()}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            minX: 0,
            maxX: (chartData.length - 1).toDouble(),
            minY: 0,
            maxY: _calculateMaxY(chartData),
            lineBarsData: [
              LineChartBarData(
                spots: chartData
                    .asMap()
                    .entries
                    .map((e) => FlSpot(
                          e.key.toDouble(),
                          e.value['y'] as double,
                        ))
                    .toList(),
                isCurved: true,
                color: AppTheme.primaryColor,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppTheme.primaryColor.withOpacity(0.1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _calculateMaxY(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 100;
    final maxY = data.map((e) => e['y'] as double).reduce((a, b) => a > b ? a : b);
    return (maxY * 1.2).roundToDouble(); // Add 20% padding
  }

  double _calculateInterval(List<Map<String, dynamic>> data) {
    final maxY = _calculateMaxY(data);
    return (maxY / 5).roundToDouble(); // Show roughly 5 intervals
  }
} 