import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo/core/utils/supabase_helper.dart';

class HistoryRemoteDataSource {
   SupabaseClient get supabase => SupabaseHelper.client;

  HistoryRemoteDataSource();

  /// Obtiene estadísticas generales del usuario
  Future<Map<String, dynamic>> getStats() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    try {
      // Total de notas
      final notesResponse = await supabase
          .from('notes')
          .select('id')
          .eq('user_id', userId)
          .eq('deleted', false); 
      
      final notesCount = (notesResponse as List).length;

      // Total de quizzes
      final quizzesResponse = await supabase
          .from('quizzes')
          .select('id')
          .eq('user_id', userId);
      
      final quizzesCount = (quizzesResponse as List).length;

      // Quizzes con puntaje (completados)
      final completedQuizzes = await supabase
          .from('quizzes')
          .select('last_score, question_count, last_attempt_at, title, created_at')
          .eq('user_id', userId)
          .not('last_score', 'is', null)
          .order('last_attempt_at', ascending: false);

      // Calcula promedio y puntos para gráfica
      double averageScore = 0;
      final List<Map<String, dynamic>> quizScores = [];

      if (completedQuizzes.isNotEmpty) {
        double totalPercentage = 0;
        for (var quiz in completedQuizzes) {
          final score = quiz['last_score'] as int;
          final total = quiz['question_count'] as int;
          final percentage = (score / total * 100);
          totalPercentage += percentage;

          quizScores.add({
            'date': quiz['last_attempt_at'] ?? quiz['created_at'],
            'score': percentage,
            'quiz_title': quiz['title'],
          });
        }
        averageScore = totalPercentage / completedQuizzes.length;
      }

      // Calcula racha de estudio (días consecutivos)
      final studyStreak = await _calculateStudyStreak(userId);

      return {
        'total_notes': notesCount,
        'total_quizzes': quizzesCount,
        'total_quizzes_completed': completedQuizzes.length,
        'average_quiz_score': averageScore,
        'study_streak': studyStreak,
        'last_activity': completedQuizzes.isNotEmpty
            ? completedQuizzes.first['last_attempt_at']
            : null,
        'quiz_scores': quizScores,
      };
    } catch (e) {
      print('Error en getStats: $e');
      return {
        'total_notes': 0,
        'total_quizzes': 0,
        'total_quizzes_completed': 0,
        'average_quiz_score': 0.0,
        'study_streak': 0,
        'last_activity': null,
        'quiz_scores': [],
      };
    }
  }

  /// Obtiene actividades recientes
  Future<List<Map<String, dynamic>>> getRecentActivity({int limit = 10}) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    try {
      final List<Map<String, dynamic>> activities = [];

      // Últimas notas creadas
      final notes = await supabase
          .from('notes')
          .select('id, title, created_at')
          .eq('user_id', userId)
          .eq('deleted', false)
          .order('created_at', ascending: false)
          .limit(5);

      for (var note in notes) {
        activities.add({
          'id': note['id'],
          'user_id': userId,
          'type': 'note_created',
          'title': note['title'],
          'description': 'Nota creada',
          'timestamp': note['created_at'],
        });
      }

      // Últimos quizzes generados
      final quizzes = await supabase
          .from('quizzes')
          .select('id, title, created_at, last_score, question_count')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(5);

      for (var quiz in quizzes) {
        if (quiz['last_score'] != null) {
          activities.add({
            'id': quiz['id'],
            'user_id': userId,
            'type': 'quiz_completed',
            'title': quiz['title'],
            'description':
                'Completado: ${quiz['last_score']}/${quiz['question_count']}',
            'timestamp': quiz['created_at'],
          });
        } else {
          activities.add({
            'id': quiz['id'],
            'user_id': userId,
            'type': 'quiz_generated',
            'title': quiz['title'],
            'description': 'Quiz generado',
            'timestamp': quiz['created_at'],
          });
        }
      }

      // Ordena por fecha
      activities.sort((a, b) =>
          DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));

      return activities.take(limit).toList();
    } catch (e) {
      print('Error en getRecentActivity: $e');
      return [];
    }
  }

  /// Calcula días consecutivos de estudio
  Future<int> _calculateStudyStreak(String userId) async {
    try {
      final activities = await supabase
          .from('quizzes')
          .select('last_attempt_at')
          .eq('user_id', userId)
          .not('last_attempt_at', 'is', null)
          .order('last_attempt_at', ascending: false);

      if (activities.isEmpty) return 0;

      int streak = 0;
      DateTime? lastDate;

      for (var activity in activities) {
        final date = DateTime.parse(activity['last_attempt_at']);
        final dateOnly = DateTime(date.year, date.month, date.day);

        if (lastDate == null) {
          lastDate = dateOnly;
          streak = 1;
        } else {
          final difference = lastDate.difference(dateOnly).inDays;
          if (difference == 1) {
            streak++;
            lastDate = dateOnly;
          } else if (difference > 1) {
            break;
          }
        }
      }

      return streak;
    } catch (e) {
      return 0;
    }
  }
}
