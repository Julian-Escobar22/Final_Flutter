import 'package:get/get.dart';
import 'package:todo/data/datasources/remote/quiz_remote_datasource.dart';
import 'package:todo/domain/entities/quiz_entity.dart';
import 'package:todo/domain/usecases/quiz/get_quizzes.dart';
import 'package:todo/domain/usecases/quiz/generate_quiz.dart';
import 'package:todo/domain/usecases/quiz/delete_quiz.dart';
import 'package:todo/presentation/controllers/history_controller.dart';
import 'package:flutter/foundation.dart';

class QuizController extends GetxController {
  final GetQuizzes getQuizzes;
  final GenerateQuiz generateQuiz;
  final DeleteQuiz deleteQuiz;

  QuizController({
    required this.getQuizzes,
    required this.generateQuiz,
    required this.deleteQuiz,
  });

  // Estado
  final quizzes = <QuizEntity>[].obs;
  final loading = false.obs;
  final generating = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadQuizzes();
  }

  /// Carga todos los quizzes del usuario
  Future<void> loadQuizzes() async {
    try {
      loading.value = true;
      final result = await getQuizzes();
      quizzes.value = result;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar los cuestionarios: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      loading.value = false;
    }
  }

  /// Guarda el resultado de un quiz completado
  Future<void> saveQuizResult({
    required String quizId,
    required int score,
    required int totalQuestions,
  }) async {
    try {
      // Actualiza el quiz en Supabase con el puntaje y fecha
      await Get.find<QuizRemoteDataSource>().saveQuizResult(
        quizId: quizId,
        score: score,
        totalQuestions: totalQuestions,
      );

      // Recarga quizzes para reflejar cambios
      await loadQuizzes();
      
    
      if (Get.isRegistered<HistoryController>()) {
        await Get.find<HistoryController>().loadData();
      }
      
      debugPrint('✅ Resultado guardado: $score/$totalQuestions');
    } catch (e) {
      debugPrint('❌ Error guardando resultado del quiz: $e');
      rethrow;
    }
  }

  /// Genera un nuevo quiz desde una nota
  Future<QuizEntity?> createQuizFromNote({
    required String noteId,
    required String noteText,
    int questionCount = 5,
    String difficulty = 'medium',
  }) async {
    try {
      generating.value = true;

      final quiz = await generateQuiz(
        noteId: noteId,
        noteText: noteText,
        questionCount: questionCount,
        difficulty: difficulty,
      );

      // Actualiza la lista
      await loadQuizzes();
      
      
      if (Get.isRegistered<HistoryController>()) {
        await Get.find<HistoryController>().loadData();
      }

      Get.snackbar(
        'Éxito',
        'Cuestionario generado con ${quiz.questions.length} preguntas',
        snackPosition: SnackPosition.BOTTOM,
      );

      return quiz;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo generar el cuestionario: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      generating.value = false;
    }
  }

  /// Elimina un quiz
  Future<void> removeQuiz(String quizId) async {
    try {
      await deleteQuiz(quizId);
      quizzes.removeWhere((q) => q.id == quizId);
      
      // Actualiza historial después de eliminar
      if (Get.isRegistered<HistoryController>()) {
        await Get.find<HistoryController>().loadData();
      }

      Get.snackbar(
        'Eliminado',
        'Cuestionario eliminado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el cuestionario: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Busca un quiz específico por ID
  QuizEntity? getQuizById(String quizId) {
    try {
      return quizzes.firstWhere((q) => q.id == quizId);
    } catch (e) {
      return null;
    }
  }
}
