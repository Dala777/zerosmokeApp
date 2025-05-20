import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/daily_plan.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/visual_widgets.dart';

class PlanScreen extends StatefulWidget {
  static const routeName = '/plan';

  @override
  _PlanScreenState createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<DailyPlan> _weeklyPlan = [];
  int _currentDay = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPlan();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPlan() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
    
    // Mock data
    _weeklyPlan = _getMockWeeklyPlan();
    _currentDay = DateTime.now().weekday - 1; // 0-based index (0 = Monday)
    if (_currentDay &lt; 0) _currentDay = 6; // Sunday
    
    setState(() {
      _isLoading = false;
    });
  }
  
  List<DailyPlan> _getMockWeeklyPlan() {
    final List<String> weekdays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    
    return List.generate(7, (index) {
      final dayName = weekdays[index];
      final isToday = index == DateTime.now().weekday - 1;
      
      return DailyPlan(
        day: dayName,
        maxCigarettes: 10 - index, // Decreasing number of cigarettes
        activities: [
          'Ejercicio de respiración profunda',
          'Beber 2 litros de agua',
          'Caminar 30 minutos',
          if (index % 2 == 0) 'Técnica de relajación',
          if (index % 3 == 0) 'Llamar a un amigo para apoyo',
        ],
        tips: [
          'Evita situaciones donde normalmente fumas',
          'Mantén las manos ocupadas con un objeto',
          if (index % 2 == 0) 'Mastica chicle sin azúcar cuando tengas ansiedad',
          if (index % 3 == 0) 'Recuerda por qué quieres dejar de fumar',
        ],
        isCompleted: index &lt; DateTime.now().weekday - 1,
        isToday: isToday,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tu Plan Personalizado'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Diario', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Semanal', icon: Icon(Icons.view_week)),
            Tab(text: 'Progreso', icon: Icon(Icons.trending_up)),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: ShimmerLoadingIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDailyPlanTab(),
                _buildWeeklyPlanTab(),
                _buildProgressTab(),
              ],
            ),
    );
  }

  Widget _buildDailyPlanTab() {
    final currentPlan = _weeklyPlan.isNotEmpty ? _weeklyPlan[_currentDay] : null;
    
    if (currentPlan == null) {
      return Center(
        child: EnhancedInfoMessage(
          message: 'No hay un plan disponible para hoy.',
          icon: Icons.info_outline,
          color: AppTheme.primaryColor,
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDayHeader(currentPlan),
          SizedBox(height: 24),
          _buildCigaretteLimit(currentPlan),
          SizedBox(height: 24),
          _buildActivitiesSection(currentPlan),
          SizedBox(height: 24),
          _buildTipsSection(currentPlan),
          SizedBox(height: 24),
          _buildMotivationSection(),
        ],
      ),
    );
  }

  Widget _buildDayHeader(DailyPlan plan) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.calendar_today,
            color: Colors.white,
            size: 32,
          ),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.day,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            Text(
              plan.isToday ? 'Hoy' : (plan.isCompleted ? 'Completado' : 'Próximamente'),
              style: TextStyle(
                fontSize: 16,
                color: plan.isToday ? AppTheme.accentColor : (plan.isCompleted ? Colors.green : Colors.grey),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCigaretteLimit(DailyPlan plan) {
    return GradientHighlightCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Límite de cigarrillos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedCircularProgressIndicator(
                value: 0.3, // Mock value - would be calculated from actual consumption
                size: 120,
                strokeWidth: 12,
                color: AppTheme.accentColor,
                backgroundColor: Colors.grey[200]!,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '3/${plan.maxCigarettes}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      'hoy',
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
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Ahorrado', '€2.50', Icons.savings),
              _buildStatItem('Tiempo', '2h 30m', Icons.access_time),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.accentColor),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesSection(DailyPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actividades para hoy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(height: 12),
        ...plan.activities.map((activity) => _buildChecklistItem(activity)).toList(),
      ],
    );
  }

  Widget _buildChecklistItem(String text) {
    final checked = false; // This would be dynamic in a real app
    
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: CheckboxListTile(
        title: Text(text),
        value: checked,
        activeColor: AppTheme.accentColor,
        onChanged: (value) {
          // In a real app, this would update the state
        },
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildTipsSection(DailyPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consejos para hoy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(height: 12),
        ...plan.tips.map((tip) => _buildTipItem(tip)).toList(),
      ],
    );
  }

  Widget _buildTipItem(String tip) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb,
            color: AppTheme.accentColor,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(tip),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationSection() {
    return GradientHighlightCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu motivación',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 12),
          Text(
            '"Quiero dejar de fumar para mejorar mi salud y estar presente para mi familia por muchos años más."',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.edit),
                  label: Text('Editar motivación'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    // Show dialog to edit motivation
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPlanTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _weeklyPlan.length,
      itemBuilder: (ctx, index) {
        final plan = _weeklyPlan[index];
        return _buildWeeklyPlanItem(plan, index);
      },
    );
  }

  Widget _buildWeeklyPlanItem(DailyPlan plan, int index) {
    final isActive = index == _currentDay;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
          color: isActive ? AppTheme.accentColor : Colors.transparent,
          width: isActive ? 2 : 0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _currentDay = index;
            });
            _tabController.animateTo(0); // Switch to daily tab
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: plan.isCompleted
                        ? Colors.green
                        : (plan.isToday ? AppTheme.accentColor : Colors.grey[300]),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: plan.isCompleted
                        ? Icon(Icons.check, color: Colors.white, size: 32)
                        : Text(
                            plan.day.substring(0, 3),
                            style: TextStyle(
                              color: plan.isToday ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.day,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Máximo: ${plan.maxCigarettes} cigarrillos',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${plan.activities.length} actividades',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    // Mock data for progress
    final List<Map<String, dynamic>> weeklyData = [
      {'day': 'Lun', 'target': 10, 'actual': 8},
      {'day': 'Mar', 'target': 9, 'actual': 7},
      {'day': 'Mié', 'target': 8, 'actual': 9},
      {'day': 'Jue', 'target': 7, 'actual': 5},
      {'day': 'Vie', 'target': 6, 'actual': 4},
      {'day': 'Sáb', 'target': 5, 'actual': 3},
      {'day': 'Dom', 'target': 4, 'actual': 0},
    ];
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressHeader(),
          SizedBox(height: 24),
          _buildWeeklyChart(weeklyData),
          SizedBox(height: 24),
          _buildProgressStats(),
          SizedBox(height: 24),
          _buildHealthBenefits(),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.trending_up,
            color: Colors.white,
            size: 32,
          ),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu progreso',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            Text(
              'Semana 1 de tu plan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(List<Map<String, dynamic>> data) {
    return GradientHighlightCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consumo semanal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            child: Row(
              children: data.map((item) {
                final double targetHeight = (item['target'] / 10) * 150;
                final double actualHeight = (item['actual'] / 10) * 150;
                final bool isToday = item['day'] == 'Jue'; // Mock today
                
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: actualHeight,
                          width: 16,
                          decoration: BoxDecoration(
                            color: isToday ? AppTheme.accentColor : Colors.blue[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Container(
                          height: 2,
                          width: 30,
                          color: Colors.grey[300],
                          margin: EdgeInsets.symmetric(vertical: 8),
                        ),
                        Text(
                          item['day'],
                          style: TextStyle(
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday ? AppTheme.primaryColor : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.blue[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text('Consumo real'),
                ],
              ),
              SizedBox(width: 24),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text('Hoy'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStats() {
    return Row(
      children: [
        Expanded(
          child: EnhancedStatCard(
            title: 'Reducción',
            value: '40%',
            icon: Icons.trending_down,
            color: Colors.green,
            subtitle: 'desde que empezaste',
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: EnhancedStatCard(
            title: 'Ahorrado',
            value: '€35',
            icon: Icons.savings,
            color: AppTheme.accentColor,
            subtitle: 'en esta semana',
          ),
        ),
      ],
    );
  }

  Widget _buildHealthBenefits() {
    // Mock health benefits data
    final List<Map<String, dynamic>> benefits = [
      {
        'title': '20 minutos',
        'description': 'Tu presión arterial y frecuencia cardíaca han disminuido',
        'achieved': true,
      },
      {
        'title': '12 horas',
        'description': 'El nivel de monóxido de carbono en tu sangre ha vuelto a la normalidad',
        'achieved': true,
      },
      {
        'title': '2 días',
        'description': 'Tu sentido del gusto y olfato han mejorado',
        'achieved': false,
      },
      {
        'title': '2-3 semanas',
        'description': 'Tu circulación y función pulmonar mejorarán',
        'achieved': false,
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Beneficios para tu salud',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(height: 12),
        ...benefits.map((benefit) => HealthBenefitWidget(
          title: benefit['title'],
          description: benefit['description'],
          achieved: benefit['achieved'],
        )).toList(),
      ],
    );
  }
}
