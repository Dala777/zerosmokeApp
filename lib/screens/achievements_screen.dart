import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../models/achievement.dart';
import '../widgets/achievement_widget.dart';
import '../widgets/visual_widgets.dart';

class AchievementsScreen extends StatefulWidget {
  static const routeName = '/achievements';

  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Fetch achievements when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<AuthProvider>(context, listen: false).user?.id ?? 'test-user';
      Provider.of<AchievementProvider>(context, listen: false).fetchAchievements(userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AchievementProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }
          
          if (provider.error != null) {
            return _buildErrorState(provider);
          }
          
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'Logros',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.accent,
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -50,
                            bottom: -50,
                            child: Icon(
                              Icons.emoji_events,
                              size: 200,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${provider.unlockedAchievements.length} de ${provider.achievements.length} logros desbloqueados',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: provider.achievements.isEmpty
                                      ? 0
                                      : provider.unlockedAchievements.length / provider.achievements.length,
                                  backgroundColor: Colors.white.withOpacity(0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    tabs: [
                      Tab(text: 'Desbloqueados'),
                      Tab(text: 'En Progreso'),
                      Tab(text: 'Bloqueados'),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildAchievementsList(provider.unlockedAchievements),
                _buildAchievementsList(provider.inProgressAchievements),
                _buildAchievementsList(provider.lockedAchievements),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(AchievementProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Error al cargar los logros',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(provider.error!),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final userId = Provider.of<AuthProvider>(context, listen: false).user?.id ?? 'test-user';
              provider.fetchAchievements(userId);
            },
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(List<Achievement> achievements) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No hay logros en esta categoría',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Sigue avanzando en tu viaje para desbloquear más logros',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Group achievements by category
    final achievementsByCategory = <String, List<Achievement>>{};
    for (var achievement in achievements) {
      if (!achievementsByCategory.containsKey(achievement.category)) {
        achievementsByCategory[achievement.category] = [];
      }
      achievementsByCategory[achievement.category]!.add(achievement);
    }

    // Sort categories
    final categories = achievementsByCategory.keys.toList();
    categories.sort();

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (ctx, categoryIndex) {
        final category = categories[categoryIndex];
        final categoryAchievements = achievementsByCategory[category]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categoryAchievements.length,
              itemBuilder: (ctx, index) {
                return AchievementWidget(
                  achievement: categoryAchievements[index],
                );
              },
            ),
            SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
