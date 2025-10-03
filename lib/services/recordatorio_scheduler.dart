import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/email_service.dart';

class RecordatorioScheduler {
  static final Map<String, Timer> _timers = {};
  static int get recordatoriosActivos => _timers.length;

  /// Programar un recordatorio
  static Future<void> programarRecordatorio({
    required Map<String, dynamic> tarea,
    required Function() onEnviado,
    required Function(String) onError,
  }) async {
    try {
      final tareaId = tarea['id']?.toString();
      if (tareaId == null) {
        throw Exception('ID de tarea es requerido');
      }

      // Verificar que el servicio de email está configurado
      if (!EmailService.isConfigured) {
        throw Exception('Servicio de email no está configurado');
      }

      // Obtener fecha y hora del recordatorio
      final fechaRecordatorio = tarea['fecha_recordatorio']?.toString();
      final horaRecordatorio = tarea['hora_recordatorio']?.toString();
      final emailRecordatorio = tarea['email_recordatorio']?.toString();

      if (fechaRecordatorio == null ||
          horaRecordatorio == null ||
          emailRecordatorio == null) {
        throw Exception('Datos de recordatorio incompletos');
      }

      // Parsear fecha y hora
      final fecha = DateTime.parse(fechaRecordatorio);
      final horaParts = horaRecordatorio.split(':');
      final hora = int.parse(horaParts[0]);
      final minuto = int.parse(horaParts[1]);

      final fechaHoraRecordatorio = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        hora,
        minuto,
      );

      final ahora = DateTime.now();

      if (fechaHoraRecordatorio.isBefore(ahora)) {
        throw Exception('La fecha/hora del recordatorio ya pasó');
      }

      final duracion = fechaHoraRecordatorio.difference(ahora);

      debugPrint(
        '🕐 Programando recordatorio para tarea $tareaId en ${duracion.inMinutes} minutos',
      );

      // Cancelar recordatorio existente si existe
      cancelarRecordatorio(tareaId);

      // Crear nuevo timer
      _timers[tareaId] = Timer(duracion, () async {
        try {
          debugPrint('📧 Enviando recordatorio para tarea $tareaId');

          await EmailService.enviarRecordatorio(
            email: emailRecordatorio,
            tarea: tarea,
          );

          // Remover timer completado
          _timers.remove(tareaId);
          onEnviado();
        } catch (e) {
          debugPrint('❌ Error enviando recordatorio: $e');
          _timers.remove(tareaId);
          onError(e.toString());
        }
      });

      debugPrint('✅ Recordatorio programado para tarea $tareaId');
    } catch (e) {
      debugPrint('❌ Error programando recordatorio: $e');
      onError(e.toString());
    }
  }

  /// Cancelar un recordatorio específico
  static void cancelarRecordatorio(String tareaId) {
    final timer = _timers[tareaId];
    if (timer != null) {
      timer.cancel();
      _timers.remove(tareaId);
      debugPrint('🚫 Recordatorio cancelado para tarea $tareaId');
    }
  }

  /// Cancelar todos los recordatorios
  static void cancelarTodosLosRecordatorios() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    debugPrint('🚫 Todos los recordatorios cancelados');
  }

  /// Verificar si una tarea tiene recordatorio activo
  static bool tieneRecordatorioActivo(String tareaId) {
    return _timers.containsKey(tareaId);
  }

  /// Obtener información de recordatorios activos
  static Map<String, String> getRecordatoriosInfo() {
    final info = <String, String>{};
    for (final entry in _timers.entries) {
      info[entry.key] = 'Activo';
    }
    return info;
  }
}
