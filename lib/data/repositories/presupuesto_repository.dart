import '../../models/presupuesto.dart';
import '../local/app_database.dart';

class PresupuestoRepository {
  Future<List<Presupuesto>> obtenerTodos() async {
    final db = await AppDatabase.instance.database;
    final filas = await db.query('presupuestos');
    return filas.map(Presupuesto.fromMap).toList();
  }

  Future<void> insertar(Presupuesto p) async {
    final db = await AppDatabase.instance.database;
    await db.insert('presupuestos', p.toMap());
  }

  Future<void> actualizar(Presupuesto p) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'presupuestos',
      p.toMap(),
      where: 'id = ?',
      whereArgs: [p.id],
    );
  }

  Future<void> eliminar(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('presupuestos', where: 'id = ?', whereArgs: [id]);
  }
}
