import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = MediaQuery.sizeOf(context).width;
    final isSmall = w < 700;
    final maxContent = isSmall ? w : 1100.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white, // fondo blanco
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            spreadRadius: 0,
            color: Color(0x14000000),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withOpacity(0.4),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContent),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 16 : 24,
              vertical: isSmall ? 18 : 22,
            ),
            // Siempre apilado como mobile (también en desktop)
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Brand(theme: theme),
                const SizedBox(height: 8),
                _Copy(theme: theme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({super.key, this.theme});
  final ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    final t = theme ?? Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.school_outlined, size: 20),
        const SizedBox(width: 8),
        Text(
          'StudyAI',
          style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _Copy extends StatelessWidget {
  const _Copy({super.key, this.theme});
  final ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    final t = theme ?? Theme.of(context);
    final year = DateTime.now().year;
    return Text(
      '© $year · Construido por Julian Escobar',
      textAlign: TextAlign.center,
      style: t.textTheme.bodySmall?.copyWith(
        color: t.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
