import 'package:flutter/material.dart';
import 'package:todo/presentation/utils/lottie_transition.dart';
import 'package:todo/presentation/routes.dart';

enum NavbarAuthMode { none, login, register }

class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  final bool transparent;
  final NavbarAuthMode authMode;

  const AppNavbar({
    super.key,
    this.transparent = false,
    this.authMode = NavbarAuthMode.none,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = transparent ? Colors.transparent : Colors.white;

    final showBackButton =
        authMode == NavbarAuthMode.login || authMode == NavbarAuthMode.register;

    return AppBar(
      elevation: transparent ? 0 : 6,
      shadowColor: transparent ? Colors.transparent : Colors.black12,
      surfaceTintColor: Colors.transparent,
      backgroundColor: bg,
      centerTitle: false,
      titleSpacing: 12,
      leadingWidth: showBackButton ? 60 : 0,
      leading: showBackButton
          ? IconButton(
              tooltip: 'Volver',
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => LottieScreenTransition.playAndNavigate(
                context,
                asset: 'assets/lottie/intro-login.json',
                routeName: AppRoutes.landing,
                backgroundColor: const Color.fromARGB(255, 7, 7, 7),
                speedMultiplier: 4.0,
              ),
            )
          : null,
      title: InkWell(
        onTap: () => LottieScreenTransition.playAndNavigate(
          context,
          asset: 'assets/lottie/intro-login.json',
          routeName: AppRoutes.landing,
          backgroundColor: const Color.fromARGB(255, 12, 12, 12),
          speedMultiplier: 4.0,
        ),
        borderRadius: BorderRadius.circular(6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school_outlined),
            const SizedBox(width: 8),
            Text(
              'StudyAI',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (authMode == NavbarAuthMode.none) ...[
          FilledButton(
            onPressed: () => LottieScreenTransition.playAndNavigate(
              context,
              asset: 'assets/lottie/intro-login.json',
              routeName: AppRoutes.login,
              backgroundColor: const Color.fromARGB(255, 15, 15, 15),
              speedMultiplier: 4.0,
            ),
            child: const Text('Ingresar'),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => LottieScreenTransition.playAndNavigate(
              context,
              asset: 'assets/lottie/intro-login.json',
              routeName: AppRoutes.register,
              backgroundColor: const Color.fromARGB(255, 12, 12, 12),
              speedMultiplier: 4.0,
            ),
            child: const Text('Registrarse'),
          ),
          const SizedBox(width: 16),
        ] else if (authMode == NavbarAuthMode.login) ...[
          OutlinedButton(
            onPressed: () => LottieScreenTransition.playAndNavigate(
              context,
              asset: 'assets/lottie/intro-login.json',
              routeName: AppRoutes.register,
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
              speedMultiplier: 3.0,
            ),
            child: const Text('Registrarse'),
          ),
          const SizedBox(width: 16),
        ] else if (authMode == NavbarAuthMode.register) ...[
          FilledButton(
            onPressed: () => LottieScreenTransition.playAndNavigate(
              context,
              asset: 'assets/lottie/intro-login.json',
              routeName: AppRoutes.login,
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
              speedMultiplier: 4.0,
            ),
            child: const Text('Ingresar'),
          ),
          const SizedBox(width: 16),
        ],
      ],
    );
  }
}
