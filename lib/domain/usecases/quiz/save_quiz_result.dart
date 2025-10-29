import 'package:todo/domain/repositories/quiz_repository.dart';

class SaveQuizResult {
  final QuizRepository repository;

  SaveQuizResult(this.repository);

  Future<void> call({
    required String quizId,
    required int score,
    required int totalQuestions,
  }) async {
    return await repository.saveQuizResult(
      quizId: quizId,
      score: score,
      totalQuestions: totalQuestions,
    );
  }
}
