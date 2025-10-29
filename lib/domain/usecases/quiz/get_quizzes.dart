import 'package:todo/domain/entities/quiz_entity.dart';
import 'package:todo/domain/repositories/quiz_repository.dart';

class GetQuizzes {
  final QuizRepository repository;

  GetQuizzes(this.repository);

  Future<List<QuizEntity>> call() async {
    return await repository.getQuizzes();
  }
}
