import 'package:todo/domain/entities/note_entity.dart';

abstract class NoteRepository {
  Future<List<NoteEntity>> getNotes();
  Future<NoteEntity> createNote({
    required String title,
    String? subject,
    required String rawText,
    String? fileUrl,
  });
  Future<void> deleteNote(String noteId);
  Future<NoteEntity> updateNote(String noteId, Map<String, dynamic> updates);
}
