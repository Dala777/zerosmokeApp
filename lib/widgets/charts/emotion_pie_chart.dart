import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class EmotionPieChart extends StatelessWidget {
  final List<EmotionChartData> data;

  const EmotionPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text("Sin datos", style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    final total = data.fold<int>(0, (sum, d) => sum + d.count);

    return SizedBox(
      height: 180,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 32,
                sections: data.map((d) {
                  final pct = total > 0 ? d.count / total : 0.0;
                  return PieChartSectionData(
                    value: pct * 100,
                    color: d.color,
                    radius: 40,
                    title: '${(pct * 100).toInt()}%',
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.map((d) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: d.color, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(d.label, style: const TextStyle(fontSize: 12, color: AppColors.text)),
                    const SizedBox(width: 4),
                    Text('${d.count}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class EmotionChartData {
  final String label;
  final int count;
  final Color color;
  const EmotionChartData({required this.label, required this.count, required this.color});
}
