import 'package:flutter/material.dart';
import 'package:todo/presentation/pages/modules/widgets.dart';

class OcrPage extends StatelessWidget {
  const OcrPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SectionScaffold(
      title: 'Lectura desde cámara / OCR',
      subtitle: 'Escanea apuntes impresos y conviértelos en texto.',
      children: const [
        TileCard(title: 'Escanear ahora', icon: Icons.camera_alt_outlined),
        TileCard(title: 'Desde galería', icon: Icons.photo_library_outlined),
        TileCard(title: 'Ajustes OCR', icon: Icons.tune_outlined),
      ],
      footer: Text(
        'Próximamente: ML Kit offline, corrección y segmentación automática.',
        style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant),
      ),
    );
  }
}
