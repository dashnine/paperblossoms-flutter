import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data_l10n.dart';
import '../rules_constants.dart';

const _ringColors = {
  ringAir: Color(0xFFB59ED1), // lavender
  ringEarth: Color(0xFF5B8C5A), // green
  ringFire: Color(0xFFC94F3D), // red
  ringWater: Color(0xFF4A7BA6), // blue
  ringVoid: Color(0xFF54495E), // dark violet
};

/// The five-elements ring diagram: one circle per ring arranged in a
/// pentagon, sized by rank. Replaces the original app's RingViewer, which
/// composited bitmap rings from colorRings.png.
class RingViewer extends StatelessWidget {
  final Map<String, int> rings;

  const RingViewer({super.key, required this.rings});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _RingPainter(
          rings: rings,
          textColor: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Map<String, int> rings;
  final Color textColor;

  _RingPainter({required this.rings, required this.textColor});

  static const _order = [ringAir, ringEarth, ringFire, ringWater, ringVoid];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final orbit = size.shortestSide * 0.30;
    for (var i = 0; i < _order.length; i++) {
      final ring = _order[i];
      final rank = rings[ring] ?? 0;
      final angle = -math.pi / 2 + i * 2 * math.pi / _order.length;
      final position =
          center + Offset(math.cos(angle) * orbit, math.sin(angle) * orbit);
      final radius = size.shortestSide * (0.07 + 0.022 * rank);
      final color = _ringColors[ring]!;

      canvas.drawCircle(
          position, radius, Paint()..color = color.withValues(alpha: 0.30));
      canvas.drawCircle(
          position,
          radius,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5);

      final label = TextPainter(
        text: TextSpan(
          text: '${trData(ring)}\n$rank',
          style: TextStyle(
              color: textColor, fontSize: size.shortestSide * 0.045),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(
          canvas, position - Offset(label.width / 2, label.height / 2));
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.rings != rings || oldDelegate.textColor != textColor;
}
