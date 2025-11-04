import 'package:get/get.dart';
import 'package:todo/core/services/ai_service.dart';
import 'package:todo/data/datasources/remote/quiz_remote_datasource.dart';
import 'package:todo/data/repositories/quiz_repository_impl.dart';
import 'package:todo/domain/usecases/quiz/get_quizzes.dart';
import 'package:todo/domain/usecases/quiz/generate_quiz.dart';
import 'package:todo/domain/usecases/quiz/delete_quiz.dart';
import 'package:todo/presentation/controllers/quiz_controller.dart';

class QuizBindings extends Bindings {
  @override
  void dependencies() {
    // DataSource
    Get.lazyPut<QuizRemoteDataSource>(
      () => QuizRemoteDataSource(
        Get.find<AiService>(),
      ),
    );

    // Repository
    Get.lazyPut<QuizRepositoryImpl>(
      () => QuizRepositoryImpl(Get.find<QuizRemoteDataSource>()),
    );

    // UseCases
    Get.lazyPut(() => GetQuizzes(Get.find<QuizRepositoryImpl>()));
    Get.lazyPut(() => GenerateQuiz(Get.find<QuizRepositoryImpl>()));
    Get.lazyPut(() => DeleteQuiz(Get.find<QuizRepositoryImpl>()));

    // Controller
    Get.lazyPut(
      () => QuizController(
        getQuizzes: Get.find(),
        generateQuiz: Get.find(),
        deleteQuiz: Get.find(),
      ),
    );
  }
}
