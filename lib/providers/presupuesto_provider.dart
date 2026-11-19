import 'package:flutter/foundation.dart';

import '../data/repositories/presupuesto_repository.dart';
import '../models/categoria.dart';
import '../models/gasto.dart';
import '../models/presupuesto.dart';
import '../models/presupuesto_estado.dart';
import 'gasto_provider.dart';

class PresupuestoProvider extends ChangeNotifier {
  PresupuestoProvider(this._repo);

  final PresupuestoRepository _repo;

  List<Presupuesto> _presupuestos = [];
  EstadoCarga estado = EstadoCarga.inicial;
  String? mensajeError;

  List<Presupuesto> get presupuestos => _presupuestos;

  Future<void> cargar() async {
    estado = EstadoCarga.cargando;
    notifyListeners();
    try {
      _presupuestos = await _repo.obtenerTodos();
      estado = EstadoCarga.listo;
    } catch (_) {
      estado = EstadoCarga.error;
      mensajeError = 'No se pudieron cargar los presupuestos';
    }
    notifyListeners();
  }

  Future<bool> guardar(Presupuesto p, {required bool esNuevo}) async {
    try {
      esNuevo ? await _repo.insertar(p) : await _repo.actualizar(p);
      await cargar();
      return true;
    } catch (_) {
      mensajeError = 'No se pudo guardar el presupuesto';
      notifyListeners();
      return false;
    }
  }

  Future<void> eliminar(String id) async {
    try {
      await _repo.eliminar(id);
      await cargar();
    } catch (_) {
      mensajeError = 'No se pudo eliminar el presupuesto';
      estado = EstadoCarga.error;
      notifyListeners();
    }
  }

  /// Inicio del periodo actual (lunes para semanal, día 1 para mensual).
  static DateTime inicioPeriodo(PeriodoPresupuesto periodo, DateTime ahora) {
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    return periodo == PeriodoPresupuesto.semanal
        ? hoy.subtract(Duration(days: hoy.weekday - 1))
        : DateTime(ahora.year, ahora.month, 1);
  }

  /// Combina presupuestos con lo gastado en su periodo actual.
  List<PresupuestoEstado> calcular(
    List<Gasto> gastos,
    List<Categoria> categorias,
  ) {
    final ahora = DateTime.now();
    return _presupuestos.map((p) {
      final inicio = inicioPeriodo(p.periodo, ahora);
      final gastado = gastos
          .where(
            (g) => g.categoriaId == p.categoriaId && !g.fecha.isBefore(inicio),
          )
          .fold<double>(0, (s, g) => s + g.monto);
      Categoria? cat;
      for (final c in categorias) {
        if (c.id == p.categoriaId) cat = c;
      }
      return PresupuestoEstado(
        presupuesto: p,
        categoria: cat,
        gastado: gastado,
      );
    }).toList();
  }
}
