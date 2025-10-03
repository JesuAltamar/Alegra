// widgets/mood_checkin_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/local_storage_service.dart';
import '../models/mood_entry.dart';

class MoodCheckInWidget extends StatefulWidget {
  final bool isDarkMode;
  final Color deepPurple;
  final Color vibrantPurple;
  final Color lightPurple;
  final Color darkBackground;
  final Color cardDark;
  final Color accentPink;
  final Color softWhite;
  final Color mentalhealthGreen;

  const MoodCheckInWidget({
    super.key,
    required this.isDarkMode,
    required this.deepPurple,
    required this.vibrantPurple,
    required this.lightPurple,
    required this.darkBackground,
    required this.cardDark,
    required this.accentPink,
    required this.softWhite,
    required this.mentalhealthGreen,
  });

  @override
  State<MoodCheckInWidget> createState() => _MoodCheckInWidgetState();
}

class _MoodCheckInWidgetState extends State<MoodCheckInWidget> {
  int? _selectedMood;
  bool _hasCheckedIn = false;
  MoodEntry? _todayEntry;
  double _weeklyAverage = 0;
  final TextEditingController _noteController = TextEditingController();
  List<String> _selectedEmotions = [];

  final List<Map<String, dynamic>> moods = [
    {'level': 1, 'emoji': '😢', 'label': 'Muy mal', 'color': Color(0xFFEF4444)},
    {'level': 2, 'emoji': '😔', 'label': 'Mal', 'color': Color(0xFFF97316)},
    {'level': 3, 'emoji': '😐', 'label': 'Normal', 'color': Color(0xFFFBBF24)},
    {'level': 4, 'emoji': '😊', 'label': 'Bien', 'color': Color(0xFF10B981)},
    {'level': 5, 'emoji': '😄', 'label': 'Muy bien', 'color': Color(0xFF06B6D4)},
  ];

  final List<String> emotions = [
    'Ansioso',
    'Tranquilo',
    'Estresado',
    'Motivado',
    'Triste',
    'Feliz',
    'Cansado',
    'Energético',
    'Frustrado',
    'Esperanzado',
    'Abrumado',
    'Agradecido',
  ];

  final List<String> reflectionQuestions = [
    '¿Qué te hace sentir agradecido hoy?',
    '¿Qué pequeño logro conseguiste hoy?',
    '¿Cómo te cuidaste hoy?',
    '¿Qué aprendiste de ti mismo hoy?',
    '¿Qué te hizo sonreír hoy?',
    '¿Qué desafío enfrentaste hoy?',
    '¿Qué te gustaría mejorar mañana?',
  ];

  String _todayQuestion = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    _todayQuestion = reflectionQuestions[DateTime.now().day % reflectionQuestions.length];
  }

  Future<void> _loadData() async {
    final hasCheckedIn = await LocalStorageService.hasCheckedInToday();
    final todayEntry = await LocalStorageService.getTodayMoodEntry();
    final weeklyAvg = await LocalStorageService.getWeeklyAverageMood();

    setState(() {
      _hasCheckedIn = hasCheckedIn;
      _todayEntry = todayEntry;
      _weeklyAverage = weeklyAvg;
      
      if (todayEntry != null) {
        _selectedMood = todayEntry.moodLevel;
        _selectedEmotions = todayEntry.emotions;
        _noteController.text = todayEntry.note ?? '';
      }
    });
  }

  Future<void> _saveMoodEntry() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor selecciona tu estado de ánimo'),
          backgroundColor: widget.accentPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final entry = MoodEntry(
      date: DateTime.now(),
      moodLevel: _selectedMood!,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      emotions: _selectedEmotions,
    );

    await LocalStorageService.saveMoodEntry(entry);
    await _loadData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Check-in guardado correctamente'),
        backgroundColor: widget.mentalhealthGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? widget.cardDark.withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: widget.vibrantPurple.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: widget.vibrantPurple.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.vibrantPurple, widget.lightPurple],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: widget.vibrantPurple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.mood, color: widget.softWhite, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasCheckedIn ? 'Tu Check-in de Hoy' : '¿Cómo te sientes hoy?',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.w700,
                        color: widget.isDarkMode ? widget.softWhite : widget.deepPurple,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, d MMMM', 'es_ES').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.isDarkMode
                            ? Colors.grey[300]
                            : widget.deepPurple.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (_weeklyAverage > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.mentalhealthGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.mentalhealthGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up, color: widget.mentalhealthGreen, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _weeklyAverage.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: widget.mentalhealthGreen,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Selector de estado de ánimo
          Text(
            'Selecciona tu estado de ánimo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode ? widget.softWhite : widget.deepPurple,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: moods.map((mood) {
              final isSelected = _selectedMood == mood['level'];
              return InkWell(
                onTap: _hasCheckedIn
                    ? null
                    : () {
                        setState(() {
                          _selectedMood = mood['level'] as int;
                        });
                      },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: isMobile ? 60 : 70,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (mood['color'] as Color).withOpacity(0.15)
                        : widget.isDarkMode
                            ? widget.cardDark.withOpacity(0.5)
                            : widget.vibrantPurple.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? mood['color'] as Color
                          : widget.vibrantPurple.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        mood['emoji'] as String,
                        style: TextStyle(fontSize: isMobile ? 28 : 32),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mood['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? mood['color'] as Color
                              : widget.isDarkMode
                                  ? Colors.grey[400]
                                  : widget.deepPurple.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Selector de emociones
          Text(
            '¿Qué emociones sientes? (opcional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode ? widget.softWhite : widget.deepPurple,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: emotions.map((emotion) {
              final isSelected = _selectedEmotions.contains(emotion);
              return InkWell(
                onTap: _hasCheckedIn
                    ? null
                    : () {
                        setState(() {
                          if (isSelected) {
                            _selectedEmotions.remove(emotion);
                          } else {
                            _selectedEmotions.add(emotion);
                          }
                        });
                      },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? widget.lightPurple.withOpacity(0.15)
                        : widget.isDarkMode
                            ? widget.cardDark.withOpacity(0.5)
                            : widget.vibrantPurple.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? widget.lightPurple
                          : widget.vibrantPurple.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    emotion,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? widget.lightPurple
                          : widget.isDarkMode
                              ? Colors.grey[300]
                              : widget.deepPurple.withOpacity(0.7),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Pregunta reflexiva
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.mentalhealthGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: widget.mentalhealthGreen.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        color: widget.mentalhealthGreen, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reflexión del día',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: widget.mentalhealthGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _todayQuestion,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: widget.isDarkMode
                        ? Colors.grey[300]
                        : widget.deepPurple.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  enabled: !_hasCheckedIn,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.isDarkMode ? widget.softWhite : widget.deepPurple,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Escribe tus pensamientos...',
                    hintStyle: TextStyle(
                      color: widget.isDarkMode
                          ? Colors.grey[500]
                          : widget.deepPurple.withOpacity(0.4),
                    ),
                    filled: true,
                    fillColor: widget.isDarkMode
                        ? widget.darkBackground.withOpacity(0.5)
                        : Colors.white.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: widget.vibrantPurple.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: widget.vibrantPurple.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: widget.vibrantPurple,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (!_hasCheckedIn) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.vibrantPurple, widget.lightPurple],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.vibrantPurple.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _saveMoodEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: widget.softWhite, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Guardar Check-in',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: widget.softWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.mentalhealthGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.mentalhealthGreen.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: widget.mentalhealthGreen, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ya completaste tu check-in hoy. ¡Sigue así!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: widget.mentalhealthGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}