import 'package:todo/domain/repositories/note_repository.dart';

class DeleteNoteUseCase {
  final NoteRepository repo;
  DeleteNoteUseCase(this.repo);

  Future<void> call(String noteId) => repo.deleteNote(noteId);
}
