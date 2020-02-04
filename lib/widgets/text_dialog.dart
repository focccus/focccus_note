import 'package:flutter/material.dart';

class TextDialog extends StatelessWidget {
  final TextEditingController controller;

  final String title;

  TextDialog(this.title, String token)
      : controller = TextEditingController(text: token);

  void _save(BuildContext context) {
    Navigator.of(context).pop(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        onSubmitted: (e) => _save(context),
      ),
      actions: <Widget>[
        RaisedButton(
          child: Text('Done'),
          onPressed: () => _save(context),
        )
      ],
    );
  }
}
