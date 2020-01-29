import 'package:focccus_note/presenter/data/keyframe.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Project {
  int key;
  List<Keyframe> frames;
  String name;
  DateTime modified;

  Project(this.name, this.frames, this.modified, this.key);

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
      );
  Map<String, dynamic> toJson() => <String, dynamic>{
        'frames': frames.map((f) => f.toJson()).toList(),
        'name': name,
        'modified': modified?.toIso8601String(),
      };
}
