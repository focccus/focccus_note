import 'package:flutter/material.dart';

class PenInputField extends StatefulWidget {
  final PenInputLayout layout;

  PenInputField(this.layout);

  @override
  _PenInputFieldState createState() => _PenInputFieldState();
}

class _PenInputFieldState extends State<PenInputField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.layout.height,
      child: LayoutBuilder(
        builder: (context, size) => Row(
          children: <Widget>[
            Container(
              width: size.maxWidth * widget.layout.nextInputRatio,
              child: Container(
                color: Colors.red,
              ),
            ),
            Expanded(
              flex: 100,
              child: CustomPaint(
                painter: BackgroundPainter(
                  widget.layout.topLineRatio,
                  widget.layout.bottomLineRatio,
                ),
                size: Size(size.maxHeight, widget.layout.height),
              ),
            ),
            if (widget.layout.showWristArea)
              Container(
                width: size.maxWidth * widget.layout.wristRatio,
                child: Container(
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double line1;
  final double line2;

  BackgroundPainter(this.line1, this.line2);

  @override
  void paint(Canvas canvas, Size size) {
    Paint back = Paint()..color = Colors.grey;

    Paint lines = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), back);

    canvas.drawLine(
      Offset(0, size.height * line1),
      Offset(size.width, size.height * line1),
      lines,
    );

    canvas.drawLine(
      Offset(0, size.height * (1 - line2)),
      Offset(size.width, size.height * (1 - line2)),
      lines,
    );
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) {
    return line1 * line2 == oldDelegate.line1 * oldDelegate.line2;
  }
}

class PenInputLayout {
  bool showWristArea;

  double height;

  double topLineRatio;
  double bottomLineRatio;

  double wristRatio;

  double nextInputRatio;

  PenInputLayout(
    this.height, {
    this.showWristArea = false,
    this.topLineRatio = 1 / 3,
    this.bottomLineRatio = 1 / 3,
    this.wristRatio,
    this.nextInputRatio = 1 / 5,
  });
}
