import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/domain/entities/document_entity.dart';
import 'package:todo/domain/usecases/upload/analyze_document.dart';
import 'package:todo/domain/usecases/upload/delete_document.dart';
import 'package:todo/domain/usecases/upload/get_documents.dart';
import 'package:todo/domain/usecases/upload/upload_document.dart';
import 'package:todo/core/services/file_service.dart';
import 'package:todo/core/services/ai_service.dart';

class UploadController extends GetxController {
  final GetDocumentsUseCase getDocuments;
  final UploadDocumentUseCase uploadDocument;
  final AnalyzeDocumentUseCase analyzeDocument;
  final DeleteDocumentUseCase deleteDocument;

  UploadController({
    required this.getDocuments,
    required this.uploadDocument,
    required this.analyzeDocument,
    required this.deleteDocument,
  });

  final documents = <DocumentEntity>[].obs;
  final isLoading = false.obs;
  final uploadProgress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDocuments();
  }

  /// Cargar documentos
  Future<void> loadDocuments() async {
    try {
      isLoading.value = true;
      final docs = await getDocuments();
      documents.assignAll(docs);
    } catch (e) {
      Get.snackbar('Error', 'Error cargando documentos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Subir PDF (SIN análisis complejo)
  Future<void> processDocument() async {
    try {
      isLoading.value = true;

      // 1. Seleccionar archivo
      final (fileBytes, extension) = await Get.find<FileService>()
          .pickAnyFile();

      if (fileBytes == null || extension == null) return;

      final fileType = Get.find<FileService>().getFileType(extension);

      if (fileType == 'unknown') {
        Get.snackbar('Error', 'Tipo de archivo no soportado.');
        return;
      }

      // 2. Subir a Storage
      uploadProgress.value = 0.5;
      final fileUrl = await Get.find<FileService>().uploadFile(
        fileBytes,
        extension,
      );

      // 3. Crear registro en BD
      uploadProgress.value = 0.7;
      final doc = await uploadDocument(
        fileName: 'Document_${DateTime.now().millisecondsSinceEpoch}',
        fileUrl: fileUrl,
        fileType: fileType,
      );

      // 4. Procesar contenido
      uploadProgress.value = 0.8;
      String extractedText = '';

      try {
        if (fileType == 'pdf') {
          // Para PDF: solo marca como disponible
          extractedText = 'Documento PDF cargado correctamente.';
        } else if (fileType == 'image') {
          // Para imágenes: usa OCR
          final aiService = Get.find<AiService>();
          extractedText = await aiService.extractTextFromImage(fileBytes);
        }
      } catch (e) {
        debugPrint('Error extrayendo contenido: $e');
        extractedText = 'Archivo cargado.';
      }

      if (extractedText.isEmpty) {
        extractedText = 'Documento cargado correctamente.';
      }

      // 5. Guardar en BD
      uploadProgress.value = 0.9;
      final analyzedDoc = await analyzeDocument(doc.id, extractedText);

      uploadProgress.value = 1.0;

      // 6. Actualizar lista
      documents.add(analyzedDoc);

      Get.snackbar(
        '✓ Éxito',
        'Documento subido correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      await Future.delayed(const Duration(seconds: 1));
      uploadProgress.value = 0.0;
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        'Error: ${e.toString().substring(0, 100)}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Eliminar documento
  Future<void> removeDocument(String documentId) async {
    try {
      await deleteDocument(documentId);
      documents.removeWhere((doc) => doc.id == documentId);
      Get.snackbar('✓ Éxito', 'Documento eliminado');
    } catch (e) {
      Get.snackbar('❌ Error', 'Error eliminando: $e');
    }
  }
}
