import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'gastos.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categorias (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        color INTEGER NOT NULL,
        icono TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE gastos (
        id TEXT PRIMARY KEY,
        monto REAL NOT NULL,
        descripcion TEXT NOT NULL,
        fecha TEXT NOT NULL,
        categoria_id TEXT NOT NULL,
        ruta_foto TEXT,
        sincronizado INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (categoria_id) REFERENCES categorias (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE presupuestos (
        id TEXT PRIMARY KEY,
        categoria_id TEXT NOT NULL,
        monto_limite REAL NOT NULL,
        periodo TEXT NOT NULL,
        FOREIGN KEY (categoria_id) REFERENCES categorias (id)
      )
    ''');

    // Categorías por defecto
    final defaults = [
      {
        'id': 'cat_comida',
        'nombre': 'Comida',
        'color': 0xFFE57373,
        'icono': 'restaurant',
      },
      {
        'id': 'cat_transporte',
        'nombre': 'Transporte',
        'color': 0xFF64B5F6,
        'icono': 'directions_bus',
      },
      {
        'id': 'cat_ocio',
        'nombre': 'Ocio',
        'color': 0xFFBA68C8,
        'icono': 'movie',
      },
      {
        'id': 'cat_salud',
        'nombre': 'Salud',
        'color': 0xFF81C784,
        'icono': 'favorite',
      },
      {
        'id': 'cat_otros',
        'nombre': 'Otros',
        'color': 0xFF90A4AE,
        'icono': 'category',
      },
    ];
    for (final c in defaults) {
      await db.insert('categorias', c);
    }
  }
}
