import 'package:todo/domain/entities/document_entity.dart';

abstract class DocumentRepository {
  Future<List<DocumentEntity>> getDocuments();
  Future<DocumentEntity> uploadDocument({
    required String fileName,
    required String fileUrl,
    required String fileType,
  });
  Future<DocumentEntity> analyzeDocument(String documentId, String extractedText);
  Future<void> deleteDocument(String documentId);
}
