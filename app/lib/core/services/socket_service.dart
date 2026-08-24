import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/api_constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  String _socketUrl = ApiConstants.socketUrl;

  bool get isConnected => _isConnected;

  void setSocketUrl(String url) {
    _socketUrl = url;
  }

  void connect({
    required String userId,
    required String coupleId,
    required Function(Map<String, dynamic>) onHeartbeatReceived,
    required Function(Map<String, dynamic>) onPartnerMoodUpdated,
    required Function(Map<String, dynamic>) onPartnerPresence,
  }) {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      _socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket?.onConnect((_) {
      _isConnected = true;
      print('💖 Socket conectado a My Heart Server');
      // Join couple room
      _socket?.emit('join_couple', {'userId': userId, 'coupleId': coupleId});
    });

    _socket?.on('heartbeat_received', (data) {
      if (data is Map<String, dynamic>) {
        onHeartbeatReceived(data);
      }
    });

    _socket?.on('partner_mood_updated', (data) {
      if (data is Map<String, dynamic>) {
        onPartnerMoodUpdated(data);
      }
    });

    _socket?.on('partner_presence', (data) {
      if (data is Map<String, dynamic>) {
        onPartnerPresence(data);
      }
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
      print('💔 Socket desconectado');
    });
  }

  void sendHeartbeat({
    required String coupleId,
    required String senderId,
    required String senderName,
    String pattern = 'double_pulse',
  }) {
    _socket?.emit('send_heartbeat', {
      'coupleId': coupleId,
      'senderId': senderId,
      'senderName': senderName,
      'pattern': pattern,
    });
  }

  void sendMoodChange({
    required String coupleId,
    required String userId,
    required String moodStatus,
    required String moodIcon,
  }) {
    _socket?.emit('mood_changed', {
      'coupleId': coupleId,
      'userId': userId,
      'moodStatus': moodStatus,
      'moodIcon': moodIcon,
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
  }
}
