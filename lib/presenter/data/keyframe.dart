import 'package:focccus_note/presenter/shapes.dart';
import 'package:hive/hive.dart';

class Keyframe {
  List<Shape> shapes;

  Keyframe(this.shapes);
  Keyframe.init() : shapes = [];

  Keyframe animated(double d) {
    if (d < 0) d = 0;
    var shown = shapes;

    if (shown.isNotEmpty) {
      final currentIndex = ((shapes.length - 1) * d).floor();
      //print("INDEX $currentIndex");
      shown = shapes.sublist(0, currentIndex + 1);
      if (shown.last != null) {
        final timePerShape = 1 / shapes.length;

        final minTime = currentIndex * timePerShape;
        final maxTime = (currentIndex + 1) * timePerShape;

        var shapeTime = (d - minTime) / (maxTime - minTime);

        if (shapeTime > 1) shapeTime = 1;
        if (shapeTime < 0) shapeTime = 0;

        shown[shown.length - 1] = shown.last.animated(shapeTime);
      }
    }

    return Keyframe(shown);
  }

  factory Keyframe.fromJson(Map<String, dynamic> json) => Keyframe(
        (json['shapes'] as List)
            ?.map((e) =>
                e == null ? null : Shape.fromJson(Map<String, dynamic>.from(e)))
            ?.toList(),
      );
  Map<String, dynamic> toJson() => <String, dynamic>{
        'shapes': shapes.map((f) => f?.toJson()).toList(),
      };
}

List<Shape> getDisplayShapes(List<Keyframe> frames, [Keyframe current]) {
  List<Shape> ret = [];
  int index = frames.indexOf(current);
  bool containCurrent = false;

  if (index == -1) {
    index = frames.length - 1;
    if (current != null) containCurrent = true;
  }
  for (var i = 0; i <= index; i++) {
    ret.addAll(frames[i].shapes);
  }
  if (containCurrent) {
    ret.addAll(current.shapes);
  }
  final int clear = ret.lastIndexWhere((s) => s is PageClearShape);
  if (clear > 0) {
    ret = ret.sublist(clear);
  }
  return ret;
}
