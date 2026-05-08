import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../models/achievement.dart';
import '../theme/app_colors.dart';
import 'achievement_widget.dart';

class RecentAchievementsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AchievementProvider>(
      builder: (ctx, provider, _) {
        final recentAchievements = provider.recentAchievements;
        
        if (recentAchievements.isEmpty) {
          return SizedBox.shrink();
        }
        
        return Card(
          margin: EdgeInsets.all(16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Logros Recientes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/achievements');
                      },
                      child: Text('Ver Todos'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recentAchievements.length,
                    itemBuilder: (ctx, index) {
                      return Container(
                        width: 140,
                        margin: EdgeInsets.only(right: 16),
                        child: AchievementWidget(
                          achievement: recentAchievements[index],
                          showDetails: false,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
