import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:focccus_note/presenter/data/project.dart';
import 'package:focccus_note/storage/storage.dart';
import 'package:focccus_note/storage/http.dart' as http;
import 'package:focccus_note/widgets/text_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectListItem extends StatefulWidget {
  final Project prj;
  final GestureTapCallback onTap;
  final void Function() onDelete;
  ProjectListItem(this.prj, this.onTap, {this.onDelete});

  @override
  _ProjectListItemState createState() => _ProjectListItemState();
}

class _ProjectListItemState extends State<ProjectListItem> {
  bool editing = false;
  final slideController = SlidableController();
  TextEditingController textController;

  @override
  void initState() {
    textController = TextEditingController(text: widget.prj.name);
    super.initState();
  }

  void _save() {
    widget.prj.name = textController.text;
    savePresentation(widget.prj).then(
      (v) => setState(() {
        editing = false;
      }),
    );
  }

  void _copy() {
    final prj = widget.prj.toJson();

    Clipboard.setData(ClipboardData(text: json.encode(prj)));
  }

  void _upload() async {
    final token = await getToken();
    try {
      final id = await http.updatePresentation(widget.prj, token);
      print(id);
      if (id != null) {
        widget.prj.gistID = id;
        await _save();
        print('uploaded');
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Successfully uploaded the presentation to https://gist.github.com/$id'),
            action: SnackBarAction(
              textColor: Colors.white,
              label: 'Open',
              onPressed: () => launch('https://gist.github.com/$id'),
            ),
          ),
        );
      }
    } catch (e) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
      final newToken = await showDialog<String>(
        context: context,
        builder: (c) => TextDialog(
          'It seems an error occured. Please check your GitHub token:',
          token,
        ),
      );
      if (newToken != null) {
        await setToken(newToken);
        _upload();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableStrechActionPane(),
      actionExtentRatio: 0.2,
      child: editing
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                autofocus: true,
                controller: textController,
                onSubmitted: (e) => _save(),
                decoration:
                    InputDecoration(labelText: "Name of the Presentation"),
              ),
            )
          : ListTile(
              title: Text(widget.prj.name),
              onTap: widget.onTap,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
      actions: editing
          ? [
              IconSlideAction(
                caption: 'Save',
                color: Colors.black,
                icon: Icons.save,
                onTap: _save,
              ),
            ]
          : [
              IconSlideAction(
                caption: 'Rename',
                color: Colors.black,
                icon: Icons.text_format,
                onTap: () => setState(() {
                  editing = true;
                }),
                closeOnTap: false,
              ),
              IconSlideAction(
                caption: 'Upload Gist',
                color: Colors.white,
                icon: Icons.file_upload,
                onTap: _upload,
                closeOnTap: false,
              ),
              IconSlideAction(
                caption: 'Copy',
                color: Colors.white,
                icon: Icons.content_copy,
                onTap: _copy,
                closeOnTap: true,
              ),
            ],
      //onTap: _openPresentation,
      secondaryActions: [
        editing
            ? IconSlideAction(
                caption: 'Close',
                icon: Icons.close,
                onTap: () => setState(() => editing = false),
              )
            : IconSlideAction(
                caption: 'Delete',
                color: Colors.black,
                icon: Icons.delete,
                onTap: widget.onDelete,
              ),
      ],
    );
  }
}
