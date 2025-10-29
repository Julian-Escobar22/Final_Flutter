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
      // Obtiene todos los quiz_questions del usuario
      final questionsData = await supabase
          .from('quiz_questions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (questionsData.isEmpty) return [];

      // Agrupa por note_id
      final Map<String, List<Map<String, dynamic>>> groupedByNote = {};
      
      for (var question in questionsData) {
        final noteId = question['note_id'] as String;
        if (!groupedByNote.containsKey(noteId)) {
          groupedByNote[noteId] = [];
        }
        groupedByNote[noteId]!.add(question);
      }

      // Construye los quizzes
      final List<Map<String, dynamic>> quizzes = [];
      
      for (var entry in groupedByNote.entries) {
        final noteId = entry.key;
        final questions = entry.value;

        try {
          // Obtiene título de la nota
          final noteData = await supabase
              .from('notes')
              .select('title')
              .eq('id', noteId)
              .maybeSingle();

          final noteTitle = noteData?['title'] ?? 'Nota eliminada';

          quizzes.add({
            'id': noteId,
            'note_id': noteId,
            'user_id': userId,
            'title': 'Quiz: $noteTitle',
            'created_at': questions.first['created_at'] ?? DateTime.now().toIso8601String(),
            'questions': questions,
            'last_score': null,
            'last_attempt_at': null,
          });
        } catch (e) {
          // Si la nota no existe, igual agregamos el quiz
          quizzes.add({
            'id': noteId,
            'note_id': noteId,
            'user_id': userId,
            'title': 'Quiz sin título',
            'created_at': questions.first['created_at'] ?? DateTime.now().toIso8601String(),
            'questions': questions,
            'last_score': null,
            'last_attempt_at': null,
          });
        }
      }

      return quizzes;
    } catch (e) {
      print('Error en getQuizzes: $e');
      return [];
    }
  }

  /// Obtiene un quiz específico con todas sus preguntas
  Future<Map<String, dynamic>?> getQuizById(String noteId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    try {
      // Obtiene todas las preguntas del quiz
      final questions = await supabase
          .from('quiz_questions')
          .select('*')
          .eq('note_id', noteId)
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      if (questions.isEmpty) return null;

      // Obtiene info de la nota
      final noteData = await supabase
          .from('notes')
          .select('title')
          .eq('id', noteId)
          .maybeSingle();

      final noteTitle = noteData?['title'] ?? 'Sin título';

      return {
        'id': noteId,
        'note_id': noteId,
        'user_id': userId,
        'title': 'Quiz: $noteTitle',
        'created_at': questions.first['created_at'] ?? DateTime.now().toIso8601String(),
        'questions': questions,
        'last_score': null,
        'last_attempt_at': null,
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

    // Genera preguntas con IA
    final questionsData = await aiService.generateQuiz(
      text: noteText,
      questionCount: questionCount,
      difficulty: difficulty,
    );

    // Guarda cada pregunta en Supabase
    final List<Map<String, dynamic>> savedQuestions = [];
    
    for (var questionData in questionsData) {
      final questionId = const Uuid().v4();
      
      final saved = await supabase.from('quiz_questions').insert({
        'id': questionId,
        'note_id': noteId,
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

    // Obtiene título de la nota
    final noteData = await supabase
        .from('notes')
        .select('title')
        .eq('id', noteId)
        .maybeSingle();

    final noteTitle = noteData?['title'] ?? 'Sin título';

    return {
      'id': noteId,
      'note_id': noteId,
      'user_id': userId,
      'title': 'Quiz: $noteTitle',
      'created_at': DateTime.now().toIso8601String(),
      'questions': savedQuestions,
      'last_score': null,
      'last_attempt_at': null,
    };
  }

  /// Elimina un quiz (todas sus preguntas)
  Future<void> deleteQuiz(String noteId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    await supabase
        .from('quiz_questions')
        .delete()
        .eq('note_id', noteId)
        .eq('user_id', userId);
  }
}
