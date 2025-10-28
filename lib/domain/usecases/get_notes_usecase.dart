import 'package:todo/domain/entities/note_entity.dart';
import 'package:todo/domain/repositories/note_repository.dart';

class GetNotesUseCase {
  final NoteRepository repo;
  GetNotesUseCase(this.repo);

  Future<List<NoteEntity>> call() => repo.getNotes();
}
