import 'package:flutter/material.dart';
import 'package:focccus_note/photo_view/photo_view.dart';
import 'package:focccus_note/presenter/data/douglas_peucker.dart';
import 'package:focccus_note/presenter/data/project.dart';
import 'package:focccus_note/presenter/data/toolmode.dart';
import 'package:focccus_note/presenter/data/keyframe.dart';
import 'package:focccus_note/presenter/painter.dart';
import 'package:focccus_note/presenter/shapes.dart';
import 'package:focccus_note/presenter/viewer.dart';
import 'package:focccus_note/presenter/widgets/modes_bar.dart';
import 'package:focccus_note/presenter/widgets/top_bar.dart';
import 'package:focccus_note/storage/storage.dart';
import 'package:focccus_note/presenter/widgets/background.dart';
import 'package:focccus_note/widgets/change.dart';
import 'package:undo/undo.dart';

import 'frames.dart';

const padding = 128.0;
const CanvasSize = Size(1920, 1080);
const CanvasPSize = Size(1920.0 + padding * 2, 1080.0 + padding * 2);

class PresenterPage extends StatefulWidget {
  final Project prj;
  PresenterPage(this.prj);
  @override
  _PresenterPageState createState() => _PresenterPageState();
}

class _PresenterPageState extends State<PresenterPage>
    with WidgetsBindingObserver {
  final changes = new ChangeStack();

  final focus = FocusNode();

  List<Keyframe> frames = [];
  Keyframe currentFrame;

  Shape currentShape;
  Toolmode toolmode = Toolmode.pen;

  bool get panMode => (toolmode == Toolmode.pan);

  Map<Toolmode, Color> colors = {Toolmode.marker: Colors.yellow.shade200};
  Map<Toolmode, double> strokeSizes = {
    Toolmode.marker: 10,
    Toolmode.eraser: 15
  };
  bool showColor = true;
  bool showStroke = true;

  @override
  void initState() {
    frames = widget.prj.frames;
    currentFrame = frames.length > 0 ? frames.last : Keyframe.init();
    super.initState();
  }

  List<Offset> simplify(List<Offset> p, [double t = 0.0014]) {
    return DouglasPeucker.simplify(
      p,
      tolerance: t,
      highestQuality: false,
    );
  }

  void shapeStart(Offset o) {
    if (frames.isNotEmpty && currentFrame == frames.last) {
      setState(() {
        currentFrame = Keyframe.init();
      });
    }

    o = (o - Offset(padding, padding)) / CanvasSize.width;

    Shape n;
    bool update = true;

    switch (toolmode) {
      case Toolmode.pen:
        {
          n = PenShape.init(getCurrentColor(), getCurrentStroke());
          break;
        }
      case Toolmode.brush:
        {
          n = BezierShape.init(getCurrentColor(), getCurrentStroke(), 0.7);
          break;
        }
      case Toolmode.eraser:
        {
          n = EraserPreviewShape.init(getCurrentStroke() * 2);
          break;
        }
      case Toolmode.marker:
        {
          n = MarkerShape.init(getCurrentColor(), getCurrentStroke());
          break;
        }
      case Toolmode.rect:
        {
          n = RectShape.init(o, getCurrentColor(), getCurrentStroke());
          update = false;
          break;
        }
      case Toolmode.line:
        {
          n = LineShape.init(o, getCurrentColor(), getCurrentStroke());
          update = false;
          break;
        }
      default:
        {}
    }
    if (n != null) {
      currentShape = n;
      if (update) shapeUpdate(o);
    }
  }

  void shapeUpdate(Offset o) {
    if (o.dx > 1) {
      o = (o - Offset(padding, padding)) / CanvasSize.width;
    }

    if (!(CanvasSize / CanvasSize.width).contains(o)) {
      shapeEnd();
      return;
    }
    bool updated = false;

    if (currentShape is PenShape) {
      final points = (currentShape as PenShape).points;
      if (points.isEmpty || points.last.dx != o.dx || points.last.dy != o.dy) {
        (currentShape as PenShape).addPoint(o);
        updated = true;
      }
    }
    if (currentShape is RectShape) {
      (currentShape as RectShape).p2 = o;
      updated = true;
    }
    if (currentShape is LineShape) {
      (currentShape as LineShape).p2 = o;
      updated = true;
    }
    if (currentShape is EraserPreviewShape) {
      (currentShape as EraserPreviewShape).o = o;
      updated = true;
    }
    if (updated) {
      setState(() {});
    }
  }

  void shapeEnd() {
    if (currentShape != null) {
      // prevent little dots when moving
      if (currentShape.length < 4) {
        setState(() {
          currentShape = null;
        });
        return;
      }

      if (currentShape is PenShape) {
        final c = (currentShape as PenShape);
        c.points = simplify(c.points);
        c.calculate();
      }
      if (currentShape is BezierShape) {
        final c = (currentShape as PenShape);
        c.points = simplify(c.points, 0.005);
        c.calculate();
      }

      setState(() {
        if (!currentShape.isEmpty) {
          changes.add(
            TwoClassChange<Keyframe, Shape>(
              currentFrame,
              currentShape,
              (f, v) => f.shapes.add(v),
              (f, v) => f.shapes.remove(v),
            ),
          );
        }

        currentShape = null;
      });
    }
  }

  void changeTool(Toolmode mode) {
    shapeEnd();

    if (toolmode != mode)
      setState(() {
        showColor = true;
        showStroke = true;
        toolmode = mode;
      });
  }

  double getCurrentStroke() {
    if (strokeSizes.containsKey(toolmode))
      return strokeSizes[toolmode] / CanvasSize.width;
    if (toolmode == Toolmode.pan) {
      return null;
    }
    return 4 / CanvasSize.width;
  }

  void setCurrentStroke(double v) {
    shapeEnd();
    setState(() {
      strokeSizes[toolmode] = v;
    });
  }

  Color getCurrentColor() {
    if (colors.containsKey(toolmode)) return colors[toolmode];
    if (toolmode == Toolmode.eraser || toolmode == Toolmode.pan) {
      return null;
    }
    return Colors.black;
  }

  void setCurrentColor(Color c) {
    shapeEnd();
    setState(() {
      colors[toolmode] = c;
    });
  }

  void addFrame() {
    shapeEnd();
    if (!frames.contains(currentFrame))
      setState(() {
        changes.add(
          ClassChange(
            currentFrame,
            (f) => frames.add(f),
            (f) => frames.remove(f),
          ),
        );
      });
  }

  void clearPage() {
    setState(() {
      changes.add(
        TwoClassChange(
          currentFrame,
          currentFrame.shapes,
          (f, oldShapes) => f.shapes = <Shape>[PageClearShape()],
          (f, oldShapes) => f.shapes = oldShapes,
        ),
      );
    });
  }

  void selectFrame(int i) {
    print("select $i");
    if (i < frames.length) {
      setState(() {
        if (!frames.contains(currentFrame)) frames.add(currentFrame);
        currentFrame = frames[i];
      });
    }
  }

  void showFrames() {
    shapeEnd();
    var current = frames.indexOf(currentFrame);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => current > 0
            ? FramesPage(
                frames,
                current,
                onSelect: selectFrame,
              )
            : FramesPage(
                [...frames, currentFrame],
                frames.length,
                onSelect: selectFrame,
              ),
      ),
    );
  }

  void present() {
    focus.unfocus();
    shapeEnd();
    if (!frames.contains(currentFrame)) frames.add(currentFrame);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => ViewerPage(frames),
      ),
    );
  }

  void undo() {
    if (changes.canUndo) {
      setState(() {
        changes.undo();
      });
    }
  }

  void redo() {
    if (changes.canRedo) {
      setState(() {
        changes.redo();
      });
    }
  }

  Future<bool> saveProject() async {
    addFrame();
    widget.prj.frames = frames;
    print("saving...");
    await savePresentation(widget.prj);
    print("saved");
    return true;
  }

  @override
  void didChangeAppLifecycleState(state) {
    print("focus");
    //if (!focus.hasFocus) FocusScope.of(context).requestFocus(focus);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: saveProject,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            PhotoView.customChild(
              //focusNode: focus,
              //enableRotation: true,
              basePosition: Alignment.topCenter,
              onPanStart: panMode ? null : (e) => shapeStart(e.localPosition),
              onPanUpdate: panMode
                  ? null
                  : (e) => currentShape != null
                      ? shapeUpdate(e.localPosition)
                      : null,
              onPanEnd: panMode ? null : (_) => shapeEnd(),
              //enableRotation: true,
              enableDoubleTap: panMode,
              minScale: 0.3,
              maxScale: 10.0,
              initialScale: 1.0,
              backgroundDecoration: BoxDecoration(color: Colors.grey),

              child: Center(
                child: SizedBox(
                  width: CanvasSize.width,
                  height: CanvasSize.height,
                  child: Stack(
                    children: <Widget>[
                      //Container(color: Colors.white),
                      RepaintBoundary(child: BackgroundPaint()),
                      RepaintBoundary(
                        child: PresentationPaint(
                            getDisplayShapes(frames, currentFrame), CanvasSize),
                      ),
                      if (currentShape != null)
                        PresentationPaint([currentShape], CanvasSize)
                    ],
                  ),
                ),
              ),
              childSize: CanvasPSize,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 16),
                child: ModesActionBar(
                  toolmode,
                  onChange: changeTool,
                  onPageClear: clearPage,
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: TopActionBar(
                  getCurrentColor(),
                  getCurrentStroke() == null
                      ? null
                      : getCurrentStroke() * CanvasSize.width,
                  frames.contains(currentFrame),
                  onColorChange: setCurrentColor,
                  onStrokeChange: setCurrentStroke,
                  onAddFrame: addFrame,
                  onViewFrames: showFrames,
                  onPresent: present,
                  onRedo: changes.canRedo ? redo : null,
                  onUndo: changes.canUndo ? undo : null,
                  onBack: () =>
                      saveProject().then((val) => Navigator.pop(context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // @override
  // void dispose() {
  //   focus.unfocus();
  //   super.dispose();
  // }
}
