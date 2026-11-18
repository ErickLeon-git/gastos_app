class Categoria {
  final String id;
  final String nombre;
  final int colorValue; // color guardado como entero
  final String icono; // nombre del icono, ej. "restaurant"

  const Categoria({
    required this.id,
    required this.nombre,
    required this.colorValue,
    required this.icono,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'color': colorValue,
    'icono': icono,
  };

  factory Categoria.fromMap(Map<String, dynamic> map) => Categoria(
    id: map['id'] as String,
    nombre: map['nombre'] as String,
    colorValue: map['color'] as int,
    icono: map['icono'] as String,
  );
}
