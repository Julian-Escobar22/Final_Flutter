import 'package:get/get.dart';
import 'package:todo/data/datasources/remote/document_remote_ds.dart';
import 'package:todo/data/repositories/document_repository_impl.dart';
import 'package:todo/domain/repositories/document_repository.dart';
import 'package:todo/domain/usecases/upload/analyze_document.dart';
import 'package:todo/domain/usecases/upload/delete_document.dart';
import 'package:todo/domain/usecases/upload/get_documents.dart';
import 'package:todo/domain/usecases/upload/upload_document.dart';
import 'package:todo/presentation/controllers/upload_controller.dart';

class UploadBindings extends Bindings {
  @override
  void dependencies() {
    // DataSource
    Get.lazyPut<DocumentRemoteDs>(() => DocumentRemoteDs());

    // Repository
    Get.lazyPut<DocumentRepository>(
      () => DocumentRepositoryImpl(Get.find<DocumentRemoteDs>()),
    );

    // UseCases
    Get.lazyPut(() => GetDocumentsUseCase(Get.find<DocumentRepository>()));
    Get.lazyPut(() => UploadDocumentUseCase(Get.find<DocumentRepository>()));
    Get.lazyPut(() => AnalyzeDocumentUseCase(Get.find<DocumentRepository>()));
    Get.lazyPut(() => DeleteDocumentUseCase(Get.find<DocumentRepository>()));

    // Controller
    Get.lazyPut(
      () => UploadController(
        getDocuments: Get.find(),
        uploadDocument: Get.find(),
        analyzeDocument: Get.find(),
        deleteDocument: Get.find(),
      ),
    );
  }
}
