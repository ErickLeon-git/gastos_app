import 'categoria.dart';
import 'presupuesto.dart';

class PresupuestoEstado {
  final Presupuesto presupuesto;
  final Categoria? categoria;
  final double gastado;

  const PresupuestoEstado({
    required this.presupuesto,
    required this.categoria,
    required this.gastado,
  });

  double get porcentaje =>
      presupuesto.montoLimite == 0 ? 0 : gastado / presupuesto.montoLimite;
}
