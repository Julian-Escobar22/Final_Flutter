import 'package:todo/domain/entities/quiz_entity.dart';
import 'package:todo/domain/repositories/quiz_repository.dart';
import 'package:todo/data/datasources/remote/quiz_remote_datasource.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizRemoteDataSource remoteDataSource;

  QuizRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<QuizEntity>> getQuizzes() async {
    final data = await remoteDataSource.getQuizzes();
    return data.map((json) => QuizEntity.fromJson(json)).toList();
  }

  @override
  Future<QuizEntity?> getQuizById(String quizId) async {
    final data = await remoteDataSource.getQuizById(quizId);
    if (data == null) return null;
    return QuizEntity.fromJson(data);
  }

  @override
  Future<QuizEntity> generateQuizFromNote({
    required String noteId,
    required String noteText,
    required int questionCount,
    required String difficulty,
  }) async {
    final data = await remoteDataSource.generateQuiz(
      noteId: noteId,
      noteText: noteText,
      questionCount: questionCount,
      difficulty: difficulty,
    );
    return QuizEntity.fromJson(data);
  }

  @override
  Future<void> saveQuizResult({
    required String quizId,
    required int score,
    required int totalQuestions,
  }) async {
    // Por ahora no guardamos resultados individuales
    // Puedes implementar una tabla quiz_results si quieres historial
    return;
  }

  @override
  Future<void> deleteQuiz(String quizId) async {
    return await remoteDataSource.deleteQuiz(quizId);
  }
}
