import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

String _URI = "ws://192.168.11.45:3000/socket";

class SocketConnection {
  WebSocketChannel _s;
  final _messageController = new StreamController();
  Stream _messages;

  void Function() onClose;

  Future<bool> connect() async {
    try {
      _s = WebSocketChannel.connect(Uri.parse(_URI));

      _messages = _messageController.stream.asBroadcastStream();

      _s.stream.listen(
        (e) {
          var msg = new Message.fromPacket(e);
          _messageController.add(msg);
        },
        onDone: onClose,
      );

      //_s.done.then((value) => print('closed'));

      return true;
    } catch (err) {
      print(err);
      return false;
    }
  }

  void send(String messageName, [data]) {
    var message = new Message(messageName, data);
    _s.sink.add(message.toPacket());
  }

  Future<void> close() async {
    await _s.sink.close();
  }

  Stream on(String messageName) {
    return _messages
        .where((msg) => msg.name == messageName)
        .map((msg) => msg.data);
  }
}

class Message {
  final String name;
  final Object data;

  Message(this.name, [this.data]);

  factory Message.fromPacket(String message) {
    if (message.isEmpty) {
      return new Message.empty();
    }

    List<String> parts = message.split(':');
    String name = parts.first;
    var data = null;

    if (parts.length > 1 && !parts[1].isEmpty) {
      data = jsonDecode(parts.sublist(1).join(':'));
    }

    return new Message(name, data);
  }

  Message.empty() : this('');

  String toPacket() {
    if (data == null) {
      return name;
    }
    return '$name:${jsonEncode(data)}';
  }
}
