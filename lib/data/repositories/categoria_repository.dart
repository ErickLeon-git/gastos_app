import '../../models/categoria.dart';
import '../local/app_database.dart';

class CategoriaRepository {
  Future<List<Categoria>> obtenerTodas() async {
    final db = await AppDatabase.instance.database;
    final filas = await db.query('categorias', orderBy: 'nombre');
    return filas.map(Categoria.fromMap).toList();
  }
}
