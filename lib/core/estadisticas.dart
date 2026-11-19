import '../models/categoria.dart';
import '../models/gasto.dart';

class PorCategoria {
  final Categoria? categoria;
  final double total;
  const PorCategoria(this.categoria, this.total);
}

class Estadisticas {
  /// Gasto del mes actual agrupado por categoría (mayor a menor).
  static List<PorCategoria> porCategoriaDelMes(
    List<Gasto> gastos,
    List<Categoria> categorias,
  ) {
    final ahora = DateTime.now();
    final mapa = <String, double>{};
    for (final g in gastos) {
      if (g.fecha.year == ahora.year && g.fecha.month == ahora.month) {
        mapa[g.categoriaId] = (mapa[g.categoriaId] ?? 0) + g.monto;
      }
    }
    final lista = mapa.entries.map((e) {
      Categoria? cat;
      for (final c in categorias) {
        if (c.id == e.key) cat = c;
      }
      return PorCategoria(cat, e.value);
    }).toList();
    lista.sort((a, b) => b.total.compareTo(a.total));
    return lista;
  }

  /// Total gastado por día en los últimos 7 días (el último es hoy).
  static List<double> ultimosSieteDias(List<Gasto> gastos) {
    final hoy = DateTime.now();
    final base = DateTime(hoy.year, hoy.month, hoy.day);
    return List.generate(7, (i) {
      final dia = base.subtract(Duration(days: 6 - i));
      return gastos
          .where(
            (g) =>
                g.fecha.year == dia.year &&
                g.fecha.month == dia.month &&
                g.fecha.day == dia.day,
          )
          .fold<double>(0, (s, g) => s + g.monto);
    });
  }
}
