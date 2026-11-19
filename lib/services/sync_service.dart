import '../data/remote/gasto_remote.dart';
import '../data/repositories/gasto_repository.dart';

class ResultadoSync {
  final int subidos;
  final int descargados;
  final String? error;
  const ResultadoSync({this.subidos = 0, this.descargados = 0, this.error});
}

class SyncService {
  SyncService(this._local, this._remoto);
  final GastoRepository _local;
  final GastoRemote _remoto;

  Future<ResultadoSync> sincronizar() async {
    try {
      // 1. Subir pendientes
      final pendientes = await _local.obtenerPendientes();
      for (final g in pendientes) {
        await _remoto.subir(g);
        await _local.marcarSincronizado(g.id);
      }

      // 2. Descargar los que solo existen en la nube
      var descargados = 0;
      for (final g in await _remoto.descargar()) {
        if (!await _local.existe(g.id)) {
          await _local.insertar(g);
          descargados++;
        }
      }
      return ResultadoSync(
        subidos: pendientes.length,
        descargados: descargados,
      );
    } catch (_) {
      return const ResultadoSync(
        error: 'No se pudo sincronizar. Revisa tu conexión e intenta de nuevo.',
      );
    }
  }
}
