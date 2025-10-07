import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LottieScreenTransition {
  /// Lottie sobre fondo sólido con control de velocidad y sin parpadeo.
  static Future<void> playAndNavigate(
    BuildContext context, {
    required String asset,
    required String routeName,
    Duration minDuration = const Duration(milliseconds: 650),
    Duration maxDuration = const Duration(milliseconds: 1200),
    Color? backgroundColor,
    double maxWidth = 420,
    double speedMultiplier = 1.8, // >1.0 = más rápida
  }) async {
    final overlayState = Overlay.of(context);
    final theme = Theme.of(context);
    final bg = backgroundColor ??
        (theme.brightness == Brightness.dark ? Colors.black : Colors.white);

    final completer = Completer<void>();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Material(
        color: bg,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: _SpeedyLottie(
              asset: asset,
              speedMultiplier: speedMultiplier,
              onReady: (actualDuration) {
                var desired = actualDuration;
                if (desired < minDuration) desired = minDuration;
                if (desired > maxDuration) desired = maxDuration;

                Future.delayed(desired).then((_) {
                  if (!completer.isCompleted) completer.complete();
                });
              },
              onError: () {
                if (!completer.isCompleted) completer.complete();
              },
            ),
          ),
        ),
      ),
    );

    overlayState.insert(entry);

    // Espera a que termine la animación
    await completer.future;

    // Navega SIN await para evitar bloqueos
    Get.offNamed(routeName);

    // Pequeño delay para asegurar que la navegación inicie
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Remueve el overlay
    entry.remove();
  }
}

/// Widget interno que acelera la animación Lottie
class _SpeedyLottie extends StatefulWidget {
  const _SpeedyLottie({
    required this.asset,
    required this.speedMultiplier,
    required this.onReady,
    required this.onError,
  });

  final String asset;
  final double speedMultiplier;
  final void Function(Duration acceleratedDuration) onReady;
  final VoidCallback onError;

  @override
  State<_SpeedyLottie> createState() => _SpeedyLottieState();
}

class _SpeedyLottieState extends State<_SpeedyLottie>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      widget.asset,
      controller: _controller,
      fit: BoxFit.contain,
      repeat: false,
      frameRate: FrameRate.max,
      onLoaded: (composition) {
        try {
          final original = composition.duration;
          final accelerated = Duration(
            milliseconds:
                (original.inMilliseconds / widget.speedMultiplier).round(),
          );
          _controller
            ..duration = accelerated
            ..forward();

          widget.onReady(accelerated);
        } catch (_) {
          widget.onError();
        }
      },
      errorBuilder: (_, __, ___) {
        WidgetsBinding.instance.addPostFrameCallback((_) => widget.onError());
        return const SizedBox.shrink();
      },
    );
  }
}