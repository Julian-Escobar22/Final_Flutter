import 'package:todo/domain/repositories/quiz_repository.dart';

class DeleteQuiz {
  final QuizRepository repository;

  DeleteQuiz(this.repository);

  Future<void> call(String quizId) async {
    return await repository.deleteQuiz(quizId);
  }
}
