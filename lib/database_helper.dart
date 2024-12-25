import 'package:proyek_todolist/todo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    // Mendapatkan direktori penyimpanan aplikasi
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'todolist.db');

    // Membuka database dan membuatnya jika belum ada
    var localDb = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    return localDb;
  }

  // Fungsi untuk membuat tabel database
  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        deskripsi TEXT NOT NULL,
        done INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // Mendapatkan semua todo dari database
  Future<List<Todo>> getAllTodos() async {
    var dbClient = await db;
    if (dbClient == null) throw Exception("Database tidak ditemukan");
    var todos = await dbClient.query('todos', orderBy: 'id DESC');
    return todos.map((todo) => Todo.fromMap(todo)).toList();
  }

  // Mencari todo berdasarkan nama (pencarian)
  Future<List<Todo>> searchTodo(String keyword) async {
    var dbClient = await db;
    if (dbClient == null) throw Exception("Database tidak ditemukan");
    var todos = await dbClient.query(
      'todos',
      where: 'nama LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'id DESC',
    );
    return todos.map((todo) => Todo.fromMap(todo)).toList();
  }

  // Menambahkan todo baru
  Future<int> addTodo(Todo todo) async {
    var dbClient = await db;
    if (dbClient == null) throw Exception("Database tidak ditemukan");
    return await dbClient.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Memperbarui todo berdasarkan id
  Future<int> updateTodo(Todo todo) async {
    var dbClient = await db;
    if (dbClient == null) throw Exception("Database tidak ditemukan");
    return await dbClient.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // Menghapus todo berdasarkan id
  Future<int> deleteTodo(int id) async {
    var dbClient = await db;
    if (dbClient == null) throw Exception("Database tidak ditemukan");
    return await dbClient.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
