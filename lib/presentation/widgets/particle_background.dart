import 'dart:math';
import 'package:flutter/material.dart';

class ParticleBackground extends StatefulWidget {
  final int count;
  const ParticleBackground({super.key, this.count = 40});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_P> _ps;
  final _rnd = Random();

  @override
  void initState() {
    super.initState();
    _ps = List.generate(widget.count, (_) => _P.random(_rnd));
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..addListener(() {
        for (final p in _ps) {
          p.t += 0.002;
          p.x += sin(p.t) * 0.3;
          p.y += cos(p.t * 0.8) * 0.25;
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
    return IgnorePointer(
      child: CustomPaint(
        painter: _ParticlePainter(_ps, Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _P {
  double x, y, r, t;
  _P(this.x, this.y, this.r, this.t);
  factory _P.random(Random rnd) => _P(
    rnd.nextDouble(), rnd.nextDouble(),
    rnd.nextDouble() * 2.2 + 0.8, rnd.nextDouble() * pi * 2,
  );
}

class _ParticlePainter extends CustomPainter {
  final List<_P> ps;
  final Color color;
  _ParticlePainter(this.ps, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    for (final p in ps) {
      final dx = (p.x % 1) * size.width;
      final dy = (p.y % 1) * size.height;
      canvas.drawCircle(Offset(dx, dy), p.r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
