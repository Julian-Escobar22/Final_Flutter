import 'package:todo/domain/entities/question_entity.dart';

class QuizEntity {
  final String id;
  final String noteId;
  final String userId;
  final String title;
  final String difficulty;
  final int questionCount;
  final List<QuestionEntity> questions;
  final DateTime createdAt;
  final int? lastScore;
  final DateTime? lastAttemptAt;

  QuizEntity({
    required this.id,
    required this.noteId,
    required this.userId,
    required this.title,
    required this.difficulty,
    required this.questionCount,
    this.questions = const [],
    required this.createdAt,
    this.lastScore,
    this.lastAttemptAt,
  });

  factory QuizEntity.fromJson(Map<String, dynamic> json) {
    return QuizEntity(
      id: json['id'] as String,
      noteId: json['note_id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String? ?? 'Quiz sin título',
      difficulty: json['difficulty'] as String? ?? 'medium',
      questionCount: json['question_count'] as int? ?? 5,
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => QuestionEntity.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      lastScore: json['last_score'] as int?,
      lastAttemptAt: json['last_attempt_at'] != null
          ? DateTime.parse(json['last_attempt_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note_id': noteId,
      'user_id': userId,
      'title': title,
      'difficulty': difficulty,
      'question_count': questionCount,
      'created_at': createdAt.toIso8601String(),
      'last_score': lastScore,
      'last_attempt_at': lastAttemptAt?.toIso8601String(),
    };
  }

  int get totalQuestions => questions.length;
  
  String get scoreText => lastScore != null 
      ? '$lastScore/$totalQuestions' 
      : 'Sin intentos';
      
  String get difficultyLabel {
    switch (difficulty) {
      case 'easy':
        return 'Fácil';
      case 'hard':
        return 'Difícil';
      default:
        return 'Media';
    }
  }
}
