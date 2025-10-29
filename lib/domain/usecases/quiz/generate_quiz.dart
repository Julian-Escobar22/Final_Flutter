import 'package:todo/domain/entities/quiz_entity.dart';
import 'package:todo/domain/repositories/quiz_repository.dart';

class GenerateQuiz {
  final QuizRepository repository;

  GenerateQuiz(this.repository);

  Future<QuizEntity> call({
    required String noteId,
    required String noteText,
    int questionCount = 5,
    String difficulty = 'medium',
  }) async {
    return await repository.generateQuizFromNote(
      noteId: noteId,
      noteText: noteText,
      questionCount: questionCount,
      difficulty: difficulty,
    );
  }
}
