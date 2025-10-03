import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GuessNumberGame extends StatefulWidget {
  const GuessNumberGame({super.key});

  @override
  State<GuessNumberGame> createState() => _GuessNumberGameState();
}

class _GuessNumberGameState extends State<GuessNumberGame>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late int _secret;
  String _message = '';
  int _attempts = 0;
  bool _isDark = false;
  int? _lastGuess;
  String _hintLevel = '';
  List<int> _guessHistory = [];
  bool _hasWon = false;
  bool _dialogShown = false; // NUEVO: prevenir múltiples diálogos

  // Paleta de colores
  final Color deepPurple = const Color(0xFF2D1B69);
  final Color vibrantPurple = const Color(0xFF6366F1);
  final Color lightPurple = const Color(0xFFA855F7);
  final Color darkBackground = const Color(0xFF0F0A1F);
  final Color cardDark = const Color(0xFF1A1335);
  final Color accentPink = const Color(0xFFEC4899);
  final Color softWhite = const Color(0xFFF8FAFC);
  final Color mentalhealthGreen = const Color(0xFF10B981);
  final Color warningOrange = const Color(0xFFF97316);
  final Color warningYellow = const Color(0xFFFBBF24);

  // Animaciones
  late AnimationController _shakeController;
  late AnimationController _celebrationController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _resetGame();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _resetGame() {
    _secret = Random().nextInt(100) + 1;
    _controller.clear();
    setState(() {
      _message = '';
      _attempts = 0;
      _lastGuess = null;
      _hintLevel = '';
      _guessHistory.clear();
      _hasWon = false;
      _dialogShown = false;
    });
  }

  Color _getProximityColor(int difference) {
    if (difference == 0) return mentalhealthGreen;
    if (difference <= 5) return mentalhealthGreen.withOpacity(0.7);
    if (difference <= 10) return warningYellow;
    if (difference <= 20) return warningOrange;
    if (difference <= 30) return accentPink;
    return vibrantPurple;
  }

  String _getProximityMessage(int difference) {
    if (difference == 0) return '¡PERFECTO!';
    if (difference <= 5) return '¡MUY CERCA!';
    if (difference <= 10) return '¡CALIENTE!';
    if (difference <= 20) return 'Tibio...';
    if (difference <= 30) return 'Frío';
    return '¡Muy lejos!';
  }

  IconData _getProximityIcon(int difference) {
    if (difference == 0) return Icons.celebration;
    if (difference <= 5) return Icons.local_fire_department;
    if (difference <= 10) return Icons.whatshot;
    if (difference <= 20) return Icons.thermostat;
    if (difference <= 30) return Icons.ac_unit;
    return Icons.explore;
  }

  void _checkGuess() {
    final value = int.tryParse(_controller.text);
    HapticFeedback.mediumImpact();

    if (value == null || value < 1 || value > 100) {
      _shakeController.forward().then((_) => _shakeController.reverse());
      setState(() => _message = 'Número entre 1 y 100');
      return;
    }

    setState(() {
      _attempts++;
      _lastGuess = value;
      _guessHistory.add(value);
      
      int difference = (value - _secret).abs();
      _hintLevel = _getProximityMessage(difference);

      if (value == _secret) {
        _hasWon = true;
        HapticFeedback.heavyImpact();
        _celebrationController.forward();
        
        if (!_dialogShown) {
          _dialogShown = true;
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _showWinDialog();
            }
          });
        }
      } else if (value < _secret) {
        _message = 'Más alto';
      } else {
        _message = 'Más bajo';
      }
    });

    _controller.clear();
  }

  void _toggleTheme() {
    setState(() => _isDark = !_isDark);
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _isDark ? cardDark : softWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: mentalhealthGreen.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: mentalhealthGreen.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Transform.rotate(
                        angle: value * 2 * pi,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: mentalhealthGreen.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: mentalhealthGreen.withOpacity(0.4),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.celebration,
                            color: mentalhealthGreen,
                            size: 30,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  '¡Has Ganado!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: _isDark ? softWhite : deepPurple,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: mentalhealthGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: mentalhealthGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'El número era',
                        style: TextStyle(
                          fontSize: 13,
                          color: _isDark
                              ? Colors.grey[300]
                              : deepPurple.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_secret',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: mentalhealthGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'En $_attempts intentos',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isDark
                              ? Colors.grey[300]
                              : deepPurple.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: _isDark
                                ? vibrantPurple.withOpacity(0.6)
                                : deepPurple.withOpacity(0.4),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Salir',
                          style: TextStyle(
                            color: _isDark ? vibrantPurple : deepPurple,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              mentalhealthGreen,
                              mentalhealthGreen.withOpacity(0.8)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: mentalhealthGreen.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.of(context).pop();
                            _resetGame();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Jugar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: _isDark ? darkBackground : softWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: (_isDark ? cardDark : softWhite).withOpacity(0.95),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: vibrantPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: vibrantPurple.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: vibrantPurple, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: vibrantPurple,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: vibrantPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.casino, color: softWhite, size: 16),
            ),
            const SizedBox(width: 12),
            Text(
              'Adivina el número',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _isDark ? softWhite : deepPurple,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: vibrantPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: vibrantPurple.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: Icon(
                _isDark ? Icons.light_mode : Icons.dark_mode,
                color: _isDark ? accentPink : vibrantPurple,
                size: 20,
              ),
              onPressed: _toggleTheme,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isDark
                    ? [
                        darkBackground,
                        deepPurple.withOpacity(0.3),
                        darkBackground
                      ]
                    : [softWhite, vibrantPurple.withOpacity(0.05), softWhite],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: 500, maxHeight: screenHeight * 0.85),
                    child: AnimatedBuilder(
                      animation: _shakeAnim,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                              _shakeAnim.value *
                                  ((_shakeController.value * 2) % 2 == 0
                                      ? 1
                                      : -1),
                              0),
                          child: Container(
                            padding: EdgeInsets.all(isMobile ? 20 : 28),
                            decoration: BoxDecoration(
                              color: _isDark
                                  ? cardDark.withOpacity(0.8)
                                  : Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: vibrantPurple.withOpacity(0.2),
                                  width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: vibrantPurple.withOpacity(0.15),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [vibrantPurple, lightPurple],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: vibrantPurple.withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.psychology,
                                      color: Colors.white, size: 30),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '¡Pon a prueba tu mente!',
                                  style: TextStyle(
                                    fontSize: isMobile ? 20 : 24,
                                    fontWeight: FontWeight.w900,
                                    color: _isDark ? softWhite : deepPurple,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Número entre 1 y 100',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _isDark
                                        ? Colors.grey[300]
                                        : deepPurple.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                if (_lastGuess != null && !_hasWon)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _getProximityColor(
                                                  (_lastGuess! - _secret).abs())
                                              .withOpacity(0.2),
                                          _getProximityColor(
                                                  (_lastGuess! - _secret).abs())
                                              .withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _getProximityColor(
                                                (_lastGuess! - _secret).abs())
                                            .withOpacity(0.4),
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          _getProximityIcon(
                                              (_lastGuess! - _secret).abs()),
                                          size: 32,
                                          color: _getProximityColor(
                                              (_lastGuess! - _secret).abs()),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _hintLevel,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: _getProximityColor(
                                                (_lastGuess! - _secret).abs()),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _message,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _isDark
                                                ? Colors.grey[300]
                                                : deepPurple.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                TextField(
                                  controller: _controller,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _isDark ? softWhite : deepPurple,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Tu número aquí',
                                    hintStyle: TextStyle(
                                      color: _isDark
                                          ? Colors.grey[500]
                                          : deepPurple.withOpacity(0.4),
                                    ),
                                    filled: true,
                                    fillColor: _isDark
                                        ? darkBackground.withOpacity(0.5)
                                        : vibrantPurple.withOpacity(0.05),
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                          color: vibrantPurple.withOpacity(0.3)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                          color: vibrantPurple.withOpacity(0.3),
                                          width: 2),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                          color: vibrantPurple, width: 2),
                                    ),
                                  ),
                                  onSubmitted: (_) => _checkGuess(),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [
                                            vibrantPurple,
                                            lightPurple
                                          ]),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: vibrantPurple
                                                  .withOpacity(0.4),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: _checkGuess,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Probar',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    OutlinedButton(
                                      onPressed: _resetGame,
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14, horizontal: 20),
                                        side: BorderSide(
                                          color: _isDark
                                              ? vibrantPurple
                                              : deepPurple.withOpacity(0.5),
                                          width: 2,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        'Reiniciar',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: _isDark
                                              ? vibrantPurple
                                              : deepPurple,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: vibrantPurple.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: vibrantPurple.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.psychology,
                                          color: vibrantPurple, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Intentos: $_attempts',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _isDark
                                              ? Colors.grey[300]
                                              : deepPurple.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_guessHistory.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _isDark
                                          ? darkBackground.withOpacity(0.3)
                                          : vibrantPurple.withOpacity(0.03),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color:
                                              vibrantPurple.withOpacity(0.15)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.history,
                                                color: vibrantPurple, size: 16),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Tus intentos',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: _isDark
                                                    ? softWhite
                                                    : deepPurple,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: _guessHistory.map((guess) {
                                            int diff = (guess - _secret).abs();
                                            Color chipColor =
                                                _getProximityColor(diff);
                                            return Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color:
                                                    chipColor.withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                    color: chipColor
                                                        .withOpacity(0.4)),
                                              ),
                                              child: Text(
                                                '$guess',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12,
                                                  color: chipColor,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_hasWon)
            ...List.generate(20, (index) {
              final random = Random();
              final color = [
                mentalhealthGreen,
                vibrantPurple,
                accentPink,
                warningYellow,
                lightPurple
              ][random.nextInt(5)];

              return TweenAnimationBuilder(
                key: ValueKey('particle_$index'),
                duration: Duration(milliseconds: 1500 + random.nextInt(1000)),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  final startX = screenWidth / 2 + random.nextDouble() * 100 - 50;
                  final endX = startX + (random.nextDouble() * 200 - 100);
                  final endY = screenHeight;

                  return Positioned(
                    left: startX + (endX - startX) * value,
                    top: 100 + endY * value,
                    child: Opacity(
                      opacity: 1 - value,
                      child: Transform.rotate(
                        angle: value * 4 * pi,
                        child: Icon(
                          Icons.star,
                          color: color,
                          size: 20 + random.nextDouble() * 20,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
        ],
      ),
    );
  }
}