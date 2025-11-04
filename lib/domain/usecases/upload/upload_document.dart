import 'package:todo/domain/entities/document_entity.dart';
import 'package:todo/domain/repositories/document_repository.dart';

class UploadDocumentUseCase {
  final DocumentRepository repository;

  UploadDocumentUseCase(this.repository);

  Future<DocumentEntity> call({
    required String fileName,
    required String fileUrl,
    required String fileType,
  }) =>
      repository.uploadDocument(
        fileName: fileName,
        fileUrl: fileUrl,
        fileType: fileType,
      );
}
