import 'package:flutter/material.dart';
import 'package:focccus_note/presenter/data/toolmode.dart';
import 'package:focccus_note/widgets/button_bar.dart';

const modes = [
  //Toolmode.eraser,
  Toolmode.pen,
  Toolmode.brush,
  Toolmode.marker,
  Toolmode.rect,
  Toolmode.line,
  Toolmode.pan,
];

class ModesActionBar extends StatelessWidget {
  final Toolmode current;
  final void Function(Toolmode) onChange;
  final void Function() onPageClear;

  ModesActionBar(this.current, {this.onChange, this.onPageClear});

  _changeTool(Toolmode mode) {
    if (mode != current && onChange != null) onChange(mode);
  }

  @override
  Widget build(BuildContext context) {
    final List<ToggleIconButton> buttons = modes
        .map((mode) => ToggleIconButton(
              current == mode,
              icon: getToolIcon(mode),
              onPressed: () => _changeTool(mode),
            ))
        .toList();

    return CustomButtonBar([
      ...buttons,
      ToggleIconButton(
        false,
        icon: Icons.note_add,
        onPressed: onPageClear,
      )
    ]);
  }
}
