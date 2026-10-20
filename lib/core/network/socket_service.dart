import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket _socket;

  IO.Socket get socket => _socket;

  SocketService._privateConstructor();

  static final SocketService instance = SocketService._privateConstructor();

  Future<void> initSocket({required String url, required String token}) async {
    _socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setTimeout(30000)
          .enableForceNew()
          .build(),
    );
    _socket.connect();

    socket.on('event', (data) => print(data));
    _socket.onConnect((_) {
      debugPrint('SOCKET CONNECTED');
    });
    _socket.onConnectError((e) => debugPrint('SOCKET CONNECT ERROR $e'));
    _socket.onReconnect((_) => debugPrint('SOCKET RECONNECT'));
    _socket.onError((e) => debugPrint('SOCKET ERROR $e'));
    _socket.onDisconnect((e) {
      debugPrint('SOCKET DISCONNECTED $e');
    });
  }

  Future<void> disConnect() async {
    _disposeSocket();
  }

  void _disposeSocket() {
    try {
      _socket.dispose();
    } catch (e) {
      debugPrint('SOCKET DISPOSE FAILED $e');
    }
  }
}

abstract class SocketEmit {
  static const String sendMessage = 'sendMessage';
  static const String joinConversation = 'joinConversation';
  static const String leaveConversation = 'leaveConversation';
}

abstract class SocketListeners {
  static const String receiveMessage = 'receiveMessage';
  static const String conversationUpdated = 'conversationUpdated';
}
