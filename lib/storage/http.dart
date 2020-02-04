import 'dart:convert';

import 'package:focccus_note/presenter/data/project.dart';
import 'package:http/http.dart' as http;

const String endpoint = "https://api.github.com/";

Future<Project> clonePresentation(String id, [String token]) async {
  final headers = token != null ? {'Authorization': 'token $token'} : {};

  final res = await http.get(endpoint + 'gists/' + id, headers: headers);
  final data = json.decode(res.body);
  final content = json.decode(data['files']['presentation.json']['content']);
  content['gistID'] = data['id'];
  return Project.fromJson(content, null);
}

Future<String> updatePresentation(Project prj, String token) async {
  if (prj.gistID == null) return uploadPresentation(prj, token);

  final headers = {'Authorization': 'token $token'};

  assert(token != null);

  final res = await http.patch(
    endpoint + 'gists/' + prj.gistID,
    headers: headers,
    body: json.encode({
      'description':
          '${prj.name} Presentation Data made with focccus presentations',
      'files': {
        'presentation.json': {
          'content': json.encode(
            prj.toJson(),
          ),
        }
      },
    }),
  );
  print(res.body);
  final data = json.decode(res.body);
  return data['id'];
}

Future<String> uploadPresentation(Project prj, String token) async {
  final headers = {'Authorization': 'token $token'};

  assert(token != null);

  final res = await http.post(
    endpoint + 'gists',
    headers: headers,
    body: json.encode({
      'description':
          '${prj.name} Presentation Data made with focccus presentations',
      'files': {
        'presentation.json': {
          'content': json.encode(
            prj.toJson(),
          )
        },
      },
    }),
  );
  final data = json.decode(res.body);

  return data['id'];
}
