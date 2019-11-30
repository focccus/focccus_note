import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'photo_view_utils.dart';

import 'controller/photo_view_controller.dart';
import 'controller/photo_view_controller_delegate.dart';
import 'photo_view_hero_attributes.dart';
import 'photo_view_typedefs.dart';
import 'package:vector_math/vector_math_64.dart';

typedef PhotoViewImageTapUpCallback = Function(
  BuildContext context,
  TapUpDetails details,
  PhotoViewControllerValue controllerValue,
);
typedef PhotoViewImageTapDownCallback = Function(
  BuildContext context,
  TapDownDetails details,
  PhotoViewControllerValue controllerValue,
);

/// Internal widget in which controls all animations lifecycle, core responses
/// to user gestures, updates to  the controller state and mounts the entire PhotoView Layout
class PhotoViewImageWrapper extends StatefulWidget {
  const PhotoViewImageWrapper({
    Key key,
    @required this.imageProvider,
    this.backgroundDecoration,
    this.gaplessPlayback = false,
    this.heroAttributes,
    this.enableRotation,
    this.onTapUp,
    this.onTapDown,
    this.onPanEnd,
    this.onPanStart,
    this.onPanUpdate,
    this.enabled = true,
    this.enableDoubleTap,
    @required this.controller,
    @required this.scaleBoundaries,
    @required this.scaleStateCycle,
    @required this.scaleStateController,
    @required this.basePosition,
  })  : customChild = null,
        super(key: key);

  const PhotoViewImageWrapper.customChild({
    Key key,
    @required this.customChild,
    this.backgroundDecoration,
    this.heroAttributes,
    this.enableRotation,
    this.onTapUp,
    this.onTapDown,
    this.onPanEnd,
    this.onPanStart,
    this.onPanUpdate,
    this.enabled = true,
    this.enableDoubleTap,
    @required this.controller,
    @required this.scaleBoundaries,
    @required this.scaleStateCycle,
    @required this.scaleStateController,
    @required this.basePosition,
  })  : imageProvider = null,
        gaplessPlayback = false,
        super(key: key);

  final Decoration backgroundDecoration;
  final ImageProvider imageProvider;
  final bool gaplessPlayback;
  final PhotoViewHeroAttributes heroAttributes;
  final bool enableRotation;
  final Widget customChild;

  final PhotoViewControllerBase controller;
  final PhotoViewScaleStateController scaleStateController;
  final ScaleBoundaries scaleBoundaries;
  final ScaleStateCycle scaleStateCycle;
  final Alignment basePosition;

  final PhotoViewImageTapUpCallback onTapUp;
  final PhotoViewImageTapDownCallback onTapDown;

  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;

  final bool enabled;
  final bool enableDoubleTap;

  @override
  State<StatefulWidget> createState() {
    return _PhotoViewImageWrapperState();
  }
}

class _PhotoViewImageWrapperState extends State<PhotoViewImageWrapper>
    with TickerProviderStateMixin, PhotoViewControllerDelegate {
  Offset _normalizedPosition;
  double _scaleBefore;
  double _rotationBefore;
  Offset _panBefore;

  AnimationController _scaleAnimationController;
  Animation<double> _scaleAnimation;

  AnimationController _positionAnimationController;
  Animation<Offset> _positionAnimation;

  AnimationController _rotationAnimationController;
  Animation<double> _rotationAnimation;

  PhotoViewHeroAttributes get heroAttributes => widget.heroAttributes;

  void handleScaleAnimation() {
    scale = _scaleAnimation.value;
  }

  void handlePositionAnimate() {
    controller.position = _positionAnimation.value;
  }

  void handleRotationAnimation() {
    controller.rotation = _rotationAnimation.value;
  }

  void onScaleStart(ScaleStartDetails details) {
    if (widget.onPanStart != null) {
      widget.onPanStart(DragStartDetails(
        globalPosition: applyMatrix(details.focalPoint),
        localPosition: applyMatrix(details.localFocalPoint),
      ));
    }

    _panBefore = applyMatrix(details.localFocalPoint);
    _rotationBefore = controller.rotation;
    _scaleBefore = scale;
    _normalizedPosition = details.focalPoint - controller.position;
    _scaleAnimationController.stop();
    _positionAnimationController.stop();
    _rotationAnimationController.stop();
  }

  Offset fromViewport(Offset viewportPoint, Matrix4 transform) {
    final double w = scaleBoundaries.childSize.width * scale -
        MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height -
        scaleBoundaries.childSize.height * scale;

    final Matrix4 inverseMatrix = Matrix4.inverted(transform);
    final Vector3 untransformed = inverseMatrix.transform3(Vector3(
      viewportPoint.dx + w / 2 * (widget.basePosition.x + 1),
      viewportPoint.dy + h / 2 * (widget.basePosition.y + 1),
      0,
    ));
    return Offset(untransformed.x, untransformed.y);
  }

  Offset applyMatrix(Offset p) {
    final matrix = Matrix4.identity()
      ..translate(controller.position.dx, controller.position.dy)
      ..scale(scale);
    return fromViewport(p, matrix);
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale == 1.0 && widget.onPanUpdate != null) {
      final Offset current = applyMatrix(details.localFocalPoint);
      widget.onPanUpdate(DragUpdateDetails(
        globalPosition: applyMatrix(details.focalPoint),
        localPosition: current,
        delta: current - _panBefore,
      ));
      _panBefore = current;
      return;
    }

    final double newScale = _scaleBefore * details.scale;
    final Offset delta = details.focalPoint - _normalizedPosition;

    updateScaleStateFromNewScale(details.scale, newScale);

    updateMultiple(
      scale: newScale,
      position: clampPosition(delta * details.scale),
      rotation: _rotationBefore + details.rotation,
      rotationFocusPoint: details.focalPoint,
    );
  }

  void onScaleEnd(ScaleEndDetails details) {
    final double _scale = scale;
    final Offset _position = controller.position;
    final double maxScale = scaleBoundaries.maxScale;
    final double minScale = scaleBoundaries.minScale;

    if (widget.onPanEnd != null) {
      widget.onPanEnd(DragEndDetails());
    }

    //animate back to maxScale if gesture exceeded the maxScale specified
    if (_scale > maxScale) {
      final double scaleComebackRatio = maxScale / _scale;
      animateScale(_scale, maxScale);
      final Offset clampedPosition = clampPosition(
        _position * scaleComebackRatio,
        scale: maxScale,
      );
      animatePosition(_position, clampedPosition);
      return;
    }

    //animate back to minScale if gesture fell smaller than the minScale specified
    if (_scale < minScale) {
      final double scaleComebackRatio = minScale / _scale;
      animateScale(_scale, minScale);
      animatePosition(
        _position,
        clampPosition(
          _position * scaleComebackRatio,
          scale: minScale,
        ),
      );
      return;
    }
    // get magnitude from gesture velocity
    final double magnitude = details.velocity.pixelsPerSecond.distance;

    // animate velocity only if there is no scale change and a significant magnitude
    if (_scaleBefore / _scale == 1.0 &&
        widget.onPanUpdate == null &&
        magnitude >= 400.0) {
      final Offset direction = details.velocity.pixelsPerSecond / magnitude;
      animatePosition(
        _position,
        clampPosition(_position + direction * 350.0),
      );
    }

    checkAndSetToInitialScaleState();
  }

  void animateScale(double from, double to) {
    _scaleAnimation = Tween<double>(
      begin: from,
      end: to,
    ).animate(_scaleAnimationController);
    _scaleAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void animatePosition(Offset from, Offset to) {
    _positionAnimation = Tween<Offset>(begin: from, end: to)
        .animate(_positionAnimationController);
    _positionAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void animateRotation(double from, double to) {
    _rotationAnimation = Tween<double>(begin: from, end: to)
        .animate(_rotationAnimationController);
    _rotationAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      checkAndSetToInitialScaleState();
    }
  }

  @override
  void initState() {
    super.initState();
    _scaleAnimationController = AnimationController(vsync: this)
      ..addListener(handleScaleAnimation);
    _scaleAnimationController.addStatusListener(onAnimationStatus);

    _positionAnimationController = AnimationController(vsync: this)
      ..addListener(handlePositionAnimate);

    _rotationAnimationController = AnimationController(vsync: this)
      ..addListener(handleRotationAnimation);
    startListeners();
    addAnimateOnScaleStateUpdate(animateOnScaleStateUpdate);

    _scaleBefore = 1;
  }

  void animateOnScaleStateUpdate(double prevScale, double nextScale) {
    animateScale(prevScale, nextScale);
    animatePosition(controller.position, Offset.zero);
    animateRotation(controller.rotation, 0.0);
  }

  @override
  void dispose() {
    _scaleAnimationController.removeStatusListener(onAnimationStatus);
    _scaleAnimationController.dispose();
    _positionAnimationController.dispose();
    _rotationAnimationController.dispose();
    super.dispose();
  }

  void onTapUp(TapUpDetails details) {
    widget.onTapUp?.call(
      context,
      TapUpDetails(
        globalPosition: details.globalPosition,
        localPosition: applyMatrix(details.localPosition),
      ),
      controller.value,
    );
  }

  void onTapDown(TapDownDetails details) {
    widget.onTapDown?.call(
      context,
      TapDownDetails(
        globalPosition: details.globalPosition,
        localPosition: applyMatrix(details.localPosition),
        kind: details.kind,
      ),
      controller.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: controller.outputStateStream,
        initialData: controller.prevValue,
        builder: (
          BuildContext context,
          AsyncSnapshot<PhotoViewControllerValue> snapshot,
        ) {
          if (snapshot.hasData) {
            final PhotoViewControllerValue value = snapshot.data;
            final matrix = Matrix4.identity()
              ..translate(value.position.dx, value.position.dy)
              ..scale(scale);
            if (widget.enableRotation) {
              matrix..rotateZ(value.rotation);
            }

            final Widget customChildLayout = CustomSingleChildLayout(
              delegate: _CenterWithOriginalSizeDelegate(
                scaleBoundaries.childSize,
                basePosition,
              ),
              child: _buildHero(),
            );
            final Widget child = Container(
              child: Center(
                child: Transform(
                  child: customChildLayout,
                  transform: matrix,
                  alignment: basePosition,
                ),
              ),
              decoration: widget.backgroundDecoration ??
                  const BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 0, 1.0),
                  ),
            );

            if (widget.enabled == null || !widget.enabled) return child;

            return Listener(
              onPointerSignal: (e) {
                if (e is PointerScrollEvent) {
                  var scale =
                      (controller.scale ?? 0.5) + e.scrollDelta.dy / -1000;

                  updateMultiple(
                    scale: scale,
                  );

                  // animateScale(controller.scale,
                  //     controller.scale + e.scrollDelta.dy / -1000);
                  // _scaleBefore += e.scrollDelta.dy / -1000;
                }
              },
              child: GestureDetector(
                child: child,
                onDoubleTap: widget.enableDoubleTap ? nextScaleState : null,
                onScaleStart: onScaleStart,
                onScaleUpdate: onScaleUpdate,
                onScaleEnd: onScaleEnd,
                // Return null to prevent overriding tap handlers higher in the widget tree.
                // See https://github.com/renancaraujo/photo_view/issues/134
                onTapUp: widget.onTapUp == null ? null : onTapUp,
                onTapDown: widget.onTapDown == null ? null : onTapDown,
              ),
            );
          } else {
            return Container();
          }
        });
  }

  Widget _buildHero() {
    return heroAttributes != null
        ? Hero(
            tag: heroAttributes.tag,
            createRectTween: heroAttributes.createRectTween,
            flightShuttleBuilder: heroAttributes.flightShuttleBuilder,
            placeholderBuilder: heroAttributes.placeholderBuilder,
            transitionOnUserGestures: heroAttributes.transitionOnUserGestures,
            child: _buildChild(),
          )
        : _buildChild();
  }

  Widget _buildChild() {
    return widget.customChild == null
        ? Image(
            image: widget.imageProvider,
            gaplessPlayback: widget.gaplessPlayback,
          )
        : widget.customChild;
  }
}

class _CenterWithOriginalSizeDelegate extends SingleChildLayoutDelegate {
  const _CenterWithOriginalSizeDelegate(this.subjectSize, this.basePosition);

  final Size subjectSize;
  final Alignment basePosition;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final double offsetX =
        ((size.width - subjectSize.width) / 2) * (basePosition.x + 1);
    final double offsetY =
        ((size.height - subjectSize.height) / 2) * (basePosition.y + 1);
    return Offset(offsetX, offsetY);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      maxWidth: subjectSize.width,
      maxHeight: subjectSize.height,
      minHeight: subjectSize.height,
      minWidth: subjectSize.width,
    );
  }

  @override
  bool shouldRelayout(SingleChildLayoutDelegate oldDelegate) {
    return true;
  }
}
