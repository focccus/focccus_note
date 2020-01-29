import 'package:flutter/material.dart';
import 'package:focccus_note/photo_view/photo_view.dart';
import 'package:focccus_note/presenter/home.dart';
import 'package:focccus_note/presenter/presenter.dart';
import 'package:focccus_note/widgets/pen_input.dart';

class TransformationsDemo extends StatefulWidget {
  final GesturePosition gesturePosition = GesturePosition();

  @override
  _TransformationsDemoState createState() => _TransformationsDemoState();
}

class _TransformationsDemoState extends State<TransformationsDemo> {
  List<Offset> points = [];
  bool translate = false;
  Rect rect = Rect.fromLTWH(100, 100, 100, 100);
  bool _editingRect = false;

  FocusNode f = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //c.updateMultiple(position: Offset(0,0));

    double width = MediaQuery.of(context).size.width;
    FocusScope.of(context).requestFocus(f);

    return Scaffold(
      appBar: AppBar(
        title: const Text('2D Tranformations'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.personal_video),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (c) => HomePage())),
          ),
          IconButton(
            icon: Icon(Icons.swap_calls,
                color: translate ? Colors.red : Colors.white),
            onPressed: () => setState(() => translate = !translate),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          PhotoView.customChild(
            //enableRotation: true,
            basePosition: Alignment.topCenter,
            onTapDown: (_, d, v) => widget.gesturePosition.onTapDown(d),
            onTapUp: (_, d, v) => widget.gesturePosition.onTapUp(d),
            onPanStart: (d) => widget.gesturePosition.onDragStart(d),
            onPanUpdate: translate ? null : widget.gesturePosition.onDragUpdate,
            onPanEnd: (d) => widget.gesturePosition.onDragEnd(d),
            // : (_) => setState(() => points.add(_.localPosition)),
            //enableRotation: true,
            enableDoubleTap: true,
            minScale: 0.2,

            maxScale: 10.0,

            child: Stack(
              children: <Widget>[
                CustomPaint(
                  painter: BoardPainter(points),
                  size: Size(width, 2000),
                ),
                ResizeableWidget(
                  widget.gesturePosition,
                  boundingBox: rect,
                  child: Container(
                    color: Colors.white,
                    child: Text(
                        """Lorem ipsum dolor sit amet, consectetur adipiscing elit. In sagittis massa in auctor posuere. Phasellus vel turpis feugiat, faucibus leo sed, bibendum tortor. Etiam pulvinar leo mauris, ut varius erat tristique non. Praesent fringilla mollis interdum. Proin eros ante, gravida nec quam in, mollis pharetra leo. Vivamus sed tincidunt justo. Fusce non suscipit leo. Aenean congue risus tincidunt, varius arcu et, varius odio. Donec rhoncus eget sapien sed iaculis. Proin gravida diam vitae dictum sodales. Duis at consequat neque, a viverra quam. Nullam dignissim erat eget lacus lobortis, sed mollis nunc sagittis. Cras egestas vel mauris vitae semper. Ut vel risus nisl. Vestibulum id ligula id tortor vulputate auctor.

Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nullam vitae urna sagittis, varius nisi sit amet, tempor neque. Nunc nec malesuada nisi, a hendrerit mi. Vestibulum vel porta est, vitae pellentesque eros. Nulla quis nunc at magna facilisis rhoncus in in dui. Sed sed gravida mi. Nam sagittis dui at sagittis faucibus. Cras ac dictum nisi, a porta nulla. Vestibulum dictum sagittis lectus sed vestibulum. Nulla ac nisl at nunc fringilla varius. Aliquam rutrum et sapien eu ullamcorper. Phasellus vitae felis non mauris interdum dapibus et id dui. Etiam in pretium neque. Nam tincidunt, ipsum eget aliquam accumsan, ligula purus pulvinar lectus, id varius velit tortor a magna. Pellentesque venenatis tincidunt scelerisque. Maecenas dignissim, risus nec eleifend condimentum, est ipsum ullamcorper ipsum, ut dignissim arcu diam ut leo.

Etiam maximus tempus dolor, ultrices condimentum lectus consectetur at. Nam non turpis nisl. Integer ac justo a dui sollicitudin fermentum sed facilisis odio. Curabitur mollis, massa id lacinia volutpat, dui augue placerat risus, nec dapibus erat turpis non neque. Donec pellentesque consequat nibh, vel pharetra lacus laoreet ac. Morbi sit amet nibh id lectus suscipit finibus sed ut lacus. In id purus erat. Ut a diam porttitor massa lobortis efficitur sed et dolor. Ut pretium urna sed molestie sagittis. Curabitur in ligula nulla. In ligula orci, volutpat eget imperdiet eu, condimentum non purus. Integer viverra nisl convallis venenatis fermentum. Aliquam neque nisl, consequat vel purus vitae, pellentesque porta purus. Ut nec posuere mauris. Duis efficitur pellentesque metus sed elementum. Fusce id vestibulum est, vitae posuere nisi.

Aliquam tempor faucibus nunc, sit amet tristique dui varius vel. Sed finibus lectus vel nunc dictum, non venenatis turpis scelerisque. Donec eu mi faucibus, imperdiet magna eget, ullamcorper velit. Phasellus vel mauris massa. Mauris eu dolor fermentum neque pellentesque tincidunt pellentesque vehicula neque. In aliquet iaculis dui. Ut eu dictum tortor. Nunc laoreet tincidunt ex, non placerat sapien mattis eu. Fusce mollis sagittis massa aliquet sodales. Quisque facilisis ipsum nulla, commodo luctus neque aliquam et. Etiam pulvinar convallis orci, sit amet hendrerit ligula hendrerit vel. Donec interdum placerat massa a rhoncus. Morbi at auctor lectus. Sed ac dictum ante, vulputate vulputate libero.

Aliquam at lorem suscipit, porttitor tellus nec, tempus ligula. Praesent quis vestibulum arcu. Pellentesque laoreet est sit amet velit tempor posuere. Curabitur eu mauris blandit, blandit sem ac, auctor nulla. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nam ultricies, enim id placerat volutpat, erat orci lobortis massa, sit amet semper tortor lacus quis urna. Donec vel ullamcorper elit."""),
                  ),
                )
              ],
            ),
            childSize: Size(width, 2000),
          ),
          PenInputField(
            PenInputLayout(
              200,
              wristRatio: 1 / 5,
              showWristArea: true,
            ),
          ),
        ],
      ),
    );
  }
}

class GesturePosition {
  final Listener<DragUpdateDetails> onDrag = Listener();
  final Listener<DragStartDetails> onDragStart = Listener();
  final Listener<DragUpdateDetails> onDragUpdate = Listener();
  final Listener<DragEndDetails> onDragEnd = Listener();
  final Listener<TapDownDetails> onTapDown = Listener();
  final Listener<TapUpDetails> onTapUp = Listener();
}

class ResizeableWidget extends StatefulWidget {
  final GesturePosition gesture;
  final Rect boundingBox;
  final Widget child;

  ResizeableWidget(this.gesture, {this.boundingBox, @required this.child});

  @override
  _ResizeableWidgetState createState() => _ResizeableWidgetState();
}

class _ResizeableWidgetState extends State<ResizeableWidget> {
  Rect boundingBox;
  bool selected = false;
  bool _moving = false;
  bool _scaling = false;

  Rect handler1;
  Rect handler2;
  bool handler1Moving = false;
  bool handler2Moving = false;

  @override
  void initState() {
    boundingBox = widget.boundingBox;
    _calcHandlers();
    widget.gesture.onTapDown.listen(
      (l) => boundingBox.inflate(6).contains(l.localPosition)
          ? onTapDown(l.localPosition)
          : null,
    );
    widget.gesture.onTapUp.listen(onTapUp);
    widget.gesture.onDragStart.listen(
      (l) => boundingBox.inflate(6).contains(l.localPosition)
          ? onDragStart(l)
          : null,
    );
    widget.gesture.onDragUpdate.listen(onDragUpdate);
    widget.gesture.onDragEnd.listen(onDragEnd);
    super.initState();
  }

  void onTapDown(Offset pos) {
    if (selected && !_moving)
      setState(() {
        if (handler1.contains(pos)) {
          handler1Moving = true;
        } else if (handler2.inflate(2).contains(pos)) {
          handler2Moving = true;
        } else {
          _moving = true;
        }
      });
  }

  void onTapUp(TapUpDetails d) {
    if (boundingBox.inflate(4).contains(d.localPosition)) {
      print("ahh");
      setState(() {
        selected = true;
        _calcHandlers();
      });
    } else {
      if (selected)
        setState(() {
          selected = false;
          _moving = false;
        });
    }
  }

  void onDragStart(DragStartDetails d) {
    if (selected)
      setState(() {
        _moving = true;
      });
  }

  void onDragEnd(DragEndDetails d) {
    print(d);
    if (_moving || handler1Moving || handler2Moving)
      setState(() {
        _moving = false;
        handler1Moving = false;
        handler2Moving = false;
      });
  }

  void onDragUpdate(DragUpdateDetails d) {
    if (_moving)
      setState(() {
        boundingBox = boundingBox.shift(d.delta);
        _calcHandlers();
      });
    if (handler1Moving)
      setState(() {
        boundingBox = Rect.fromLTWH(
          boundingBox.left + d.delta.dx,
          boundingBox.top + d.delta.dy,
          boundingBox.width - d.delta.dx,
          boundingBox.height - d.delta.dy,
        );
        _calcHandlers();
      });
    if (handler2Moving)
      setState(() {
        boundingBox = Rect.fromLTWH(
          boundingBox.left,
          boundingBox.top,
          boundingBox.width + d.delta.dx,
          boundingBox.height + d.delta.dy,
        );
        _calcHandlers();
      });
  }

  void _calcHandlers() {
    handler1 = Rect.fromLTWH(
      boundingBox.left - 4,
      boundingBox.top - 4,
      10,
      10,
    );
    handler2 = Rect.fromLTWH(
      boundingBox.left + boundingBox.width - 6,
      boundingBox.top + boundingBox.height - 6,
      10,
      10,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fromRect(
          rect: boundingBox,
          child: Container(
            decoration: BoxDecoration(
                border:
                    selected ? Border.all(color: Colors.blue, width: 3) : null),
            child: widget.child,
          ),
        ),
        if (selected)
          Positioned(
            top: boundingBox.top - 4,
            left: boundingBox.left - 4,
            child: Container(
              width: 10,
              height: 10,
              color: Colors.black,
            ),
          ),
        if (selected)
          Positioned.fromRect(
            rect: handler2,
            child: Container(
              width: 10,
              height: 10,
              color: Colors.black,
            ),
          ),
      ],
    );
  }
}

class Listener<T> {
  List<void Function(T)> _listeners = [];

  listen(void Function(T) l) {
    _listeners.add(l);
  }

  void call(T val) => notify(val);

  removeListener(void Function(T) l) {
    _listeners.remove(l);
  }

  notify(T val) {
    _listeners.forEach((l) => l(val));
  }
}

// class TransformationsDemo extends StatefulWidget {
//   const TransformationsDemo({Key key}) : super(key: key);

//   static const String routeName = '/transformations';

//   @override
//   _TransformationsDemoState createState() => _TransformationsDemoState();
// }

// class _TransformationsDemoState extends State<TransformationsDemo> {
//   bool translate = false;
//   List<Offset> points = [];
//   bool _reset = false;
//   Matrix4 matrix = Matrix4.identity();
//   double height = 100;

//   @override
//   Widget build(BuildContext context) {
//     // The scene is drawn by a CustomPaint, but user interaction is handled by
//     // the GestureTransformable parent widget.
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('2D Tranformations'),
//         actions: <Widget>[
//           IconButton(
//             icon: Icon(Icons.swap_calls,
//                 color: translate ? Colors.red : Colors.white),
//             onPressed: () => setState(() => translate = !translate),
//           )
//         ],
//       ),
//       body: LayoutBuilder(
//         builder: (BuildContext context, BoxConstraints constraints) {
//           // Draw the scene as big as is available, but allow the user to
//           // translate beyond that to a visibleSize that's a bit bigger.

//           // if (translate)
//           //   return Transform(
//           //     transform: matrix,
//           //     child: Center(
//           //       child: Container(
//           //         width: 200,
//           //         child: GestureDetector(
//           //           onPanUpdate: _onTapUp,
//           //           child: CustomPaint(
//           //               painter: BoardPainter(points), size: Size(200, 2000)),
//           //         ),
//           //       ),
//           //     ),
//           //   );
//           double width = constraints.maxHeight / height > 1
//               ? constraints.maxWidth
//               : constraints.maxWidth * constraints.maxHeight / height;
//           double scale = constraints.maxWidth / width;
//           print(scale);
//           return MatrixGestureDetector(
//             key: Key(scale.toString()),
//             shouldRotate: false,
//             initialScale: scale,
//             initialTranslate: Offset(-constraints.maxWidth / 2, 0)
//                 .scale(scale - 1, scale - 1),
//             //disableRotation: true,
//             onMatrixUpdate: (m1, m2, m3, m4) {
//               setState(() => matrix = m1);
//             },

//             onPanUpdate: translate
//                 ? null
//                 : (p) => setState(() {
//                       print(p);
//                       points.add(p.translate(
//                           -(MediaQuery.of(context).size.width - width) / 2,
//                           -60));
//                     }),

//             //onPanEnd: () => setState(() => translate = false),

//             //onDoubleTap: () => setState(() => translate = true),

//             child: Transform(
//               transform: matrix,
//               child: Container(
//                 width: 3000,
//                 alignment: Alignment.topCenter,
//                 child: Stack(
//                   children: <Widget>[
//                     CustomPaint(
//                       painter: BoardPainter(points),
//                       size: Size(
//                         width,
//                         height,
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.add),
//                       onPressed: () => setState(() {
//                         height += 100;
//                       }),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//             // Center the board in the middle of the screen. It's drawn centered
//             // at the origin, which is the top left corner of the
//             // GestureTransformable.
//             //onDoubleTap: () => setState(() => translate = !translate),
//           );
//         },
//       ),
//     );
//   }

//   void _onTapUp(DragUpdateDetails d) {
//     setState(() {
//       points.add(d.localPosition
//           .translate(-MediaQuery.of(context).size.width / 2, 60));
//     });

//     // final Offset scenePoint = details.globalPosition;
//     // final BoardPoint boardPoint = _board.pointToBoardPoint(scenePoint);
//     // setState(() {
//     //   _board = _board.copyWithSelected(boardPoint);
//     // });
//   }
// }

// CustomPainter is what is passed to CustomPaint and actually draws the scene
// when its `paint` method is called.
class BoardPainter extends CustomPainter {
  final List<Offset> points;

  const BoardPainter(this.points);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height)),
        Paint()..color = Colors.red);
    points.forEach((p) {
      canvas.drawCircle(p, 2, Paint()..color = Colors.blue);
    });
  }

  // We should repaint whenever the board changes, such as board.selected.
  @override
  bool shouldRepaint(BoardPainter oldDelegate) {
    return true;
  }
}
