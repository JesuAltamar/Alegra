// widgets/weekly_streak_widget.dart
import 'package:flutter/material.dart';
import 'package:pro9/rachas/streak_provider.dart';
import 'package:provider/provider.dart';

class WeeklyStreakWidget extends StatelessWidget {
  final int userId;
  final bool isDarkMode;

  const WeeklyStreakWidget({
    Key? key,
    required this.userId,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 360;
    final isMobile = screenWidth < 800;
    final isTablet = screenWidth >= 800 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;

    // Colores de tu paleta
    final Color deepPurple = Color(0xFF2D1B69);
    final Color vibrantPurple = Color(0xFF6366F1);
    final Color lightPurple = Color(0xFFA855F7);
    final Color darkBackground = Color(0xFF0F0A1F);
    final Color cardDark = Color(0xFF1A1335);
    final Color accentPink = Color(0xFFEC4899);
    final Color softWhite = Color(0xFFF8FAFC);
    final Color mentalhealthGreen = Color(0xFF10B981);
    final Color goldenYellow = Color(0xFFFFD93D);

    return Consumer<StreakProvider>(
      builder: (context, streakProvider, child) {
        if (streakProvider.isLoading) {
          return Container(
            height: 120,
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? cardDark.withOpacity(0.8)
                      : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: vibrantPurple.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: vibrantPurple,
                strokeWidth: 2,
              ),
            ),
          );
        }

        final stats = streakProvider.stats;
        final rachaActual = stats?.rachaActual ?? 0;
        final rachaMaxima = stats?.rachaMaxima ?? 0;
        final completadaHoy = streakProvider.tareaCompletadaHoy;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isSmallMobile ? 10 : 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isDarkMode
                      ? [cardDark, deepPurple.withOpacity(0.8)]
                      : [softWhite, vibrantPurple.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: vibrantPurple.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: vibrantPurple.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título de la racha
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🔥',
                    style: TextStyle(fontSize: isSmallMobile ? 18 : 20),
                  ),
                  SizedBox(width: 6),
                  Text(
                    '¡$rachaActual Días de Racha!',
                    style: TextStyle(
                      fontSize: isSmallMobile ? 14 : 16,
                      fontWeight: FontWeight.w900,
                      color: isDarkMode ? softWhite : deepPurple,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              // Círculos de la semana
              _buildWeekDaysCircles(
                streakProvider.historial,
                isSmallMobile,
                isDarkMode,
                vibrantPurple,
                goldenYellow,
                deepPurple,
                softWhite,
              ),

              SizedBox(height: 10),

              // Botón de completar tarea
              if (!completadaHoy)
                Container(
                  width: double.infinity,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [vibrantPurple, lightPurple],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: vibrantPurple.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final success = await streakProvider
                            .completarTareaDiaria(userId);
                        if (success && context.mounted) {
                          await streakProvider.cargarHistorial(userId, dias: 7);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Text('🎉'),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      streakProvider.getMensajeMotivasional(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        } else if (streakProvider.error != null &&
                            context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(streakProvider.error!),
                              backgroundColor: Color(0xFFEC4899),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Center(
                        child: Text(
                          'Completar Tarea del Día',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF10B981).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Color(0xFF10B981).withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF10B981),
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '¡Tarea completada hoy!',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 8),

              // Récord personal
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: goldenYellow.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: goldenYellow.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events_rounded,
                      color: goldenYellow,
                      size: 14,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Récord: $rachaMaxima días',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? softWhite : deepPurple,
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

  Widget _buildWeekDaysCircles(
    List<dynamic> historial,
    bool isSmallMobile,
    bool isDarkMode,
    Color vibrantPurple,
    Color goldenYellow,
    Color deepPurple,
    Color softWhite,
  ) {
    final dias = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final now = DateTime.now();

    // Calcular qué días están completados en los últimos 7 días
    List<bool> diasCompletados = List.filled(7, false);

    for (int i = 0; i < 7; i++) {
      final dia = now.subtract(Duration(days: 6 - i));
      final diaStr =
          '${dia.year}-${dia.month.toString().padLeft(2, '0')}-${dia.day.toString().padLeft(2, '0')}';

      // Verificar si este día está en el historial
      final completado = historial.any((item) {
        if (item is Map && item.containsKey('fecha')) {
          final fechaItem = item['fecha'].toString();
          final tareaCompletada =
              item['tarea_completada'] == true || item['tarea_completada'] == 1;
          return fechaItem == diaStr && tareaCompletada;
        }
        return false;
      });

      diasCompletados[i] = completado;
    }

    final circleSize = isSmallMobile ? 26.0 : 28.0;
    final fontSize = isSmallMobile ? 10.0 : 11.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(7, (index) {
        final isCompleted = diasCompletados[index];

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallMobile ? 2 : 3),
          child: Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isCompleted
                      ? goldenYellow
                      : (isDarkMode
                          ? deepPurple.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2)),
              border: Border.all(
                color:
                    isCompleted
                        ? goldenYellow.withOpacity(0.8)
                        : vibrantPurple.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow:
                  isCompleted
                      ? [
                        BoxShadow(
                          color: goldenYellow.withOpacity(0.4),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ]
                      : [],
            ),
            child: Center(
              child: Text(
                dias[index],
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  color:
                      isCompleted
                          ? Colors.white
                          : (isDarkMode
                              ? softWhite.withOpacity(0.6)
                              : deepPurple.withOpacity(0.5)),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
