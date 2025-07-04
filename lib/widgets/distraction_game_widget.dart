import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';
import '../theme/app_colors.dart';

class DistractionGameWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const DistractionGameWidget({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  _DistractionGameWidgetState createState() => _DistractionGameWidgetState();
}

class _DistractionGameWidgetState extends State<DistractionGameWidget>
    with TickerProviderStateMixin {
  bool _isPlaying = false;
  int _score = 0;
  int _targetScore = 10;
  late List<BubbleData> _bubbles;
  final Random _random = Random();
  Timer? _gameTimer;
  Timer? _bubbleTimer;
  int _timeRemaining = 60; // 60 segundos para jugar
  
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _bubbles = [];
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _bubbleTimer?.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  void _startGame() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isPlaying = true;
      _score = 0;
      _timeRemaining = 60;
      _bubbles = [];
    });
    
    // Temporizador para el tiempo de juego
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _endGame();
        }
      });
    });
    
    // Temporizador para generar burbujas
    _bubbleTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (_bubbles.length < 10) {
        _addBubble();
      }
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    _bubbleTimer?.cancel();
    
    setState(() {
      _isPlaying = false;
    });
    
    if (_score >= _targetScore) {
      widget.onComplete();
    }
    
    // Mostrar resultado
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          _score >= _targetScore ? "¡Felicidades!" : "Fin del juego",
          style: TextStyle(
            color: _score >= _targetScore ? Colors.green : AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _score >= _targetScore
                  ? "¡Has alcanzado el objetivo! Conseguiste $_score puntos."
                  : "Has conseguido $_score puntos. El objetivo era $_targetScore.",
            ),
            const SizedBox(height: 16),
            Text(
              _score >= _targetScore
                  ? "¡Has superado el antojo con éxito!"
                  : "¡Inténtalo de nuevo!",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cerrar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade400,
            ),
            child: const Text("Jugar de nuevo"),
          ),
        ],
      ),
    );
  }

  void _addBubble() {
    if (!_isPlaying) return;
    
    // Conseguir el ancho disponible corregido
    final screenWidth = MediaQuery.of(context).size.width - 100;
    final bubbleSize = 40.0 + _random.nextDouble() * 30.0; // Reducido el tamaño de las burbujas
    
    setState(() {
      _bubbles.add(
        BubbleData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          x: _random.nextDouble() * (screenWidth - bubbleSize),
          y: 250.0, // Ajustado para el nuevo tamaño del área de juego
          size: bubbleSize,
          color: Color.fromRGBO(
            100 + _random.nextInt(155),
            100 + _random.nextInt(155),
            200 + _random.nextInt(55),
            0.8,
          ),
          speed: 1.0 + _random.nextDouble() * 2.0,
        ),
      );
    });
  }

  void _updateBubbles() {
    if (!_isPlaying) return;
    
    setState(() {
      for (int i = _bubbles.length - 1; i >= 0; i--) {
        _bubbles[i].y -= _bubbles[i].speed;
        
        // Eliminar burbujas que salen de la pantalla
        if (_bubbles[i].y < -_bubbles[i].size) {
          _bubbles.removeAt(i);
        }
      }
    });
  }

  void _popBubble(int index) {
    HapticFeedback.lightImpact();
    
    // Animar el puntaje
    _scaleController.reset();
    _scaleController.forward();
    
    setState(() {
      _score++;
      _bubbles.removeAt(index);
    });
    
    // Si alcanzamos el objetivo y el juego sigue activo
    if (_score >= _targetScore && _isPlaying) {
      _endGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Actualizar posición de burbujas en cada frame
    if (_isPlaying) {
      Future.delayed(const Duration(milliseconds: 16), _updateBubbles);
    }
    
    return Container(
      padding: const EdgeInsets.all(16), // Reducido de 20 a 16
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.games,
                color: Colors.purple.shade600,
                size: 24,
              ),
              const SizedBox(width: 10),
              const Text(
                "Distráete con un juego",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Reducido de 16 a 12
          const Text(
            "Un juego rápido para distraer tu mente del antojo de fumar. ¡Explota las burbujas para ganar puntos!",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12), // Reducido de 20 a 12
        
          // Información del juego
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Puntaje
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isPlaying ? _scaleAnimation.value : 1.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reducido
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.purple.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.purple.shade700,
                            size: 18, // Reducido de 20 a 18
                          ),
                          const SizedBox(width: 4), // Reducido de 8 a 4
                          Text(
                            "Puntos: $_score/$_targetScore",
                            style: TextStyle(
                              fontSize: 14, // Reducido de 16 a 14
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              // Tiempo restante
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reducido
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.blue.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      color: Colors.blue.shade700,
                      size: 18, // Reducido de 20 a 18
                    ),
                    const SizedBox(width: 4), // Reducido de 8 a 4
                    Text(
                      "Tiempo: $_timeRemaining s",
                      style: TextStyle(
                        fontSize: 14, // Reducido de 16 a 14
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Reducido de 20 a 12
        
          // Área de juego - reducida aún más
          Container(
            width: double.infinity,
            height: 250, // Reducido de 350 a 250
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.indigo.shade100,
              ),
            ),
            child: _isPlaying
                ? Stack(
                    children: [
                      // Burbujas
                      ...List.generate(_bubbles.length, (index) {
                        final bubble = _bubbles[index];
                        return Positioned(
                          left: bubble.x,
                          top: bubble.y,
                          child: GestureDetector(
                            onTap: () => _popBubble(index),
                            child: Container(
                              width: bubble.size,
                              height: bubble.size,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: bubble.color,
                                boxShadow: [
                                  BoxShadow(
                                    color: bubble.color.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.bubble_chart,
                                  color: Colors.white.withOpacity(0.7),
                                  size: bubble.size * 0.5,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  )
                : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 40, // Reducido de 48 a 40
                        color: Colors.indigo.shade300,
                      ),
                      const SizedBox(height: 12), // Reducido de 16 a 12
                      Text(
                        "Toca las burbujas para explotarlas",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.indigo.shade400,
                        ),
                      ),
                      const SizedBox(height: 4), // Reducido de 8 a 4
                      Text(
                        "Objetivo: $_targetScore puntos",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.indigo.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 12), // Reducido de 20 a 12
        
        // Botón de inicio
        if (!_isPlaying)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12), // Reducido de 16 a 12
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Comenzar juego",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
}

// Clase para almacenar datos de las burbujas
class BubbleData {
  final String id;
  double x;
  double y;
  final double size;
  final Color color;
  final double speed;

  BubbleData({
    required this.id,
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
  });
}
