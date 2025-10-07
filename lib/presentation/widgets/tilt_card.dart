import 'dart:math';
import 'package:flutter/material.dart';

class TiltCard extends StatefulWidget {
  final Widget child;
  final double maxTilt;      // grados
  final Duration speed;      // suavizado
  final bool enabled;        //  desactivarlo en mobile

  const TiltCard({
    super.key,
    required this.child,
    this.maxTilt = 10,
    this.speed = const Duration(milliseconds: 140),
    this.enabled = true,
  });

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  double _rx = 0, _ry = 0; // radianes

  void _to(double rx, double ry) => setState(() { _rx = rx; _ry = ry; });

  void _onMove(PointerEvent e, Size s) {
    if (!widget.enabled) return;
    final px = (e.localPosition.dx / s.width).clamp(0, 1);
    final py = (e.localPosition.dy / s.height).clamp(0, 1);
    final nx = (px * 2 - 1); // [-1,1]
    final ny = (py * 2 - 1);
    final rad = (pi / 180) * widget.maxTilt;
    _to(ny * rad, -nx * rad); // rotX, rotY
  }

  void _reset() => _to(0, 0);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => MouseRegion(
        onExit: (_) => _reset(),
        child: Listener(
          onPointerHover: (e) => _onMove(e, Size(c.maxWidth, c.maxHeight)),
          onPointerMove:  (e) => _onMove(e, Size(c.maxWidth, c.maxHeight)),
          onPointerUp: (_) => _reset(),
          onPointerCancel: (_) => _reset(),
          child: AnimatedContainer(
            duration: widget.speed,
            transformAlignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateX(_rx)
              ..rotateY(_ry),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
