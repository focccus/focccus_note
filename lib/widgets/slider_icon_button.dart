import 'package:flutter/material.dart';

class SliderIconButton extends StatefulWidget {
  final void Function(double) valueChanged;
  final double value;

  SliderIconButton(this.value, {this.valueChanged});

  @override
  _SliderIconButtonState createState() => _SliderIconButtonState();
}

class _SliderIconButtonState extends State<SliderIconButton> {
  double strokeSize;
  OverlayEntry _overlayEntry;
  bool overlayShown = false;

  void initState() {
    strokeSize = widget.value ?? 4;

    super.initState();
  }

  void didUpdateWidget(old) {
    strokeSize = widget.value ?? 4;
    super.didUpdateWidget(old);
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
        maintainState: true,
        builder: (context) => Positioned(
              left: offset.dx - 90,
              top: offset.dy + size.height + 5.0,
              width: 240,
              child: Material(
                elevation: 2.0,
                borderRadius: BorderRadius.circular(50),
                child: Row(
                  children: <Widget>[
                    Slider(
                      value: strokeSize,
                      max: 48,
                      onChanged: (v) {},
                    ),
                    Text(
                      "${strokeSize.round()}",
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ),
            ));
  }

  void showOverlay() {
    this._overlayEntry = this._createOverlayEntry();
    Overlay.of(context).insert(this._overlayEntry);
  }

  void updateOverlay() {
    hideOverlay();
    showOverlay();
  }

  void hideOverlay() {
    _overlayEntry.remove();
  }

  Offset lastPosition;

  void onStart(Offset start) {
    overlayShown = true;
    showOverlay();
    setState(() {
      lastPosition = start;
    });
  }

  void onEnd() {
    if (overlayShown) {
      hideOverlay();
      if (widget.valueChanged != null) {
        widget.valueChanged(strokeSize.roundToDouble());
      }
      overlayShown = false;
    }
  }

  void onUpdate(Offset o) {
    final d = o - lastPosition;
    //if (d.dx < 10 && d.dx > -10) return;
    final newSize = strokeSize + d.dx / 2;
    if (newSize > 1 && newSize < 48) {
      lastPosition = o;
      setState(() {
        strokeSize = newSize;
      });
      updateOverlay();
    }
  }

  final size = 32.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onHorizontalDragUpdate: (e) => onUpdate(e.localPosition),
          onHorizontalDragEnd: (e) => onEnd(),
          onTapDown: (e) => onStart(e.localPosition),
          //onLongPressMoveUpdate: (e) => onUpdate(e.localPosition),
          onTapUp: (e) => onEnd(),
          child: Container(
            width: size,
            height: size,
            decoration:
                BoxDecoration(color: Colors.black, shape: BoxShape.circle),
            child: Center(
              child: Container(
                height: strokeSize,
                width: strokeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
