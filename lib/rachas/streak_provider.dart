// providers/streak_provider.dart
import 'package:flutter/material.dart';
import 'package:pro9/rachas/streak_models.dart';
import 'package:pro9/rachas/streak_service.dart';

class StreakProvider with ChangeNotifier {
  final StreakService _streakService = StreakService();
  
  StreakStats? _stats;
  bool _isLoading = false;
  bool _tareaCompletadaHoy = false;
  String? _error;
  List<StreakHistorialItem> _historial = [];

  StreakStats? get stats => _stats;
  bool get isLoading => _isLoading;
  bool get tareaCompletadaHoy => _tareaCompletadaHoy;
  String? get error => _error;
  List<StreakHistorialItem> get historial => _historial;

  // Cargar racha del usuario
  Future<void> cargarRacha(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await _streakService.obtenerRacha(userId);
      _tareaCompletadaHoy = await _streakService.yaCompletoHoy(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Completar tarea diaria
  Future<bool> completarTareaDiaria(int userId) async {
    if (_tareaCompletadaHoy) {
      _error = 'Ya completaste tu tarea de hoy';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _streakService.completarTarea(userId);
      
      if (result['success'] == true) {
        // Actualizar estadísticas localmente
        _stats = StreakStats(
          rachaActual: result['racha_actual'],
          rachaMaxima: result['racha_maxima'],
          ultimaActividad: DateTime.now(),
        );
        _tareaCompletadaHoy = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cargar historial
  Future<void> cargarHistorial(int userId, {int dias = 30}) async {
    try {
      _historial = await _streakService.obtenerHistorial(userId, dias: dias);
      notifyListeners();
    } catch (e) {
      print('Error cargando historial: $e');
    }
  }

  // Resetear estado
  void reset() {
    _stats = null;
    _isLoading = false;
    _tareaCompletadaHoy = false;
    _error = null;
    _historial = [];
    notifyListeners();
  }

  // Obtener mensaje motivacional
  String getMensajeMotivasional() {
    if (_stats == null) return '';
    
    final racha = _stats!.rachaActual;
    
    if (racha == 0) {
      return '¡Comienza tu racha hoy!';
    } else if (racha == 1) {
      return '¡Buen comienzo! Primer día 🎯';
    } else if (racha < 7) {
      return '¡Vas bien! $racha días 💪';
    } else if (racha == 7) {
      return '¡Una semana completa! 🌟';
    } else if (racha < 30) {
      return '¡Imparable! $racha días 🔥';
    } else if (racha == 30) {
      return '¡UN MES ENTERO! 🏆';
    } else {
      return '¡LEYENDA! $racha días 👑';
    }
  }
}