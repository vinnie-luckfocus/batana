import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database.dart';

/// 数据库管理器
///
/// 负责 SQLite 数据库的初始化和操作
class DatabaseManager {
  static const String _tableName = 'analysis_records';
  static const int _defaultKeepCount = 50;

  Database? _database;

  /// 获取数据库实例
  Database? get database => _database;

  /// 是否已初始化
  bool get isInitialized => _database != null;

  /// 初始化数据库
  ///
  /// 创建数据库表和必要的索引
  Future<void> initDatabase() async {
    if (_database != null) {
      return;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'batana.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );

    // 自动清理旧记录
    await deleteOldRecords(_defaultKeepCount);
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at TEXT NOT NULL,
        score INTEGER NOT NULL,
        velocity REAL,
        angle REAL,
        coordination REAL,
        suggestions TEXT,
        video_path TEXT
      )
    ''');

    // 创建时间索引以加快查询
    await db.execute('''
      CREATE INDEX idx_created_at ON $_tableName (created_at DESC)
    ''');
  }

  /// 保存分析记录
  ///
  /// [record] 要保存的分析记录
  /// 返回保存后的记录（包含生成的 ID）
  Future<AnalysisRecord> saveRecord(AnalysisRecord record) async {
    final db = _database;
    if (db == null) {
      throw StateError('Database not initialized. Call initDatabase() first.');
    }

    final id = await db.insert(_tableName, record.toMap());

    // 自动清理旧记录
    await deleteOldRecords(_defaultKeepCount);

    return AnalysisRecord(
      id: id,
      createdAt: record.createdAt,
      score: record.score,
      velocity: record.velocity,
      angle: record.angle,
      coordination: record.coordination,
      suggestions: record.suggestions,
      videoPath: record.videoPath,
    );
  }

  /// 获取最近的记录
  ///
  /// [limit] 返回的记录数量
  /// 返回按时间倒序排列的记录列表
  Future<List<AnalysisRecord>> getRecentRecords({int limit = 10}) async {
    final db = _database;
    if (db == null) {
      throw StateError('Database not initialized. Call initDatabase() first.');
    }

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return maps.map((map) => AnalysisRecord.fromMap(map)).toList();
  }

  /// 根据 ID 获取单条记录
  ///
  /// [id] 记录 ID
  /// 返回记录，如果不存在则返回 null
  Future<AnalysisRecord?> getRecordById(int id) async {
    final db = _database;
    if (db == null) {
      throw StateError('Database not initialized. Call initDatabase() first.');
    }

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return AnalysisRecord.fromMap(maps.first);
  }

  /// 删除旧记录
  ///
  /// [keepCount] 保留的记录数量
  /// 删除超出数量的旧记录
  Future<int> deleteOldRecords(int keepCount) async {
    final db = _database;
    if (db == null) {
      return 0;
    }

    // 获取记录总数
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    );

    if (count == null || count <= keepCount) {
      return 0;
    }

    // 删除超出保留数量的旧记录
    final deleteCount = count - keepCount;
    final result = await db.rawDelete('''
      DELETE FROM $_tableName
      WHERE id IN (
        SELECT id FROM $_tableName
        ORDER BY created_at ASC
        LIMIT ?
      )
    ''', [deleteCount]);

    return result;
  }

  /// 删除所有记录
  ///
  /// 注意：此操作不可恢复
  Future<int> deleteAllRecords() async {
    final db = _database;
    if (db == null) {
      throw StateError('Database not initialized. Call initDatabase() first.');
    }

    return await db.delete(_tableName);
  }

  /// 关闭数据库
  ///
  /// 释放数据库连接
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
