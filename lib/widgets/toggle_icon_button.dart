import 'package:flutter/material.dart';

class ToggleIconButton extends StatelessWidget {
  final bool value;
  final IconData icon;
  final Color color;
  final Color activeColor;
  final IconData activeIcon;
  final void Function() onPressed;
  final double size;
  final VisualDensity density;

  ToggleIconButton(
    this.value, {
    @required this.icon,
    @required this.onPressed,
    this.activeColor = Colors.white,
    this.activeIcon,
    this.color,
    this.size = 20,
    this.density,
  });

  _getCurrentColor() {
    if (color != null) return color;
    return value ? null : activeColor;
  }

  @override
  Widget build(BuildContext context) {
    var d = density ?? MediaQuery.of(context).size.width < 600
        ? VisualDensity.compact
        : VisualDensity.standard;

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        decoration: BoxDecoration(
          color: value ? activeColor : null,
          borderRadius: BorderRadius.circular(100),
        ),
        child: IconButton(
          iconSize: size,
          visualDensity: d,
          focusColor: activeColor,
          disabledColor: Colors.grey,
          icon: Icon(activeIcon != null && value ? activeIcon : icon),
          color: _getCurrentColor(),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
