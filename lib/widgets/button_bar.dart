import 'package:flutter/material.dart';
export 'color_icon_button.dart';
export 'toggle_icon_button.dart';

class CustomButtonBar extends StatelessWidget {
  final List<Widget> buttons;
  final Axis direction;

  CustomButtonBar(
    this.buttons, {
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(100),
      ),
      child: direction == Axis.horizontal
          ? Row(
              children: buttons,
            )
          : Column(
              children: buttons,
            ),
    );
  }
}
