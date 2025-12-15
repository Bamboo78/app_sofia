import 'dart:async';
import 'package:flutter/foundation.dart';
import '../db/avisos_database.dart';

class AvisosService {
  static final AvisosService _instance = AvisosService._internal();
  Timer? _monitoringTimer;

  factory AvisosService() {
    return _instance;
  }

  AvisosService._internal();

  /// Inicia el monitoreo de avisos
  void startMonitoring() {
    if (_monitoringTimer != null && _monitoringTimer!.isActive) {
      return; // Ya está corriendo
    }

    // Verificar cada minuto si se deben enviar alertas
    _monitoringTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await _checkAndSendAlerts();
    });

    if (kDebugMode) {
      print('Monitoreo de avisos iniciado');
    }
  }

  /// Detiene el monitoreo de avisos
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    if (kDebugMode) {
      print('Monitoreo de avisos detenido');
    }
  }

  /// Verifica y envía alertas si es necesario
  Future<void> _checkAndSendAlerts() async {
    try {
      final avisos = await AvisosDatabase.getActivados();
      final now = DateTime.now();

      for (final aviso in avisos) {
        final horaInicio = aviso['horaInicio'] as String; // HH:00
        final horaFinal = aviso['horaFinal'] as String; // HH:00
        final intervaloMinutos = (aviso['intervalo'] as int) * 60; // Convertir horas a minutos
        final lastUsedTimeStr = aviso['lastUsedTime'] as String?;

        // Verificar si estamos dentro del rango de horas
        if (_isWithinTimeRange(now, horaInicio, horaFinal)) {
          // Parsear última vez que se usó
          DateTime? lastUsedTime;
          if (lastUsedTimeStr != null) {
            try {
              lastUsedTime = DateTime.parse(lastUsedTimeStr);
            } catch (e) {
              if (kDebugMode) {
                print('Error parsing lastUsedTime: $e');
              }
            }
          }

          // Si no se ha usado o ha pasado el intervalo
          if (lastUsedTime == null || 
              now.difference(lastUsedTime).inMinutes >= intervaloMinutos) {
            // Enviar alerta por WhatsApp
            await _sendAlert(aviso);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error en checkAndSendAlerts: $e');
      }
    }
  }

  /// Verifica si la hora actual está dentro del rango especificado
  bool _isWithinTimeRange(DateTime now, String horaInicio, String horaFinal) {
    try {
      // Parsear las horas (formato HH:00)
      final startHour = int.parse(horaInicio.split(':')[0]);
      final endHour = int.parse(horaFinal.split(':')[0]);
      final currentHour = now.hour;

      // Comparar horas
      if (startHour <= endHour) {
        return currentHour >= startHour && currentHour < endHour;
      } else {
        // Caso cuando el rango cruza la medianoche (ej: 22:00 a 06:00)
        return currentHour >= startHour || currentHour < endHour;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing hours: $e');
      }
      return false;
    }
  }

  /// Envía una alerta por WhatsApp
  Future<void> _sendAlert(Map<String, dynamic> aviso) async {
    try {
      final telefono = aviso['telefonoContacto'] as String;
      final mensaje = aviso['mensaje'] as String;
      final id = aviso['id'] as int;

      // Enviar mensaje por WhatsApp
      await AvisosDatabase.enviarMensajeWhatsApp(telefono, mensaje);

      // Actualizar el lastUsedTime para no enviar múltiples mensajes
      await AvisosDatabase.updateLastUsedTime(id);

      if (kDebugMode) {
        print('Alerta enviada: ID=$id, Teléfono=$telefono');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error enviando alerta: $e');
      }
    }
  }
}
