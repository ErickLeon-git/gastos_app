class Gasto {
  final String id;
  final double monto;
  final String descripcion;
  final DateTime fecha;
  final String categoriaId; // relación con Categoria
  final String? rutaFoto; // foto del ticket (opcional)
  final bool sincronizado; // para la sincronización con la nube

  const Gasto({
    required this.id,
    required this.monto,
    required this.descripcion,
    required this.fecha,
    required this.categoriaId,
    this.rutaFoto,
    this.sincronizado = false,
  });

  Gasto copyWith({
    double? monto,
    String? descripcion,
    DateTime? fecha,
    String? categoriaId,
    String? rutaFoto,
    bool? sincronizado,
  }) => Gasto(
    id: id,
    monto: monto ?? this.monto,
    descripcion: descripcion ?? this.descripcion,
    fecha: fecha ?? this.fecha,
    categoriaId: categoriaId ?? this.categoriaId,
    rutaFoto: rutaFoto ?? this.rutaFoto,
    sincronizado: sincronizado ?? this.sincronizado,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'monto': monto,
    'descripcion': descripcion,
    'fecha': fecha.toIso8601String(),
    'categoria_id': categoriaId,
    'ruta_foto': rutaFoto,
    'sincronizado': sincronizado ? 1 : 0,
  };

  factory Gasto.fromMap(Map<String, dynamic> map) => Gasto(
    id: map['id'] as String,
    monto: (map['monto'] as num).toDouble(),
    descripcion: map['descripcion'] as String,
    fecha: DateTime.parse(map['fecha'] as String),
    categoriaId: map['categoria_id'] as String,
    rutaFoto: map['ruta_foto'] as String?,
    sincronizado: (map['sincronizado'] as int) == 1,
  );
}
