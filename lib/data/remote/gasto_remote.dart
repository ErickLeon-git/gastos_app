import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/gasto.dart';

class GastoRemote {
  final _client = Supabase.instance.client;

  Future<void> subir(Gasto g) async {
    await _client.from('gastos').upsert({
      'id': g.id,
      'monto': g.monto,
      'descripcion': g.descripcion,
      'fecha': g.fecha.toUtc().toIso8601String(),
      'categoria_id': g.categoriaId,
    });
  }

  Future<void> eliminar(String id) async {
    await _client.from('gastos').delete().eq('id', id);
  }

  Future<List<Gasto>> descargar() async {
    final filas = await _client.from('gastos').select();
    return filas
        .map(
          (m) => Gasto(
            id: m['id'] as String,
            monto: (m['monto'] as num).toDouble(),
            descripcion: m['descripcion'] as String,
            fecha: DateTime.parse(m['fecha'] as String).toLocal(),
            categoriaId: m['categoria_id'] as String,
            sincronizado: true,
          ),
        )
        .toList();
  }
}
