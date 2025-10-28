import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo/domain/entities/note_entity.dart';

class NoteRemoteDs {
  final SupabaseClient client;
  NoteRemoteDs(this.client);

  Future<List<NoteEntity>> getNotes() async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final res = await client
        .from('notes')
        .select()
        .eq('user_id', user.id)
        .eq('deleted', false)
        .order('created_at', ascending: false);

    return (res as List).map((e) => NoteEntity.fromJson(e)).toList();
  }

  Future<NoteEntity> createNote({
    required String title,
    String? subject,
    required String rawText,
    String? fileUrl,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final now = DateTime.now().toIso8601String();
    final data = {
      'user_id': user.id,
      'title': title,
      'subject': subject,
      'raw_text': rawText,
      'file_url': fileUrl,
      'clean_text': null,
      'summary': null,
      'tags': <dynamic>[],
      'deleted': false,
      'created_at': now,
      'updated_at': now,
    };

    final res = await client.from('notes').insert(data).select().single();
    return NoteEntity.fromJson(res);
  }

  Future<void> deleteNote(String noteId) async {
    await client
        .from('notes')
        .update({'deleted': true, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', noteId);
  }

  Future<NoteEntity> updateNote(String noteId, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    final res = await client
        .from('notes')
        .update(updates)
        .eq('id', noteId)
        .select()
        .single();
    return NoteEntity.fromJson(res);
  }
}
