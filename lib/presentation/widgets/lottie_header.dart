import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieHeader extends StatelessWidget {
  final String asset;
  final double maxWidth;
  const LottieHeader({super.key, required this.asset, this.maxWidth = 420});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Lottie.asset(
        asset,
        repeat: true,
        frameRate: FrameRate.max,
        fit: BoxFit.contain,
      ),
    );
  }
}
