import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketDataSource {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  Future<void> connect(String ipAddress) async {
    await disconnect();
    final wsUrl = Uri.parse("ws://$ipAddress:8765");
    _channel = WebSocketChannel.connect(wsUrl);
    
    _channel!.stream.listen(
      (message) {
        try {
          final data = jsonDecode(message.toString());
          if (data is Map<String, dynamic>) {
            _messageController.add(data);
          }
        } catch (e) {
          _messageController.addError(e);
        }
      },
      onError: (err) {
        _messageController.addError(err);
      },
      onDone: () {
        // Socket closed
      },
    );
  }

  Future<void> sendBytes(List<int> bytes) async {
    if (_channel != null) {
      _channel!.sink.add(bytes);
    }
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
  }
}
