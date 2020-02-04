// import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:focccus_note/presenter/data/project.dart';
import 'package:hive/hive.dart';

import 'path_html.dart'
    if (dart.library.io) 'path_io.dart'
    if (dart.library.html) 'path_html.dart';

Box<Map> box;
Box options;

void initStorage() async {
  if (box != null) return;
  print("hiveINit");
  if (!kIsWeb) {
    await Hive.init(await getPath());
  }

  box = await Hive.openBox<Map>('focccus_presentation');
  options = await Hive.openBox('options');
}

clear() async {
  await initStorage();
  box.deleteAll(box.keys);
}

Future<String> getToken() async {
  if (box == null) await initStorage();
  return options.get('token');
}

Future<void> setToken(String token) async {
  if (box == null) await initStorage();
  return options.put('token', token);
}

Future<bool> addPresentation(Project prj) async {
  if (box == null) await initStorage();
  if (prj == null) return false;
  //print(drawings.last);
  box.add(prj.toJson());
  prj.key = box.keys.last;
  return true;
}

// Future<bool> updateDrawing(Drawing dr) async {
//   await initStorage();
//   if (dr == null || dr.isEmpty) return false;
//   List drawings = box.get('drawings') ?? [];
//   Map updated = dr.toMap();
//   var oldIndex = drawings.indexWhere((d) => d['date'] == updated['date']);
//   if (oldIndex >= 0)
//     drawings[oldIndex] = updated;
//   else
//     drawings.insert(0, updated);

//   await box.put('drawings', drawings);
//   return true;
// }

Future<void> savePresentation(Project prj) {
  prj.modified = DateTime.now();
  return box.put(prj.key, prj.toJson());
}

Future<void> deletePresentation(key) {
  print("delete $key");
  return box.delete(key);
}

Future<List<Project>> getPresentations() async {
  if (box == null) {
    await initStorage();
  }
  final res = box.keys
      .map(
          (k) => Project.fromJson(new Map<String, dynamic>.from(box.get(k)), k))
      .toList();
  res.sort((a, b) => b.modified.compareTo(a.modified));
  return res;
}
