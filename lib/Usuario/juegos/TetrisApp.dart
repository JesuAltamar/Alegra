import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pro9/Usuario/juegos/juegos.dart';

// Paleta de colores Alegra para las piezas del Tetris
const Color colorI = Color(0xFF6366F1); // vibrantPurple
const Color colorJ = Color(0xFFA855F7); // lightPurple
const Color colorL = Color(0xFF8B5CF6); // cloudBlue
const Color colorO = Color(0xFFEC4899); // accentPink
const Color colorS = Color(0xFF10B981); // mentalhealthGreen
const Color colorT = Color(0xFF2D1B69); // deepPurple
const Color colorZ = Color(0xFFFFB84D); // Amarillo cálido

// Colores Alegra unificados
class AppColors {
  // Paleta principal de Alegra
  static const Color deepPurple = Color(0xFF2D1B69);
  static const Color vibrantPurple = Color(0xFF6366F1);
  static const Color lightPurple = Color(0xFFA855F7);
  static const Color darkBackground = Color(0xFF0F0A1F);
  static const Color cardDark = Color(0xFF1A1335);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color softWhite = Color(0xFFF8FAFC);
  static const Color cloudBlue = Color(0xFF8B5CF6);
  static const Color mentalhealthGreen = Color(0xFF10B981);

  // Colores derivados para UI
  static Color getBackground(bool isDark) =>
      isDark ? darkBackground : softWhite;
  static Color getSurface(bool isDark) =>
      isDark ? cardDark.withOpacity(0.95) : Colors.white;
  static Color getCard(bool isDark) =>
      isDark ? cardDark.withOpacity(0.8) : lightPurple.withOpacity(0.05);
  static Color getBorder(bool isDark) =>
      isDark ? vibrantPurple.withOpacity(0.2) : deepPurple.withOpacity(0.1);
  static Color getTextPrimary(bool isDark) => isDark ? softWhite : deepPurple;
  static Color getTextSecondary(bool isDark) =>
      isDark ? softWhite.withOpacity(0.7) : deepPurple.withOpacity(0.7);
}

class TetrisApp extends StatefulWidget {
  const TetrisApp({super.key});

  @override
  State<TetrisApp> createState() => _TetrisAppState();
}

class _TetrisAppState extends State<TetrisApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TetrisGame(
      toggleTheme: toggleTheme,
      isDarkMode: _themeMode == ThemeMode.dark,
    );
  }
}

enum Tetromino { I, J, L, O, X, T, D }

class TetrisGame extends StatefulWidget {
  final Function(ThemeMode) toggleTheme;
  final bool isDarkMode;
  const TetrisGame({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  _TetrisGameState createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame> with TickerProviderStateMixin {
  static const int col = 12;
  static const int row = 22;

  Timer? timer;
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreAnimation;
  bool isGameOver = false;
  bool isPaused = false;
  int currentScore = 0;
  int linesCleared = 0;
  int level = 1;
  List<List<Color>> board = List.generate(
    row,
    (i) => List.generate(col, (j) => Colors.transparent),
  );
  Tetromino? currentPiece;
  List<int> currentPiecePosition = [];
  Color currentPieceColor = Colors.transparent;
  List<int> nextPiecePosition = [];
  Tetromino? nextPiece;
  Color nextPieceColor = Colors.transparent;
  final List<int> possibleRotations = [0, 45, 90, 135, 180, 225, 270, 315];
  int currentRotation = 0;

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    startGame();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _scoreAnimationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool _handleKeyEvent(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent && !isGameOver) {
      if (event.logicalKey == LogicalKeyboardKey.keyP ||
          event.logicalKey == LogicalKeyboardKey.escape) {
        pauseGame();
        return true;
      }

      if (!isPaused) {
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
            event.logicalKey == LogicalKeyboardKey.keyA) {
          movePieceLeft();
          return true;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
            event.logicalKey == LogicalKeyboardKey.keyD) {
          movePieceRight();
          return true;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
            event.logicalKey == LogicalKeyboardKey.keyS) {
          dropPiece();
          return true;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
            event.logicalKey == LogicalKeyboardKey.keyW ||
            event.logicalKey == LogicalKeyboardKey.space) {
          rotatePiece();
          return true;
        }
      }
    }
    return false;
  }

  void startGame() {
    if (!mounted) return;

    setState(() {
      board = List.generate(
        row,
        (i) => List.generate(col, (j) => Colors.transparent),
      );
      currentScore = 0;
      linesCleared = 0;
      level = 1;
      isGameOver = false;
      isPaused = false;
    });
    spawnNewPiece();
    generateNextPiece();
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(
      Duration(milliseconds: max(100, 600 - (level * 50))),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (isGameOver || isPaused) {
          return;
        } else {
          movePieceDown();
        }
      },
    );
  }

  void pauseGame() {
    if (!mounted) return;
    setState(() {
      isPaused = !isPaused;
    });
  }

  void generateNextPiece() {
    Random random = Random();
    nextPiece = Tetromino.values[random.nextInt(Tetromino.values.length)];
    switch (nextPiece!) {
      case Tetromino.I:
        nextPieceColor = colorI;
        break;
      case Tetromino.J:
        nextPieceColor = colorJ;
        break;
      case Tetromino.L:
        nextPieceColor = colorL;
        break;
      case Tetromino.O:
        nextPieceColor = colorO;
        break;
      case Tetromino.X:
        nextPieceColor = colorS;
        break;
      case Tetromino.T:
        nextPieceColor = colorT;
        break;
      case Tetromino.D:
        nextPieceColor = colorZ;
        break;
    }
  }

  void spawnNewPiece() {
    if (nextPiece != null) {
      currentPiece = nextPiece;
      currentPieceColor = nextPieceColor;
    } else {
      Random random = Random();
      currentPiece = Tetromino.values[random.nextInt(Tetromino.values.length)];
    }

    currentRotation = 0;
    currentPiecePosition.clear();

    switch (currentPiece!) {
      case Tetromino.I:
        currentPiecePosition = [4, 5, 6, 7];
        currentPieceColor = colorI;
        break;
      case Tetromino.J:
        currentPiecePosition = [3, 4, 5, 15];
        currentPieceColor = colorJ;
        break;
      case Tetromino.L:
        currentPiecePosition = [5, 6, 7, 15];
        currentPieceColor = colorL;
        break;
      case Tetromino.O:
        currentPiecePosition = [4, 5, 14, 15];
        currentPieceColor = colorO;
        break;
      case Tetromino.X:
        currentPiecePosition = [5, 6, 14, 15];
        currentPieceColor = colorS;
        break;
      case Tetromino.T:
        currentPiecePosition = [4, 5, 6, 15];
        currentPieceColor = colorT;
        break;
      case Tetromino.D:
        currentPiecePosition = [4, 5, 15, 16];
        currentPieceColor = colorZ;
        break;
    }

    generateNextPiece();

    if (!canMove(currentPiecePosition, 0)) {
      gameOver();
    }
  }

  void movePieceDown() {
    if (!mounted) return;

    if (canMove(currentPiecePosition, col)) {
      setState(() {
        for (int i = 0; i < currentPiecePosition.length; i++) {
          currentPiecePosition[i] += col;
        }
      });
    } else {
      landPiece();
    }
  }

  void movePieceLeft() {
    if (!mounted) return;

    if (canMove(currentPiecePosition, -1)) {
      setState(() {
        for (int i = 0; i < currentPiecePosition.length; i++) {
          currentPiecePosition[i] -= 1;
        }
      });
    }
  }

  void movePieceRight() {
    if (!mounted) return;

    if (canMove(currentPiecePosition, 1)) {
      setState(() {
        for (int i = 0; i < currentPiecePosition.length; i++) {
          currentPiecePosition[i] += 1;
        }
      });
    }
  }

  void dropPiece() {
    if (!mounted) return;

    while (canMove(currentPiecePosition, col)) {
      for (int i = 0; i < currentPiecePosition.length; i++) {
        currentPiecePosition[i] += col;
      }
    }
    setState(() {});
    landPiece();
  }

  void rotatePiece() {
    if (!mounted) return;

    if (currentPiece == Tetromino.O) return;

    List<int> newPosition = [];
    int pivot = currentPiecePosition[1];

    switch (currentPiece!) {
      case Tetromino.I:
        if (currentRotation == 0) {
          newPosition = [pivot - col, pivot, pivot + col, pivot + (2 * col)];
        } else {
          newPosition = [pivot - 1, pivot, pivot + 1, pivot + 2];
        }
        break;

      case Tetromino.T:
        switch (currentRotation) {
          case 0:
            newPosition = [pivot - col, pivot - 1, pivot, pivot + 1];
            break;
          case 1:
            newPosition = [pivot - col, pivot, pivot + 1, pivot + col];
            break;
          case 2:
            newPosition = [pivot - 1, pivot, pivot + 1, pivot + col];
            break;
          case 3:
            newPosition = [pivot - col, pivot - 1, pivot, pivot + col];
            break;
        }
        break;

      case Tetromino.L:
        switch (currentRotation) {
          case 0:
            newPosition = [pivot - col, pivot, pivot + col, pivot + col + 1];
            break;
          case 1:
            newPosition = [pivot - 1, pivot, pivot + 1, pivot - col + 1];
            break;
          case 2:
            newPosition = [pivot + col, pivot, pivot - col, pivot - col - 1];
            break;
          case 3:
            newPosition = [pivot + 1, pivot, pivot - 1, pivot + col - 1];
            break;
        }
        break;

      case Tetromino.J:
        switch (currentRotation) {
          case 0:
            newPosition = [pivot - col, pivot, pivot + col, pivot + col - 1];
            break;
          case 1:
            newPosition = [pivot - 1, pivot, pivot + 1, pivot - col - 1];
            break;
          case 2:
            newPosition = [pivot + col, pivot, pivot - col, pivot - col + 1];
            break;
          case 3:
            newPosition = [pivot + 1, pivot, pivot - 1, pivot + col + 1];
            break;
        }
        break;

      case Tetromino.X:
        if (currentRotation == 0 || currentRotation == 2) {
          newPosition = [pivot - col + 1, pivot - col, pivot, pivot + 1];
        } else {
          newPosition = [pivot - col, pivot, pivot + 1, pivot + col + 1];
        }
        break;

      case Tetromino.D:
        if (currentRotation == 0 || currentRotation == 2) {
          newPosition = [pivot - col - 1, pivot - col, pivot, pivot + 1];
        } else {
          newPosition = [pivot - col + 1, pivot, pivot + 1, pivot + col];
        }
        break;

      case Tetromino.O:
        break;
    }

    if (canMove(newPosition, 0)) {
      setState(() {
        currentPiecePosition = newPosition;
        currentRotation = (currentRotation + 1) % 4;
      });
    }
  }

  void landPiece() {
    if (!mounted) return;

    for (int position in currentPiecePosition) {
      int r = (position / col).floor();
      int c = position % col;
      board[r][c] = currentPieceColor;
    }
    checkLines();
    spawnNewPiece();
  }

  bool canMove(List<int> position, int direction) {
    for (int pos in position) {
      int nextPos = pos + direction;
      int r = (nextPos / col).floor();
      int c = nextPos % col;

      if (r < 0 ||
          r >= row ||
          c < 0 ||
          c >= col ||
          board[r][c] != Colors.transparent) {
        return false;
      }
    }
    return true;
  }

  void checkLines() {
    if (!mounted) return;

    int linesCleared = 0;
    for (int r = row - 1; r >= 0; r--) {
      bool isLineFull = true;
      for (int c = 0; c < col; c++) {
        if (board[r][c] == Colors.transparent) {
          isLineFull = false;
          break;
        }
      }
      if (isLineFull) {
        linesCleared++;
        for (int c = 0; c < col; c++) {
          board[r][c] = Colors.transparent;
        }
        for (int i = r; i > 0; i--) {
          for (int c = 0; c < col; c++) {
            board[i][c] = board[i - 1][c];
          }
        }
        r++;
      }
    }
    if (linesCleared > 0) {
      setState(() {
        this.linesCleared += linesCleared;
        currentScore += linesCleared * 100 * level;
        level = (this.linesCleared ~/ 10) + 1;
      });
      _scoreAnimationController.forward().then((_) {
        if (mounted) {
          _scoreAnimationController.reverse();
        }
      });

      timer?.cancel();
      startTimer();
    }
  }

  void gameOver() {
    if (!mounted) return;

    setState(() {
      isGameOver = true;
    });
    timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.getSurface(widget.isDarkMode),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: AppColors.vibrantPurple,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '¡Juego Terminado!',
                style: TextStyle(
                  color: AppColors.getTextPrimary(widget.isDarkMode),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.vibrantPurple, AppColors.lightPurple],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.sports_esports,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Puntuación Final',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextSecondary(widget.isDarkMode),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$currentScore',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.vibrantPurple,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.getCard(widget.isDarkMode),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '$linesCleared',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mentalhealthGreen,
                              ),
                            ),
                            Text(
                              'Líneas',
                              style: TextStyle(
                                color: AppColors.getTextSecondary(
                                  widget.isDarkMode,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '$level',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentPink,
                              ),
                            ),
                            Text(
                              'Nivel',
                              style: TextStyle(
                                color: AppColors.getTextSecondary(
                                  widget.isDarkMode,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.vibrantPurple, AppColors.lightPurple],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.vibrantPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.replay, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Jugar de Nuevo',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildSquare(Color color) {
    return Container(
      margin: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color:
            color == Colors.transparent
                ? (widget.isDarkMode
                    ? AppColors.cardDark.withOpacity(0.3)
                    : AppColors.lightPurple.withOpacity(0.05))
                : color,
        borderRadius: BorderRadius.circular(4),
        border:
            color != Colors.transparent
                ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                : Border.all(
                  color: AppColors.getBorder(widget.isDarkMode),
                  width: 0.5,
                ),
        boxShadow:
            color != Colors.transparent
                ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 2,
                    offset: const Offset(1, 1),
                  ),
                ]
                : null,
      ),
    );
  }

  Widget buildGrid() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.vibrantPurple.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.isDarkMode ? Colors.black : AppColors.vibrantPurple)
                .withOpacity(widget.isDarkMode ? 0.4 : 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient:
                widget.isDarkMode
                    ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.cardDark.withOpacity(0.95),
                        AppColors.darkBackground.withOpacity(0.95),
                      ],
                    )
                    : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, AppColors.softWhite],
                    ),
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: col,
            ),
            itemCount: col * row,
            itemBuilder: (context, index) {
              int r = (index / col).floor();
              int c = index % col;
              Color color = board[r][c];
              if (currentPiecePosition.contains(index)) {
                color = currentPieceColor;
              }
              return buildSquare(color);
            },
          ),
        ),
      ),
    );
  }

  Widget buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? label,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              color != null
                  ? [color, color.withOpacity(0.8)]
                  : [AppColors.vibrantPurple, AppColors.lightPurple],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (color ?? AppColors.vibrantPurple).withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            if (label != null) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(widget.isDarkMode),
      appBar: AppBar(
        backgroundColor: AppColors.getSurface(widget.isDarkMode),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.getTextPrimary(widget.isDarkMode),
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.vibrantPurple, AppColors.lightPurple],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.sports_esports, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Tetris Alegra',
              style: TextStyle(
                color: AppColors.getTextPrimary(widget.isDarkMode),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.getCard(widget.isDarkMode),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.getBorder(widget.isDarkMode)),
            ),
            child: IconButton(
              icon: Icon(
                widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color:
                    widget.isDarkMode
                        ? AppColors.accentPink
                        : AppColors.vibrantPurple,
              ),
              onPressed: () {
                widget.toggleTheme(
                  widget.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                );
              },
            ),
          ),
        ],
      ),
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (RawKeyEvent event) {
          _handleKeyEvent(_focusNode, event);
        },
        autofocus: true,
        child: GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient:
                      widget.isDarkMode
                          ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.darkBackground,
                              AppColors.deepPurple.withOpacity(0.2),
                            ],
                          )
                          : LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.softWhite,
                              AppColors.vibrantPurple.withOpacity(0.03),
                            ],
                          ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      // Información del juego compacta
                      Container(
                        height: 60,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.getCard(widget.isDarkMode),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.getBorder(
                                      widget.isDarkMode,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$currentScore',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.vibrantPurple,
                                      ),
                                    ),
                                    Text(
                                      'Puntos',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.getTextSecondary(
                                          widget.isDarkMode,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.getCard(widget.isDarkMode),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.getBorder(
                                      widget.isDarkMode,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$linesCleared',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.mentalhealthGreen,
                                          ),
                                        ),
                                        Text(
                                          'Líneas',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: AppColors.getTextSecondary(
                                              widget.isDarkMode,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$level',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.accentPink,
                                          ),
                                        ),
                                        Text(
                                          'Nivel',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: AppColors.getTextSecondary(
                                              widget.isDarkMode,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 50,
                              height: 60,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.getCard(widget.isDarkMode),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.getBorder(widget.isDarkMode),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Siguiente',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: AppColors.getTextSecondary(
                                        widget.isDarkMode,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: nextPieceColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: nextPieceColor.withOpacity(0.4),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.extension,
                                      size: 12,
                                      color: nextPieceColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tablero de juego
                      Expanded(
                        flex: 10,
                        child: AspectRatio(
                          aspectRatio: col / row,
                          child: buildGrid(),
                        ),
                      ),

                      // Controles del juego
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildControlButton(
                            icon: isPaused ? Icons.play_arrow : Icons.pause,
                            label: isPaused ? 'Reanudar' : 'Pausar',
                            onPressed: pauseGame,
                            color:
                                isPaused
                                    ? AppColors.mentalhealthGreen
                                    : AppColors.cloudBlue,
                          ),
                          buildControlButton(
                            icon: Icons.refresh,
                            label: 'Reiniciar',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      backgroundColor: AppColors.getSurface(
                                        widget.isDarkMode,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: Text(
                                        '¿Reiniciar juego?',
                                        style: TextStyle(
                                          color: AppColors.getTextPrimary(
                                            widget.isDarkMode,
                                          ),
                                        ),
                                      ),
                                      content: Text(
                                        'Se perderá el progreso actual',
                                        style: TextStyle(
                                          color: AppColors.getTextSecondary(
                                            widget.isDarkMode,
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            if (mounted)
                                              _focusNode.requestFocus();
                                          },
                                          child: Text(
                                            'Cancelar',
                                            style: TextStyle(
                                              color: AppColors.cloudBlue,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.accentPink,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            startGame();
                                            if (mounted)
                                              _focusNode.requestFocus();
                                          },
                                          child: const Text('Reiniciar'),
                                        ),
                                      ],
                                    ),
                              );
                            },
                            color: AppColors.accentPink,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Controles de movimiento
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildControlButton(
                            icon: Icons.keyboard_arrow_left,
                            onPressed:
                                isGameOver || isPaused ? () {} : movePieceLeft,
                          ),
                          buildControlButton(
                            icon: Icons.keyboard_arrow_down,
                            onPressed:
                                isGameOver || isPaused ? () {} : dropPiece,
                          ),
                          buildControlButton(
                            icon: Icons.rotate_right,
                            onPressed:
                                isGameOver || isPaused ? () {} : rotatePiece,
                          ),
                          buildControlButton(
                            icon: Icons.keyboard_arrow_right,
                            onPressed:
                                isGameOver || isPaused ? () {} : movePieceRight,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Instrucciones
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.getCard(widget.isDarkMode),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.getBorder(widget.isDarkMode),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.keyboard,
                                  size: 16,
                                  color: AppColors.vibrantPurple,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Controles de Teclado',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.getTextPrimary(
                                      widget.isDarkMode,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '← → ↑ ↓ • WASD • Espacio: rotar • P: pausar',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.getTextSecondary(
                                  widget.isDarkMode,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Overlay de pausa
              if (isPaused)
                Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      margin: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.getSurface(widget.isDarkMode),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.vibrantPurple.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.vibrantPurple.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.vibrantPurple,
                                  AppColors.lightPurple,
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.pause_circle_outline,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Juego Pausado',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.getTextPrimary(
                                widget.isDarkMode,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Presiona P o Escape para continuar',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.getTextSecondary(
                                widget.isDarkMode,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.vibrantPurple,
                                  AppColors.lightPurple,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.vibrantPurple.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                pauseGame();
                                if (mounted) _focusNode.requestFocus();
                              },
                              icon: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Reanudar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
