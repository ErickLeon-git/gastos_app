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
    await db.update(
      'gastos',
      gasto.toMap(),
      where: 'id = ?',
      whereArgs: [gasto.id],
    );
  }

  Future<void> eliminar(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }
}
