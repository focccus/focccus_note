import 'package:flutter/material.dart';
import 'package:focccus_note/presenter/painter.dart';
import 'package:focccus_note/presenter/shapes.dart';

import 'package:focccus_note/socket.dart';

class ProjectorPage extends StatefulWidget {
  ProjectorPage();

  @override
  _ProjectorPageState createState() => _ProjectorPageState();
}

class _ProjectorPageState extends State<ProjectorPage> {
  SocketConnection s;

  @override
  void initState() {
    s = SocketConnection();
    s.connect();

    s.on('client_joined').listen(
      (event) {
        if (event['count'] != null && event['count'] > 1) {
          setState(() {
            isRecieving = true;
          });
        }
      },
    );
    s.on('client_left').listen(
      (event) {
        if (event['count'] == null || event['count'] < 2) {
          setState(() {
            isRecieving = false;
            shapes = [];
          });
        }
      },
    );

    s.on('clear').listen((event) => clear());
    s.on('undo').listen((event) => undo());
    s.on('addshapes').listen((event) {
      if (event != null && event is List) {
        final shapes = event.map((e) => Shape.fromJson(e)).toList();
        if (shapes != null) addShapes(shapes);
      }
    });
    s.on('updatecurrent').listen((event) {
      if (event != null && event is Map) {
        final shape = Shape.fromJson(event);
        if (shape != null) updateCurrent(shape);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    s?.close();
    super.dispose();
  }

  bool isRecieving = false;

  List<Shape> shapes = [];

  Shape currentShape;

  void clear() {
    print('clear');
    setState(() {
      shapes = [];
    });
  }

  void addShapes(List<Shape> s) {
    setState(() {
      currentShape = null;
      shapes.addAll(s);
    });
  }

  void updateCurrent(Shape s) {
    setState(() {
      currentShape = s;
    });
  }

  void undo() {
    if (shapes.isNotEmpty)
      setState(() {
        shapes.removeLast();
      });
  }

  PointerShape pointer;
  Offset lastPointer;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size;

    //FocusScope.of(context).requestFocus(focus);

    return GestureDetector(
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
              if (!isRecieving)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Please wait for someone to project onto the screen!'),
                    SizedBox(
                      height: 16,
                    ),
                    CircularProgressIndicator(),
                  ],
                ),
              if (isRecieving)
                PresentationPaint(
                  [...shapes, currentShape, pointer],
                  w,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
