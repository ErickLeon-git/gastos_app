import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/presupuesto_estado.dart';
import '../providers/presupuesto_provider.dart';
import 'notificacion_service.dart';
import '../core/formato.dart';

class AlertaPresupuestoService {
  static const _storage = FlutterSecureStorage();

  /// Revisa los presupuestos y notifica al cruzar 80 % o 100 %.
  Future<void> evaluar(List<PresupuestoEstado> estados) async {
    final ahora = DateTime.now();
    for (final e in estados) {
      final nivel = e.porcentaje >= 1 ? 100 : (e.porcentaje >= 0.8 ? 80 : 0);
      if (nivel == 0) continue;

      final inicio = PresupuestoProvider.inicioPeriodo(
        e.presupuesto.periodo,
        ahora,
      );
      final clave = 'alerta_${e.presupuesto.id}_${inicio.toIso8601String()}';
      final previo = int.tryParse(await _storage.read(key: clave) ?? '') ?? 0;
      if (nivel <= previo) continue;

      final nombre = e.categoria?.nombre ?? 'una categoría';
      final titulo = nivel == 100
          ? 'Presupuesto superado: $nombre'
          : 'Presupuesto al 80 %: $nombre';
      final cuerpo =
          'Llevas ${Formato.moneda(e.gastado)} de ${Formato.moneda(e.presupuesto.montoLimite)}.';

      await NotificacionService.instance.mostrar(
        e.presupuesto.id.hashCode & 0x7fffffff,
        titulo,
        cuerpo,
      );
      await _storage.write(key: clave, value: nivel.toString());
    }
  }
}
