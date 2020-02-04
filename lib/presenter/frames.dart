import 'package:flutter/material.dart';
import 'package:focccus_note/presenter/data/keyframe.dart';
import 'package:focccus_note/presenter/painter.dart';
import 'package:snaplist/snaplist.dart';
import 'package:snaplist/snaplist_view.dart';

class FramesPage extends StatelessWidget {
  final List<Keyframe> frames;
  final int current;
  final void Function(int) onSelect;

  FramesPage(this.frames, this.current, {this.onSelect});

  @override
  Widget build(BuildContext context) {
    final controller = SnaplistController(initialPosition: current);

    final w = MediaQuery.of(context).size.width;

    Size size = Size(w, w / 16 * 9) * 0.65;

    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(title: Text("Frames")),
      body: SnapList(
        snaplistController: controller,
        sizeProvider: (index, data) => size,
        separatorProvider: (index, data) => Size(16.0, 16.0),
        builder: (context, index, data) {
          return GestureDetector(
            onTap: () {
              if (onSelect != null) onSelect(index);
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: index == current
                    ? Border.all(color: Colors.black, width: 2)
                    : null,
                boxShadow: index == data.next
                    ? [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(5, 5),
                          blurRadius: 15,
                        )
                      ]
                    : null,
              ),
              child: RepaintBoundary(
                child: PresentationPaint(
                  getDisplayShapes(frames, frames[index]),
                  size,
                ),
              ),
            ),
          );
        },
        count: frames.length,
        padding: EdgeInsets.only(left: (w - size.width) / 2),
      ),
    );
  }
}
