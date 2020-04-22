import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:focccus_note/presenter/presenter.dart';
import 'package:focccus_note/presenter/projector.dart';
import 'package:focccus_note/presenter/widgets/project_list_item.dart';
import 'package:focccus_note/storage/storage.dart';
import 'package:focccus_note/widgets/text_dialog.dart';
import 'data/project.dart';
import 'package:focccus_note/storage/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Project> projects = [];

  void _openPresentation(Project p) {
    Navigator.push(
        context, MaterialPageRoute(builder: (c) => PresenterPage(p)));
  }

  void _addPresentation([Project p]) {
    final prj = p ?? Project.init();
    addPresentation(prj).then((value) {
      if (value) {
        setState(() => projects.insert(0, prj));
      }
    });
  }

  void _pastePresentation(BuildContext context) async {
    final d = await Clipboard.getData('text/plain');
    if (d != null) {
      try {
        final m = json.decode(d.text) as Map<String, dynamic>;
        final prj = Project.fromJson(m, null);
        if (prj != null) {
          _addPresentation(prj);
        }
      } catch (e) {
        print(e);
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sorry the pasted content was not in the right format. Please ensure that you copy a project.',
            ),
          ),
        );
      }
    }
  }

  void _clonePresentation() async {
    var url = await showDialog<String>(
      context: context,
      builder: (c) => TextDialog('Please enter a Gist id or Url below.', ''),
    );

    if (url != null) {
      url = url.split('/').last;
      final token = await getToken();
      try {
        final prj = await http.clonePresentation(url, token);
        if (prj != null) {
          _addPresentation(prj);
        }
      } catch (e) {
        print(e);
        final newToken = await showDialog<String>(
          context: context,
          builder: (c) => TextDialog(
              'It seems an error occured. Please check your GitHub token:',
              token),
        );
        if (newToken != null) {
          await setToken(newToken);
          _clonePresentation();
        }
      }
    }
  }

  double calcPadding() {
    var w = MediaQuery.of(context).size.width - 300;
    if (w < 600) return 0;
    return w * 0.2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Project>>(
          future: getPresentations(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              projects = snapshot.data;
              return ListView.builder(
                padding: EdgeInsets.symmetric(
                    horizontal: calcPadding(), vertical: 60),
                itemCount: projects.length,
                itemBuilder: (context, i) => ProjectListItem(
                  projects[i],
                  () => _openPresentation(projects[i]),
                  onDelete: () => deletePresentation(projects[i].key).then(
                    (value) => setState(() => projects.remove(projects[i])),
                  ),
                ),
              );
            } else
              return Center(
                child: CircularProgressIndicator(),
              );
          }),
      floatingActionButton: Builder(
        builder: (context) => SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          children: [
            SpeedDialChild(
              child: Icon(Icons.add),
              onTap: _addPresentation,
              label: 'Add',
            ),
            SpeedDialChild(
              child: Icon(Icons.content_paste),
              onTap: () => _pastePresentation(context),
              label: 'Paste',
            ),
            SpeedDialChild(
              child: Icon(Icons.cast_connected),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => ProjectorPage()),
              ),
              label: 'Connect',
            ),
            SpeedDialChild(
              child: Icon(Icons.system_update),
              onTap: _clonePresentation,
              label: 'Clone',
            ),
          ],
        ),
      ),
    );
  }
}
