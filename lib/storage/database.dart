import 'dart:convert';

/// 分析记录数据模型
///
/// 用于存储和检索挥棒分析结果
class AnalysisRecord {
  final int? id;
  final DateTime createdAt;
  final int score;
  final double velocity;
  final double angle;
  final double coordination;
  final List<String> suggestions;
  final String? videoPath;

  const AnalysisRecord({
    this.id,
    required this.createdAt,
    required this.score,
    required this.velocity,
    required this.angle,
    required this.coordination,
    required this.suggestions,
    this.videoPath,
  });

  /// 从数据库 Map 构造
  factory AnalysisRecord.fromMap(Map<String, dynamic> map) {
    return AnalysisRecord(
      id: map['id'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      score: map['score'] as int,
      velocity: (map['velocity'] as num).toDouble(),
      angle: (map['angle'] as num).toDouble(),
      coordination: (map['coordination'] as num).toDouble(),
      suggestions: map['suggestions'] != null
          ? List<String>.from(jsonDecode(map['suggestions'] as String))
          : <String>[],
      videoPath: map['video_path'] as String?,
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'created_at': createdAt.toIso8601String(),
      'score': score,
      'velocity': velocity,
      'angle': angle,
      'coordination': coordination,
      'suggestions': jsonEncode(suggestions),
      'video_path': videoPath,
    };
  }

  /// 获取格式化的日期字符串
  String get formattedDate {
    return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')} '
        '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// 获取简要反馈
  String get briefFeedback {
    if (suggestions.isNotEmpty) {
      return suggestions.first;
    }
    return '动作表现良好';
  }

  @override
  String toString() {
    return 'AnalysisRecord(id: $id, score: $score, date: $formattedDate)';
  }
}
