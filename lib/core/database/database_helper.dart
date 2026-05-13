import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  static const String databaseName = 'ninaivu.db';
  static const int databaseVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, databaseName);

    return openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        business_id TEXT NOT NULL,
        name TEXT NOT NULL,
        mobile TEXT,
        email TEXT,
        role TEXT NOT NULL,
        status TEXT NOT NULL,
        profile_completed INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        sync_status TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_users_business_id ON users(business_id)',
    );

    await db.execute('CREATE INDEX idx_users_role ON users(role)');

    await db.execute('CREATE INDEX idx_users_mobile ON users(mobile)');

    await db.execute('CREATE INDEX idx_users_email ON users(email)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations will be handled here.
  }
}
