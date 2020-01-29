// import 'package:flutter/foundation.dart';
import 'package:focccus_note/presenter/data/project.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

Box<Map> box;

initStorage() async {
  if (box != null) return box;
  print("hiveINit");
  await Hive.initFlutter();
  box = await Hive.openBox<Map>('focccus_presentation');
}

clear() async {
  await initStorage();
  box.deleteAll(box.keys);
}

Future<bool> addPresentation(Project prj) async {
  await initStorage();
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
  return box.put(prj.key, prj.toJson());
}

Future<void> deletePresentation(key) {
  print("delete $key");
  return box.delete(key);
}

Future<List<Project>> getPresentations() async {
  await initStorage();
  return box.keys
      .map(
          (k) => Project.fromJson(new Map<String, dynamic>.from(box.get(k)), k))
      .toList();
}
