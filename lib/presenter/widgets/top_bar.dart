import 'package:flutter/material.dart';
import 'package:focccus_note/widgets/button_bar.dart';
import 'package:focccus_note/widgets/slider_icon_button.dart';

class TopActionBar extends StatelessWidget {
  final double strokeSize;
  final Color color;
  final bool isSelectedFrame;
  final void Function() onUndo;
  final void Function() onRedo;
  final void Function(double) onStrokeChange;
  final void Function(Color) onColorChange;
  final void Function() onViewFrames;
  final void Function() onPresent;
  final void Function() onAddFrame;
  final void Function() onBack;
  final void Function() onProject;
  final bool projectingActive;

  TopActionBar(
    this.color,
    this.strokeSize,
    this.isSelectedFrame, {
    this.onUndo,
    this.onRedo,
    this.onStrokeChange,
    this.onColorChange,
    this.onAddFrame,
    this.onViewFrames,
    this.onPresent,
    this.onBack,
    this.onProject,
    this.projectingActive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CustomButtonBar([
          ToggleIconButton(
            false,
            icon: Icons.arrow_back,
            onPressed: onBack,
          )
        ]),
        SizedBox(
          width: 16,
        ),
        CustomButtonBar(
          [
            ToggleIconButton(
              false,
              icon: Icons.undo,
              onPressed: onUndo,
            ),
            ToggleIconButton(
              false,
              icon: Icons.redo,
              onPressed: onRedo,
            ),
            if (strokeSize != null)
              SliderIconButton(
                strokeSize,
                valueChanged: onStrokeChange,
              ),
            if (color != null) ColorIconButton(color, onColorChange),
            ToggleIconButton(
              false,
              icon: Icons.view_module,
              onPressed: onViewFrames,
            ),
            ToggleIconButton(
              isSelectedFrame,
              icon: Icons.center_focus_weak,
              activeIcon: Icons.center_focus_strong,
              onPressed: onAddFrame,
            ),
            ToggleIconButton(
              false,
              icon: Icons.play_arrow,
              onPressed: onPresent,
            ),
            ToggleIconButton(
              projectingActive ?? false,
              icon: Icons.cast,
              onPressed: onProject,
            ),
          ],
          direction: Axis.horizontal,
        ),
      ],
    );
  }
}
