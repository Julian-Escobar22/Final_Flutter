import 'package:flutter/material.dart';
import 'package:todo/presentation/pages/modules/widgets.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SectionScaffold(
      title: 'Historial / progreso',
      subtitle: 'Revisa actividad reciente y tu evolución.',
      children: const [
        TileCard(title: 'Actividad reciente', icon: Icons.history_outlined),
        TileCard(title: 'Estadísticas', icon: Icons.insights_outlined),
        TileCard(title: 'Marcadores', icon: Icons.bookmark_outline),
      ],
      footer: Text(
        'Próximamente: badges, rachas, calendario de estudio.',
        style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant),
      ),
    );
  }
}
