import 'dart:math';

import 'package:flutter/material.dart';

extension OffsetJson on Offset {
  List<double> toJson() => [this.dx, this.dy];
  static Offset fromJson(List<double> l) => Offset(l[0], l[1]);
}

List<Offset> _getPoints(List<dynamic> json) {
  List<Offset> offsets = [];
  for (var i = 0; i < json.length - 1; i += 2) {
    offsets.add(Offset(json[i], json[i + 1]));
  }
  return offsets;
}

List<double> _jsonPoints(List<Offset> points) {
  List<double> ret = [];
  points.forEach((p) {
    ret.addAll(p.toJson());
  });
  return ret;
}

abstract class Shape {
  void paint(Canvas c, Size size);
  Shape animated(double d);

  static Shape fromJson(Map<String, dynamic> json) {
    final type = (json["type"] as String);
    switch (type) {
      case 'page_clear':
        return PageClearShape.fromJson(json);
      case 'pen':
        return PenShape.fromJson(json);
      case 'bezier':
        return BezierShape.fromJson(json);
      case 'marker':
        return MarkerShape.fromJson(json);
      case 'rect':
        return RectShape.fromJson(json);
      case 'line':
        return LineShape.fromJson(json);
    }
    return null;
  }

  bool get isEmpty;
  int get length;

  Map<String, dynamic> toJson();
  bool collides(Offset o, double d);
}

class PageClearShape extends Shape {
  bool get isEmpty => false;
  int get length => 0;

  PageClearShape();

  factory PageClearShape.fromJson(json) => PageClearShape();

  @override
  void paint(Canvas c, Size size) {}

  PageClearShape animated(double d) => this;
  @override
  bool collides(o, d) => false;

  Map<String, dynamic> toJson() => {'type': 'page_clear'};
}

class EraserPreviewShape extends Shape {
  Offset o;
  double width;

  bool get isEmpty => o == null;
  int get length => 0;

  EraserPreviewShape();
  EraserPreviewShape.init(this.width);

  factory EraserPreviewShape.fromJson(json) => null;

  @override
  void paint(Canvas c, Size size) {
    if (o != null) {
      final p = Paint()..color = Colors.grey;

      c.drawCircle(o * size.width, width / 2 * size.width, p);
    }
  }

  EraserPreviewShape animated(double d) => this;
  @override
  bool collides(o, d) => false;

  Map<String, dynamic> toJson() => {};
}

class PenShape extends Shape {
  List<Offset> points;
  Color color;
  double strokeWidth;
  Path path;

  void addPoint(Offset o) {
    if (o != null) points.add(o);
    calculate();
  }

  void calculate() {
    if (points.length > 1) {
      path = Path()
        ..fillType = PathFillType.nonZero
        ..moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }
  }

  bool collides(o, d) {
    if (!path.getBounds().contains(o)) return false;
    if (path.contains(o)) return true;

    for (var p in points) {
      if ((o - p).distanceSquared <= pow(d + strokeWidth, 2)) return true;
    }

    return false;
  }

  PenShape(this.points, this.color, this.strokeWidth) {
    calculate();
  }

  PenShape.init(this.color, this.strokeWidth) : points = [];

  factory PenShape.fromJson(json) => PenShape(
        _getPoints(json['points']),
        Color(json['color']),
        json['stroke'],
      );

  bool get isEmpty => points.isEmpty;
  int get length => points.length * 2;

  PenShape animated(double d) => PenShape(
        points.sublist(0, (d * (points.length - 1)).round() + 1),
        color,
        strokeWidth,
      );

  @override
  void paint(Canvas c, size) {
    final p = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth * size.width;

    if (path != null) {
      var _path = path.transform(
        Matrix4.diagonal3Values(size.width, size.width, size.width).storage,
      );

      c.drawPath(_path, p);
    } else if (points.length > 0) {
      c.drawCircle(points.first * size.width, strokeWidth / 2, p);
    }
  }

  // @override
  // bool collides(o, d) => ;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'pen',
        'points': _jsonPoints(points),
        'color': color.value,
        'stroke': strokeWidth,
      };
}

class BezierShape extends PenShape {
  final double tension;
  BezierShape(
      List<Offset> points, Color color, double strokeWidth, this.tension)
      : super(points, color, strokeWidth);
  BezierShape.init(Color color, double strokeWidth, this.tension)
      : super([], color, strokeWidth);

  factory BezierShape.fromJson(json) => BezierShape(
        _getPoints(json['points']),
        Color(json['color']),
        json['stroke'],
        json['tension'],
      );

  BezierShape animated(double d) => BezierShape(
        points.sublist(0, (d * (points.length - 1)).round() + 1),
        color,
        strokeWidth,
        tension,
      );

  void calculate() {
    if (points.length > 1) {
      final control_scale = tension / 0.5 * 0.175;

      path = Path()
        ..fillType = PathFillType.nonZero
        ..moveTo(points.first.dx, points.first.dy);
      for (var i = 0; i < points.length - 2; i++) {
        final p1 = points[i];
        final p4 = points[i + 1];
        final p_before = i != 0 ? points[i - 1] : p1;
        final p_after = i < points.length - 2 ? points[i + 2] : p4;

        var dp = p4 - p_before;

        final p2 = p1 + (dp * control_scale);

        dp = p_after - p1;

        final p3 = p4 - (dp * control_scale);

        path.cubicTo(p2.dx, p2.dy, p3.dx, p3.dy, p4.dx, p4.dy);
      }

      if ((points.last - points.first).distance <= 0.002) {
        path.close();
      }
    }
  }

  @override
  void paint(Canvas c, size) {
    final p = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth * size.width;

    if (path != null) {
      final _path = path.transform(
          Matrix4.diagonal3Values(size.width, size.width, size.width).storage);
      c.drawPath(_path, p);
    } else {
      c.drawCircle(points.first, strokeWidth / 2, p);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final ret = super.toJson();
    ret['type'] = 'bezier';
    ret['tension'] = tension;
    return ret;
  }
}

class PointerShape extends Shape {
  List<Offset> points;
  Color color;
  int get length => points.length;

  void addPoint(Offset o) {
    points.add(o);
    if (points.length > 50) {
      points = points.sublist(1);
    }
  }

  PointerShape(this.points, this.color);
  PointerShape.init(this.color) : points = [];

  bool get isEmpty => points.isEmpty;

  bool collides(o, d) => false;

  @override
  void paint(Canvas c, size) {
    final p = Paint()
      ..color = color
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.01 * size.width;
    if (points.length > 1) {
      for (var i = 1; i < points.length; i++) {
        p.color = color.withAlpha((i / (points.length - 1) * 250).round());
        c.drawLine(points[i - 1] * size.width, points[i] * size.width, p);
      }
    } else if (points.length > 0) {
      c.drawCircle(points.first * size.width, 2, p);
    }
  }

  PointerShape animated(double d) => this;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'pointer',
        'points': _jsonPoints(points),
        'color': color.value,
        'stroke': 0.01,
      };
}

class MarkerShape extends PenShape {
  MarkerShape(List<Offset> points, Color color, double strokeWidth)
      : super(points, color, strokeWidth);
  MarkerShape.init(Color color, double strokeWidth)
      : super([], color, strokeWidth);

  factory MarkerShape.fromJson(json) => MarkerShape(
        _getPoints(json['points']),
        Color(json['color']),
        json['stroke'],
      );

  MarkerShape animated(double d) => MarkerShape(
        points.sublist(0, (d * (points.length - 1)).round() + 1),
        color,
        strokeWidth,
      );

  @override
  void paint(Canvas c, size) {
    final p = Paint()
      // ..blendMode = BlendMode.dstATop
      ..color = color.withOpacity(0.5)
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.bevel
      ..strokeWidth = strokeWidth * 2 * size.width;

    if (path != null) {
      var _path = path.transform(
        Matrix4.diagonal3Values(size.width, size.width, size.width).storage,
      );

      c.drawPath(_path, p);
    } else if (points.length > 0) {
      c.drawCircle(points.first * size.width, strokeWidth / 2, p);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final ret = super.toJson();
    ret['type'] = 'marker';
    return ret;
  }
}

class RectShape extends Shape {
  Offset p1;
  Offset p2;
  Color color;
  double strokeWidth;
  int get length => ((p2.dx - p1.dx) * 100).abs().toInt();

  RectShape(this.p1, this.p2, this.color, this.strokeWidth);
  RectShape.init(this.p1, this.color, this.strokeWidth);

  factory RectShape.fromJson(json) => RectShape(
        Offset(json['p1'][0], json['p1'][1]),
        Offset(json['p2'][0], json['p2'][1]),
        Color(json['color']),
        json['stroke'],
      );

  bool get isEmpty => p1 == null || p2 == null;

  RectShape animated(double d) => RectShape(
        p1,
        p1 + (p2 - p1) * d,
        color,
        strokeWidth,
      );

  bool collides(o, d) {
    d = d + strokeWidth / 2;
    final r = Rect.fromPoints(p1, p2);
    final dc = (o - r.center);

    if (dc.dx.abs() > (r.width / 2 + d)) return false;
    if (dc.dy.abs() > (r.height / 2 + d)) return false;
    if (dc.dx.abs() < (r.width / 2 - d)) return false;
    if (dc.dy.abs() < (r.height / 2 - d)) return false;

    return true;
  }

  @override
  void paint(Canvas c, size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * size.width;

    c.drawRect(Rect.fromPoints(p1 * size.width, p2 * size.width), p);
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'rect',
        'p1': p1.toJson(),
        'p2': p2.toJson(),
        'color': color.value,
        'stroke': strokeWidth,
      };
}

class LineShape extends Shape {
  Offset p1;
  Offset p2;
  Color color;
  double strokeWidth;
  int get length => ((p2.dx - p1.dx) * 100).abs().toInt();

  LineShape(this.p1, this.p2, this.color, this.strokeWidth);
  LineShape.init(this.p1, this.color, this.strokeWidth);

  factory LineShape.fromJson(json) => LineShape(
        Offset(json['p1'][0], json['p1'][1]),
        Offset(json['p2'][0], json['p2'][1]),
        Color(json['color']),
        json['stroke'],
      );

  bool get isEmpty => p1 == null || p2 == null;

  LineShape animated(double d) => LineShape(
        p1,
        p1 + (p2 - p1) * d,
        color,
        strokeWidth,
      );

  @override
  void paint(Canvas c, size) {
    final p = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth * size.width;

    c.drawLine(p1 * size.width, p2 * size.width, p);
  }

  bool collides(o, d) {
    d = d + strokeWidth;

    final d1 = (p1 - o).distance;
    final d2 = (p2 - o).distance;

    final lineLength = (p2 - p1).distance;

    if (d1 + d2 >= lineLength - d && d1 + d2 <= lineLength + d) {
      return true;
    }
    return false;
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'line',
        'p1': p1.toJson(),
        'p2': p2.toJson(),
        'color': color.value,
        'stroke': strokeWidth,
      };
}
