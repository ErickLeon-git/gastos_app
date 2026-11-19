import 'package:flutter/foundation.dart';

import '../services/foto_service.dart';
import '../data/repositories/categoria_repository.dart';
import '../data/repositories/gasto_repository.dart';
import '../models/categoria.dart';
import '../models/gasto.dart';
import '../data/remote/gasto_remote.dart';
import '../services/sync_service.dart';

enum EstadoCarga { inicial, cargando, listo, error }

class GastoProvider extends ChangeNotifier {
  GastoProvider(this._gastoRepo, this._categoriaRepo);

  final GastoRepository _gastoRepo;
  final CategoriaRepository _categoriaRepo;

  List<Gasto> _gastos = [];
  List<Categoria> _categorias = [];
  EstadoCarga estado = EstadoCarga.inicial;
  String? mensajeError;

  List<Gasto> get gastos => _gastos;
  List<Categoria> get categorias => _categorias;
  double get total => _gastos.fold(0, (suma, g) => suma + g.monto);

  Categoria? categoriaDe(String id) {
    for (final c in _categorias) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> cargar() async {
    estado = EstadoCarga.cargando;
    notifyListeners();
    try {
      _categorias = await _categoriaRepo.obtenerTodas();
      _gastos = await _gastoRepo.obtenerTodos();
      estado = EstadoCarga.listo;
    } catch (e) {
      estado = EstadoCarga.error;
      mensajeError = 'No se pudieron cargar los gastos';
    }
    notifyListeners();
  }

  Future<bool> guardar(Gasto gasto, {required bool esNuevo}) async {
    try {
      if (esNuevo) {
        await _gastoRepo.insertar(gasto);
      } else {
        await _gastoRepo.actualizar(gasto);
      }
      await cargar();
      return true;
    } catch (e) {
      mensajeError = 'No se pudo guardar el gasto';
      estado = EstadoCarga.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> eliminar(String id) async {
    try {
      final gasto = _gastos.where((g) => g.id == id).firstOrNull;
      await _gastoRepo.eliminar(id);
      try {
        await GastoRemote().eliminar(id);
      } catch (_) {
        /* sin conexión: queda en la nube hasta la próxima limpieza */
      }
      await FotoService().borrar(gasto?.rutaFoto);
      await cargar();
    } catch (e) {
      mensajeError = 'No se pudo eliminar el gasto';
      estado = EstadoCarga.error;
      notifyListeners();
    }
  }

  bool sincronizando = false;
  String? mensajeSync;

  Future<void> sincronizar() async {
    sincronizando = true;
    mensajeSync = null;
    notifyListeners();

    final r = await SyncService(_gastoRepo, GastoRemote()).sincronizar();
    mensajeSync =
        r.error ??
        'Sincronizado: ${r.subidos} subidos, ${r.descargados} descargados';

    sincronizando = false;
    await cargar();
  }
}
