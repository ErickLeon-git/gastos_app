import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificacionService {
  NotificacionService._();
  static final NotificacionService instance = NotificacionService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _listo = false;

  static const _canal = AndroidNotificationDetails(
    'presupuestos',
    'Alertas de presupuesto',
    channelDescription: 'Avisos cuando te acercas al límite de un presupuesto',
    importance: Importance.high,
    priority: Priority.high,
  );
  static const _detalles = NotificationDetails(android: _canal);

  Future<void> init() async {
    if (_listo) return;
    tz.initializeTimeZones();
    try {
      final zona = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zona.identifier));
    } catch (e) {
      debugPrint('No se pudo obtener la zona horaria: $e');
    }

    const ajustes = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: ajustes);

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    _listo = true;
  }

  /// Notificación inmediata (alerta de presupuesto).
  Future<void> mostrar(int id, String titulo, String cuerpo) async {
    if (!_listo) return;
    await _plugin.show(
      id: id,
      title: titulo,
      body: cuerpo,
      notificationDetails: _detalles,
    );
  }

  /// Recordatorio semanal programado (lunes a las 9:00).
  Future<void> programarRecordatorioSemanal() async {
    if (!_listo) return;
    final ahora = tz.TZDateTime.now(tz.local);
    var fecha = tz.TZDateTime(tz.local, ahora.year, ahora.month, ahora.day, 9);
    while (fecha.weekday != DateTime.monday || fecha.isBefore(ahora)) {
      fecha = fecha.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      id: 9000,
      title: 'Revisa tus gastos',
      body: 'Empieza la semana: registra tus gastos y revisa tus presupuestos.',
      scheduledDate: fecha,
      notificationDetails: _detalles,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }
}
