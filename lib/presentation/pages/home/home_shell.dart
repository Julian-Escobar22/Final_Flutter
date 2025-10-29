import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/presentation/controllers/auth_controller.dart';
import 'package:todo/presentation/routes.dart';

// Módulos (stubs)
import 'package:todo/presentation/pages/modules/notes_page.dart';
import 'package:todo/presentation/pages/modules/quiz_page.dart';
import 'package:todo/presentation/pages/modules/ocr_page.dart';
import 'package:todo/presentation/pages/modules/history_page.dart';
import 'package:todo/presentation/pages/modules/uploads_page.dart';
import 'package:todo/presentation/pages/home/profile_sheet.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _auth = Get.find<AuthController>();
  int _index = 0;

  final _pages = const [
    NotesPage(),
    QuizPage(),
    OcrPage(),
    HistoryPage(),
    UploadsPage(),
  ];

  final _labels = const [
    'Notas / IA',
    'Cuestionario',
    'OCR',
    'Historial',
    'Subidas',
  ];

  final _icons = const [
    Icons.menu_book_outlined,
    Icons.quiz_outlined,
    Icons.camera_alt_outlined,
    Icons.insights_outlined,
    Icons.cloud_upload_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, c) {
        final isSmall = c.maxWidth < 900;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F0FF),
          appBar: AppBar(
            elevation: 3,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 12,
            title: InkWell(
              onTap: () => Get.offAllNamed(AppRoutes.landing),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school_outlined),
                  const SizedBox(width: 8),
                  Text(
                    'StudyAI',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Email del usuario
              Obx(() {
                // 👇 Forzamos la dependencia a un Rx para que Obx sea válido
                final _ = _auth.user.value;

                final display =
                    _auth.displayNameOrEmail; // (getter del AuthController)
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 180,
                    ), // evita overflow
                    child: Text(
                      display,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 8),
              // Menú de perfil + cerrar sesión
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      useSafeArea: true,
                      isScrollControlled: true,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (_) => const ProfileSheet(),
                    );
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.12),
                    child: Icon(
                      Icons.person_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),
            ],
          ),

          // BODY: Rail (desktop) o BottomNav (mobile)
          body: Row(
            children: [
              if (!isSmall)
                _SideRail(
                  index: _index,
                  onTap: (i) => setState(() => _index = i),
                  labels: _labels,
                  icons: _icons,
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _pages[_index],
                ),
              ),
            ],
          ),

          bottomNavigationBar: isSmall
              ? NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  destinations: List.generate(_labels.length, (i) {
                    return NavigationDestination(
                      icon: Icon(_icons[i]),
                      label: _labels[i],
                    );
                  }),
                )
              : null,
        );
      },
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({
    required this.index,
    required this.onTap,
    required this.labels,
    required this.icons,
  });

  final int index;
  final ValueChanged<int> onTap;
  final List<String> labels;
  final List<IconData> icons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NavigationRail(
      backgroundColor: Colors.white,
      indicatorColor: theme.colorScheme.primary.withOpacity(0.12),
      selectedIndex: index,
      onDestinationSelected: onTap,
      labelType: NavigationRailLabelType.all,
      destinations: List.generate(labels.length, (i) {
        return NavigationRailDestination(
          icon: Icon(icons[i]),
          selectedIcon: Icon(icons[i]),
          label: Text(labels[i]),
        );
      }),
    );
  }
}
