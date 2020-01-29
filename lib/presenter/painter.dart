import 'package:flutter/material.dart';
import 'package:focccus_note/presenter/data/keyframe.dart';
import 'package:focccus_note/presenter/shapes.dart';

class PresentationPaint extends StatelessWidget {
  final List<Shape> shapes;
  final Size size;
  final bool forceUpdate;

  PresentationPaint(this.shapes, this.size, {this.forceUpdate = false});

  @override
  Widget build(BuildContext context) {
    final painter = _PresentationPainter(shapes, forceUpdate);
    return CustomPaint(
      willChange: false,
      isComplex: true,
      foregroundPainter: painter,
      size: size,
    );
  }
}

class AnimatedPresentationPaint extends StatelessWidget {
  final Keyframe frame;
  final Size size;
  final int currentAnimation;

  AnimatedPresentationPaint(this.frame, this.size, this.currentAnimation);

  Widget build(BuildContext context) {
    final int dur = frame.shapes.isNotEmpty
        ? (frame.shapes
                    .map((s) => s.length)
                    .toList()
                    .reduce((value, element) => value + element) *
                2)
            .round()
        : 0;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: currentAnimation.toDouble() + 1),
      duration: Duration(milliseconds: dur),
      builder: (c, double value, w) {
        return PresentationPaint(
          frame.animated(value - currentAnimation).shapes,
          size,
          forceUpdate: true,
        );
      },
    );
  }
}

class _PresentationPainter extends CustomPainter {
  final List<Shape> shapes;
  final bool forceUpdate;

  int get length => shapes != null ? shapes.length : 0;

  _PresentationPainter(this.shapes, this.forceUpdate);

  @override
  void paint(Canvas canvas, Size size) {
    if (length > 1) {
      final pShapes = List<Shape>.from(shapes);
      pShapes.sort((s1, s2) {
        return s2 is MarkerShape ? 1 : 0;
      });
      pShapes.forEach(
          (s) => s == null || s.isEmpty ? null : s.paint(canvas, size));
    } else if (length == 1) {
      if (shapes.first != null && !shapes.first.isEmpty) {
        shapes.first.paint(canvas, size);
      }
    }
  }

  @override
  bool shouldRepaint(_PresentationPainter old) {
    return shapes.isNotEmpty &&
        (forceUpdate || length != old.length || shapes.last is PointerShape);
  }
}
