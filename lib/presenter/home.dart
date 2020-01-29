import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:focccus_note/presenter/presenter.dart';
import 'package:focccus_note/presenter/widgets/project_list_item.dart';
import 'package:focccus_note/storage.dart';

import 'data/project.dart';

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

  void _addPresentation() {
    final prj = Project.init();
    print(prj);
    addPresentation(prj).then((value) {
      if (value) {
        print(projects);
        setState(() => projects.add(prj));
      }
    });
  }

  double calcPadding() {
    var w = MediaQuery.of(context).size.width - 300;
    if (w < 600) return 0;
    return w * 0.2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add), onPressed: _addPresentation),
    );
  }
}
