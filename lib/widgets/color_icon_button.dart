import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/material_picker.dart';
import 'package:focccus_note/widgets/toggle_icon_button.dart';

class ColorIconButton extends StatelessWidget {
  final void Function(Color) onChange;
  final Color currentColor;

  ColorIconButton(
    this.currentColor,
    this.onChange,
  );

  @override
  Widget build(BuildContext context) {
    return ToggleIconButton(
      true,
      icon: Icons.album,
      color: currentColor,
      onPressed: () {
        //Color changed = this.currentColor;
        showDialog(
          context: context,
          child: AlertDialog(
            content: SingleChildScrollView(
              child: MaterialPicker(
                pickerColor: currentColor,
                onColorChanged: (c) {
                  onChange(c);
                  Navigator.of(context).pop();
                },
              ),
              // Use Material color picker:
              //
              // child: MaterialPicker(
              //   pickerColor: pickerColor,
              //   onColorChanged: changeColor,
              //   enableLabel: true, // only on portrait mode
              // ),
              //
              // Use Block color picker:
              //
              // child: BlockPicker(
              //   pickerColor: currentColor,
              //   onColorChanged: changeColor,
              // ),
            ),
            // actions: <Widget>[
            //   FlatButton(
            //     child: const Text('Got it'),
            //     onPressed: () {
            //       onChange(changed);
            //       Navigator.of(context).pop();
            //     },
            //   ),
            // ],
          ),
        );
      },
    );
  }
}
