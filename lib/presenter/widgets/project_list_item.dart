import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:focccus_note/presenter/data/project.dart';
import 'package:focccus_note/storage.dart';

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

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableStrechActionPane(),
      actionExtentRatio: 0.2,
      child: editing
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
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
      actions: <Widget>[
        editing
            ? IconSlideAction(
                caption: 'Save',
                color: Colors.black,
                icon: Icons.save,
                onTap: _save,
              )
            : IconSlideAction(
                caption: 'Rename',
                color: Colors.black,
                icon: Icons.text_format,
                onTap: () => setState(() {
                  editing = true;
                }),
                closeOnTap: false,
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
