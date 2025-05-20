import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../theme/app_colors.dart';

class AchievementWidget extends StatelessWidget {
  final Achievement achievement;
  final bool showDetails;
  
  AchievementWidget({
    required this.achievement,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: achievement.isUnlocked
              ? AppColors.accent
              : Colors.grey.withOpacity(0.3),
          width: achievement.isUnlocked ? 2 : 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: achievement.isUnlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    AppColors.accent.withOpacity(0.1),
                  ],
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAchievementIcon(),
              SizedBox(height: 12),
              Text(
                achievement.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: achievement.isUnlocked
                      ? AppColors.primary
                      : Colors.grey[700],
                ),
              ),
              if (showDetails) ...[
                SizedBox(height: 8),
                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              SizedBox(height: 8),
              if (!achievement.isUnlocked && achievement.progressTotal > 1)
                _buildProgressIndicator(),
              if (achievement.isUnlocked && achievement.unlockedAt != null)
                _buildUnlockedDate(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementIcon() {
    final iconData = _getIconData(achievement.iconName);
    
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: achievement.isUnlocked
            ? AppColors.accent
            : Colors.grey[300],
        boxShadow: achievement.isUnlocked
            ? [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Icon(
        iconData,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        SizedBox(height: 4),
        LinearProgressIndicator(
          value: achievement.progressPercentage,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
        ),
        SizedBox(height: 4),
        Text(
          '${achievement.progressCurrent} / ${achievement.progressTotal}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUnlockedDate() {
    return Text(
      'Desbloqueado el ${_formatDate(achievement.unlockedAt!)}',
      style: TextStyle(
        fontSize: 10,
        fontStyle: FontStyle.italic,
        color: Colors.grey[600],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'access_time':
        return Icons.access_time;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'event_available':
        return Icons.event_available;
      case 'date_range':
        return Icons.date_range;
      case 'event_note':
        return Icons.event_note;
      case 'smoke_free':
        return Icons.smoke_free;
      case 'savings':
        return Icons.savings;
      case 'air':
        return Icons.air;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'favorite':
        return Icons.favorite;
      case 'lungs':
        return Icons.air; // Using air as a substitute for lungs
      case 'share':
        return Icons.share;
      case 'people':
        return Icons.people;
      default:
        return Icons.emoji_events;
    }
  }
}
