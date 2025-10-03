import 'dart:math';
import 'package:flutter/material.dart';

class TiltCard extends StatefulWidget {
  final Widget child;
  final double maxTilt;
  const TiltCard({super.key, required this.child, this.maxTilt = 10});

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  double _dx = 0, _dy = 0;

  void _onPointerMove(PointerEvent e, Size s) {
    final px = e.localPosition.dx.clamp(0, s.width);
    final py = e.localPosition.dy.clamp(0, s.height);
    final nx = (px / s.width) * 2 - 1;   // [-1,1]
    final ny = (py / s.height) * 2 - 1;  // [-1,1]
    setState(() {
      _dx = -nx * widget.maxTilt * (pi / 180);
      _dy = ny * widget.maxTilt * (pi / 180);
    });
  }

  void _reset() => setState(() { _dx = 0; _dy = 0; });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      return Listener(
        onPointerHover: (e) => _onPointerMove(e, Size(c.maxWidth, c.maxHeight)),
        onPointerMove: (e) => _onPointerMove(e, Size(c.maxWidth, c.maxHeight)),
        onPointerUp: (_) => _reset(),
        onPointerCancel: (_) => _reset(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateX(_dy)
            ..rotateY(_dx),
          child: widget.child,
        ),
      );
    });
  }
}
