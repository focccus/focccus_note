import 'package:flutter/material.dart';

IconData getToolIcon(Toolmode m) {
  switch (m) {
    case Toolmode.eraser:
      return Icons.delete_sweep;
    case Toolmode.pen:
      return Icons.gesture;
    case Toolmode.brush:
      return Icons.brush;
    case Toolmode.marker:
      return Icons.format_paint;
    case Toolmode.rect:
      return Icons.crop_square;
    case Toolmode.line:
      return Icons.remove;
    case Toolmode.pan:
      return Icons.pan_tool;
    default:
      return Icons.do_not_disturb_off;
  }
}

enum Toolmode {
  eraser,
  pen,
  brush,
  marker,
  rect,
  line,
  pan,
}
