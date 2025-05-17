import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class DrinkWaterWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const DrinkWaterWidget({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  _DrinkWaterWidgetState createState() => _DrinkWaterWidgetState();
}

class _DrinkWaterWidgetState extends State<DrinkWaterWidget> {
  int _glassesCount = 0;
  final int _targetGlasses = 8;

  void _addGlass() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_glassesCount < _targetGlasses) {
        _glassesCount++;
      }
      
      if (_glassesCount >= 3) {
        widget.onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.water_drop,
                color: Colors.blue.shade600,
                size: 24,
              ),
              const SizedBox(width: 10),
              const Text(
                "Bebe agua",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Beber agua puede ayudar a reducir los antojos de nicotina y mantener tu boca y garganta ocupadas.",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Contador de vasos
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$_glassesCount",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "/ $_targetGlasses",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.blue.shade400,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "vasos",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue.shade400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Indicador visual de vasos
          SizedBox(
            height: 60, // Altura fija para evitar overflow
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _targetGlasses,
              itemBuilder: (context, index) {
                final bool isFilled = index < _glassesCount;
                return Container(
                  width: 30,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isFilled ? Colors.blue.shade400 : Colors.transparent,
                    border: Border.all(
                      color: Colors.blue.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Botón para registrar un vaso
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addGlass,
              icon: const Icon(Icons.add),
              label: const Text("Registrar un vaso"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Consejo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.shade100,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Consejo: Mantén una botella de agua cerca de ti durante todo el día",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
