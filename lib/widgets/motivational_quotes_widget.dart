import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../theme/app_colors.dart';

class MotivationalQuotesWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const MotivationalQuotesWidget({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  _MotivationalQuotesWidgetState createState() => _MotivationalQuotesWidgetState();
}

class _MotivationalQuotesWidgetState extends State<MotivationalQuotesWidget> with SingleTickerProviderStateMixin {
  int _currentQuoteIndex = 0;
  bool _isCompleted = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final PageController _pageController = PageController();

  final List<Map<String, String>> _quotes = [
    {
      'quote': 'Cada día sin fumar es una victoria para tu salud y tu libertad.',
      'author': 'Anónimo',
    },
    {
      'quote': 'La fuerza no viene de lo que puedes hacer. Viene de superar lo que pensabas que no podías.',
      'author': 'Rikki Rogers',
    },
    {
      'quote': 'El éxito no es definitivo, el fracaso no es fatal: lo que cuenta es el coraje para continuar.',
      'author': 'Winston Churchill',
    },
    {
      'quote': 'No importa lo lento que vayas, siempre y cuando no te detengas.',
      'author': 'Confucio',
    },
    {
      'quote': 'Tu cuerpo es un templo, pero solo si lo tratas como tal.',
      'author': 'Astrid Alauda',
    },
    {
      'quote': 'Cada cigarrillo que no fumas es una pequeña victoria. Acumula suficientes victorias y ganarás la guerra.',
      'author': 'Anónimo',
    },
    {
      'quote': 'La mejor manera de predecir tu futuro es crearlo.',
      'author': 'Abraham Lincoln',
    },
    {
      'quote': 'Nunca es demasiado tarde para ser lo que podrías haber sido.',
      'author': 'George Eliot',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    
    // Mezclar las citas para que aparezcan en orden aleatorio
    _quotes.shuffle();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextQuote() {
    HapticFeedback.lightImpact();
    if (_currentQuoteIndex < _quotes.length - 1) {
      _animationController.reset();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _animationController.forward();
    } else if (!_isCompleted) {
      setState(() {
        _isCompleted = true;
      });
      widget.onComplete();
    }
  }

  void _previousQuote() {
    if (_currentQuoteIndex > 0) {
      HapticFeedback.lightImpact();
      _animationController.reset();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              Icon(
                Icons.format_quote,
                color: Colors.amber.shade600,
                size: 24,
              ),
              const SizedBox(width: 10),
              const Text(
                "Frases motivadoras",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Lee estas frases para motivarte y recordar por qué estás en este viaje para dejar de fumar.",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 30),
          
          // Carrusel de citas
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _quotes.length,
              onPageChanged: (index) {
                setState(() {
                  _currentQuoteIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return FadeTransition(
                  opacity: _animation,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.shade100,
                          Colors.amber.shade50,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.shade200,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _quotes[index]['quote']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "— ${_quotes[index]['author']}",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          
          // Indicadores de página
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_quotes.length, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentQuoteIndex == index
                      ? Colors.amber.shade600
                      : Colors.grey.shade300,
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          
          // Botones de navegación
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _currentQuoteIndex > 0 ? _previousQuote : null,
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: _currentQuoteIndex > 0
                      ? Colors.amber.shade600
                      : Colors.grey.shade400,
                ),
              ),
              ElevatedButton(
                onPressed: _nextQuote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentQuoteIndex < _quotes.length - 1
                      ? "Siguiente"
                      : _isCompleted
                          ? "Completado"
                          : "Finalizar",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _currentQuoteIndex < _quotes.length - 1 ? _nextQuote : null,
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: _currentQuoteIndex < _quotes.length - 1
                      ? Colors.amber.shade600
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
