import 'package:focccus_note/presenter/data/keyframe.dart';

class Project {
  int key;
  String gistID;
  List<Keyframe> frames;
  String name;
  DateTime modified;

  Project(this.name, this.frames, this.modified, this.key, this.gistID);

  Project.init()
      : name = "Untitled",
        frames = [Keyframe.init()],
        modified = DateTime.now();

  factory Project.fromJson(Map<String, dynamic> json, int key) => Project(
        json['name'] as String,
        (json['frames'] as List)
            ?.map((e) => e == null
                ? null
                : Keyframe.fromJson(new Map<String, dynamic>.from(e)))
            ?.toList(),
        json['modified'] == null
            ? null
            : DateTime.parse(json['modified'] as String),
        key,
        json['gistID'] as String,
      );
  Map<String, dynamic> toJson() => <String, dynamic>{
        'frames': frames.map((f) => f.toJson()).toList(),
        'name': name,
        'modified': modified?.toIso8601String(),
        'gistID': gistID,
      };
}
