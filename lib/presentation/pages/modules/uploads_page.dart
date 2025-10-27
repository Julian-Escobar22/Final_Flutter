import 'package:flutter/material.dart';
import 'package:todo/presentation/pages/modules/widgets.dart';
class UploadsPage extends StatelessWidget {
  const UploadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SectionScaffold(
      title: 'Subida de archivos',
      subtitle: 'Carga PDFs/imagenes y deja que la IA los analice.',
      children: const [
      TileCard(title: 'Subir documento', icon: Icons.cloud_upload_outlined),
      TileCard(title: 'Mis documentos', icon: Icons.folder_open_outlined),
      TileCard(title: 'Analizar con IA', icon: Icons.auto_awesome_outlined),
      ],
      footer: Text(
        'Próximamente: previsualización, chunks y embeddings para preguntas.',
        style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant),
      ),
    );
  }
}
