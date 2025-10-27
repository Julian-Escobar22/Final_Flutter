import 'package:flutter/material.dart';

class SectionScaffold extends StatelessWidget {
  const SectionScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
    this.footer,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return LayoutBuilder(
      builder: (context, c) {
        final isSmall = c.maxWidth < 900;
        final maxW = isSmall ? c.maxWidth : 1100.0;

        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 20, vertical: 18),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: t.textTheme.titleMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: children,
                  ),
                  if (footer != null) ...[
                    const SizedBox(height: 16),
                    footer!,
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class TileGrid extends StatelessWidget {
  const TileGrid({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final isSmall = w < 700;

        // En mobile: cards centradas y con ancho fluido (máx 320)
        final double tileWidth = isSmall ? ((w - 48).clamp(260.0, 320.0)).toDouble() : 320.0;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,      
          runAlignment: WrapAlignment.center,   
          children: children.map((child) {
            return SizedBox(width: tileWidth, child: child);
          }).toList(),
        );
      },
    );
  }
}

class TileCard extends StatelessWidget {
  const TileCard({required this.title, required this.icon, this.onTap});

  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SizedBox(
      width: 260,
      height: 120,
      child: Material(
        color: Colors.white,
        elevation: 6,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 28, color: t.colorScheme.primary),
                const Spacer(),
                Text(
                  title,
                  style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
