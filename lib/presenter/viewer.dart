import 'package:flutter/material.dart';
import 'package:focccus_note/presenter/data/keyframe.dart';
import 'package:focccus_note/presenter/painter.dart';
import 'package:focccus_note/presenter/shapes.dart';

class ViewerPage extends StatefulWidget {
  final List<Keyframe> frames;

  ViewerPage(this.frames);

  @override
  _ViewerPageState createState() => _ViewerPageState();
}

class _ViewerPageState extends State<ViewerPage> {
  int current = 0;

  PointerShape pointer;
  Offset lastPointer;

  final focus = FocusNode();

  void nextFrame() {
    if (current < widget.frames.length - 1) {
      setState(() {
        current++;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void prevFrame() {
    if (current > 0)
      setState(() {
        current--;
      });
  }

  @override
  void didChangeDependencies() {
    FocusScope.of(context).requestFocus(focus);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size;

    final includeOldShapes =
        !widget.frames[current].shapes.any((e) => e is PageClearShape);

    //FocusScope.of(context).requestFocus(focus);

    return RawKeyboardListener(
      focusNode: focus,
      onKey: (e) {
        if (e.runtimeType.toString() == 'RawKeyDownEvent') {
          // escape
          if (e.logicalKey.keyId == 0x100070029) {
            Navigator.of(context).pop();
          }
          // right arrow
          if (e.logicalKey.keyId == 0x10007004f) {
            nextFrame();
          }
          if (e.logicalKey.keyLabel == " ") {
            nextFrame();
          }
          // left arrow
          if (e.logicalKey.keyId == 0x100070050) {
            prevFrame();
          }
        }
      },
      child: GestureDetector(
        onTap: nextFrame,
        onPanStart: (e) => setState(
          () => pointer = PointerShape.init(Colors.red),
        ),
        onPanUpdate: (e) {
          if (!(lastPointer != null && e.localPosition == lastPointer))
            setState(
              () {
                pointer.addPoint(e.localPosition / w.width);
                lastPointer = e.localPosition;
              },
            );
        },
        onPanEnd: (e) => setState(
          () => pointer = PointerShape.init(Colors.red),
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Stack(
              children: <Widget>[
                if (includeOldShapes)
                  PresentationPaint(
                    getDisplayShapes(widget.frames.sublist(0, current)),
                    w,
                  ),
                AnimatedPresentationPaint(widget.frames[current], w, current),
                PresentationPaint(
                  [pointer],
                  w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
