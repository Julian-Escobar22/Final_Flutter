import 'package:todo/domain/repositories/document_repository.dart';

class DeleteDocumentUseCase {
  final DocumentRepository repository;

  DeleteDocumentUseCase(this.repository);

  Future<void> call(String documentId) =>
      repository.deleteDocument(documentId);
}
