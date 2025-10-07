import 'dart:math';
import 'package:flutter/material.dart';

class ParticleBackground extends StatefulWidget {
  final int count;        // cuántas partículas
  final double alpha;     // opacidad [0..1]
  final double speed;     // velocidad base
  final double sizeMin;   // radio mínimo
  final double sizeMax;   // radio máximo

  const ParticleBackground({
    super.key,
    this.count = 60,
    this.alpha = 0.12,
    this.speed = 0.5,
    this.sizeMin = 0.8,
    this.sizeMax = 2.8,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_P> _ps;
  final _rnd = Random();

  @override
  void initState() {
    super.initState();
    _ps = List.generate(
      widget.count,
      (_) => _P.random(_rnd, widget.sizeMin, widget.sizeMax),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )
      ..addListener(() {
        for (final p in _ps) {
          p.t += 0.002 * widget.speed;
          p.x += sin(p.t) * 0.25 * widget.speed;
          p.y += cos(p.t * 0.8) * 0.2 * widget.speed;

          // wrap-around
          if (p.x < -0.1) p.x = 1.1;
          if (p.x > 1.1)  p.x = -0.1;
          if (p.y < -0.1) p.y = 1.1;
          if (p.y > 1.1)  p.y = -0.1;
        }
        setState(() {});
      })
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context)
        .colorScheme
        .primary
        .withValues(alpha: widget.alpha);
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _ParticlePainter(_ps, color),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _P {
  double x, y, r, t;
  _P(this.x, this.y, this.r, this.t);
  factory _P.random(Random rnd, double minR, double maxR) => _P(
        rnd.nextDouble(),
        rnd.nextDouble(),
        rnd.nextDouble() * (maxR - minR) + minR,
        rnd.nextDouble() * pi * 2,
      );
}

class _ParticlePainter extends CustomPainter {
  final List<_P> ps;
  final Color color;
  _ParticlePainter(this.ps, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (final p in ps) {
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.r,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
