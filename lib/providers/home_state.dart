import 'package:flutter/foundation.dart';
import '../storage/database.dart';
import '../storage/database_manager.dart';

/// HomeState 状态管理
///
/// 负责管理主界面的状态，包括最近分析列表、加载状态和错误状态
class HomeState extends ChangeNotifier {
  final DatabaseManager _databaseManager;

  /// 最近分析记录列表
  List<AnalysisRecord> _recentRecords = [];

  /// 是否正在加载
  bool _isLoading = false;

  /// 错误信息
  String? _error;

  /// 是否已初始化
  bool _isInitialized = false;

  /// 构造函数
  HomeState({DatabaseManager? databaseManager})
      : _databaseManager = databaseManager ?? DatabaseManager();

  // Getters
  List<AnalysisRecord> get recentRecords => List.unmodifiable(_recentRecords);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  bool get hasError => _error != null;
  bool get hasRecords => _recentRecords.isNotEmpty;

  /// 初始化状态
  ///
  /// 初始化数据库并加载最近记录
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _databaseManager.initDatabase();
    _isInitialized = true;
    await loadRecentRecords();
  }

  /// 加载最近分析记录
  ///
  /// 从数据库获取最近的分析记录
  Future<void> loadRecentRecords() async {
    _setLoading(true);
    _clearError();

    try {
      final records = await _databaseManager.getRecentRecords(limit: 10);
      _recentRecords = records;
      notifyListeners();
    } catch (e) {
      _setError('加载历史记录失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 下拉刷新
  ///
  /// 重新加载最近分析记录
  Future<void> refresh() async {
    await loadRecentRecords();
  }

  /// 删除记录
  ///
  /// [id] 要删除的记录ID
  Future<void> deleteRecord(int id) async {
    try {
      // 从本地列表移除
      _recentRecords.removeWhere((record) => record.id == id);
      notifyListeners();

      // TODO: 实现数据库删除操作
      // await _databaseManager.deleteRecord(id);
    } catch (e) {
      _setError('删除记录失败: $e');
      // 重新加载以恢复状态
      await loadRecentRecords();
    }
  }

  /// 添加新记录
  ///
  /// [record] 要添加的分析记录
  Future<void> addRecord(AnalysisRecord record) async {
    try {
      final savedRecord = await _databaseManager.saveRecord(record);
      _recentRecords.insert(0, savedRecord);
      // 保持最多10条记录
      if (_recentRecords.length > 10) {
        _recentRecords = _recentRecords.sublist(0, 10);
      }
      notifyListeners();
    } catch (e) {
      _setError('保存记录失败: $e');
    }
  }

  /// 清除错误状态
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// 设置加载状态
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// 设置错误信息
  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  /// 清除错误信息
  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    _databaseManager.closeDatabase();
    super.dispose();
  }
}
