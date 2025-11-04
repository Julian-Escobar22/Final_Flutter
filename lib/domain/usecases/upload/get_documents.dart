import 'package:todo/domain/entities/document_entity.dart';
import 'package:todo/domain/repositories/document_repository.dart';

class GetDocumentsUseCase {
  final DocumentRepository repository;

  GetDocumentsUseCase(this.repository);

  Future<List<DocumentEntity>> call() => repository.getDocuments();
}
