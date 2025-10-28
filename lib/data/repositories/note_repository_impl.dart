import 'package:todo/data/datasources/remote/note_remote_ds.dart';
import 'package:todo/domain/entities/note_entity.dart';
import 'package:todo/domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteRemoteDs remote;
  NoteRepositoryImpl(this.remote);

  @override
  Future<List<NoteEntity>> getNotes() => remote.getNotes();

  @override
  Future<NoteEntity> createNote({
    required String title,
    String? subject,
    required String rawText,
    String? fileUrl,
  }) =>
      remote.createNote(
        title: title,
        subject: subject,
        rawText: rawText,
        fileUrl: fileUrl,
      );

  @override
  Future<void> deleteNote(String noteId) => remote.deleteNote(noteId);

  @override
  Future<NoteEntity> updateNote(String noteId, Map<String, dynamic> updates) =>
      remote.updateNote(noteId, updates);
}
