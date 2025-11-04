import 'package:todo/data/datasources/remote/document_remote_ds.dart';
import 'package:todo/domain/entities/document_entity.dart';
import 'package:todo/domain/repositories/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDs remoteDs;

  DocumentRepositoryImpl(this.remoteDs);

  @override
  Future<List<DocumentEntity>> getDocuments() => remoteDs.getDocuments();

  @override
  Future<DocumentEntity> uploadDocument({
    required String fileName,
    required String fileUrl,
    required String fileType,
  }) =>
      remoteDs.createDocument(
        fileName: fileName,
        fileUrl: fileUrl,
        fileType: fileType,
      );

  @override
  Future<DocumentEntity> analyzeDocument(
    String documentId,
    String extractedText,
  ) =>
      remoteDs.updateDocument(documentId, extractedText);

  @override
  Future<void> deleteDocument(String documentId) =>
      remoteDs.deleteDocument(documentId);
}
