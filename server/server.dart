import 'package:start/start.dart';
import 'dart:io';

final sockets = <Socket>[];

void main() async {
  final app = await start(host: InternetAddress.anyIPv4.address, port: 3000);
  app.static('web');

  app.get('/hello/:name.:lastname?').listen((request) {
    request.response
        .header('Content-Type', 'text/html; charset=UTF-8')
        .send('Hello, ${request.param('name')} ${request.param('lastname')}');
  });

  app.ws('/socket').listen((socket) {
    socket.onOpen.listen((ws) {
      sockets.add(socket);
      sendAll('client_joined', {'count': sockets.length});
    });

    socket.onClose.listen((ws) {
      sockets.remove(socket);
      sendAll('client_left', {'count': sockets.length});
    });

    socket.on('clear').listen((data) => sendAll('clear', data));
    socket.on('undo').listen((data) => sendAll('undo', data));
    socket.on('addshapes').listen((data) => sendAll('addshapes', data));
    socket.on('updatecurrent').listen((data) => sendAll('updatecurrent', data));
  });
}

void sendAll(String msg, Object data) {
  print(msg);
  sockets.forEach((s) => s.send(msg, data));
}
