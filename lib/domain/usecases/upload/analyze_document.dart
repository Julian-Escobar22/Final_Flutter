import 'package:todo/domain/entities/document_entity.dart';
import 'package:todo/domain/repositories/document_repository.dart';

class AnalyzeDocumentUseCase {
  final DocumentRepository repository;

  AnalyzeDocumentUseCase(this.repository);

  Future<DocumentEntity> call(String documentId, String extractedText) =>
      repository.analyzeDocument(documentId, extractedText);
}
