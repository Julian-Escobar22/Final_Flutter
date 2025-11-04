import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/core/services/ai_service.dart';
import 'package:todo/presentation/controllers/upload_controller.dart';
import 'package:todo/core/providers/pdf_content_provider.dart'; // ✅ AGREGAR

class UploadPage extends StatelessWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UploadController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis PDFs'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildHeader(theme),
            const SizedBox(height: 40),
            _buildMainOptions(context, controller, theme),
            const SizedBox(height: 40),
            _buildDocumentsSection(context, controller, theme),
          ],
        ),
      ),
    );
  }

  // ============ HEADER ============
  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Mis PDFs',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sube PDFs y haz preguntas con IA',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ============ 2 OPCIONES PRINCIPALES ============
  Widget _buildMainOptions(
    BuildContext context,
    UploadController controller,
    ThemeData theme,
  ) {
    return Column(
      children: [
        // 1. SUBIR PDF
        _buildOptionCard(
          context: context,
          icon: Icons.cloud_upload_outlined,
          title: 'Subir PDF',
          description: 'Carga un archivo para analizar',
          onTap: () => controller.processDocument(),
          theme: theme,
        ),
        const SizedBox(height: 16),
        // 2. MIS PDFS
        _buildOptionCard(
          context: context,
          icon: Icons.folder_outlined,
          title: 'Mis PDFs',
          description: 'Abre un PDF y haz preguntas',
          onTap: () => _showPDFsList(context, controller, theme),
          theme: theme,
        ),
      ],
    );
  }

  // ============ TARJETA DE OPCIÓN ============
  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, size: 40, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ SECCIÓN DE DOCUMENTOS ============
  Widget _buildDocumentsSection(
    BuildContext context,
    UploadController controller,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PDFs Cargados',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.documents.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.description,
                      size: 48,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sin PDFs cargados',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.documents.length,
            itemBuilder: (context, index) {
              final doc = controller.documents[index];
              return _buildDocumentTile(context, doc, controller, theme);
            },
          );
        }),
      ],
    );
  }

  // ============ TARJETA DE DOCUMENTO ============
  Widget _buildDocumentTile(
    BuildContext context,
    dynamic doc,
    UploadController controller,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.picture_as_pdf, color: Colors.red),
        title: Text(doc.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          'Toca para hacer preguntas',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _confirmDelete(context, doc.id, controller),
        ),
        // ✅ TAP PARA ABRIR CHAT
        onTap: () => _showPDFChat(context, doc, theme),
      ),
    );
  }

  // ============ LISTA DE PDFS ============
  void _showPDFsList(
    BuildContext context,
    UploadController controller,
    ThemeData theme,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Obx(
                () => Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'Mis PDFs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (controller.documents.isEmpty)
                      const Text('No hay PDFs cargados')
                    else
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: controller.documents.length,
                          itemBuilder: (context, index) {
                            final doc = controller.documents[index];
                            return _buildDocumentTile(
                              context,
                              doc,
                              controller,
                              theme,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPDFChat(BuildContext context, dynamic doc, ThemeData theme) {
    final questionController = TextEditingController();
    final messages = <Map<String, String>>[].obs;
    final isLoading = false.obs;
    final pdfProvider = PdfContentProvider.instance;

    // ✅ ESTO ES IMPORTANTE: tomar contenido de caché o BD
    final contentAvailable =
        pdfProvider.getPdfContent(doc.id) ?? doc.extractedText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 1,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ... resto del código igual ...

                  // EL BOTÓN QUE ENVÍA LA PREGUNTA
                  FloatingActionButton(
                    mini: true,
                    onPressed:
                        (contentAvailable == null || contentAvailable.isEmpty)
                        ? null
                        : () async {
                            final question = questionController.text.trim();
                            if (question.isEmpty) return;

                            messages.add({'type': 'user', 'text': question});
                            questionController.clear();

                            isLoading.value = true;

                            try {
                              final aiService = Get.find<AiService>();

                              // ✅ ESTO HACE LA MAGIA
                              final response = await aiService.askOnText(
                                text: contentAvailable, // ← CONTENIDO DEL PDF
                                question: question, // ← LO QUE PREGUNTÓ
                              );

                              messages.add({'type': 'ai', 'text': response});
                            } catch (e) {
                              messages.add({
                                'type': 'ai',
                                'text': 'Error: ${e.toString()}',
                              });
                            } finally {
                              isLoading.value = false;
                            }
                          },
                    child: Obx(
                      () => isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============ CONFIRMAR ELIMINACIÓN ============
  void _confirmDelete(
    BuildContext context,
    String documentId,
    UploadController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar PDF'),
        content: const Text('¿Estás seguro de que quieres eliminar este PDF?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              controller.removeDocument(documentId);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
