import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class KpiCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double? progress;
  final Widget? trailing;

  const KpiCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color,
    this.backgroundColor,
    this.gradient,
    this.progress,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        color: backgroundColor ?? AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: gradient != null
                      ? Colors.white.withOpacity(0.25)
                      : effectiveColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: gradient != null ? Colors.white : effectiveColor, size: 20),
              ),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: gradient != null ? Colors.white : AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: gradient != null
                  ? Colors.white.withOpacity(0.85)
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress!.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: gradient != null
                    ? Colors.white.withOpacity(0.25)
                    : effectiveColor.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(
                  gradient != null ? Colors.white : effectiveColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
