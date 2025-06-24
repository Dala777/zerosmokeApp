import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../models/initial_test.dart';
import '../providers/progress_provider.dart';
import 'dashboard_screen.dart';

class InitialTestScreen extends StatefulWidget {
  const InitialTestScreen({Key? key}) : super(key: key);

  @override
  _InitialTestScreenState createState() => _InitialTestScreenState();
}

class _InitialTestScreenState extends State<InitialTestScreen> {
  // Estado para seguir la página actual
  int _currentPage = 0;
  final PageController _pageController = PageController();
  
  // Variables para las respuestas del test
  int _cigarettesPerDay = 10;
  bool _smokesWithinMinutes = false;
  bool _difficultToAvoidPublicPlaces = false;
  bool _hatesMostToGiveUpMorningCigarette = false;
  bool _smokesMoreInMorning = false;
  bool _smokesWhenIll = false;
  double _packagePrice = 5.0;
  List<String> _selectedMotivations = [];
  int _stressLevel = 5;
  int _anxietyLevel = 5;
  Map<String, bool> _healthConditions = {
    'Problemas respiratorios': false,
    'Problemas cardíacos': false,
    'Hipertensión': false,
    'Diabetes': false,
    'Ninguno': true,
  };
  
  final List<String> _availableMotivations = [
    'Salud',
    'Familia',
    'Dinero',
    'Aspecto físico',
    'Rendimiento deportivo',
    'Olores',
    'Libertad',
    'Autocontrol',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitTest();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitTest() async {
    // Crear el objeto de test inicial
    final test = InitialTest(
      cigarettesPerDay: _cigarettesPerDay,
      smokesWithinMinutes: _smokesWithinMinutes,
      difficultToAvoidPublicPlaces: _difficultToAvoidPublicPlaces,
      hatesMostToGiveUpMorningCigarette: _hatesMostToGiveUpMorningCigarette,
      smokesMoreInMorning: _smokesMoreInMorning,
      smokesWhenIll: _smokesWhenIll,
      packagePrice: _packagePrice,
      motivations: _selectedMotivations,
      stressLevel: _stressLevel,
      anxietyLevel: _anxietyLevel,
      healthConditions: _healthConditions,
    );
    
    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
    
    // Guardar el test y asignar plan
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    final success = await progressProvider.saveInitialTest(test);
    
    // Cerrar diálogo de carga
    if (mounted) Navigator.of(context).pop();
    
    if (success) {
      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Test completado! Tu plan personalizado ha sido creado.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        
        // Navegar al dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } else {
      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(progressProvider.errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Test Inicial",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Indicador de progreso
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / 5,
                backgroundColor: AppColors.accent.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                borderRadius: BorderRadius.circular(10),
                minHeight: 8,
              ),
            ),
            
            // Contenido paginado
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildPage1(),
                  _buildPage2(),
                  _buildPage3(),
                  _buildPage4(),
                  _buildPage5(),
                ],
              ),
            ),
            
            // Botones de navegación
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    ElevatedButton(
                      onPressed: _previousPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent.withOpacity(0.2),
                        foregroundColor: AppColors.text,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Anterior"),
                    )
                  else
                    const SizedBox(width: 85),
                  
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(_currentPage == 4 ? "Terminar" : "Siguiente"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Página 1: Consumo de cigarrillos y precios
  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hábitos de Consumo",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Primero, necesitamos conocer tus hábitos actuales de consumo de tabaco.",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 30),
          
          // Cigarrillos por día
          const Text(
            "¿Cuántos cigarrillos fumas al día?",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$_cigarettesPerDay cigarrillos",
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.text,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_cigarettesPerDay > 1) {
                              setState(() {
                                _cigarettesPerDay--;
                              });
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _cigarettesPerDay++;
                            });
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Slider(
                  min: 1,
                  max: 40,
                  divisions: 39,
                  value: _cigarettesPerDay.toDouble(),
                  onChanged: (value) {
                    setState(() {
                      _cigarettesPerDay = value.round();
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Precio del paquete
          const Text(
            "¿Cuánto cuesta un paquete de cigarrillos?",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${_packagePrice.toStringAsFixed(2)} BS",
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.text,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_packagePrice > 1) {
                              setState(() {
                                _packagePrice = (_packagePrice - 0.5).clamp(1, 20);
                              });
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _packagePrice = (_packagePrice + 0.5).clamp(1, 20);
                            });
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Slider(
                  min: 1,
                  max: 20,
                  divisions: 38,
                  value: _packagePrice,
                  onChanged: (value) {
                    setState(() {
                      _packagePrice = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Página 2: Test de Fagerström
  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dependencia a la Nicotina",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Estas preguntas nos ayudarán a evaluar tu nivel de dependencia a la nicotina.",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 30),
          
          _buildYesNoQuestion(
            "¿Fumas tu primer cigarrillo dentro de los primeros 30 minutos después de despertar?",
            _smokesWithinMinutes,
            (value) {
              setState(() {
                _smokesWithinMinutes = value;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          _buildYesNoQuestion(
            "¿Te resulta difícil no fumar en lugares donde está prohibido (hospitales, cines, bibliotecas, etc.)?",
            _difficultToAvoidPublicPlaces,
            (value) {
              setState(() {
                _difficultToAvoidPublicPlaces = value;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          _buildYesNoQuestion(
            "¿El cigarrillo que más te costaría abandonar es el primero de la mañana?",
            _hatesMostToGiveUpMorningCigarette,
            (value) {
              setState(() {
                _hatesMostToGiveUpMorningCigarette = value;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          _buildYesNoQuestion(
            "¿Fumas más durante las primeras horas del día que durante el resto?",
            _smokesMoreInMorning,
            (value) {
              setState(() {
                _smokesMoreInMorning = value;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          _buildYesNoQuestion(
            "¿Fumas aunque estés tan enfermo que tengas que guardar cama la mayor parte del día?",
            _smokesWhenIll,
            (value) {
              setState(() {
                _smokesWhenIll = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // Página 3: Motivaciones
  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tus Motivaciones",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "¿Cuáles son tus principales motivaciones para dejar de fumar?",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Selecciona todas las que apliquen:",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          
          // Motivaciones
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _availableMotivations.map((motivation) {
              final isSelected = _selectedMotivations.contains(motivation);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedMotivations.remove(motivation);
                    } else {
                      _selectedMotivations.add(motivation);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.accent.withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    motivation,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.text,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 30),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "¿Hay alguna otra motivación personal que quieras agregar?",
                hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                if (value.isNotEmpty && !_selectedMotivations.contains(value)) {
                  // Opcional: agregar motivación personalizada
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Página 4: Estado emocional
  Widget _buildPage4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Estado Emocional",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Evalúa tu estado emocional actual. Esto nos ayudará a personalizar tu plan.",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 30),
          
          // Nivel de estrés
          const Text(
            "Nivel de estrés",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "¿Cuál es tu nivel de estrés general en este momento?",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Bajo",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      "$_stressLevel",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const Text(
                      "Alto",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Slider(
                  min: 1,
                  max: 10,
                  divisions: 9,
                  value: _stressLevel.toDouble(),
                  onChanged: (value) {
                    setState(() {
                      _stressLevel = value.round();
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Nivel de ansiedad
          const Text(
            "Nivel de ansiedad",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "¿Cuánta ansiedad sientes cuando piensas en dejar de fumar?",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Baja",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      "$_anxietyLevel",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const Text(
                      "Alta",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Slider(
                  min: 1,
                  max: 10,
                  divisions: 9,
                  value: _anxietyLevel.toDouble(),
                  onChanged: (value) {
                    setState(() {
                      _anxietyLevel = value.round();
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Página 5: Condiciones de salud
  Widget _buildPage5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Salud General",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "¿Tienes alguna de las siguientes condiciones de salud?",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Esta información es opcional pero nos ayudará a personalizar mejor tu experiencia.",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 30),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: _healthConditions.keys.map((condition) {
                return CheckboxListTile(
                  title: Text(
                    condition,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.text,
                    ),
                  ),
                  value: _healthConditions[condition],
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) {
                    setState(() {
                      if (condition == 'Ninguno') {
                        // Si selecciona "Ninguno", desmarcar los demás
                        if (value == true) {
                          for (var key in _healthConditions.keys) {
                            _healthConditions[key] = false;
                          }
                          _healthConditions['Ninguno'] = true;
                        }
                      } else {
                        // Si selecciona otro, desmarcar "Ninguno"
                        _healthConditions[condition] = value!;
                        _healthConditions['Ninguno'] = false;
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 30),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "¡Estás a un paso de comenzar tu viaje hacia una vida sin tabaco! Esta información nos ayudará a crear un plan personalizado para ti.",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
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

  Widget _buildYesNoQuestion(String question, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: value ? AppColors.primary : AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: value ? AppColors.primary : Colors.transparent,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Sí",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: value ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !value ? AppColors.primary : AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: !value ? AppColors.primary : Colors.transparent,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "No",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: !value ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
