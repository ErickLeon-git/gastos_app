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

  static String? email(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Ingresa tu correo';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(v)) return 'Correo no válido';
    return null;
  }

  static String? password(String? valor) {
    final v = valor ?? '';
    if (v.isEmpty) return 'Ingresa tu contraseña';
    if (v.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Debe incluir un número';
    return null;
  }

  static String? limite(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Ingresa un límite';
    final n = parseMonto(valor);
    if (n == null) return 'Monto no válido';
    if (n <= 0) return 'Debe ser mayor a 0';
    if (n > 10000000) return 'El límite es demasiado alto';
    return null;
  }
}
