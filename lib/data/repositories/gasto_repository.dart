import '../../models/gasto.dart';
import '../local/app_database.dart';

class GastoRepository {
  Future<List<Gasto>> obtenerTodos() async {
    final db = await AppDatabase.instance.database;
    final filas = await db.query('gastos', orderBy: 'fecha DESC');
    return filas.map(Gasto.fromMap).toList();
  }

  Future<void> insertar(Gasto gasto) async {
    final db = await AppDatabase.instance.database;
    await db.insert('gastos', gasto.toMap());
  }

  Future<void> actualizar(Gasto gasto) async {
    final db = await AppDatabase.instance.database;
    // Al editar, vuelve a quedar pendiente de sincronizar
    await db.update(
      'gastos',
      {...gasto.toMap(), 'sincronizado': 0},
      where: 'id = ?',
      whereArgs: [gasto.id],
    );
  }

  Future<void> eliminar(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }

  // ---- Métodos para la sincronización ----

  Future<List<Gasto>> obtenerPendientes() async {
    final db = await AppDatabase.instance.database;
    final filas = await db.query('gastos', where: 'sincronizado = 0');
    return filas.map(Gasto.fromMap).toList();
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
