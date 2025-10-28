import 'package:todo/domain/entities/note_entity.dart';
import 'package:todo/domain/repositories/note_repository.dart';

class CreateNoteUseCase {
  final NoteRepository repo;
  CreateNoteUseCase(this.repo);

  Future<NoteEntity> call({
    required String title,
    String? subject,
    required String rawText,
    String? fileUrl,
  }) {
    return repo.createNote(
      title: title,
      subject: subject,
      rawText: rawText,
      fileUrl: fileUrl,
    );
  }
}
