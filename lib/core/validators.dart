class Validators {
  static double? parseMonto(String texto) =>
      double.tryParse(texto.trim().replaceAll(',', '.'));

  static String? monto(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Ingresa un monto';
    final n = parseMonto(valor);
    if (n == null) return 'Monto no válido';
    if (n <= 0) return 'El monto debe ser mayor a 0';
    if (n > 1000000) return 'El monto es demasiado alto';
    return null;
  }

  static String? descripcion(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Ingresa una descripción';
    if (v.length > 100) return 'Máximo 100 caracteres';
    return null;
  }
}
