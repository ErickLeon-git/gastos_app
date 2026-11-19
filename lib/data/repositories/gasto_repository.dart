import '../../core/cifrado_service.dart';
import '../../models/gasto.dart';
import '../local/app_database.dart';

class GastoRepository {
  // ---- Cifrado / descifrado ----

  Map<String, dynamic> _cifrarMapa(Gasto g, {int? sincronizado}) {
    final c = CifradoService.instance;
    final m = g.toMap();
    m['descripcion'] = c.cifrar(g.descripcion);
    if (g.rutaFoto != null) m['ruta_foto'] = c.cifrar(g.rutaFoto!);
    if (sincronizado != null) m['sincronizado'] = sincronizado;
    return m;
  }

  Gasto _descifrarFila(Map<String, dynamic> fila) {
    final c = CifradoService.instance;
    final m = Map<String, dynamic>.from(fila);
    m['descripcion'] = c.descifrar(m['descripcion'] as String);
    if (m['ruta_foto'] != null) {
      m['ruta_foto'] = c.descifrar(m['ruta_foto'] as String);
    }
    return Gasto.fromMap(m);
  }

  // ---- CRUD ----

  Future<List<Gasto>> obtenerTodos() async {
    final db = await AppDatabase.instance.database;
    final filas = await db.query('gastos', orderBy: 'fecha DESC');
    return filas.map(_descifrarFila).toList();
  }

  Future<void> insertar(Gasto gasto) async {
    final db = await AppDatabase.instance.database;
    await db.insert('gastos', _cifrarMapa(gasto));
  }

  Future<void> actualizar(Gasto gasto) async {
    final db = await AppDatabase.instance.database;
    // Al editar, vuelve a quedar pendiente de sincronizar
    await db.update(
      'gastos',
      _cifrarMapa(gasto, sincronizado: 0),
      where: 'id = ?',
      whereArgs: [gasto.id],
    );
  }

  Future<void> eliminar(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }

  // ---- Sincronización ----

  Future<List<Gasto>> obtenerPendientes() async {
    final db = await AppDatabase.instance.database;
    final filas = await db.query('gastos', where: 'sincronizado = 0');
    return filas.map(_descifrarFila).toList();
  }

  Future<void> marcarSincronizado(String id) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'gastos',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> existe(String id) async {
    final db = await AppDatabase.instance.database;
    final r = await db.query(
      'gastos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return r.isNotEmpty;
  }
}
