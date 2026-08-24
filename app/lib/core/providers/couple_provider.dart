import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class CoupleProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _coupleData;
  String? _pairingCode;
  bool _isPaired = false;

  // Real-time Love Timer
  Timer? _tickerTimer;
  int _daysTogether = 0;
  int _hoursTogether = 0;
  int _minutesTogether = 0;
  int _secondsTogether = 0;

  // Heartbeat trigger for UI animation
  bool _showHeartbeatAnimation = false;
  String? _lastHeartbeatSender;

  // Daily Sparks
  Map<String, dynamic>? _todayQuestion;
  bool _isLoadingQuestion = false;

  // Memories & Timeline
  List<dynamic> _memories = [];
  bool _isLoadingMemories = false;

  // Bucket List
  List<dynamic> _bucketList = [];
  bool _isLoadingBucket = false;

  // Secret Letters
  List<dynamic> _letters = [];
  bool _isLoadingLetters = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get coupleData => _coupleData;
  String? get pairingCode => _pairingCode;
  bool get isPaired => _isPaired;

  int get daysTogether => _daysTogether;
  int get hoursTogether => _hoursTogether;
  int get minutesTogether => _minutesTogether;
  int get secondsTogether => _secondsTogether;

  bool get showHeartbeatAnimation => _showHeartbeatAnimation;
  String? get lastHeartbeatSender => _lastHeartbeatSender;

  Map<String, dynamic>? get todayQuestion => _todayQuestion;
  bool get isLoadingQuestion => _isLoadingQuestion;

  List<dynamic> get memories => _memories;
  bool get isLoadingMemories => _isLoadingMemories;

  List<dynamic> get bucketList => _bucketList;
  bool get isLoadingBucket => _isLoadingBucket;

  List<dynamic> get letters => _letters;
  bool get isLoadingLetters => _isLoadingLetters;

  int get petLevel => _coupleData?['pet_level'] ?? 1;
  int get petXp => _coupleData?['pet_xp'] ?? 0;
  String get petName => _coupleData?['pet_name'] ?? 'Corazoncito';

  // Initialize couple state and real-time sockets
  Future<void> initCouple({
    required String userId,
    required String? coupleId,
    required Function(String mood, String icon) onPartnerMood,
    required Function(bool online) onPartnerOnline,
  }) async {
    await fetchCoupleStatus();

    if (_isPaired && _coupleData != null) {
      _startLoveTicker();

      // Connect WebSockets
      _socketService.connect(
        userId: userId,
        coupleId: _coupleData!['id'],
        onHeartbeatReceived: (data) {
          triggerHeartbeatReceived(data['senderName'] ?? 'Tu pareja');
        },
        onPartnerMoodUpdated: (data) {
          onPartnerMood(data['moodStatus'] ?? '', data['moodIcon'] ?? '🥰');
        },
        onPartnerPresence: (data) {
          onPartnerOnline(data['is_online'] ?? false);
        },
      );

      // Load initial feature data
      loadTodayQuestion();
      loadMemories();
      loadBucketList();
      loadLetters();
    }
  }

  Future<void> fetchCoupleStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _apiService.get('/couple/status');
      _isPaired = res['is_paired'] ?? false;
      if (_isPaired) {
        _coupleData = res['couple'];
        _calculateLoveDuration();
      } else {
        _pairingCode = res['pairing_code'];
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> generateNewCode() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.post('/couple/create-code', {});
      _pairingCode = res['pairing_code'];
      _isLoading = false;
      notifyListeners();
      return _pairingCode;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> linkWithCode(String code, {DateTime? anniversaryDate}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.post('/couple/link-code', {
        'code': code,
        'anniversary_date': anniversaryDate?.toIso8601String().split('T').first,
      });

      _coupleData = res['couple'];
      _isPaired = true;
      _startLoveTicker();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Real-time Love Ticker
  void _startLoveTicker() {
    _tickerTimer?.cancel();
    _calculateLoveDuration();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateLoveDuration();
    });
  }

  void _calculateLoveDuration() {
    if (_coupleData == null) return;
    final startDateStr = _coupleData!['anniversary_date'] ?? _coupleData!['relationship_time_start'] ?? _coupleData!['created_at'];
    if (startDateStr == null) return;

    final startDate = DateTime.tryParse(startDateStr.toString()) ?? DateTime.now();
    final difference = DateTime.now().difference(startDate);

    if (difference.isNegative) {
      _daysTogether = 0;
      _hoursTogether = 0;
      _minutesTogether = 0;
      _secondsTogether = 0;
    } else {
      _daysTogether = difference.inDays;
      _hoursTogether = difference.inHours % 24;
      _minutesTogether = difference.inMinutes % 60;
      _secondsTogether = difference.inSeconds % 60;
    }
    notifyListeners();
  }

  // Trigger Heartbeat to Partner
  void sendHeartbeat({required String userId, required String userName}) {
    if (!_isPaired || _coupleData == null) return;

    HapticFeedback.heavyImpact();

    // Trigger local feedback animation
    _showHeartbeatAnimation = true;
    _lastHeartbeatSender = 'Tú';
    notifyListeners();

    Timer(const Duration(seconds: 3), () {
      _showHeartbeatAnimation = false;
      notifyListeners();
    });

    _socketService.sendHeartbeat(
      coupleId: _coupleData!['id'],
      senderId: userId,
      senderName: userName,
    );
  }

  void triggerHeartbeatReceived(String senderName) {
    HapticFeedback.vibrate();
    _showHeartbeatAnimation = true;
    _lastHeartbeatSender = senderName;
    notifyListeners();

    Timer(const Duration(seconds: 4), () {
      _showHeartbeatAnimation = false;
      notifyListeners();
    });
  }

  // Daily Sparks
  Future<void> loadTodayQuestion() async {
    _isLoadingQuestion = true;
    notifyListeners();

    try {
      final res = await _apiService.get('/questions/today');
      _todayQuestion = res;
    } catch (e) {
      print('Error cargando pregunta: $e');
    }

    _isLoadingQuestion = false;
    notifyListeners();
  }

  Future<bool> answerTodayQuestion(String questionId, String answerText) async {
    try {
      await _apiService.post('/questions/answer', {
        'question_id': questionId,
        'answer_text': answerText,
      });

      // Reload today question to unlock answers
      await loadTodayQuestion();
      await fetchCoupleStatus(); // Updates XP
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Memories
  Future<void> loadMemories() async {
    _isLoadingMemories = true;
    notifyListeners();

    try {
      final res = await _apiService.get('/memories');
      _memories = res['memories'] ?? [];
    } catch (e) {
      print('Error cargando recuerdos: $e');
    }

    _isLoadingMemories = false;
    notifyListeners();
  }

  Future<bool> addMemory({
    required String title,
    String? description,
    required String memoryDate,
    String? locationName,
  }) async {
    try {
      await _apiService.post('/memories', {
        'title': title,
        'description': description,
        'memory_date': memoryDate,
        'location_name': locationName,
      });
      await loadMemories();
      await fetchCoupleStatus();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Bucket List
  Future<void> loadBucketList() async {
    _isLoadingBucket = true;
    notifyListeners();

    try {
      final res = await _apiService.get('/bucket');
      _bucketList = res['items'] ?? [];
    } catch (e) {
      print('Error cargando bucket list: $e');
    }

    _isLoadingBucket = false;
    notifyListeners();
  }

  Future<bool> addBucketItem(String title, {String? category, String? description}) async {
    try {
      await _apiService.post('/bucket', {
        'title': title,
        'category': category ?? 'date_night',
        'description': description ?? '',
      });
      await loadBucketList();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleBucketItem(String itemId, bool isCompleted) async {
    try {
      await _apiService.patch('/bucket/$itemId', {
        'is_completed': isCompleted,
      });
      await loadBucketList();
      await fetchCoupleStatus();
    } catch (e) {
      print('Error alternando bucket item: $e');
    }
  }

  // Secret Letters
  Future<void> loadLetters() async {
    _isLoadingLetters = true;
    notifyListeners();

    try {
      final res = await _apiService.get('/letters');
      _letters = res['letters'] ?? [];
    } catch (e) {
      print('Error cargando cartas: $e');
    }

    _isLoadingLetters = false;
    notifyListeners();
  }

  Future<bool> sendSecretLetter({
    required String title,
    required String content,
    String unlockType = 'date',
    DateTime? unlockDate,
    String? unlockMood,
  }) async {
    try {
      await _apiService.post('/letters', {
        'title': title,
        'content': content,
        'unlock_type': unlockType,
        'unlock_date': unlockDate?.toIso8601String(),
        'unlock_mood': unlockMood,
      });
      await loadLetters();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _socketService.disconnect();
    super.dispose();
  }
}
