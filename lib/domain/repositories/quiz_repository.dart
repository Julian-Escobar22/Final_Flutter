import 'package:todo/domain/entities/quiz_entity.dart';

abstract class QuizRepository {
  /// Obtiene todos los quizzes del usuario
  Future<List<QuizEntity>> getQuizzes();

  /// Obtiene un quiz específico con sus preguntas
  Future<QuizEntity?> getQuizById(String quizId);

  /// Genera y guarda un nuevo quiz desde una nota
  Future<QuizEntity> generateQuizFromNote({
    required String noteId,
    required String noteText,
    required int questionCount,
    required String difficulty,
  });

  /// Guarda el resultado de un intento de quiz
  Future<void> saveQuizResult({
    required String quizId,
    required int score,
    required int totalQuestions,
  });

  /// Elimina un quiz
  Future<void> deleteQuiz(String quizId);
}
