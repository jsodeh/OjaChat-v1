import 'package:flutter/material.dart';
import '../../styles/app_theme.dart';

class OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final double trend;
  final IconData icon;

  const OverviewCard({
    Key? key,
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white70),
              if (trend != 0)
                Row(
                  children: [
                    Icon(
                      trend > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      color: trend > 0 ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    Text(
                      '${trend.abs()}%',
                      style: TextStyle(
                        color: trend > 0 ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
} 