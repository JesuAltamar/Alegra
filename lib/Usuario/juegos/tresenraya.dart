import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

class TicTacToeApp extends StatefulWidget {
  const TicTacToeApp({super.key});

  @override
  State<TicTacToeApp> createState() => _TicTacToeAppState();
}

class _TicTacToeAppState extends State<TicTacToeApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return TicTacToeGame(toggleTheme: toggleTheme, isDarkMode: _isDarkMode);
  }
}

class TicTacToeGame extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const TicTacToeGame({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

enum GameMode { vsAI, vsPlayer }

class _TicTacToeGameState extends State<TicTacToeGame>
    with TickerProviderStateMixin {
  late List<String> _board;
  String _currentPlayer = 'X';
  late bool _isGameFinished;
  String _winner = '';
  final String _humanPlayer = 'X';
  final String _aiPlayer = 'O';
  GameMode _gameMode = GameMode.vsAI;
  bool _showModeSelector = true;

  // Paleta de colores Alegra
  final Color deepPurple = Color(0xFF2D1B69);
  final Color vibrantPurple = Color(0xFF6366F1);
  final Color lightPurple = Color(0xFFA855F7);
  final Color darkBackground = Color(0xFF0F0A1F);
  final Color cardDark = Color(0xFF1A1335);
  final Color accentPink = Color(0xFFEC4899);
  final Color softWhite = Color(0xFFF8FAFC);
  final Color cloudBlue = Color(0xFF8B5CF6);
  final Color mentalhealthGreen = Color(0xFF10B981);

  // Controladores de animación
  late AnimationController _mainController;
  late AnimationController _cellController;
  late AnimationController _modeController;
  late List<Animation<double>> _cellAnimations;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cellController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _modeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Crear animaciones para cada celda del tablero
    _cellAnimations = List.generate(9, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _mainController,
          curve: Interval(
            index * 0.05,
            0.4 + (index * 0.05),
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });

    _modeController.forward();
    _startNewGame();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _cellController.dispose();
    _modeController.dispose();
    super.dispose();
  }

  void _selectGameMode(GameMode mode) {
    setState(() {
      _gameMode = mode;
      _showModeSelector = false;
    });
    HapticFeedback.mediumImpact();
    _startNewGame(); // Reiniciar juego al seleccionar modo
    _mainController.forward();
  }

  void _changeGameMode() {
    setState(() {
      _showModeSelector = true;
      _modeController.reset();
    });
    _modeController.forward();
    _startNewGame(); // Reiniciar el tablero al cambiar de modo
  }

  void _startNewGame() {
    setState(() {
      _board = List.generate(9, (index) => '');
      _currentPlayer = _humanPlayer;
      _isGameFinished = false;
      _winner = '';
    });
    _mainController.reset();
    if (!_showModeSelector) {
      _mainController.forward();
    }
  }

  void _onTap(int index) {
    if (_isGameFinished || _board[index] != '') {
      return;
    }

    // En modo vs IA, solo permitir jugadas del humano
    if (_gameMode == GameMode.vsAI && _currentPlayer != _humanPlayer) {
      return;
    }

    HapticFeedback.mediumImpact();

    setState(() {
      _board[index] = _currentPlayer;
    });

    _cellController.forward().then((_) {
      _cellController.reverse();
    });

    _checkGameStatus();
  }

  void _checkGameStatus() {
    if (_checkWinner()) {
      _showWinnerDialog();
      return;
    }
    if (_checkDraw()) {
      _showWinnerDialog();
      return;
    }

    _togglePlayer();
    
    // Solo hacer movimiento de IA si estamos en modo vs IA
    if (_gameMode == GameMode.vsAI && _currentPlayer == _aiPlayer) {
      Timer(const Duration(milliseconds: 800), () {
        _makeAIMove();
      });
    }
  }

  void _togglePlayer() {
    setState(() {
      _currentPlayer =
          (_currentPlayer == _humanPlayer) ? _aiPlayer : _humanPlayer;
    });
  }

  void _makeAIMove() {
    int move = -1;

    // Estrategia de IA
    for (var combo in _getWinningCombos()) {
      if (_board[combo[0]] == _aiPlayer &&
          _board[combo[1]] == _aiPlayer &&
          _board[combo[2]] == '') {
        move = combo[2];
      } else if (_board[combo[0]] == _aiPlayer &&
          _board[combo[2]] == _aiPlayer &&
          _board[combo[1]] == '') {
        move = combo[1];
      } else if (_board[combo[1]] == _aiPlayer &&
          _board[combo[2]] == _aiPlayer &&
          _board[combo[0]] == '') {
        move = combo[0];
      }
      if (move != -1) break;
    }

    if (move == -1) {
      for (var combo in _getWinningCombos()) {
        if (_board[combo[0]] == _humanPlayer &&
            _board[combo[1]] == _humanPlayer &&
            _board[combo[2]] == '') {
          move = combo[2];
        } else if (_board[combo[0]] == _humanPlayer &&
            _board[combo[2]] == _humanPlayer &&
            _board[combo[1]] == '') {
          move = combo[1];
        } else if (_board[combo[1]] == _humanPlayer &&
            _board[combo[2]] == _humanPlayer &&
            _board[combo[0]] == '') {
          move = combo[0];
        }
        if (move != -1) break;
      }
    }

    if (move == -1 && _board[4] == '') {
      move = 4;
    }

    if (move == -1) {
      List<int> corners = [0, 2, 6, 8];
      corners.shuffle();
      for (var corner in corners) {
        if (_board[corner] == '') {
          move = corner;
          break;
        }
      }
    }

    if (move == -1) {
      List<int> sides = [1, 3, 5, 7];
      sides.shuffle();
      for (var side in sides) {
        if (_board[side] == '') {
          move = side;
          break;
        }
      }
    }

    if (move != -1) {
      setState(() {
        _board[move] = _aiPlayer;
      });
      _checkGameStatus();
    }
  }

  List<List<int>> _getWinningCombos() {
    return [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
  }

  bool _checkWinner() {
    for (var combo in _getWinningCombos()) {
      if (_board[combo[0]] != '' &&
          _board[combo[0]] == _board[combo[1]] &&
          _board[combo[0]] == _board[combo[2]]) {
        _isGameFinished = true;
        _winner = _board[combo[0]];
        return true;
      }
    }
    return false;
  }

  bool _checkDraw() {
    if (_board.every((element) => element != '')) {
      _isGameFinished = true;
      _winner = 'Empate';
      return true;
    }
    return false;
  }

  void _showWinnerDialog() {
    String message;
    String title;
    IconData iconData;
    Color accentColor;

    if (_winner == 'Empate') {
      title = '¡Empate!';
      message = 'Buen juego';
      iconData = Icons.handshake;
      accentColor = cloudBlue;
    } else if (_gameMode == GameMode.vsPlayer) {
      // En modo 2 jugadores
      title = '¡Ganó $_winner!';
      message = 'Jugador $_winner';
      iconData = Icons.celebration;
      accentColor = _winner == 'X' ? mentalhealthGreen : accentPink;
    } else {
      // En modo vs IA
      if (_winner == _humanPlayer) {
        title = '¡Victoria!';
        message = 'Has ganado';
        iconData = Icons.celebration;
        accentColor = mentalhealthGreen;
      } else {
        title = 'Derrota';
        message = 'La IA ganó';
        iconData = Icons.psychology;
        accentColor = accentPink;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: 320),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? cardDark : softWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accentColor.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(iconData, color: accentColor, size: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: widget.isDarkMode ? softWhite : deepPurple,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        widget.isDarkMode
                            ? Colors.grey[300]
                            : deepPurple.withOpacity(0.7),
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
                            color:
                                widget.isDarkMode
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
                            color:
                                widget.isDarkMode ? vibrantPurple : deepPurple,
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
                            colors: [accentColor, accentColor.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.of(context).pop();
                            _startNewGame();
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
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      backgroundColor: widget.isDarkMode ? darkBackground : softWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: (widget.isDarkMode ? cardDark : softWhite).withOpacity(
          0.95,
        ),
        leading: Container(
          margin: EdgeInsets.all(8),
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
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.grid_3x3, color: softWhite, size: 16),
            ),
            SizedBox(width: 12),
            Text(
              'Tres en Raya',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: widget.isDarkMode ? softWhite : deepPurple,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: vibrantPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: vibrantPurple.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: Icon(
                widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: widget.isDarkMode ? accentPink : vibrantPurple,
                size: 20,
              ),
              onPressed: widget.toggleTheme,
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                widget.isDarkMode
                    ? [
                      darkBackground,
                      deepPurple.withOpacity(0.3),
                      darkBackground,
                    ]
                    : [softWhite, vibrantPurple.withOpacity(0.05), softWhite],
          ),
        ),
        child: SafeArea(
          child: _showModeSelector
              ? _buildModeSelector(isMobile)
              : _buildGameScreen(isMobile),
        ),
      ),
    );
  }

  Widget _buildModeSelector(bool isMobile) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 24 : 40),
        child: AnimatedBuilder(
          animation: _modeController,
          builder: (context, child) {
            return Opacity(
              opacity: _modeController.value,
              child: Transform.translate(
                offset: Offset(0, (1 - _modeController.value) * 50),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
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
                        child: Column(
                          children: [
                            Icon(
                              Icons.grid_3x3,
                              size: 48,
                              color: vibrantPurple,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Selecciona el Modo',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: widget.isDarkMode ? softWhite : deepPurple,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Elige cómo quieres jugar',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    widget.isDarkMode
                                        ? Colors.grey[300]
                                        : deepPurple.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      _buildModeCard(
                        icon: Icons.psychology,
                        title: 'Vs IA',
                        subtitle: 'Juega contra la inteligencia artificial',
                        color: accentPink,
                        onTap: () => _selectGameMode(GameMode.vsAI),
                      ),
                      SizedBox(height: 16),
                      _buildModeCard(
                        icon: Icons.people,
                        title: 'Vs Jugador',
                        subtitle: 'Juega con un amigo en el mismo dispositivo',
                        color: mentalhealthGreen,
                        onTap: () => _selectGameMode(GameMode.vsPlayer),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color:
                widget.isDarkMode
                    ? cardDark.withOpacity(0.8)
                    : Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: widget.isDarkMode ? softWhite : deepPurple,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            widget.isDarkMode
                                ? Colors.grey[300]
                                : deepPurple.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameScreen(bool isMobile) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 20 : 40),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              return Opacity(
                opacity: _mainController.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 40),
                    _buildGameBoard(isMobile),
                    const SizedBox(height: 40),
                    _buildActionButtons(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    String statusText;
    if (_isGameFinished) {
      statusText = _winner == 'Empate' ? 'Empate' : '$_winner ha ganado';
    } else {
      if (_gameMode == GameMode.vsPlayer) {
        statusText = 'Turno: Jugador $_currentPlayer';
      } else {
        statusText = 'Turno: ${_currentPlayer == _humanPlayer ? "Tú (X)" : "IA (O)"}';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color:
            widget.isDarkMode
                ? cardDark.withOpacity(0.8)
                : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: vibrantPurple.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: vibrantPurple.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color:
                  _currentPlayer == _humanPlayer
                      ? mentalhealthGreen
                      : accentPink,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: widget.isDarkMode ? softWhite : deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard(bool isMobile) {
    final boardSize = isMobile ? 300.0 : 340.0;

    return Container(
      width: boardSize,
      height: boardSize,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            widget.isDarkMode
                ? cardDark.withOpacity(0.8)
                : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: vibrantPurple.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: vibrantPurple.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _cellAnimations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _cellAnimations[index].value,
                child: GestureDetector(
                  onTap: () => _onTap(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          widget.isDarkMode
                              ? darkBackground.withOpacity(0.5)
                              : vibrantPurple.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            _board[index].isEmpty
                                ? vibrantPurple.withOpacity(0.2)
                                : (_board[index] == 'X'
                                    ? mentalhealthGreen
                                    : accentPink),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _board[index],
                        style: TextStyle(
                          fontSize: isMobile ? 36 : 42,
                          fontWeight: FontWeight.w900,
                          color:
                              _board[index] == 'X'
                                  ? mentalhealthGreen
                                  : accentPink,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [vibrantPurple, lightPurple]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: vibrantPurple.withOpacity(0.4),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              _startNewGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, color: softWhite, size: 20),
                SizedBox(width: 8),
                Text(
                  'Reiniciar Juego',
                  style: TextStyle(
                    color: softWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
        TextButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            _changeGameMode();
          },
          icon: Icon(Icons.swap_horiz, color: vibrantPurple, size: 18),
          label: Text(
            'Cambiar Modo',
            style: TextStyle(
              color: vibrantPurple,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}