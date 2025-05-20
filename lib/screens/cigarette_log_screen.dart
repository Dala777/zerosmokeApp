import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/cigarette_log_provider.dart';
import '../models/cigarette_log.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:uuid/uuid.dart';

class CigaretteLogScreen extends StatefulWidget {
  static const routeName = '/cigarette-log';

  @override
  _CigaretteLogScreenState createState() => _CigaretteLogScreenState();
}

class _CigaretteLogScreenState extends State<CigaretteLogScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Cigarrillos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Registro'),
            Tab(text: 'Estadísticas'),
            Tab(text: 'Patrones'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLogTab(),
          _buildStatsTab(),
          _buildPatternsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddLogDialog(context);
        },
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildLogTab() {
    return Consumer<CigaretteLogProvider>(
      builder: (ctx, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (provider.logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.smoke_free,
                  size: 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'No hay registros',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Registra tus antojos y cigarrillos para ver patrones',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddLogDialog(context);
                  },
                  icon: Icon(Icons.add),
                  label: Text('Añadir registro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }
        
        // Agrupar logs por día
        final logsByDay = provider.logsByDay;
        final sortedDates = logsByDay.keys.toList()
          ..sort((a, b) => b.compareTo(a)); // Ordenar por fecha descendente
        
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: sortedDates.length,
          itemBuilder: (ctx, index) {
            final date = sortedDates[index];
            final logs = logsByDay[date]!;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _formatDate(date),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ),
                ...logs.map((log) => _buildLogItem(log)).toList(),
                if (index < sortedDates.length - 1)
                  Divider(height: 32),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLogItem(CigaretteLog log) {
    final timeFormat = DateFormat('HH:mm');
    
    return Dismissible(
      key: Key(log.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16),
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<CigaretteLogProvider>(context, listen: false)
            .deleteLog(log.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registro eliminado'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            _showLogDetailsDialog(context, log);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: log.avoided 
                        ? AppColors.success.withOpacity(0.2)
                        : AppColors.error.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    log.avoided ? Icons.check_circle : Icons.smoking_rooms,
                    color: log.avoided ? AppColors.success : AppColors.error,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            log.avoided ? 'Antojo evitado' : 'Cigarrillo fumado',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            timeFormat.format(log.timestamp),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (log.trigger != null)
                        _buildInfoRow(Icons.flash_on, log.trigger!),
                      if (log.location != null)
                        _buildInfoRow(Icons.location_on, log.location!),
                      if (log.mood != null)
                        _buildInfoRow(Icons.mood, log.mood!),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Intensidad: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          ...List.generate(5, (index) {
                            return Icon(
                              Icons.circle,
                              size: 12,
                              color: index < log.intensity
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                            );
                          }),
                        ],
                      ),
                      if (log.notes != null && log.notes!.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(
                          log.notes!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return Consumer<CigaretteLogProvider>(
      builder: (ctx, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (provider.logs.isEmpty) {
          return Center(
            child: Text('No hay datos suficientes para mostrar estadísticas'),
          );
        }
        
        final totalLogs = provider.totalLogs;
        final avoidedCount = provider.avoidedCount;
        final smokedCount = totalLogs - avoidedCount;
        final avoidedPercentage = totalLogs > 0 ? (avoidedCount / totalLogs * 100).toStringAsFixed(1) : '0';
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total registros',
                      value: totalLogs.toString(),
                      icon: Icons.list_alt,
                      color: AppColors.info,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Antojos evitados',
                      value: avoidedCount.toString(),
                      icon: Icons.check_circle,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Cigarrillos fumados',
                      value: smokedCount.toString(),
                      icon: Icons.smoking_rooms,
                      color: AppColors.error,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Tasa de éxito',
                      value: '$avoidedPercentage%',
                      icon: Icons.trending_up,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'Distribución',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 200,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        value: smokedCount.toDouble(),
                        title: 'Fumados',
                        color: AppColors.error,
                        radius: 60,
                        titleStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: avoidedCount.toDouble(),
                        title: 'Evitados',
                        color: AppColors.success,
                        radius: 60,
                        titleStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPatternsTab() {
    return Consumer<CigaretteLogProvider>(
      builder: (ctx, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (provider.logs.isEmpty) {
          return Center(
            child: Text('No hay datos suficientes para mostrar patrones'),
          );
        }
        
        final logsByLocation = provider.logsByLocation;
        final logsByMood = provider.logsByMood;
        final logsByTrigger = provider.logsByTrigger;
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patrones identificados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Analiza tus hábitos para identificar desencadenantes',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 24),
              
              // Por ubicación
              _buildPatternSection(
                title: 'Por ubicación',
                icon: Icons.location_on,
                data: logsByLocation,
                color: Colors.blue,
              ),
              
              SizedBox(height: 24),
              
              // Por estado de ánimo
              _buildPatternSection(
                title: 'Por estado de ánimo',
                icon: Icons.mood,
                data: logsByMood,
                color: Colors.orange,
              ),
              
              SizedBox(height: 24),
              
              // Por desencadenante
              _buildPatternSection(
                title: 'Por desencadenante',
                icon: Icons.flash_on,
                data: logsByTrigger,
                color: Colors.purple,
              ),
              
              SizedBox(height: 32),
              
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: AppColors.info,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Consejo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Identifica tus principales desencadenantes y prepara estrategias específicas para cada uno. Por ejemplo, si sueles fumar después de comer, planifica una actividad alternativa para ese momento.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPatternSection({
    required String title,
    required IconData icon,
    required Map<String, int> data,
    required Color color,
  }) {
    if (data.isEmpty) {
      return Container();
    }
    
    // Ordenar datos por frecuencia (descendente)
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ...sortedEntries.take(5).map((entry) {
          final percentage = (entry.value / data.values.reduce((a, b) => a + b) * 100).toStringAsFixed(1);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      '${entry.value} (${percentage}%)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: entry.value / sortedEntries.first.value,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddLogDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String? _location;
    String? _mood;
    String? _trigger;
    int _intensity = 3;
    String? _notes;
    bool _avoided = false;
    
    // Opciones predefinidas
    final locations = ['Casa', 'Trabajo', 'Bar/Restaurante', 'Calle', 'Coche', 'Otro'];
    final moods = ['Estresado', 'Ansioso', 'Aburrido', 'Triste', 'Feliz', 'Relajado', 'Irritado', 'Otro'];
    final triggers = [
      'Después de comer', 
      'Con café/bebida', 
      'Situación social', 
      'Descanso en el trabajo',
      'Viendo TV/móvil',
      'Al despertar',
      'Antes de dormir',
      'Alcohol',
      'Otro'
    ];
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Registrar cigarrillo/antojo'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tipo de registro
                Text(
                  '¿Qué quieres registrar?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _avoided = false;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: !_avoided ? AppColors.error.withOpacity(0.1) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: !_avoided ? AppColors.error : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.smoking_rooms,
                                color: !_avoided ? AppColors.error : Colors.grey,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Cigarrillo fumado',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: !_avoided ? AppColors.error : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _avoided = true;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _avoided ? AppColors.success.withOpacity(0.1) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _avoided ? AppColors.success : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: _avoided ? AppColors.success : Colors.grey,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Antojo evitado',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _avoided ? AppColors.success : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Ubicación
                Text(
                  'Ubicación',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: locations.map((location) {
                    return ChoiceChip(
                      label: Text(location),
                      selected: _location == location,
                      onSelected: (selected) {
                        setState(() {
                          _location = selected ? location : null;
                        });
                      },
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _location == location ? AppColors.primary : AppColors.textSecondary,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                
                // Estado de ánimo
                Text(
                  'Estado de ánimo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: moods.map((mood) {
                    return ChoiceChip(
                      label: Text(mood),
                      selected: _mood == mood,
                      onSelected: (selected) {
                        setState(() {
                          _mood = selected ? mood : null;
                        });
                      },
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _mood == mood ? AppColors.primary : AppColors.textSecondary,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                
                // Desencadenante
                Text(
                  'Desencadenante',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: triggers.map((trigger) {
                    return ChoiceChip(
                      label: Text(trigger),
                      selected: _trigger == trigger,
                      onSelected: (selected) {
                        setState(() {
                          _trigger = selected ? trigger : null;
                        });
                      },
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _trigger == trigger ? AppColors.primary : AppColors.textSecondary,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                
                // Intensidad
                Text(
                  'Intensidad del antojo (1-5)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 8),
                Slider(
                  value: _intensity.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _intensity.toString(),
                  onChanged: (value) {
                    setState(() {
                      _intensity = value.round();
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                SizedBox(height: 16),
                
                // Notas
                Text(
                  'Notas (opcional)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Añade detalles adicionales...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    _notes = value;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final provider = Provider.of<CigaretteLogProvider>(context, listen: false);
                provider.createLog(
                  userId: 'user123', // En una app real, esto vendría del usuario autenticado
                  location: _location,
                  mood: _mood,
                  trigger: _trigger,
                  intensity: _intensity,
                  notes: _notes,
                  avoided: _avoided,
                );
                Navigator.of(ctx).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Registro añadido correctamente'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showLogDetailsDialog(BuildContext context, CigaretteLog log) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          log.avoided ? 'Antojo evitado' : 'Cigarrillo fumado',
          style: TextStyle(
            color: log.avoided ? AppColors.success : AppColors.error,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Fecha y hora', dateFormat.format(log.timestamp)),
            if (log.location != null)
              _buildDetailRow('Ubicación', log.location!),
            if (log.mood != null)
              _buildDetailRow('Estado de ánimo', log.mood!),
            if (log.trigger != null)
              _buildDetailRow('Desencadenante', log.trigger!),
            _buildDetailRow('Intensidad', '${log.intensity}/5'),
            if (log.notes != null && log.notes!.isNotEmpty)
              _buildDetailRow('Notas', log.notes!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Provider.of<CigaretteLogProvider>(context, listen: false)
                  .deleteLog(log.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Registro eliminado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    if (dateToCheck == DateTime(now.year, now.month, now.day)) {
      return 'Hoy';
    } else if (dateToCheck == yesterday) {
      return 'Ayer';
    } else {
      return DateFormat('EEEE, d MMMM', 'es').format(date);
    }
  }
}
