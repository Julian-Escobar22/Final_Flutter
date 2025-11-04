import 'package:get/get.dart';

class PdfContentController extends GetxController {
  // Singleton
  static PdfContentController get instance => Get.find<PdfContentController>();

  // Mapa global de contenido
  final _pdfContents = <String, String>{}.obs;

  /// Guardar contenido
  void savePdfContent(String documentId, String content) {
    _pdfContents[documentId] = content;
    print('✅ GUARDADO: $documentId (${content.length} chars)');
    print('📚 Total guardados: ${_pdfContents.length}');
  }

  /// Obtener contenido
  String? getPdfContent(String documentId) {
    final content = _pdfContents[documentId];
    print('🔍 BUSCANDO: $documentId → ${content != null ? "ENCONTRADO" : "NO ENCONTRADO"}');
    if (content != null) {
      print('   Primeros 50 chars: ${content.substring(0, 50)}...');
    }
    return content;
  }

  /// Ver todo
  void printAll() {
    print('\n📚 CONTENIDOS GUARDADOS:');
    _pdfContents.forEach((key, value) {
      print('  $key: ${value.substring(0, 30)}... (${value.length} chars)');
    });
    print('');
  }
}
