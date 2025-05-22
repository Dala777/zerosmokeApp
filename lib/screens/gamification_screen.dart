import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({Key? key}) : super(key: key);

  @override
  _GamificationScreenState createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _motivationPoints = 350; // Puntos de motivación del usuario
  
  // Lista de logros
  final List<Map<String, dynamic>> _achievements = [
    {
      'id': 'day1',
      'title': 'Primer día sin fumar',
      'description': 'Completaste tu primer día sin fumar. ¡El primer paso hacia una vida más saludable!',
      'icon': Icons.calendar_today,
      'color': Colors.blue,
      'isCompleted': true,
      'date': '15/04/2023',
      'points': 50,
    },
    {
      'id': 'week1',
      'title': 'Una semana sin fumar',
      'description': 'Has completado 7 días consecutivos sin fumar. ¡Tu cuerpo ya está notando los beneficios!',
      'icon': Icons.calendar_view_week,
      'color': Colors.green,
      'isCompleted': true,
      'date': '22/04/2023',
      'points': 100,
    },
    {
      'id': 'activities10',
      'title': '10 actividades completadas',
      'description': 'Has completado 10 actividades de tu plan personalizado.',
      'icon': Icons.check_circle,
      'color': Colors.purple,
      'isCompleted': true,
      'date': '25/04/2023',
      'points': 75,
    },
    {
      'id': 'month1',
      'title': 'Un mes sin fumar',
      'description': 'Has completado 30 días sin fumar. ¡Tu riesgo de enfermedades cardíacas ha disminuido!',
      'icon': Icons.calendar_month,
      'color': Colors.orange,
      'isCompleted': false,
      'progress': 0.7,
      'points': 200,
    },
    {
      'id': 'money50',
      'title': 'Ahorro de bs. 50',
      'description': 'Has ahorrado bs. 50 al no comprar cigarrillos.',
      'icon': Icons.savings,
      'color': Colors.amber,
      'isCompleted': true,
      'date': '28/04/2023',
      'points': 50,
    },
    {
      'id': 'streak10',
      'title': 'Racha de 10 días',
      'description': 'Has completado actividades durante 10 días consecutivos.',
      'icon': Icons.local_fire_department,
      'color': Colors.red,
      'isCompleted': false,
      'progress': 0.8,
      'points': 100,
    },
    {
      'id': 'health25',
      'title': '25% de mejora en salud',
      'description': 'Tu salud ha mejorado un 25% desde que dejaste de fumar.',
      'icon': Icons.favorite,
      'color': Colors.pink,
      'isCompleted': true,
      'date': '01/05/2023',
      'points': 75,
    },
    {
      'id': 'cravings20',
      'title': 'Superaste 20 antojos',
      'description': 'Has utilizado técnicas para superar 20 antojos de fumar.',
      'icon': Icons.psychology,
      'color': Colors.teal,
      'isCompleted': false,
      'progress': 0.5,
      'points': 100,
    },
  ];
  
  // Lista de recompensas
  final List<Map<String, dynamic>> _rewards = [
    {
      'id': 'avatar1',
      'title': 'Avatar Premium',
      'description': 'Desbloquea un avatar exclusivo para tu perfil.',
      'icon': Icons.person,
      'color': Colors.purple,
      'cost': 100,
      'isUnlocked': true,
    },
    {
      'id': 'theme1',
      'title': 'Tema Naturaleza',
      'description': 'Cambia el tema de la app a un hermoso diseño inspirado en la naturaleza.',
      'icon': Icons.palette,
      'color': Colors.green,
      'cost': 150,
      'isUnlocked': true,
    },
    {
      'id': 'game1',
      'title': 'Minijuego: Puzzle',
      'description': 'Desbloquea un juego de puzzle para distraerte durante los antojos.',
      'icon': Icons.extension,
      'color': Colors.blue,
      'cost': 200,
      'isUnlocked': false,
    },
    {
      'id': 'badge1',
      'title': 'Insignia de Oro',
      'description': 'Una insignia especial para mostrar en tu perfil.',
      'icon': Icons.military_tech,
      'color': Colors.amber,
      'cost': 250,
      'isUnlocked': false,
    },
    {
      'id': 'meditation1',
      'title': 'Pack de Meditación',
      'description': 'Desbloquea 5 meditaciones guiadas exclusivas.',
      'icon': Icons.self_improvement,
      'color': Colors.indigo,
      'cost': 300,
      'isUnlocked': false,
    },
  ];
  
  // Datos del avatar
  final Map<String, dynamic> _avatarData = {
    'level': 3,
    'name': 'Carlos',
    'items': [
      {'type': 'hair', 'name': 'Pelo corto', 'isEquipped': true},
      {'type': 'eyes', 'name': 'Ojos azules', 'isEquipped': true},
      {'type': 'outfit', 'name': 'Casual', 'isEquipped': true},
      {'type': 'accessory', 'name': 'Gafas', 'isEquipped': false},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _unlockReward(String rewardId) {
    if (_motivationPoints >= _getRewardCost(rewardId)) {
      setState(() {
        _motivationPoints -= _getRewardCost(rewardId);
        
        // Actualizar estado de la recompensa
        for (int i = 0; i < _rewards.length; i++) {
          if (_rewards[i]['id'] == rewardId) {
            _rewards[i]['isUnlocked'] = true;
            break;
          }
        }
      });
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Recompensa desbloqueada con éxito!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No tienes suficientes puntos de motivación'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
  
  int _getRewardCost(String rewardId) {
    for (var reward in _rewards) {
      if (reward['id'] == rewardId) {
        return reward['cost'];
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Gamificación",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: "Logros"),
            Tab(text: "Recompensas"),
            Tab(text: "Avatar"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña de Logros
          _buildAchievementsTab(),
          
          // Pestaña de Recompensas
          _buildRewardsTab(),
          
          // Pestaña de Avatar
          _buildAvatarTab(),
        ],
      ),
    );
  }
  
  Widget _buildAchievementsTab() {
    // Separar logros completados y pendientes
    final completedAchievements = _achievements.where((a) => a['isCompleted'] == true).toList();
    final pendingAchievements = _achievements.where((a) => a['isCompleted'] != true).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Puntos de motivación
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.accent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.stars,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Puntos de Motivación",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$_motivationPoints MP",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // Mostrar información sobre los puntos
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Puntos de Motivación"),
                        content: const Text(
                          "Los Puntos de Motivación (MP) se ganan completando actividades diarias, logrando objetivos y manteniendo rachas. Puedes canjearlos por recompensas en la pestaña 'Recompensas'.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Entendido"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Logros completados
          const Text(
            "Logros completados",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          
          ...completedAchievements.map((achievement) => _buildAchievementCard(
            achievement: achievement,
            isCompleted: true,
          )).toList(),
          
          const SizedBox(height: 24),
          
          // Logros pendientes
          const Text(
            "Próximos logros",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          
          ...pendingAchievements.map((achievement) => _buildAchievementCard(
            achievement: achievement,
            isCompleted: false,
          )).toList(),
        ],
      ),
    );
  }
  
  Widget _buildRewardsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Puntos de motivación
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.accent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.stars,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tus Puntos",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$_motivationPoints MP",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recompensas disponibles
          const Text(
            "Recompensas disponibles",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._rewards.map((reward) => _buildRewardCard(reward)).toList(),
        ],
      ),
    );
  }
  
  Widget _buildAvatarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar preview
          Center(
            child: Column(
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 100,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "${_avatarData['name']}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Nivel ${_avatarData['level']}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Personalización
          const Text(
            "Personaliza tu avatar",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          
          // Categorías de personalización
          _buildAvatarCategory(
            title: "Cabello",
            items: [
              {"name": "Pelo corto", "isSelected": true},
              {"name": "Pelo largo", "isSelected": false},
              {"name": "Calvo", "isSelected": false},
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildAvatarCategory(
            title: "Ojos",
            items: [
              {"name": "Ojos azules", "isSelected": true},
              {"name": "Ojos marrones", "isSelected": false},
              {"name": "Ojos verdes", "isSelected": false},
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildAvatarCategory(
            title: "Ropa",
            items: [
              {"name": "Casual", "isSelected": true},
              {"name": "Formal", "isSelected": false},
              {"name": "Deportivo", "isSelected": false},
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildAvatarCategory(
            title: "Accesorios",
            items: [
              {"name": "Ninguno", "isSelected": true},
              {"name": "Gafas", "isSelected": false},
              {"name": "Sombrero", "isSelected": false},
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Botón de guardar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Guardar cambios
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Cambios guardados con éxito'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Guardar cambios",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAchievementCard({
    required Map<String, dynamic> achievement,
    required bool isCompleted,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: achievement['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  achievement['icon'],
                  color: achievement['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCompleted
                            ? AppColors.text
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCompleted
                          ? "Completado el ${achievement['date']}"
                          : "En progreso",
                      style: TextStyle(
                        fontSize: 12,
                        color: isCompleted
                            ? Colors.green
                            : AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.stars,
                      color: AppColors.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${achievement['points']}",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            achievement['description'],
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          if (!isCompleted && achievement['progress'] != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: achievement['progress'],
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(achievement['color']),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${(achievement['progress'] * 100).toInt()}% completado",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildRewardCard(Map<String, dynamic> reward) {
    final bool isUnlocked = reward['isUnlocked'] == true;
    final bool canUnlock = _motivationPoints >= reward['cost'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isUnlocked
            ? Border.all(color: Colors.green, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: reward['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  reward['icon'],
                  color: reward['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.stars,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${reward['cost']} MP",
                          style: TextStyle(
                            color: canUnlock
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Desbloqueado",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ElevatedButton(
                  onPressed: canUnlock
                      ? () => _unlockReward(reward['id'])
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canUnlock
                        ? AppColors.primary
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Desbloquear"),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reward['description'],
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAvatarCategory({
    required String title,
    required List<Map<String, dynamic>> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = item['isSelected'] == true;
              
              return GestureDetector(
                onTap: () {
                  // Actualizar selección
                  HapticFeedback.lightImpact();
                  setState(() {
                    for (var i = 0; i < items.length; i++) {
                      items[i]['isSelected'] = i == index;
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.accent.withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item['name'],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
