import 'dart:math';

import 'dart:ui';

/// CREDIT: Darwin Morocho

class DouglasPeucker {
  /// polyline simplification  it uses a combination of Douglas-Peucker and Radial Distance algorithms.
  ///
  /// [points] List<Offset>
  /// [tolerance] double tolerance
  /// [highestQuality] bool
  static List<Offset> simplify(List<Offset> points,
      {double tolerance = 1, bool highestQuality = false}) {
    if (points.length <= 2) {
      return points;
    }

    final sqTolerance = pow(tolerance, 2);

    if (!highestQuality) {
      points = simplifyRadialDistance(points, sqTolerance);
    }

    points = simplifyDouglasPeucker(points, sqTolerance);

    return points;
  }

  static List<Offset> simplifyRadialDistance(
      List<Offset> points, double sqTolerance) {
    var prevOffset = points[0];
    var newOffsets = List<Offset>();
    newOffsets.add(prevOffset);
    Offset point;

    for (Offset iOffset in points) {
      point = iOffset;
      if (getSquareDistance(point, prevOffset) > sqTolerance) {
        newOffsets.add(point);
        prevOffset = point;
      }
    }

    if (prevOffset.dx != point.dx && prevOffset.dy != point.dy) {
      newOffsets.add(point);
    }

    return newOffsets;
  }

  static getSquareDistance(Offset p1, Offset p2) {
    final dx = p1.dx - p2.dx;
    final dy = p1.dy - p2.dy;
    return pow(dx, 2) + pow(dy, 2);
  }

  static getSquareSegmentDistance(Offset p, Offset p1, Offset p2) {
    var x = p1.dx;
    var y = p1.dy;
    var dx = p2.dx - x;
    var dy = p2.dy - y;
    if (dx != 0 || dy != 0) {
      final t = ((p.dx - x) * dx + (p.dy - y) * dy) / (dx * dx + dy * dy);
      if (t > 1) {
        x = p2.dx;
        y = p2.dy;
      } else if (t > 0) {
        x += dx * t;
        y += dy * t;
      }
    }
    dx = p.dx - x;
    dy = p.dy - y;
    return dx * dx + dy * dy;
  }

  static List<Offset> simplifyDouglasPeucker(
      List<Offset> points, double sqTolerance) {
    final len = points.length;
    var markers = List<int>.filled(len, 0, growable: true);
    var first = 0;
    var last = len - 1;
    var firstStack = List<int>();
    var lastStack = List<int>();
    var newOffsets = List<Offset>();

    markers[first] = markers[last] = 1;
    var index = 0;

    while (true) {
      double maxSqDist = 0;
      for (var i = first + 1; i < last; i++) {
        var sqDist =
            getSquareSegmentDistance(points[i], points[first], points[last]);

        if (sqDist > maxSqDist) {
          index = i;
          maxSqDist = sqDist;
        }
      }

      if (maxSqDist > sqTolerance) {
        markers[index] = 1;

        firstStack.add(first);
        lastStack.add(index);
        firstStack.add(index);
        lastStack.add(last);
      }

      if (firstStack.length == 0 || lastStack.length == 0) {
        break;
      }

      first = firstStack.removeLast();
      last = lastStack.removeLast();
    }

    for (var i = 0; i < len; i++) {
      if (markers[i] != null) {
        newOffsets.add(points[i]);
      }
    }

    return newOffsets;
  }
}