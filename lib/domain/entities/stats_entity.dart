class StatsEntity {
  final int totalNotes;
  final int totalQuizzes;
  final int totalQuizzesCompleted;
  final double averageQuizScore;
  final int studyStreak;
  final DateTime? lastActivity;
  final List<QuizScorePoint> quizScores;

  StatsEntity({
    required this.totalNotes,
    required this.totalQuizzes,
    required this.totalQuizzesCompleted,
    required this.averageQuizScore,
    required this.studyStreak,
    this.lastActivity,
    this.quizScores = const [],
  });

  factory StatsEntity.fromJson(Map<String, dynamic> json) {
    return StatsEntity(
      totalNotes: json['total_notes'] as int? ?? 0,
      totalQuizzes: json['total_quizzes'] as int? ?? 0,
      totalQuizzesCompleted: json['total_quizzes_completed'] as int? ?? 0,
      averageQuizScore: (json['average_quiz_score'] as num?)?.toDouble() ?? 0.0,
      studyStreak: json['study_streak'] as int? ?? 0,
      lastActivity: json['last_activity'] != null
          ? DateTime.parse(json['last_activity'] as String)
          : null,
      quizScores: (json['quiz_scores'] as List<dynamic>?)
              ?.map((e) => QuizScorePoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class QuizScorePoint {
  final DateTime date;
  final double score;
  final String quizTitle;

  QuizScorePoint({
    required this.date,
    required this.score,
    required this.quizTitle,
  });

  factory QuizScorePoint.fromJson(Map<String, dynamic> json) {
    return QuizScorePoint(
      date: DateTime.parse(json['date'] as String),
      score: (json['score'] as num).toDouble(),
      quizTitle: json['quiz_title'] as String? ?? '',
    );
  }
}
