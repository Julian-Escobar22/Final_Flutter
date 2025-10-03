import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  final bool transparent;
  const AppNavbar({super.key, this.transparent = true});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      elevation: transparent ? 0 : 2,
      backgroundColor: transparent ? Colors.transparent : theme.colorScheme.surface,
      centerTitle: false,
      titleSpacing: 16,
      title: Row(
        children: [
          const Icon(Icons.school_outlined),
          const SizedBox(width: 8),
          Text(
            'StudyAI',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () {}, child: const Text('Características')),
        TextButton(onPressed: () {}, child: const Text('Precios')),
        TextButton(onPressed: () {}, child: const Text('Soporte')),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () => Get.toNamed('/login'),
          child: const Text('Ingresar'),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}
