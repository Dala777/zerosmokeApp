import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HealthBenefitWidget extends StatelessWidget {
  final String title;
  final String description;
  final bool achieved;

  const HealthBenefitWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.achieved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: achieved ? AppColors.success : Colors.grey[300]!,
          width: achieved ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: achieved ? AppColors.success : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                achieved ? Icons.check : Icons.hourglass_empty,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: achieved ? AppColors.success : AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
