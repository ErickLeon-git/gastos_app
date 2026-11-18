enum PeriodoPresupuesto { semanal, mensual }

class Presupuesto {
  final String id;
  final String categoriaId; // relación con Categoria
  final double montoLimite;
  final PeriodoPresupuesto periodo;

  const Presupuesto({
    required this.id,
    required this.categoriaId,
    required this.montoLimite,
    required this.periodo,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'categoria_id': categoriaId,
    'monto_limite': montoLimite,
    'periodo': periodo.name,
  };

  factory Presupuesto.fromMap(Map<String, dynamic> map) => Presupuesto(
    id: map['id'] as String,
    categoriaId: map['categoria_id'] as String,
    montoLimite: (map['monto_limite'] as num).toDouble(),
    periodo: PeriodoPresupuesto.values.byName(map['periodo'] as String),
  );
}
