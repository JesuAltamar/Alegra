import 'dart:async';
import 'package:flutter/material.dart';

// Widget wrapper para usar en navegación
class MemoryGameWidget extends StatelessWidget {
  const MemoryGameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const MemoryGame();
  }
}

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> with TickerProviderStateMixin {
  // Colores del proyecto Alegra (de PagInicio)
  final Color deepPurple = const Color(0xFF2D1B69);
  final Color vibrantPurple = const Color(0xFF6366F1);
  final Color lightPurple = const Color(0xFFA855F7);
  final Color darkBackground = const Color(0xFF0F0A1F);
  final Color cardDark = const Color(0xFF1A1335);
  final Color accentPink = const Color(0xFFEC4899);
  final Color softWhite = const Color(0xFFF8FAFC);
  final Color cloudBlue = const Color(0xFF8B5CF6);
  final Color mentalhealthGreen = const Color(0xFF10B981);

  bool isDarkMode = false;
  List<String> _emojis = [];
  List<bool> _revelado = [];
  int _puntos = 0;
  int _intentos = 0;
  int? _primerIndex;
  Timer? _timer;
  int _tiempoRestante = 60;
  bool _jugando = false;

  final List<String> easyEmojis = [
    "🌺",
    "🌺",
    "🦋",
    "🦋",
    "🍀",
    "🍀",
    "⭐️",
    "⭐️",
  ];

  final List<String> mediumEmojis = [
    "🌈",
    "🌈",
    "🌙",
    "🌙",
    "✨",
    "✨",
    "🎵",
    "🎵",
    "🕊️",
    "🕊️",
    "🪐",
    "🪐",
  ];

  final List<String> hardEmojis = [
    "🐱",
    "🐱",
    "🐰",
    "🐰",
    "🧸",
    "🧸",
    "🍓",
    "🍓",
    "🍩",
    "🍩",
    "💖",
    "💖",
    "🦄",
    "🦄",
    "🌻",
    "🌻",
  ];

  @override
  void initState() {
    super.initState();
  }

  void _setNivel(String nivel) {
    if (nivel == "facil") {
      _emojis = List.from(easyEmojis);
    } else if (nivel == "medio") {
      _emojis = List.from(mediumEmojis);
    } else {
      _emojis = List.from(hardEmojis);
    }
    _emojis.shuffle();
    _revelado = List<bool>.filled(_emojis.length, false);
    _puntos = 0;
    _intentos = 0;
    _tiempoRestante = 60;
    _jugando = true;
    _iniciarTimer();
    setState(() {});
  }

  void _iniciarTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_tiempoRestante > 0) {
        setState(() {
          _tiempoRestante--;
        });
      } else {
        timer.cancel();
        setState(() {
          _jugando = false;
        });
        _mostrarDialogoFinal();
      }
    });
  }

  void _mostrarDialogoFinal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? cardDark : softWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.timer_off, color: accentPink, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Tiempo terminado',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: isDarkMode ? softWhite : deepPurple,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _resultRow(Icons.stars, 'Puntos', '$_puntos', lightPurple),
              const SizedBox(height: 8),
              _resultRow(
                Icons.refresh,
                'Intentos',
                '$_intentos',
                vibrantPurple,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_puntos >= _emojis.length / 2
                          ? mentalhealthGreen
                          : lightPurple)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (_puntos >= _emojis.length / 2
                            ? mentalhealthGreen
                            : lightPurple)
                        .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _puntos >= _emojis.length / 2
                          ? Icons.celebration
                          : Icons.emoji_events,
                      color:
                          _puntos >= _emojis.length / 2
                              ? mentalhealthGreen
                              : lightPurple,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _puntos >= _emojis.length / 2
                            ? 'Excelente trabajo'
                            : 'Sigue practicando',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color:
                              _puntos >= _emojis.length / 2
                                  ? mentalhealthGreen
                                  : lightPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                color: vibrantPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _jugando = false;
                  });
                },
                child: Text(
                  'Aceptar',
                  style: TextStyle(
                    color: softWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _tocarCarta(int index) {
    if (_revelado[index] || !_jugando) return;

    setState(() {
      _revelado[index] = true;
      if (_primerIndex == null) {
        _primerIndex = index;
      } else {
        _intentos++;
        if (_emojis[_primerIndex!] == _emojis[index]) {
          _puntos++;
          _primerIndex = null;
          if (_puntos == _emojis.length / 2) {
            _timer?.cancel();
            Future.delayed(const Duration(milliseconds: 500), () {
              _mostrarDialogoVictoria();
            });
          }
        } else {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                _revelado[_primerIndex!] = false;
                _revelado[index] = false;
                _primerIndex = null;
              });
            }
          });
        }
      }
    });
  }

  void _mostrarDialogoVictoria() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? cardDark : softWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: mentalhealthGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.celebration,
                  color: mentalhealthGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Felicidades',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: isDarkMode ? softWhite : deepPurple,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Completaste el juego',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color:
                      isDarkMode
                          ? softWhite.withOpacity(0.9)
                          : deepPurple.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
              _resultRow(Icons.stars, 'Puntos', '$_puntos', lightPurple),
              const SizedBox(height: 8),
              _resultRow(
                Icons.refresh,
                'Intentos',
                '$_intentos',
                vibrantPurple,
              ),
              const SizedBox(height: 8),
              _resultRow(
                Icons.timer,
                'Tiempo restante',
                '${_tiempoRestante}s',
                cloudBlue,
              ),
            ],
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                color: vibrantPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _jugando = false;
                  });
                },
                child: Text(
                  'Jugar de nuevo',
                  style: TextStyle(
                    color: softWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _resultRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: isDarkMode ? darkBackground : softWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? softWhite : deepPurple,
          ),
          onPressed: () {
            // Cancelar timer si está jugando
            if (_jugando) {
              _timer?.cancel();
            }
            // Regresar al menú de juegos
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: vibrantPurple,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: vibrantPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'ALEGRA - Juego de Memoria',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? softWhite : deepPurple,
              ),
            ),
          ],
        ),
        backgroundColor: (isDarkMode ? cardDark : softWhite).withOpacity(0.95),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? accentPink : vibrantPurple,
              size: 24,
            ),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
        ],
      ),
      body: _jugando ? _buildGame(isWeb) : _buildMenu(isWeb),
    );
  }

  Widget _buildMenu(bool isWeb) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWeb ? 80 : 24,
          vertical: 40,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      vibrantPurple.withOpacity(0.1),
                      lightPurple.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: vibrantPurple.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: vibrantPurple,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: vibrantPurple.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology,
                        size: 26,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Juego de Memoria",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDarkMode ? softWhite : deepPurple,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Encuentra todas las parejas",
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Selecciona un nivel",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? softWhite : deepPurple,
                ),
              ),
              const SizedBox(height: 20),
              _nivelCard(
                Icons.eco,
                "Fácil",
                "facil",
                "4 pares - Perfecto para comenzar",
                mentalhealthGreen,
              ),
              const SizedBox(height: 12),
              _nivelCard(
                Icons.star_half,
                "Medio",
                "medio",
                "6 pares - Un poco más de desafío",
                vibrantPurple,
              ),
              const SizedBox(height: 12),
              _nivelCard(
                Icons.whatshot,
                "Difícil",
                "dificil",
                "8 pares - Para expertos",
                accentPink,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nivelCard(
    IconData icon,
    String title,
    String nivel,
    String subtitle,
    Color primaryColor,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _setNivel(nivel),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? cardDark.withOpacity(0.8) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primaryColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Icon(icon, color: primaryColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? softWhite : deepPurple,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: primaryColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGame(bool isWeb) {
    int crossAxisCount = _emojis.length <= 8 ? 4 : 4;
    final screenSize = MediaQuery.of(context).size;
    final maxGridWidth = isWeb ? 550.0 : screenSize.width - 48;

    return Column(
      children: [
        const SizedBox(height: 16),
        Expanded(
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxGridWidth),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isDarkMode ? cardDark.withOpacity(0.8) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: vibrantPurple.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: vibrantPurple.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          vibrantPurple.withOpacity(0.1),
                          lightPurple.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statItem(
                          Icons.stars,
                          "Puntos",
                          "$_puntos",
                          lightPurple,
                        ),
                        _divider(),
                        _statItem(
                          Icons.refresh,
                          "Intentos",
                          "$_intentos",
                          vibrantPurple,
                        ),
                        _divider(),
                        _statItem(
                          Icons.timer,
                          "Tiempo",
                          "${_tiempoRestante}s",
                          accentPink,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: _emojis.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.0,
                        ),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _tocarCarta(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                gradient:
                                    _revelado[index]
                                        ? LinearGradient(
                                          colors: [Colors.white, Colors.white],
                                        )
                                        : LinearGradient(
                                          colors: [vibrantPurple, lightPurple],
                                        ),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    _revelado[index]
                                        ? Border.all(
                                          color: vibrantPurple.withOpacity(0.3),
                                          width: 2,
                                        )
                                        : null,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        _revelado[index]
                                            ? vibrantPurple.withOpacity(0.2)
                                            : vibrantPurple.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Text(
                                    _revelado[index] ? _emojis[index] : "?",
                                    key: ValueKey(_revelado[index]),
                                    style: TextStyle(
                                      fontSize: isWeb ? 32 : 28,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: isWeb ? 200 : double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accentPink, accentPink.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: accentPink.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: softWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          onPressed: () {
                            _timer?.cancel();
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.exit_to_app, size: 18),
                          label: const Text(
                            "Salir del Juego",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _statItem(IconData icon, String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 40,
      color:
          isDarkMode
              ? Colors.grey.withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
    );
  }
}