import 'package:flutter/material.dart';

class BackgroundPaint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (c, size) => CustomPaint(
        foregroundPainter: _BackgroundPainter(),
        size: Size(size.maxWidth, size.maxHeight),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size size) {
    final p = Paint()..color = Colors.grey.shade400;

    c.drawRect(
      Rect.fromPoints(Offset.zero, size.bottomRight(Offset.zero)),
      Paint()..color = Colors.white,
    );

    for (var i = 40.0; i < size.width; i += 40) {
      c.drawLine(Offset(i, 0), Offset(i, size.height), p);
    }
    for (var i = 40.0; i < size.height; i += 40) {
      c.drawLine(Offset(0, i), Offset(size.width, i), p);
    }
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) => false;
}
