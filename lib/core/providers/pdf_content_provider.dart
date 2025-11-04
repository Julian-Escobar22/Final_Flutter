import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class PdfContentProvider extends GetxController {
  static PdfContentProvider get instance => Get.isRegistered<PdfContentProvider>()
      ? Get.find<PdfContentProvider>()
      : Get.put(PdfContentProvider());

  // Mapa: documentId -> contenido extraído
  final Map<String, String> _pdfContents = {};

  /// Guardar contenido de PDF
  void savePdfContent(String documentId, String content) {
    _pdfContents[documentId] = content;
    debugPrint('✅ GUARDADO: $documentId (${content.length} caracteres)');
  }

  /// Obtener contenido de PDF
  String? getPdfContent(String documentId) {
    final content = _pdfContents[documentId];
    debugPrint('🔍 BUSCANDO: $documentId → ${content != null ? "ENCONTRADO" : "NO ENCONTRADO"}');
    return content;
  }

  /// Limpiar todo
  void clear() {
    _pdfContents.clear();
    debugPrint('🗑️  LIMPIADO TODO');
  }
}
