import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo/core/services/ai_service.dart';
import 'package:uuid/uuid.dart';

class QuizRemoteDataSource {
  final SupabaseClient supabase;
  final AiService aiService;

  QuizRemoteDataSource(this.supabase, this.aiService);

  /// Obtiene todos los quizzes del usuario actual
  Future<List<Map<String, dynamic>>> getQuizzes() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    try {
      // Obtiene todos los quizzes
      final quizzesData = await supabase
          .from('quizzes')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // Para cada quiz, obtiene sus preguntas
      final List<Map<String, dynamic>> quizzesWithQuestions = [];
      
      for (var quiz in quizzesData) {
        final questions = await supabase
            .from('quiz_questions')
            .select('*')
            .eq('quiz_id', quiz['id'])
            .order('created_at', ascending: true);

        quizzesWithQuestions.add({
          ...quiz,
          'questions': questions,
        });
      }

      return quizzesWithQuestions;
    } catch (e) {
      print('Error en getQuizzes: $e');
      return [];
    }
  }

  /// Obtiene un quiz específico con todas sus preguntas
  Future<Map<String, dynamic>?> getQuizById(String quizId) async {
    try {
      final quiz = await supabase
          .from('quizzes')
          .select('*')
          .eq('id', quizId)
          .maybeSingle();

      if (quiz == null) return null;

      final questions = await supabase
          .from('quiz_questions')
          .select('*')
          .eq('quiz_id', quizId)
          .order('created_at', ascending: true);

      return {
        ...quiz,
        'questions': questions,
      };
    } catch (e) {
      print('Error en getQuizById: $e');
      return null;
    }
  }

  /// Genera y guarda un nuevo quiz
  Future<Map<String, dynamic>> generateQuiz({
    required String noteId,
    required String noteText,
    required int questionCount,
    required String difficulty,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    // Obtiene título de la nota
    final noteData = await supabase
        .from('notes')
        .select('title')
        .eq('id', noteId)
        .maybeSingle();

    final noteTitle = noteData?['title'] ?? 'Sin título';

    // Crea el quiz en la base de datos
    final quizId = const Uuid().v4();
    final quizData = await supabase.from('quizzes').insert({
      'id': quizId,
      'note_id': noteId,
      'user_id': userId,
      'title': 'Quiz: $noteTitle (${_getDifficultyLabel(difficulty)})',
      'difficulty': difficulty,
      'question_count': questionCount,
    }).select().single();

    // Genera preguntas con IA
    final questionsData = await aiService.generateQuiz(
      text: noteText,
      questionCount: questionCount,
      difficulty: difficulty,
    );

    // Guarda cada pregunta
    final List<Map<String, dynamic>> savedQuestions = [];
    
    for (var questionData in questionsData) {
      final questionId = const Uuid().v4();
      
      final saved = await supabase.from('quiz_questions').insert({
        'id': questionId,
        'quiz_id': quizId,
        'user_id': userId,
        'type': questionData['type'] ?? 'multiple_choice',
        'question': questionData['question'] ?? '',
        'options': questionData['options'] ?? [],
        'answer': questionData['answer'] ?? '',
        'explanation': questionData['explanation'],
        'difficulty': questionData['difficulty'] ?? difficulty,
      }).select().single();

      savedQuestions.add(saved);
    }

    return {
      ...quizData,
      'questions': savedQuestions,
    };
  }

  /// Elimina un quiz
  Future<void> deleteQuiz(String quizId) async {
    await supabase.from('quizzes').delete().eq('id', quizId);
    // Las preguntas se eliminan automáticamente por CASCADE
  }

  String _getDifficultyLabel(String difficulty) {
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
