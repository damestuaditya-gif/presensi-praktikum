
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class LocalDatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'chainattend.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students (
            wallet TEXT PRIMARY KEY,
            nim TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  String _normalizeWallet(String wallet) {
    return wallet.trim().toLowerCase();
  }

  Future<void> saveStudent({
    required String walletAddress,
    required String nim,
  }) async {
    final db = await database;

    await db.insert(
      'students',
      {
        'wallet': _normalizeWallet(walletAddress),
        'nim': nim.trim(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> init() async {
  await database;
}

  Future<String?> getNimByWallet(String walletAddress) async {
    final db = await database;

    final result = await db.query(
      'students',
      columns: ['nim'],
      where: 'wallet = ?',
      whereArgs: [_normalizeWallet(walletAddress)],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first['nim'] as String?;
  }

  Future<void> dispose() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }

    _database = null;
  }
}
